package com.nhietdoixanh.controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.nhietdoixanh.dao.CartItemDao;
import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.dao.impl.CartItemDaoImpl;
import com.nhietdoixanh.dao.impl.OrderDaoImpl;
import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.model.User;
import com.nhietdoixanh.service.PayOSPaymentService;
import com.nhietdoixanh.util.PaymentStatuses;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;

/**
 * Endpoint callback PayOS:
 * - POST /payment/payos/webhook — PayOS gọi server-to-server (KHÔNG login, KHÔNG _csrf token).
 *   Bắt buộc verify chữ ký HMAC-SHA256 trước khi tin bất cứ điều gì. Idempotent.
 * - GET  /payment/payos/return  — trình duyệt user quay về sau khi thanh toán. KHÔNG tự đánh dấu
 *   PAID (chỉ webhook đã verify mới được); trang này chỉ đọc trạng thái thật từ DB.
 * - GET  /payment/payos/cancel  — user bấm hủy trên trang PayOS. Không xóa cart; hủy đơn PENDING
 *   nếu đúng chủ sở hữu.
 *
 * CsrfFilter đã được cấu hình bỏ qua đúng path webhook này (xem CsrfFilter#isPayOSWebhook) —
 * không nới lỏng CSRF cho bất kỳ endpoint nào khác.
 */
@WebServlet(name = "PaymentController", urlPatterns = {
        "/payment/payos/webhook",
        "/payment/payos/return",
        "/payment/payos/cancel"
})
public class PaymentController extends HttpServlet {

    private static final Gson GSON = new Gson();

    private OrderDAO orderDao;
    private CartItemDao cartItemDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
        cartItemDao = new CartItemDaoImpl();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if ("/payment/payos/webhook".equals(req.getServletPath())) {
            handleWebhook(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        switch (req.getServletPath()) {
            case "/payment/payos/return" -> handleReturn(req, resp);
            case "/payment/payos/cancel" -> handleCancel(req, resp);
            // PayOS xác nhận webhook URL bằng một GET test — trả 200 để không fail đăng ký webhook.
            case "/payment/payos/webhook" -> resp.setStatus(HttpServletResponse.SC_OK);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================================================
    // POST /payment/payos/webhook — server-to-server, verify chữ ký bắt buộc, idempotent
    // =========================================================================================

    private void handleWebhook(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String rawBody = readBody(req);

        // verifyWebhook trả null nếu payload/chữ ký không hợp lệ — coi null là TỪ CHỐI, không suy diễn.
        PayOSPaymentService.WebhookVerifyResult result = PayOSPaymentService.verifyWebhook(rawBody);
        if (result == null) {
            // Chữ ký sai / chưa cấu hình / payload rác — KHÔNG chạm DB.
            writeWebhookAck(resp, HttpServletResponse.SC_UNAUTHORIZED, false, "Chữ ký không hợp lệ.");
            return;
        }

        try {
            Order order = orderDao.findByPayOSOrderCode(result.orderCode).orElse(null);
            if (order == null) {
                // Không tìm thấy đơn — trả 200 để PayOS không retry vô hạn, nhưng không làm gì.
                writeWebhookAck(resp, HttpServletResponse.SC_OK, true, "Không tìm thấy đơn hàng tương ứng.");
                return;
            }

            if (result.isPaymentSuccess()) {
                // markPaidByPayOSOrderCode idempotent: chỉ chuyển PAID lần đầu + xóa đúng CartItems của đơn.
                orderDao.markPaidByPayOSOrderCode(result.orderCode);
            } else {
                // Thất bại/hết hạn — chỉ ghi FAILED khi đơn còn PENDING, không đụng cart.
                orderDao.markNonSuccessByPayOSOrderCode(result.orderCode, PaymentStatuses.FAILED);
            }
            writeWebhookAck(resp, HttpServletResponse.SC_OK, true, "Đã xử lý.");
        } catch (Exception e) {
            // Không log chi tiết nhạy cảm; trả 500 để PayOS retry.
            System.err.println("[PaymentController] Lỗi xử lý webhook PayOS: " + e.getClass().getSimpleName());
            writeWebhookAck(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, false, "Lỗi xử lý.");
        }
    }

    // =========================================================================================
    // GET /payment/payos/return — chỉ đọc trạng thái thật từ DB, KHÔNG tự đánh dấu PAID
    // =========================================================================================

    private void handleReturn(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Long orderCode = parseLong(req.getParameter("orderCode"));
        Order order = (orderCode != null)
                ? orderDao.findByPayOSOrderCode(orderCode).orElse(null)
                : null;

        // Ownership: chỉ hiển thị đơn của chính user hiện tại.
        if (order == null || order.getUserId() == null || order.getUserId() != user.getUserId()) {
            resp.sendRedirect(req.getContextPath() + "/account/orders");
            return;
        }

        // Nếu webhook đã xác nhận PAID → đơn đã thanh toán; cập nhật badge giỏ hàng (webhook đã xóa
        // CartItems của đơn). Nếu chưa (webhook có thể tới trễ) → hiển thị "đang chờ xác nhận".
        int cartCount = cartItemDao.countQuantityByUserId(user.getUserId());
        session.setAttribute("cartCount", cartCount);

        req.setAttribute("order", order);
        req.setAttribute("paymentStatusLabel", PaymentStatuses.getLabel(order.getPaymentStatus()));
        req.setAttribute("orderStatusLabel", com.nhietdoixanh.util.OrderStatuses.getLabel(order.getOrderStatus()));
        req.setAttribute("isPaid", PaymentStatuses.isPaid(order.getPaymentStatus()));
        req.getRequestDispatcher("/WEB-INF/views/payment-return.jsp").forward(req, resp);
    }

    // =========================================================================================
    // GET /payment/payos/cancel — user hủy trên trang PayOS. Không xóa cart.
    // =========================================================================================

    private void handleCancel(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        Long orderCode = parseLong(req.getParameter("orderCode"));
        Order order = (orderCode != null)
                ? orderDao.findByPayOSOrderCode(orderCode).orElse(null)
                : null;

        if (order != null && order.getUserId() != null && order.getUserId() == user.getUserId()) {
            try {
                // Chỉ hủy nếu đơn thuộc đúng user và còn PENDING — không đụng CartItems.
                orderDao.cancelPayOSPendingByOrderIdAndUserId(order.getOrderId(), user.getUserId());
            } catch (Exception e) {
                System.err.println("[PaymentController] Hủy đơn PayOS thất bại: " + e.getClass().getSimpleName());
            }
            session.setAttribute("cartFlashError",
                    "Bạn đã hủy thanh toán PayOS. Giỏ hàng của bạn vẫn được giữ nguyên.");
        }
        // CartItems chưa từng bị xóa ở luồng PayOS cho tới khi PAID → quay lại giỏ hàng an toàn.
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    private String readBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            char[] buf = new char[1024];
            int read;
            int total = 0;
            // Chặn body quá lớn (webhook PayOS nhỏ) — tránh cạn bộ nhớ nếu bị bắn payload rác.
            while ((read = reader.read(buf)) != -1 && total < 1_048_576) {
                sb.append(buf, 0, read);
                total += read;
            }
        }
        return sb.toString();
    }

    private void writeWebhookAck(HttpServletResponse resp, int status, boolean success, String message)
            throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        JsonObject json = new JsonObject();
        json.addProperty("success", success);
        json.addProperty("message", message);
        resp.getWriter().write(GSON.toJson(json));
    }

    private Long parseLong(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            return Long.parseLong(raw.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
