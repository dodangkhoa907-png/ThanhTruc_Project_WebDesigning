package com.nhietdoixanh.controller.admin;

import com.nhietdoixanh.dao.AuditLogDao;
import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.dao.StaffDao;
import com.nhietdoixanh.dao.impl.AuditLogDaoImpl;
import com.nhietdoixanh.dao.impl.OrderDaoImpl;
import com.nhietdoixanh.dao.impl.StaffDaoImpl;
import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.model.OrderAdminFilter;
import com.nhietdoixanh.model.OrderTabCounts;
import com.nhietdoixanh.model.Staff;
import com.nhietdoixanh.util.AdminAuth;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.OrderStatuses;
import com.nhietdoixanh.util.PaymentStatuses;
import com.nhietdoixanh.util.StaffRoles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Admin quản lý đơn hàng — danh sách/tìm kiếm/phân trang, chi tiết, cập nhật
 * trạng thái theo state machine {@link OrderStatuses}, duyệt/từ chối yêu cầu hủy.
 *
 * Quyền hạn: nằm dưới urlPattern "/admin/*" nên đã được {@link com.nhietdoixanh.filter.AuthFilter}
 * chặn — chỉ Staff đã đăng nhập (cookie {@link com.nhietdoixanh.util.AdminAuth}) mới tới được. Mọi POST đã được
 * {@link com.nhietdoixanh.filter.CsrfFilter} kiểm tra token "_csrf" trước khi vào servlet này.
 * Người thao tác luôn lấy từ session, KHÔNG bao giờ nhận staffId từ request.
 */
@WebServlet(name = "AdminOrderController", urlPatterns = {
        "/admin/don-hang",
        "/admin/don-hang/chi-tiet",
        "/admin/don-hang/cap-nhat-trang-thai",
        "/admin/don-hang/duyet-huy",
        "/admin/don-hang/tu-choi-huy",
        "/admin/don-hang/chot-hoan-thanh",
        "/admin/don-hang/giao-van-chuyen"
})
public class AdminOrderController extends HttpServlet {

    private static final int PAGE_SIZE = 10;
    /** Số thẻ tối đa render trong hàng đợi khẩn cấp; nếu còn nhiều hơn, JSP hiển thị chú thích. */
    private static final int QUEUE_LIMIT = 24;

    private OrderDAO orderDao;
    private AuditLogDao auditLogDao;
    private StaffDao staffDao;

    @Override
    public void init() {
        orderDao = new OrderDaoImpl();
        auditLogDao = new AuditLogDaoImpl();
        staffDao = new StaffDaoImpl();
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
            case "/admin/don-hang/chot-hoan-thanh" -> handleConfirmDelivery(req, resp);
            case "/admin/don-hang/giao-van-chuyen" -> handleShipOrder(req, resp);
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
        // "PENDING" | "CONFIRMED" | null — chỉ có ý nghĩa khi orderStatus=DONE, tách đôi tab
        // "Chờ xác nhận" / "Thành công" mà không cần thêm giá trị mới vào state machine OrderStatuses.
        String confirmStateRaw = trimOrNull(req.getParameter("confirmState"));

        // Chỉ chấp nhận giá trị filter hợp lệ đã biết — không đẩy thẳng input thô vào SQL param
        // nếu nó không khớp danh sách trạng thái/phương thức hợp lệ (phòng lỗi âm thầm, không phải SQLi
        // vì đã dùng PreparedStatement, nhưng tránh query vô nghĩa).
        if (orderStatus != null && !OrderStatuses.isValid(orderStatus)) orderStatus = null;
        if (paymentStatus != null && !PaymentStatuses.isValid(paymentStatus)) paymentStatus = null;
        if (paymentMethod != null && !paymentMethod.equals("COD") && !paymentMethod.equals("PAYOS")) paymentMethod = null;

        Boolean receivedConfirmed = null;
        if (OrderStatuses.DONE.equals(orderStatus)) {
            if ("CONFIRMED".equals(confirmStateRaw)) receivedConfirmed = Boolean.TRUE;
            else if ("PENDING".equals(confirmStateRaw)) receivedConfirmed = Boolean.FALSE;
        }

        OrderAdminFilter filter = new OrderAdminFilter();
        filter.setKeyword(keyword);
        filter.setOrderStatus(orderStatus);
        filter.setPaymentStatus(paymentStatus);
        filter.setPaymentMethod(paymentMethod);
        filter.setFromDate(parseDate(fromDateRaw));
        filter.setToDate(parseDate(toDateRaw));
        filter.setReceivedConfirmed(receivedConfirmed);

        // Tab đang chọn — JSP chỉ so sánh 1 chuỗi này để bôi active, không tự suy luận lại.
        String activeTab;
        if (orderStatus == null) activeTab = "ALL";
        else if (OrderStatuses.PENDING.equals(orderStatus)) activeTab = "PENDING";
        else if (OrderStatuses.CONFIRMED.equals(orderStatus)) activeTab = "CONFIRMED";
        else if (OrderStatuses.SHIPPING.equals(orderStatus)) activeTab = "SHIPPING";
        else if (OrderStatuses.DONE.equals(orderStatus)) {
            activeTab = Boolean.TRUE.equals(receivedConfirmed) ? "COMPLETED" : "AWAITING_CONFIRM";
        } else activeTab = "OTHER"; // CANCELLED/PENDING_CANCEL — lọc qua dropdown, không có tab riêng
        req.setAttribute("activeTab", activeTab);
        req.setAttribute("tabCounts", orderDao.countOrdersByTab());

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

        consumeFlash(req);

        // Đội giao hàng (Staffs.Role=DELIVERY, active) cho dropdown "Giao vận chuyển" — nằm
        // TRONG fragment _history-section.jsp (không phải shell list.jsp) nên phải tính cả ở
        // nhánh AJAX, không chỉ nhánh tải trang đầy đủ như pendingQueue bên dưới.
        List<Staff> activeShippers = staffDao.findAll().stream()
                .filter(s -> StaffRoles.DELIVERY.equals(s.getRole()) && s.isActive())
                .collect(Collectors.toList());
        req.setAttribute("activeShippers", activeShippers);

        // Điều hướng AJAX (tab/phân trang/lọc, xem JS trong list.jsp) chỉ cần fragment bảng —
        // bỏ qua truy vấn hàng đợi khẩn cấp (Phân vùng 1 nằm ngoài fragment, không dùng tới).
        if (isAjax(req)) {
            req.getRequestDispatcher("/WEB-INF/views/admin/orders/_history-section.jsp").forward(req, resp);
            return;
        }

        // Hàng đợi khẩn cấp — đơn PENDING, LẤY ĐỘC LẬP với bộ lọc/phân trang của bảng lịch sử
        // để admin không bao giờ bỏ sót đơn mới dù đang lọc/xem trang khác.
        OrderAdminFilter pendingFilter = new OrderAdminFilter();
        pendingFilter.setOrderStatus(OrderStatuses.PENDING);
        var pendingQueue = orderDao.adminSearchOrders(pendingFilter, 0, QUEUE_LIMIT);
        int pendingTotal = orderDao.countAdminSearchOrders(pendingFilter);
        req.setAttribute("pendingQueue", pendingQueue);
        req.setAttribute("pendingTotal", pendingTotal);
        req.setAttribute("queueLimit", QUEUE_LIMIT);

        req.setAttribute("pageTitle", "Đơn hàng");
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
        // Đội giao hàng cho dropdown "Chuyển đang giao" — bắt buộc chọn người phụ trách, KHÔNG được
        // tự động chuyển SHIPPING mà không gán ai (đồng bộ với nút cùng chức năng ở trang danh sách,
        // xem handleShipOrder/shipOrderWithHandler — trước đây trang chi tiết bỏ sót bước này, cho
        // phép né việc gán người bằng cách thao tác qua đây thay vì danh sách).
        List<Staff> activeShippers = staffDao.findAll().stream()
                .filter(s -> StaffRoles.DELIVERY.equals(s.getRole()) && s.isActive())
                .collect(Collectors.toList());
        req.setAttribute("activeShippers", activeShippers);
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
        boolean ajax = isAjax(req);
        String returnTo = returnUrl(req, orderId);

        if (orderId == null || newStatusRaw == null) {
            respond(req, resp, ajax, false, "Yêu cầu không hợp lệ.", returnTo);
            return;
        }

        String newStatus = OrderStatuses.normalize(newStatusRaw);
        if (!OrderStatuses.isValid(newStatus)) {
            respond(req, resp, ajax, false, "Trạng thái không hợp lệ.", returnTo);
            return;
        }
        // CONFIRMED -> SHIPPING BẮT BUỘC gán người giao (đội DELIVERY) — chỉ được thực hiện qua
        // /admin/don-hang/giao-van-chuyen (xem handleShipOrder). Chặn ở đây để không có đường nào
        // (kể cả gọi thẳng endpoint này) chuyển sang SHIPPING mà bỏ qua bước gán người.
        if (OrderStatuses.SHIPPING.equals(newStatus)) {
            respond(req, resp, ajax, false,
                    "Chuyển sang \"Đang giao\" phải chọn người phụ trách — dùng nút \"Chuyển đang giao\".", returnTo);
            return;
        }

        try {
            boolean updated;
            if (OrderStatuses.CANCELLED.equals(newStatus)) {
                if (reason == null) {
                    respond(req, resp, ajax, false, "Vui lòng nhập lý do hủy đơn.", returnTo);
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
                respond(req, resp, ajax, true, "Đã cập nhật đơn #" + orderId + " thành \""
                        + OrderStatuses.getLabel(newStatus) + "\".", returnTo);
            } else {
                respond(req, resp, ajax, false,
                        "Không thể cập nhật — đơn hàng đã đổi trạng thái ở nơi khác. Vui lòng tải lại.", returnTo);
            }
        } catch (IllegalStateException | IllegalArgumentException e) {
            respond(req, resp, ajax, false, e.getMessage(), returnTo);
        } catch (Exception e) {
            System.err.println("[AdminOrderController] cap-nhat-trang-thai lỗi: " + e.getMessage());
            respond(req, resp, ajax, false, "Có lỗi xảy ra, vui lòng thử lại.", returnTo);
        }
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
    // POST /admin/don-hang/chot-hoan-thanh — DONE (chưa xác nhận) -> đã đối soát, "Thành công"
    // =========================================================================================

    private void handleConfirmDelivery(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer orderId = parsePositiveInt(req.getParameter("orderId"));
        String returnTo = returnUrl(req, orderId);

        if (orderId == null) {
            flashError(req, "Yêu cầu không hợp lệ.");
            resp.sendRedirect(returnTo);
            return;
        }

        try {
            if (orderDao.confirmDeliveryByAdmin(orderId)) {
                AuditLogger.log(req, admin.getStaffId(), "ORDER_DELIVERY_CONFIRMED", "Order#" + orderId,
                        "Đối soát, chốt hoàn thành đơn #" + orderId);
                flashSuccess(req, "Đã chốt hoàn thành đơn #" + orderId + ".");
            } else {
                flashError(req, "Không thể chốt — đơn không còn ở trạng thái chờ xác nhận.");
            }
        } catch (Exception e) {
            System.err.println("[AdminOrderController] chot-hoan-thanh lỗi: " + e.getMessage());
            flashError(req, "Có lỗi xảy ra, vui lòng thử lại.");
        }

        resp.sendRedirect(returnTo);
    }

    // =========================================================================================
    // POST /admin/don-hang/giao-van-chuyen — CONFIRMED -> SHIPPING, gán người giao (đội DELIVERY)
    // =========================================================================================

    private void handleShipOrder(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer orderId = parsePositiveInt(req.getParameter("orderId"));
        Integer handlerId = parsePositiveInt(req.getParameter("handlerId"));
        String returnTo = returnUrl(req, orderId);

        if (orderId == null) {
            flashError(req, "Yêu cầu không hợp lệ.");
            resp.sendRedirect(returnTo);
            return;
        }
        if (handlerId == null) {
            flashError(req, "Vui lòng chọn người phụ trách giao hàng.");
            resp.sendRedirect(returnTo);
            return;
        }

        // Không tin id client gửi lên — phải thật sự là nhân viên đội DELIVERY đang active,
        // tránh gán nhầm/gán ác ý một StaffID bất kỳ (VD: một ADMIN khác) làm người giao hàng.
        Optional<Staff> handler = staffDao.findById(handlerId);
        if (handler.isEmpty() || !handler.get().isActive() || !StaffRoles.DELIVERY.equals(handler.get().getRole())) {
            flashError(req, "Người phụ trách không hợp lệ hoặc đã bị khóa/đổi vai trò.");
            resp.sendRedirect(returnTo);
            return;
        }

        try {
            if (orderDao.shipOrderWithHandler(orderId, handlerId)) {
                AuditLogger.log(req, admin.getStaffId(), "ORDER_SHIPPED", "Order#" + orderId,
                        "Giao đơn #" + orderId + " cho " + handler.get().getFullName() + " vận chuyển");
                flashSuccess(req, "Đã giao đơn #" + orderId + " cho " + handler.get().getFullName() + " vận chuyển.");
            } else {
                flashError(req, "Không thể giao — đơn không còn ở trạng thái chờ giao (đã đổi ở nơi khác).");
            }
        } catch (Exception e) {
            System.err.println("[AdminOrderController] giao-van-chuyen lỗi: " + e.getMessage());
            flashError(req, "Có lỗi xảy ra, vui lòng thử lại.");
        }

        resp.sendRedirect(returnTo);
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    /** Luôn lấy admin thao tác từ cookie AdminAuth — KHÔNG BAO GIỜ nhận staffId/adminId từ client. */
    private Staff currentAdmin(HttpServletRequest req) {
        return AdminAuth.currentAdmin(req);
    }

    /** Hàng đợi khẩn cấp gọi bằng fetch() với header này — phân biệt để trả JSON thay vì redirect. */
    /**
     * true chỉ khi đây thực sự là gọi fetch() từ JS, KHÔNG phải điều hướng cấp cao nhất (gõ URL,
     * F5, mở tab mới, back/forward...). Chỉ dựa vào "X-Requested-With" là không đủ an toàn — nếu
     * một điều hướng thật (VD: F5 lại URL đã được history.pushState của tab lịch sử đơn hàng) vì
     * lý do nào đó vẫn mang theo header này (cache trình duyệt, extension...), route "/admin/don-hang"
     * sẽ trả về fragment trần (không header/sidebar/CSS) thay vì trang đầy đủ — vỡ giao diện hoàn
     * toàn (đã xảy ra thực tế). "Sec-Fetch-Mode" do trình duyệt hiện đại tự gắn dựa trên loại
     * request thật sự, JS không thể giả mạo — "navigate" LUÔN là điều hướng cấp cao nhất, dù có
     * "X-Requested-With" hay không, vẫn phải trả về trang đầy đủ.
     */
    private boolean isAjax(HttpServletRequest req) {
        if (!"XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) return false;
        String secFetchMode = req.getHeader("Sec-Fetch-Mode");
        return secFetchMode == null || !"navigate".equals(secFetchMode);
    }

    /**
     * Trả kết quả một hành động: AJAX → JSON (200 thành công / 422 lỗi nghiệp vụ),
     * request thường (form trang chi tiết) → flash message + redirect như cũ.
     */
    private void respond(HttpServletRequest req, HttpServletResponse resp, boolean ajax,
                         boolean success, String message, String returnTo) throws IOException {
        if (ajax) {
            resp.setStatus(success ? HttpServletResponse.SC_OK : 422); // 422 Unprocessable — lỗi nghiệp vụ
            resp.setContentType("application/json; charset=UTF-8");
            resp.getWriter().write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}");
        } else {
            if (success) flashSuccess(req, message); else flashError(req, message);
            resp.sendRedirect(returnTo);
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length() + 8);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"' -> sb.append("\\\"");
                case '\\' -> sb.append("\\\\");
                case '\n' -> sb.append("\\n");
                case '\r' -> sb.append("\\r");
                case '\t' -> sb.append("\\t");
                default -> {
                    if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
                    else sb.append(c);
                }
            }
        }
        return sb.toString();
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
