package com.nhietdoixanh.controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.nhietdoixanh.dao.AuditLogDao;
import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.dao.UserDao;
import com.nhietdoixanh.dao.impl.AuditLogDaoImpl;
import com.nhietdoixanh.dao.impl.OrderDaoImpl;
import com.nhietdoixanh.dao.impl.UserDaoImpl;
import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.model.OrderDetail;
import com.nhietdoixanh.model.User;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.MemberTierService;
import com.nhietdoixanh.util.OrderStatuses;
import com.nhietdoixanh.util.PaymentStatuses;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * Khu vực tài khoản khách hàng — dashboard, lịch sử đơn hàng, hủy đơn.
 * Toàn bộ route nằm dưới "/account/*" nên đã được {@link com.nhietdoixanh.filter.AuthFilter}
 * yêu cầu đăng nhập (session "user"); mọi POST đã được
 * {@link com.nhietdoixanh.filter.CsrfFilter} kiểm tra token "_csrf" trước khi vào servlet này.
 * userId luôn lấy từ session, KHÔNG bao giờ nhận từ request.
 */
@WebServlet(name = "AccountController", urlPatterns = {
        "/account",
        "/account/orders",
        "/account/orders/detail",
        "/account/orders/status",
        "/account/order/cancel"
})
public class AccountController extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    private static final Gson GSON = new Gson();

    private OrderDAO orderDao;
    private UserDao userDao;
    private AuditLogDao auditLogDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
        userDao = new UserDaoImpl();
        auditLogDao = new AuditLogDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/account" -> handleDashboard(req, resp);
            case "/account/orders" -> handleOrdersList(req, resp);
            case "/account/orders/detail" -> handleOrderDetail(req, resp);
            case "/account/orders/status" -> handleOrderStatusJson(req, resp);
            // /account/order/cancel là hành động ghi — không cho phép GET.
            default -> resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        switch (path) {
            case "/account/order/cancel" -> handleCancelOrder(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================================================
    // GET /account — dashboard
    // =========================================================================================

    private void handleDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int userId = currentUserId(req);

        User user = userDao.findById(userId).orElse(null);
        if (user == null) {
            // Session còn nhưng tài khoản đã bị xóa/khoá ở DB — đăng xuất an toàn thay vì lỗi 500.
            invalidateSession(req);
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int totalOrders = orderDao.countOrdersByUserId(userId);
        int doneOrders = orderDao.countDoneOrdersByUserId(userId);
        int processingOrders = orderDao.countProcessingOrdersByUserId(userId);
        BigDecimal totalSpent = orderDao.sumDoneAmountByUserId(userId);

        MemberTierService.Tier tier = MemberTierService.resolve(totalSpent);
        MemberTierService.Tier nextTier = MemberTierService.nextTier(totalSpent);
        BigDecimal amountToNext = MemberTierService.amountToNextTier(totalSpent);

        req.setAttribute("user", user);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("doneOrders", doneOrders);
        req.setAttribute("processingOrders", processingOrders);
        req.setAttribute("totalSpent", totalSpent);
        req.setAttribute("tier", tier);
        req.setAttribute("nextTier", nextTier);
        req.setAttribute("amountToNext", amountToNext);
        req.setAttribute("tierProgressPercent", tierProgressPercent(tier, nextTier, totalSpent));
        req.setAttribute("currentPage", "account");
        req.setAttribute("accountTab", "overview");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/account/dashboard.jsp").forward(req, resp);
    }

    // =========================================================================================
    // GET /account/orders — lịch sử đơn: lọc trạng thái + tìm theo mã đơn + phân trang
    // =========================================================================================

    private void handleOrdersList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int userId = currentUserId(req);

        String orderStatusRaw = trimOrNull(req.getParameter("status"));
        String orderStatus = (orderStatusRaw != null && OrderStatuses.isValid(orderStatusRaw))
                ? OrderStatuses.normalize(orderStatusRaw) : null;

        String q = trimOrNull(req.getParameter("q"));
        Integer searchOrderId = parseOrderIdSearch(q);

        int page = parsePositiveIntOrDefault(req.getParameter("page"), 1);
        int totalOrders = orderDao.countOrdersByUserIdFiltered(userId, orderStatus, searchOrderId);
        int totalPages = Math.max(1, (int) Math.ceil(totalOrders / (double) PAGE_SIZE));
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * PAGE_SIZE;

        List<Order> orders = orderDao.findOrdersByUserIdFiltered(userId, orderStatus, searchOrderId, offset, PAGE_SIZE);

        req.setAttribute("orders", orders);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("currentPageNum", page);
        req.setAttribute("q", q);
        req.setAttribute("orderStatus", orderStatus);
        req.setAttribute("currentPage", "account");
        req.setAttribute("accountTab", "orders");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/account/orders.jsp").forward(req, resp);
    }

    // =========================================================================================
    // GET /account/orders/detail?id=... — ownership kiểm tra ngay trong SQL
    // =========================================================================================

    private void handleOrderDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        int userId = currentUserId(req);

        Integer orderId = parsePositiveInt(req.getParameter("id"));
        if (orderId == null) {
            resp.sendRedirect(req.getContextPath() + "/account/orders");
            return;
        }

        Order order = orderDao.findByIdAndUserId(orderId, userId).orElse(null);
        if (order == null) {
            // Không tồn tại HOẶC thuộc user khác — cùng một phản hồi, không lộ thông tin.
            resp.sendRedirect(req.getContextPath() + "/account/orders");
            return;
        }

        List<OrderDetail> items = orderDao.findDetailsByOrderIdAndUserId(orderId, userId);
        boolean canCancel = OrderStatuses.isCancellableByCustomer(order.getOrderStatus(), order.getPaymentStatus());

        req.setAttribute("order", order);
        req.setAttribute("orderItems", items);
        req.setAttribute("canCancel", canCancel);
        req.setAttribute("auditTrail", auditLogDao.findByTarget("Order#" + orderId));
        req.setAttribute("currentPage", "account");
        req.setAttribute("accountTab", "orders");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/account/order-detail.jsp").forward(req, resp);
    }

    // =========================================================================================
    // GET /account/orders/status?id=... — JSON nhẹ cho polling gần-realtime từ trang chi tiết
    // =========================================================================================

    private void handleOrderStatusJson(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = currentUserId(req);
        Integer orderId = parsePositiveInt(req.getParameter("id"));

        JsonObject json = new JsonObject();
        if (orderId == null) {
            writeJson(resp, HttpServletResponse.SC_BAD_REQUEST, errorJson("Thiếu mã đơn hàng."));
            return;
        }

        Order order = orderDao.findByIdAndUserId(orderId, userId).orElse(null);
        if (order == null) {
            writeJson(resp, HttpServletResponse.SC_NOT_FOUND, errorJson("Không tìm thấy đơn hàng."));
            return;
        }

        json.addProperty("success", true);
        json.addProperty("orderStatus", order.getOrderStatus());
        json.addProperty("orderStatusLabel", OrderStatuses.getLabel(order.getOrderStatus()));
        json.addProperty("paymentStatus", order.getPaymentStatus());
        json.addProperty("paymentStatusLabel", PaymentStatuses.getLabel(order.getPaymentStatus()));
        writeJson(resp, HttpServletResponse.SC_OK, json);
    }

    // =========================================================================================
    // POST /account/order/cancel
    // =========================================================================================

    private void handleCancelOrder(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = currentUserId(req);
        Integer orderId = parsePositiveInt(req.getParameter("orderId"));
        String reason = trimOrNull(req.getParameter("cancelReason"));
        String returnTo = returnUrl(req, orderId);

        if (orderId == null) {
            flashError(req, "Yêu cầu không hợp lệ.");
            resp.sendRedirect(returnTo);
            return;
        }
        if (reason == null) {
            flashError(req, "Vui lòng nhập lý do hủy đơn.");
            resp.sendRedirect(returnTo);
            return;
        }
        if (reason.length() > 500) {
            flashError(req, "Lý do hủy đơn tối đa 500 ký tự.");
            resp.sendRedirect(returnTo);
            return;
        }

        // Query ownership ngay trong SQL (WHERE OrderID = ? AND UserID = ?) — không lấy OrderID
        // rồi tự kiểm tra ở tầng khác.
        Order order = orderDao.findByIdAndUserId(orderId, userId).orElse(null);
        if (order == null) {
            flashError(req, "Đơn hàng không tồn tại hoặc không thuộc về bạn.");
            resp.sendRedirect(returnTo);
            return;
        }

        if (!OrderStatuses.isCancellableByCustomer(order.getOrderStatus(), order.getPaymentStatus())) {
            flashError(req, "Không thể hủy đơn ở trạng thái hiện tại.");
            resp.sendRedirect(returnTo);
            return;
        }

        try {
            String status = OrderStatuses.normalize(order.getOrderStatus());
            if (OrderStatuses.PENDING.equals(status)) {
                // Đơn còn PENDING, chưa ai xử lý — hủy ngay.
                if (orderDao.cancelOrder(orderId, userId, reason) > 0) {
                    AuditLogger.log(req, null, "ORDER_CUSTOMER_CANCELLED", "Order#" + orderId,
                            "Khách tự hủy đơn #" + orderId + " | Lý do: " + reason);
                    flashSuccess(req, "Đã hủy đơn #" + orderId + ".");
                } else {
                    flashError(req, "Không thể hủy — đơn hàng đã đổi trạng thái. Vui lòng tải lại.");
                }
            } else {
                // CONFIRMED — đơn có thể đang được chuẩn bị, chuyển yêu cầu hủy để admin duyệt.
                if (orderDao.requestCancelOrder(orderId, userId, reason) > 0) {
                    AuditLogger.log(req, null, "ORDER_CUSTOMER_CANCEL_REQUESTED", "Order#" + orderId,
                            "Khách gửi yêu cầu hủy đơn #" + orderId + " | Lý do: " + reason);
                    flashSuccess(req, "Đã gửi yêu cầu hủy đơn #" + orderId + ". Chúng tôi sẽ xử lý sớm nhất.");
                } else {
                    flashError(req, "Không thể gửi yêu cầu hủy — đơn hàng đã đổi trạng thái. Vui lòng tải lại.");
                }
            }
        } catch (SecurityException e) {
            flashError(req, "Đơn hàng không thuộc về bạn.");
        } catch (Exception e) {
            System.err.println("[AccountController] order/cancel lỗi: " + e.getMessage());
            flashError(req, "Có lỗi xảy ra, vui lòng thử lại.");
        }

        resp.sendRedirect(returnTo);
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    /**
     * % tiến độ trong khoảng [hạng hiện tại, hạng kế tiếp) — tính ở Java để tránh chia BigDecimal
     * trong JSP EL (có thể ném ArithmeticException với số thập phân vô hạn tuần hoàn).
     */
    private int tierProgressPercent(MemberTierService.Tier tier, MemberTierService.Tier nextTier, BigDecimal totalSpent) {
        if (nextTier == null) return 100;
        BigDecimal from = tier.getMinSpend();
        BigDecimal range = nextTier.getMinSpend().subtract(from);
        if (range.signum() <= 0) return 100;
        BigDecimal progressed = (totalSpent != null ? totalSpent : BigDecimal.ZERO).subtract(from);
        int pct = progressed.multiply(BigDecimal.valueOf(100)).divide(range, 0, RoundingMode.HALF_UP).intValue();
        return Math.max(0, Math.min(100, pct));
    }

    /** userId luôn lấy từ session — AuthFilter đảm bảo session "user" tồn tại trước khi tới đây. */
    private int currentUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        return user.getUserId();
    }

    private void invalidateSession(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) session.invalidate();
    }

    private String returnUrl(HttpServletRequest req, Integer orderId) {
        String returnTo = req.getParameter("returnTo");
        if ("detail".equals(returnTo) && orderId != null) {
            return req.getContextPath() + "/account/orders/detail?id=" + orderId;
        }
        return req.getContextPath() + "/account/orders";
    }

    private void flashSuccess(HttpServletRequest req, String message) {
        HttpSession session = req.getSession(false);
        if (session != null) session.setAttribute("accountFlashSuccess", message);
    }

    private void flashError(HttpServletRequest req, String message) {
        HttpSession session = req.getSession(false);
        if (session != null) session.setAttribute("accountFlashError", message);
    }

    private void consumeFlash(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return;
        Object success = session.getAttribute("accountFlashSuccess");
        Object error = session.getAttribute("accountFlashError");
        if (success != null) {
            req.setAttribute("flashSuccess", success);
            session.removeAttribute("accountFlashSuccess");
        }
        if (error != null) {
            req.setAttribute("flashError", error);
            session.removeAttribute("accountFlashError");
        }
    }

    private String trimOrNull(String raw) {
        if (raw == null) return null;
        String trimmed = raw.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private Integer parsePositiveInt(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            int v = Integer.parseInt(raw.trim());
            return v > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parsePositiveIntOrDefault(String raw, int fallback) {
        Integer v = parsePositiveInt(raw);
        return v != null ? v : fallback;
    }

    /** Cho phép người dùng gõ "#5", "5", hoặc "Đơn 5" — chỉ lấy phần số. */
    private Integer parseOrderIdSearch(String q) {
        if (q == null) return null;
        String digits = q.replaceAll("[^0-9]", "");
        if (digits.isEmpty()) return null;
        try {
            return Integer.parseInt(digits);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private JsonObject errorJson(String message) {
        JsonObject json = new JsonObject();
        json.addProperty("success", false);
        json.addProperty("message", message);
        return json;
    }

    private void writeJson(HttpServletResponse resp, int status, JsonObject json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(GSON.toJson(json));
    }
}
