package com.nhietdoixanh.controller.admin;

import com.nhietdoixanh.dao.AuditLogDao;
import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.dao.impl.AuditLogDaoImpl;
import com.nhietdoixanh.dao.impl.OrderDaoImpl;
import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.model.OrderAdminFilter;
import com.nhietdoixanh.model.Staff;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.OrderStatuses;
import com.nhietdoixanh.util.PaymentStatuses;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/**
 * Admin quản lý đơn hàng — danh sách/tìm kiếm/phân trang, chi tiết, cập nhật
 * trạng thái theo state machine {@link OrderStatuses}, duyệt/từ chối yêu cầu hủy.
 *
 * Quyền hạn: nằm dưới urlPattern "/admin/*" nên đã được {@link com.nhietdoixanh.filter.AuthFilter}
 * chặn — chỉ Staff đã đăng nhập (session "adminUser") mới tới được. Mọi POST đã được
 * {@link com.nhietdoixanh.filter.CsrfFilter} kiểm tra token "_csrf" trước khi vào servlet này.
 * Người thao tác luôn lấy từ session, KHÔNG bao giờ nhận staffId từ request.
 */
@WebServlet(name = "AdminOrderController", urlPatterns = {
        "/admin/don-hang",
        "/admin/don-hang/chi-tiet",
        "/admin/don-hang/cap-nhat-trang-thai",
        "/admin/don-hang/duyet-huy",
        "/admin/don-hang/tu-choi-huy"
})
public class AdminOrderController extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    private OrderDAO orderDao;
    private AuditLogDao auditLogDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
        auditLogDao = new AuditLogDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/admin/don-hang" -> handleList(req, resp);
            case "/admin/don-hang/chi-tiet" -> handleDetail(req, resp);
            // Các route hành động chỉ nhận POST — chặn GET để không cho thao tác qua link/prefetch.
            default -> resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        switch (path) {
            case "/admin/don-hang/cap-nhat-trang-thai" -> handleUpdateStatus(req, resp);
            case "/admin/don-hang/duyet-huy" -> handleApproveCancel(req, resp);
            case "/admin/don-hang/tu-choi-huy" -> handleRejectCancel(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================================================
    // GET /admin/don-hang — danh sách + tìm kiếm/lọc/phân trang (server-side)
    // =========================================================================================

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String keyword = trimOrNull(req.getParameter("q"));
        String orderStatus = trimOrNull(req.getParameter("orderStatus"));
        String paymentStatus = trimOrNull(req.getParameter("paymentStatus"));
        String paymentMethod = trimOrNull(req.getParameter("paymentMethod"));
        String fromDateRaw = trimOrNull(req.getParameter("fromDate"));
        String toDateRaw = trimOrNull(req.getParameter("toDate"));

        // Chỉ chấp nhận giá trị filter hợp lệ đã biết — không đẩy thẳng input thô vào SQL param
        // nếu nó không khớp danh sách trạng thái/phương thức hợp lệ (phòng lỗi âm thầm, không phải SQLi
        // vì đã dùng PreparedStatement, nhưng tránh query vô nghĩa).
        if (orderStatus != null && !OrderStatuses.isValid(orderStatus)) orderStatus = null;
        if (paymentStatus != null && !PaymentStatuses.isValid(paymentStatus)) paymentStatus = null;
        if (paymentMethod != null && !paymentMethod.equals("COD") && !paymentMethod.equals("PAYOS")) paymentMethod = null;

        OrderAdminFilter filter = new OrderAdminFilter();
        filter.setKeyword(keyword);
        filter.setOrderStatus(orderStatus);
        filter.setPaymentStatus(paymentStatus);
        filter.setPaymentMethod(paymentMethod);
        filter.setFromDate(parseDate(fromDateRaw));
        filter.setToDate(parseDate(toDateRaw));

        int page = parsePositiveIntOrDefault(req.getParameter("page"), 1);
        int totalOrders = orderDao.countAdminSearchOrders(filter);
        int totalPages = Math.max(1, (int) Math.ceil(totalOrders / (double) PAGE_SIZE));
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * PAGE_SIZE;

        var orders = orderDao.adminSearchOrders(filter, offset, PAGE_SIZE);

        req.setAttribute("orders", orders);
        req.setAttribute("totalOrders", totalOrders);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("q", keyword);
        req.setAttribute("orderStatus", orderStatus);
        req.setAttribute("paymentStatus", paymentStatus);
        req.setAttribute("paymentMethod", paymentMethod);
        req.setAttribute("fromDate", fromDateRaw);
        req.setAttribute("toDate", toDateRaw);
        req.setAttribute("pageTitle", "Đơn hàng");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/admin/orders/list.jsp").forward(req, resp);
    }

    // =========================================================================================
    // GET /admin/don-hang/chi-tiet?id=...
    // =========================================================================================

    private void handleDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Integer orderId = parsePositiveInt(req.getParameter("id"));
        if (orderId == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/don-hang");
            return;
        }

        Order order = orderDao.findOrderById(orderId);
        if (order == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/don-hang");
            return;
        }

        String status = order.getOrderStatus();
        req.setAttribute("order", order);
        req.setAttribute("auditTrail", auditLogDao.findByTarget("Order#" + orderId));
        // Nút hành động hiển thị dựa đúng theo state machine OrderStatuses — không suy luận lại ở JSP.
        req.setAttribute("canConfirm", OrderStatuses.canTransition(status, OrderStatuses.CONFIRMED));
        req.setAttribute("canShip", OrderStatuses.canTransition(status, OrderStatuses.SHIPPING));
        req.setAttribute("canDone", OrderStatuses.canTransition(status, OrderStatuses.DONE));
        boolean isPendingCancel = OrderStatuses.PENDING_CANCEL.equals(OrderStatuses.normalize(status));
        // adminCancelOrder() chỉ hủy trực tiếp đơn PENDING/CONFIRMED (SQL WHERE OrderStatus IN (...)).
        // PENDING_CANCEL -> CANCELLED tuy hợp lệ theo canTransition() nhưng PHẢI đi qua "duyệt hủy",
        // không qua nút hủy trực tiếp — nếu không sẽ hiện 2 nút mâu thuẫn và nút hủy trực tiếp luôn lỗi.
        req.setAttribute("canCancelDirect", !isPendingCancel && OrderStatuses.canTransition(status, OrderStatuses.CANCELLED));
        req.setAttribute("canReviewCancelRequest", isPendingCancel);
        req.setAttribute("pageTitle", "Đơn hàng #" + orderId);
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/admin/orders/detail.jsp").forward(req, resp);
    }

    // =========================================================================================
    // POST /admin/don-hang/cap-nhat-trang-thai — chuyển trạng thái theo state machine
    // =========================================================================================

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer orderId = parsePositiveInt(req.getParameter("orderId"));
        String newStatusRaw = trimOrNull(req.getParameter("newStatus"));
        String reason = trimOrNull(req.getParameter("reason"));
        String returnTo = returnUrl(req, orderId);

        if (orderId == null || newStatusRaw == null) {
            flashError(req, "Yêu cầu không hợp lệ.");
            resp.sendRedirect(returnTo);
            return;
        }

        String newStatus = OrderStatuses.normalize(newStatusRaw);
        if (!OrderStatuses.isValid(newStatus)) {
            flashError(req, "Trạng thái không hợp lệ.");
            resp.sendRedirect(returnTo);
            return;
        }

        try {
            boolean updated;
            if (OrderStatuses.CANCELLED.equals(newStatus)) {
                if (reason == null) {
                    flashError(req, "Vui lòng nhập lý do hủy đơn.");
                    resp.sendRedirect(returnTo);
                    return;
                }
                updated = orderDao.adminCancelOrder(orderId, reason) > 0;
            } else {
                updated = orderDao.updateStatusWithValidation(orderId, newStatus);
            }

            if (updated) {
                AuditLogger.log(req, admin.getStaffId(), "ORDER_STATUS_" + newStatus,
                        "Order#" + orderId,
                        "Chuyển trạng thái đơn #" + orderId + " sang " + OrderStatuses.getLabel(newStatus)
                                + (reason != null ? " | Lý do: " + reason : ""));
                flashSuccess(req, "Đã cập nhật trạng thái đơn #" + orderId + " thành \""
                        + OrderStatuses.getLabel(newStatus) + "\".");
            } else {
                flashError(req, "Không thể cập nhật — đơn hàng đã đổi trạng thái ở nơi khác. Vui lòng tải lại.");
            }
        } catch (IllegalStateException | IllegalArgumentException e) {
            flashError(req, e.getMessage());
        } catch (Exception e) {
            System.err.println("[AdminOrderController] cap-nhat-trang-thai lỗi: " + e.getMessage());
            flashError(req, "Có lỗi xảy ra, vui lòng thử lại.");
        }

        resp.sendRedirect(returnTo);
    }

    // =========================================================================================
    // POST /admin/don-hang/duyet-huy — PENDING_CANCEL -> CANCELLED
    // =========================================================================================

    private void handleApproveCancel(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer orderId = parsePositiveInt(req.getParameter("orderId"));
        String returnTo = returnUrl(req, orderId);

        if (orderId == null) {
            flashError(req, "Yêu cầu không hợp lệ.");
            resp.sendRedirect(returnTo);
            return;
        }

        try {
            if (orderDao.approveCancelOrder(orderId) > 0) {
                AuditLogger.log(req, admin.getStaffId(), "ORDER_CANCEL_APPROVED", "Order#" + orderId,
                        "Duyệt yêu cầu hủy đơn #" + orderId);
                flashSuccess(req, "Đã duyệt hủy đơn #" + orderId + ".");
            } else {
                flashError(req, "Không thể duyệt hủy — đơn không còn ở trạng thái chờ duyệt hủy.");
            }
        } catch (Exception e) {
            System.err.println("[AdminOrderController] duyet-huy lỗi: " + e.getMessage());
            flashError(req, "Có lỗi xảy ra, vui lòng thử lại.");
        }

        resp.sendRedirect(returnTo);
    }

    // =========================================================================================
    // POST /admin/don-hang/tu-choi-huy — PENDING_CANCEL -> CONFIRMED
    // =========================================================================================

    private void handleRejectCancel(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer orderId = parsePositiveInt(req.getParameter("orderId"));
        String returnTo = returnUrl(req, orderId);

        if (orderId == null) {
            flashError(req, "Yêu cầu không hợp lệ.");
            resp.sendRedirect(returnTo);
            return;
        }

        try {
            if (orderDao.rejectCancelOrder(orderId) > 0) {
                AuditLogger.log(req, admin.getStaffId(), "ORDER_CANCEL_REJECTED", "Order#" + orderId,
                        "Từ chối yêu cầu hủy đơn #" + orderId);
                flashSuccess(req, "Đã từ chối yêu cầu hủy đơn #" + orderId + ".");
            } else {
                flashError(req, "Không thể từ chối — đơn không còn ở trạng thái chờ duyệt hủy.");
            }
        } catch (Exception e) {
            System.err.println("[AdminOrderController] tu-choi-huy lỗi: " + e.getMessage());
            flashError(req, "Có lỗi xảy ra, vui lòng thử lại.");
        }

        resp.sendRedirect(returnTo);
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    /** Luôn lấy admin thao tác từ session — KHÔNG BAO GIỜ nhận staffId/adminId từ client. */
    private Staff currentAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (Staff) session.getAttribute("adminUser") : null;
    }

    /** Quay lại trang chi tiết nếu request đến từ đó, ngược lại về danh sách. */
    private String returnUrl(HttpServletRequest req, Integer orderId) {
        String referer = req.getParameter("returnTo");
        if ("detail".equals(referer) && orderId != null) {
            return req.getContextPath() + "/admin/don-hang/chi-tiet?id=" + orderId;
        }
        return req.getContextPath() + "/admin/don-hang";
    }

    private void flashSuccess(HttpServletRequest req, String message) {
        HttpSession session = req.getSession(false);
        if (session != null) session.setAttribute("adminFlashSuccess", message);
    }

    private void flashError(HttpServletRequest req, String message) {
        HttpSession session = req.getSession(false);
        if (session != null) session.setAttribute("adminFlashError", message);
    }

    private void consumeFlash(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return;
        Object success = session.getAttribute("adminFlashSuccess");
        Object error = session.getAttribute("adminFlashError");
        if (success != null) {
            req.setAttribute("flashSuccess", success);
            session.removeAttribute("adminFlashSuccess");
        }
        if (error != null) {
            req.setAttribute("flashError", error);
            session.removeAttribute("adminFlashError");
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

    private LocalDate parseDate(String raw) {
        if (raw == null) return null;
        try {
            return LocalDate.parse(raw);
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
