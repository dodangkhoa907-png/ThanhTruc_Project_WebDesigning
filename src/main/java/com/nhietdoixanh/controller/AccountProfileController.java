package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.UserDao;
import com.nhietdoixanh.dao.impl.UserDaoImpl;
import com.nhietdoixanh.model.User;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.AvatarUpload;
import com.nhietdoixanh.util.Validators;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * /account/profile — cập nhật hồ sơ cá nhân (avatar, nickname, họ tên, SĐT, email).
 * Chỉ nhận đúng 5 trường này từ form — KHÔNG bao giờ đọc/param role, userId, createdAt từ
 * request (chống mass assignment). userId luôn lấy từ session.
 */
@WebServlet(name = "AccountProfileController", urlPatterns = {"/account/profile"})
@MultipartConfig(fileSizeThreshold = 1024 * 512, maxFileSize = 2_000_000, maxRequestSize = 3_000_000)
public class AccountProfileController extends HttpServlet {

    private UserDao userDao;

    @Override
    public void init() {
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int userId = currentUserId(req);
        User user = userDao.findById(userId).orElse(null);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        req.setAttribute("profileUser", user);
        req.setAttribute("currentPage", "account");
        req.setAttribute("accountTab", "profile");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        int userId = currentUserId(req);
        User existing = userDao.findById(userId).orElse(null);
        if (existing == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String fullName = trimOrNull(req.getParameter("fullName"));
        String phone = trimOrNull(req.getParameter("phone"));
        String nickname = trimOrNull(req.getParameter("nickname"));
        String email = trimOrNull(req.getParameter("email"));

        Map<String, String> errors = new LinkedHashMap<>();

        if (fullName == null || fullName.length() < 2 || fullName.length() > 100) {
            errors.put("fullName", "Họ và tên phải từ 2 đến 100 ký tự.");
        }
        if (nickname != null && nickname.length() > 100) {
            errors.put("nickname", "Nickname tối đa 100 ký tự.");
        }
        if (phone != null && !Validators.isValidPhone(phone)) {
            errors.put("phone", "Số điện thoại không hợp lệ.");
        }
        if (email == null || !Validators.isValidEmail(email)) {
            errors.put("email", "Email không hợp lệ.");
        } else if (userDao.emailExistsForOtherUser(email, userId)) {
            errors.put("email", "Email này đã được sử dụng bởi tài khoản khác.");
        }

        String newAvatarPath = null;
        if (errors.isEmpty()) {
            try {
                Part avatarPart = req.getPart("avatar");
                newAvatarPath = AvatarUpload.store(avatarPart, getServletContext(), userId);
            } catch (IllegalArgumentException e) {
                errors.put("avatar", e.getMessage());
            } catch (Exception e) {
                System.err.println("[AccountProfileController] Lỗi lưu avatar: " + e.getMessage());
                errors.put("avatar", "Không thể lưu ảnh đại diện, vui lòng thử lại.");
            }
        }

        if (!errors.isEmpty()) {
            req.setAttribute("formErrors", errors);
            req.setAttribute("oldFullName", fullName);
            req.setAttribute("oldPhone", phone);
            req.setAttribute("oldNickname", nickname);
            req.setAttribute("oldEmail", email);
            req.setAttribute("profileUser", existing);
            req.setAttribute("currentPage", "account");
            req.setAttribute("accountTab", "profile");
            req.getRequestDispatcher("/WEB-INF/views/account/profile.jsp").forward(req, resp);
            return;
        }

        boolean updated = userDao.updateProfile(userId, fullName, phone, nickname, email);
        if (updated && newAvatarPath != null) {
            String oldAvatar = existing.getProfileImage();
            if (userDao.updateAvatar(userId, newAvatarPath)) {
                AvatarUpload.deleteQuietly(oldAvatar, getServletContext());
            }
        }

        if (updated) {
            // Refresh session.user để header/dashboard hiển thị dữ liệu mới ngay, không cần đăng nhập lại.
            User refreshed = userDao.findById(userId).orElse(existing);
            req.getSession().setAttribute("user", refreshed);
            AuditLogger.log(req, null, "CUSTOMER_PROFILE_UPDATE", refreshed.getEmail(), "Cập nhật hồ sơ cá nhân");
            flashSuccess(req, "Đã cập nhật hồ sơ thành công.");
        } else {
            flashError(req, "Không thể cập nhật hồ sơ, vui lòng thử lại.");
        }

        resp.sendRedirect(req.getContextPath() + "/account/profile");
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

    private String trimOrNull(String raw) {
        if (raw == null) return null;
        String trimmed = raw.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
