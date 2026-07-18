package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.UserDao;
import com.nhietdoixanh.dao.impl.UserDaoImpl;
import com.nhietdoixanh.model.User;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.Passwords;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * /account/security — đổi mật khẩu. Không bao giờ log/hiển thị mật khẩu thật hay password hash;
 * chỉ log hành động (CUSTOMER_PASSWORD_CHANGE) không kèm giá trị mật khẩu.
 */
@WebServlet(name = "AccountSecurityController", urlPatterns = {"/account/security", "/account/password"})
public class AccountSecurityController extends HttpServlet {

    // Cùng rule với đăng ký (AuthController.handleRegister) — ít nhất 6 ký tự, có hoa/thường/số.
    private static final String PASSWORD_RULE = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,}$";

    private UserDao userDao;

    @Override
    public void init() {
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!"/account/security".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        req.setAttribute("currentPage", "account");
        req.setAttribute("accountTab", "security");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/account/security.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!"/account/password".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        req.setCharacterEncoding("UTF-8");

        int userId = currentUserId(req);
        User user = userDao.findById(userId).orElse(null);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Không log giá trị mật khẩu thật (raw) ở bất kỳ đâu — chỉ dùng trong bộ nhớ để so sánh/hash.
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (currentPassword == null || currentPassword.isEmpty() || !Passwords.matches(currentPassword, user.getPasswordHash())) {
            error = "Mật khẩu hiện tại không đúng.";
        } else if (newPassword == null || !newPassword.matches(PASSWORD_RULE)) {
            error = "Mật khẩu mới phải có ít nhất 6 ký tự, gồm chữ hoa, chữ thường và số.";
        } else if (!newPassword.equals(confirmPassword)) {
            error = "Xác nhận mật khẩu mới không khớp.";
        } else if (currentPassword.equals(newPassword)) {
            error = "Mật khẩu mới phải khác mật khẩu hiện tại.";
        }

        if (error != null) {
            flashError(req, error);
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        boolean updated = userDao.updatePasswordHash(userId, Passwords.hash(newPassword));
        if (updated) {
            // Rotate session ID sau khi đổi mật khẩu — giữ nguyên attribute nhưng đổi ID phiên,
            // giảm rủi ro nếu session cũ đã bị lộ (session fixation / cookie theft trước đó).
            if (req.getSession(false) != null) req.changeSessionId();
            AuditLogger.log(req, null, "CUSTOMER_PASSWORD_CHANGE", user.getEmail(), "Đổi mật khẩu tài khoản");
            flashSuccess(req, "Đã đổi mật khẩu thành công.");
        } else {
            flashError(req, "Không thể đổi mật khẩu, vui lòng thử lại.");
        }
        resp.sendRedirect(req.getContextPath() + "/account/security");
    }

    private int currentUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        return user.getUserId();
    }

    private void flashSuccess(HttpServletRequest req, String message) {
        req.getSession(false).setAttribute("accountFlashSuccess", message);
    }

    private void flashError(HttpServletRequest req, String message) {
        req.getSession(false).setAttribute("accountFlashError", message);
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
}
