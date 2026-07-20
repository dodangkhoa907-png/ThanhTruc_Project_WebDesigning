package com.nhietdoixanh.controller.admin;

import com.nhietdoixanh.dao.StaffDao;
import com.nhietdoixanh.dao.impl.StaffDaoImpl;
import com.nhietdoixanh.model.Staff;
import com.nhietdoixanh.util.AdminAuth;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.Passwords;
import com.nhietdoixanh.util.StaffRoles;
import com.nhietdoixanh.util.Validators;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Admin quản lý tài khoản nhân viên (bảng Staffs) — danh sách, thêm, sửa (họ tên/vai trò),
 * khóa/mở khóa đăng nhập, admin reset mật khẩu.
 *
 * Thêm/sửa KHÔNG có trang riêng — chỉ 1 modal dùng chung trên chính /admin/nhan-vien (xem
 * staff/list.jsp). "/admin/nhan-vien/them" và "/admin/nhan-vien/sua" giờ chỉ nhận POST (submit
 * từ modal); lỗi validate redirect NGƯỢC về /admin/nhan-vien kèm query param để JS tự mở lại
 * đúng modal, đúng dữ liệu vừa nhập — không mất input, không có "trang lỗi" riêng.
 *
 * Quyền hạn: nằm dưới urlPattern "/admin/*" nên đã qua {@link com.nhietdoixanh.filter.AuthFilter}
 * (chỉ Role=ADMIN mới tới được, xem {@link AdminAuthController}) và {@link com.nhietdoixanh.filter.CsrfFilter}.
 *
 * Tự bảo vệ: không cho tự khóa chính mình, không cho tự đổi vai trò khỏi ADMIN, và không cho
 * khóa/hạ quyền ADMIN cuối cùng còn active — tránh khóa cả hệ thống ngoài quyền truy cập.
 */
@WebServlet(name = "AdminStaffController", urlPatterns = {
        "/admin/nhan-vien",
        "/admin/nhan-vien/them",
        "/admin/nhan-vien/sua",
        "/admin/nhan-vien/khoa-mo",
        "/admin/nhan-vien/doi-mat-khau"
})
public class AdminStaffController extends HttpServlet {

    private StaffDao staffDao;

    @Override
    public void init() {
        staffDao = new StaffDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/admin/nhan-vien" -> handleList(req, resp);
            // "/them" và "/sua" giờ chỉ là action POST của modal — không còn trang GET riêng.
            default -> resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        switch (path) {
            case "/admin/nhan-vien/them" -> handleCreate(req, resp);
            case "/admin/nhan-vien/sua" -> handleUpdate(req, resp);
            case "/admin/nhan-vien/khoa-mo" -> handleToggleActive(req, resp);
            case "/admin/nhan-vien/doi-mat-khau" -> handleResetPassword(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================================================
    // GET /admin/nhan-vien — danh sách nhân viên, lọc theo vai trò qua tab (?role=...)
    // =========================================================================================

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Staff> allStaff = staffDao.findAll();

        String roleParam = trimOrNull(req.getParameter("role"));
        final String roleFilter = (roleParam != null && StaffRoles.isValid(roleParam)) ? roleParam : null;

        List<Staff> staffList = roleFilter == null ? allStaff
                : allStaff.stream().filter(s -> roleFilter.equals(s.getRole())).collect(Collectors.toList());

        // Số đếm cho từng tab vai trò — tính 1 lần trên allStaff, không query lại theo từng tab.
        Map<String, Long> roleCounts = new LinkedHashMap<>();
        for (String role : StaffRoles.all().keySet()) {
            roleCounts.put(role, allStaff.stream().filter(s -> role.equals(s.getRole())).count());
        }

        req.setAttribute("staffList", staffList);
        req.setAttribute("totalStaff", staffList.size());
        req.setAttribute("totalAllStaff", allStaff.size());
        req.setAttribute("roles", StaffRoles.all());
        req.setAttribute("roleCounts", roleCounts);
        req.setAttribute("roleFilter", roleFilter);
        req.setAttribute("pageTitle", "Nhân viên");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/admin/staff/list.jsp").forward(req, resp);
    }

    // =========================================================================================
    // POST /admin/nhan-vien/them — tạo tài khoản nhân viên mới (submit từ modal trên list.jsp)
    // =========================================================================================

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);

        String username = trimOrNull(req.getParameter("username"));
        String fullName = trimOrNull(req.getParameter("fullName"));
        String role = trimOrNull(req.getParameter("role"));
        String password = req.getParameter("password");

        // Lỗi -> quay về /admin/nhan-vien kèm dữ liệu vừa nhập để JS tự mở lại modal "Thêm",
        // không mất input (không có mật khẩu trong URL — không đưa dữ liệu nhạy cảm vào query string).
        String returnTo = req.getContextPath() + "/admin/nhan-vien?formOpen=them"
                + "&username=" + enc(username) + "&fullName=" + enc(fullName) + "&role=" + enc(role);

        if (!Validators.isValidUsername(username)) {
            flashError(req, "Tên đăng nhập phải 3-32 ký tự (chữ, số, dấu chấm/gạch dưới/gạch ngang).");
            resp.sendRedirect(returnTo);
            return;
        }
        if (Validators.isBlank(fullName)) {
            flashError(req, "Vui lòng nhập họ tên.");
            resp.sendRedirect(returnTo);
            return;
        }
        if (!StaffRoles.isValid(role)) {
            flashError(req, "Vai trò không hợp lệ.");
            resp.sendRedirect(returnTo);
            return;
        }
        if (password == null || password.length() < 8) {
            flashError(req, "Mật khẩu phải có ít nhất 8 ký tự.");
            resp.sendRedirect(returnTo);
            return;
        }
        if (staffDao.existsByUsername(username)) {
            flashError(req, "Tên đăng nhập \"" + username + "\" đã tồn tại.");
            resp.sendRedirect(returnTo);
            return;
        }

        Staff s = new Staff();
        s.setUsername(username);
        s.setPasswordHash(Passwords.hash(password));
        s.setFullName(fullName);
        s.setRole(role);
        s.setActive(true);

        int newId = staffDao.insert(s);
        if (newId > 0) {
            AuditLogger.log(req, admin.getStaffId(), "CREATE_STAFF", "Staff#" + newId,
                    "Tạo tài khoản nhân viên \"" + username + "\" (" + StaffRoles.getLabel(role) + ")");
            flashSuccess(req, "Đã tạo tài khoản nhân viên \"" + fullName + "\".");
            resp.sendRedirect(req.getContextPath() + "/admin/nhan-vien");
        } else {
            flashError(req, "Không thể tạo tài khoản, vui lòng thử lại.");
            resp.sendRedirect(returnTo);
        }
    }

    // =========================================================================================
    // POST /admin/nhan-vien/sua — cập nhật họ tên + vai trò (submit từ modal trên list.jsp)
    // =========================================================================================

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer staffId = parsePositiveInt(req.getParameter("staffId"));

        if (staffId == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/nhan-vien");
            return;
        }

        String fullName = trimOrNull(req.getParameter("fullName"));
        String role = trimOrNull(req.getParameter("role"));

        // Username không đổi được — lấy lại từ DB (không phải từ client) để JS mở lại modal "Sửa"
        // vẫn hiện đúng username hiện tại nếu bước lưu bị lỗi.
        String currentUsername = staffDao.findById(staffId).map(Staff::getUsername).orElse("");
        String returnTo = req.getContextPath() + "/admin/nhan-vien?formOpen=sua&editId=" + staffId
                + "&username=" + enc(currentUsername) + "&fullName=" + enc(fullName) + "&role=" + enc(role);

        if (Validators.isBlank(fullName)) {
            flashError(req, "Vui lòng nhập họ tên.");
            resp.sendRedirect(returnTo);
            return;
        }
        if (!StaffRoles.isValid(role)) {
            flashError(req, "Vai trò không hợp lệ.");
            resp.sendRedirect(returnTo);
            return;
        }
        if (staffId == admin.getStaffId() && !StaffRoles.ADMIN.equals(role)) {
            flashError(req, "Không thể tự đổi vai trò của chính mình khỏi Quản trị viên.");
            resp.sendRedirect(returnTo);
            return;
        }
        if (!StaffRoles.ADMIN.equals(role) && isLastActiveAdmin(staffId)) {
            flashError(req, "Không thể đổi vai trò — đây là Quản trị viên đang hoạt động cuối cùng.");
            resp.sendRedirect(returnTo);
            return;
        }

        Staff s = new Staff();
        s.setStaffId(staffId);
        s.setFullName(fullName);
        s.setRole(role);

        if (staffDao.update(s)) {
            AuditLogger.log(req, admin.getStaffId(), "UPDATE_STAFF", "Staff#" + staffId,
                    "Cập nhật nhân viên: " + fullName + " (" + StaffRoles.getLabel(role) + ")");
            flashSuccess(req, "Đã cập nhật nhân viên \"" + fullName + "\".");
            resp.sendRedirect(req.getContextPath() + "/admin/nhan-vien");
        } else {
            flashError(req, "Không thể cập nhật — nhân viên không tồn tại.");
            resp.sendRedirect(returnTo);
        }
    }

    // =========================================================================================
    // POST /admin/nhan-vien/khoa-mo — khóa/mở khóa đăng nhập (AJAX)
    // =========================================================================================

    private void handleToggleActive(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer id = parsePositiveInt(req.getParameter("id"));
        boolean currentlyActive = Boolean.parseBoolean(req.getParameter("active"));

        if (id == null) {
            writeJson(resp, false, "Yêu cầu không hợp lệ.");
            return;
        }
        boolean newActive = !currentlyActive;

        if (!newActive && id == admin.getStaffId()) {
            writeJson(resp, false, "Không thể tự khóa tài khoản của chính mình.");
            return;
        }
        if (!newActive && isLastActiveAdmin(id)) {
            writeJson(resp, false, "Không thể khóa — đây là Quản trị viên đang hoạt động cuối cùng.");
            return;
        }

        if (staffDao.setActive(id, newActive)) {
            AuditLogger.log(req, admin.getStaffId(), newActive ? "UNLOCK_STAFF" : "LOCK_STAFF",
                    "Staff#" + id, (newActive ? "Mở khóa" : "Khóa") + " tài khoản nhân viên #" + id);
            writeJson(resp, true, newActive ? "Đã mở khóa tài khoản." : "Đã khóa tài khoản.");
        } else {
            writeJson(resp, false, "Không thể cập nhật — nhân viên không tồn tại.");
        }
    }

    // =========================================================================================
    // POST /admin/nhan-vien/doi-mat-khau — admin đặt lại mật khẩu cho nhân viên (AJAX)
    // =========================================================================================

    private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer id = parsePositiveInt(req.getParameter("id"));
        String newPassword = req.getParameter("newPassword");

        if (id == null) {
            writeJson(resp, false, "Yêu cầu không hợp lệ.");
            return;
        }
        if (newPassword == null || newPassword.length() < 8) {
            writeJson(resp, false, "Mật khẩu mới phải có ít nhất 8 ký tự.");
            return;
        }

        if (staffDao.updatePassword(id, Passwords.hash(newPassword))) {
            AuditLogger.log(req, admin.getStaffId(), "RESET_STAFF_PASSWORD", "Staff#" + id,
                    "Admin đặt lại mật khẩu cho nhân viên #" + id);
            writeJson(resp, true, "Đã đặt lại mật khẩu.");
        } else {
            writeJson(resp, false, "Không thể đổi mật khẩu — nhân viên không tồn tại.");
        }
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    /** true nếu staffId thuộc về ADMIN đang active và đó là ADMIN active DUY NHẤT còn lại. */
    private boolean isLastActiveAdmin(int staffId) {
        Optional<Staff> target = staffDao.findById(staffId);
        if (target.isEmpty() || !StaffRoles.ADMIN.equals(target.get().getRole()) || !target.get().isActive()) {
            return false;
        }
        long activeAdmins = staffDao.findAll().stream()
                .filter(s -> StaffRoles.ADMIN.equals(s.getRole()) && s.isActive())
                .count();
        return activeAdmins <= 1;
    }

    private Staff currentAdmin(HttpServletRequest req) {
        return AdminAuth.currentAdmin(req);
    }

    private void writeJson(HttpServletResponse resp, boolean success, String message) throws IOException {
        resp.setStatus(success ? HttpServletResponse.SC_OK : 422);
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write("{\"success\":" + success + ",\"message\":\"" + escapeJson(message) + "\"}");
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

    private String enc(String s) {
        return URLEncoder.encode(s == null ? "" : s, StandardCharsets.UTF_8);
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
