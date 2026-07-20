package com.nhietdoixanh.controller.admin;

import com.nhietdoixanh.dao.FeedbackDao;
import com.nhietdoixanh.dao.impl.FeedbackDaoImpl;
import com.nhietdoixanh.model.Feedback;
import com.nhietdoixanh.model.Staff;
import com.nhietdoixanh.util.AdminAuth;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.FeedbackStatuses;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * Admin duyệt phản hồi khách hàng — danh sách/lọc theo trạng thái + tìm kiếm/phân trang,
 * chuyển trạng thái NEW -&gt; SEEN -&gt; RESOLVED (duyệt hiển thị công khai trên trang chủ)
 * theo {@link FeedbackStatuses}.
 *
 * Quyền hạn: nằm dưới urlPattern "/admin/*" nên đã được {@link com.nhietdoixanh.filter.AuthFilter}
 * chặn — chỉ Staff đã đăng nhập (cookie {@link com.nhietdoixanh.util.AdminAuth}) mới tới được. Mọi POST đã được
 * {@link com.nhietdoixanh.filter.CsrfFilter} kiểm tra token "_csrf" trước khi vào servlet này.
 * Người thao tác luôn lấy từ session, KHÔNG bao giờ nhận staffId từ request.
 *
 * LƯU Ý BẢO MẬT: Name/Phone/Email/Message của Feedback đều do khách vãng lai (KHÔNG xác thực)
 * tự nhập qua form phản hồi công khai trên trang chủ — coi là dữ liệu hoàn toàn không đáng tin
 * (rủi ro stored XSS). JSP hiển thị các trường này PHẢI luôn đi qua &lt;c:out&gt;.
 */
@WebServlet(name = "AdminFeedbackController", urlPatterns = {
        "/admin/phan-hoi",
        "/admin/phan-hoi/cap-nhat-trang-thai"
})
public class AdminFeedbackController extends HttpServlet {

    private static final int PAGE_SIZE = 20;

    private FeedbackDao feedbackDao;

    @Override
    public void init() {
        feedbackDao = new FeedbackDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/admin/phan-hoi" -> handleList(req, resp);
            // Route hành động chỉ nhận POST — chặn GET để không cho thao tác qua link/prefetch.
            default -> resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        switch (path) {
            case "/admin/phan-hoi/cap-nhat-trang-thai" -> handleUpdateStatus(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================================================
    // GET /admin/phan-hoi — danh sách + lọc theo trạng thái (tab) + tìm kiếm + phân trang
    // =========================================================================================

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String keyword = trimOrNull(req.getParameter("q"));
        String status = trimOrNull(req.getParameter("status"));
        // Chỉ chấp nhận giá trị trạng thái hợp lệ đã biết — không đẩy thẳng input thô vào SQL
        // param nếu nó không khớp NEW/SEEN/RESOLVED (phòng lỗi âm thầm, không phải SQLi vì đã
        // dùng PreparedStatement, nhưng tránh query vô nghĩa / tab "OTHER" không tồn tại).
        if (status != null && !FeedbackStatuses.isValid(status)) status = null;

        // Tab đang chọn — JSP chỉ so sánh 1 chuỗi này để bôi active, không tự suy luận lại.
        String activeTab = (status == null) ? "ALL" : status;

        int page = parsePositiveIntOrDefault(req.getParameter("page"), 1);
        int totalFeedback = feedbackDao.countFiltered(status, keyword);
        int totalPages = Math.max(1, (int) Math.ceil(totalFeedback / (double) PAGE_SIZE));
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * PAGE_SIZE;

        List<Feedback> feedbackList = feedbackDao.findFiltered(status, keyword, offset, PAGE_SIZE);

        req.setAttribute("feedbackList", feedbackList);
        req.setAttribute("totalFeedback", totalFeedback);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("q", keyword);
        req.setAttribute("status", status);
        req.setAttribute("activeTab", activeTab);

        // Đếm theo tab — dùng lại các phương thức countByStatus/countAll sẵn có (khối lượng
        // phản hồi không lớn như đơn hàng, không cần gộp vào 1 truy vấn riêng).
        req.setAttribute("countAll", feedbackDao.countAll());
        req.setAttribute("countNew", feedbackDao.countByStatus(FeedbackStatuses.NEW));
        req.setAttribute("countSeen", feedbackDao.countByStatus(FeedbackStatuses.SEEN));
        req.setAttribute("countResolved", feedbackDao.countByStatus(FeedbackStatuses.RESOLVED));

        req.setAttribute("pageTitle", "Phản hồi");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/admin/feedback/list.jsp").forward(req, resp);
    }

    // =========================================================================================
    // POST /admin/phan-hoi/cap-nhat-trang-thai — đổi trạng thái phản hồi (NEW/SEEN/RESOLVED)
    // =========================================================================================

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer feedbackId = parsePositiveInt(req.getParameter("feedbackId"));
        String newStatusRaw = trimOrNull(req.getParameter("newStatus"));
        boolean ajax = isAjax(req);
        String returnTo = returnUrl(req);

        if (feedbackId == null || newStatusRaw == null || !FeedbackStatuses.isValid(newStatusRaw)) {
            respond(req, resp, ajax, false, "Yêu cầu không hợp lệ.", returnTo);
            return;
        }

        try {
            boolean updated = feedbackDao.updateStatus(feedbackId, newStatusRaw) > 0;
            if (updated) {
                AuditLogger.log(req, admin.getStaffId(), "UPDATE_FEEDBACK_STATUS", "Feedback#" + feedbackId,
                        "Đổi trạng thái phản hồi #" + feedbackId + " sang " + FeedbackStatuses.getLabel(newStatusRaw));
                respond(req, resp, ajax, true, "Đã cập nhật phản hồi #" + feedbackId + " thành \""
                        + FeedbackStatuses.getLabel(newStatusRaw) + "\".", returnTo);
            } else {
                respond(req, resp, ajax, false, "Không thể cập nhật — phản hồi không tồn tại.", returnTo);
            }
        } catch (Exception e) {
            System.err.println("[AdminFeedbackController] cap-nhat-trang-thai lỗi: " + e.getMessage());
            respond(req, resp, ajax, false, "Có lỗi xảy ra, vui lòng thử lại.", returnTo);
        }
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    /** Luôn lấy admin thao tác từ cookie AdminAuth — KHÔNG BAO GIỜ nhận staffId từ client. */
    private Staff currentAdmin(HttpServletRequest req) {
        return AdminAuth.currentAdmin(req);
    }

    /** Nút hành động trong bảng gọi bằng fetch() với header này — phân biệt để trả JSON thay vì redirect. */
    private boolean isAjax(HttpServletRequest req) {
        return "XMLHttpRequest".equals(req.getHeader("X-Requested-With"));
    }

    /**
     * Trả kết quả một hành động: AJAX → JSON (200 thành công / 422 lỗi nghiệp vụ),
     * request thường (form không JS) → flash message + redirect như cũ.
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

    /** Quay lại danh sách, giữ nguyên tab/tìm kiếm/trang hiện tại (đọc lại từ chính request POST). */
    private String returnUrl(HttpServletRequest req) {
        String status = trimOrNull(req.getParameter("status"));
        String q = trimOrNull(req.getParameter("q"));
        String page = trimOrNull(req.getParameter("page"));

        List<String> params = new ArrayList<>();
        if (status != null) params.add("status=" + urlEncode(status));
        if (q != null) params.add("q=" + urlEncode(q));
        if (page != null) params.add("page=" + urlEncode(page));

        String base = req.getContextPath() + "/admin/phan-hoi";
        return params.isEmpty() ? base : base + "?" + String.join("&", params);
    }

    private String urlEncode(String raw) {
        return URLEncoder.encode(raw, StandardCharsets.UTF_8);
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
}
