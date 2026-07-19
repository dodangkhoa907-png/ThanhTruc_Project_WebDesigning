package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.UserDao;
import com.nhietdoixanh.dao.impl.UserDaoImpl;
import com.nhietdoixanh.model.User;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.EmailUtil;
import com.nhietdoixanh.util.Passwords;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;

/**
 * /account/security — đổi mật khẩu với xác minh 2 bước bằng OTP gửi qua email đăng ký.
 *
 * Luồng:
 *   1. POST /account/password/request-otp — xác thực mật khẩu hiện tại (BCrypt) + validate mật
 *      khẩu mới → sinh OTP 6 số, gửi email, chuyển UI sang bước nhập OTP.
 *   2. POST /account/password/change — xác thực OTP → áp dụng mật khẩu mới, rotate session.
 *   3. POST /account/password/resend-otp — gửi lại OTP (cooldown 60s).
 *
 * NGUYÊN TẮC BẢO MẬT:
 * - KHÔNG log/hiển thị mật khẩu thật, password hash, hay OTP ở bất kỳ đâu.
 * - KHÔNG lưu OTP thô hay mật khẩu mới thô trong session — chỉ lưu BCrypt hash của chúng
 *   (pendingOtpHash, pendingNewPasswordHash). Mật khẩu mới chỉ tồn tại dưới dạng hash cho tới
 *   khi OTP hợp lệ mới được ghi vào DB.
 * - OTP hết hạn sau 5 phút, tối đa 5 lần thử, cooldown gửi lại 60 giây.
 * - Auth (AuthFilter) + CSRF (CsrfFilter) bắt buộc cho mọi POST; userId luôn lấy từ session.
 */
@WebServlet(name = "AccountSecurityController", urlPatterns = {
        "/account/security",
        "/account/password/request-otp",
        "/account/password/change",
        "/account/password/resend-otp"
})
public class AccountSecurityController extends HttpServlet {

    // Cùng rule với đăng ký (AuthController.handleRegister) — ít nhất 6 ký tự, có hoa/thường/số.
    private static final String PASSWORD_RULE = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,}$";

    private static final long OTP_TTL_MS = 5L * 60 * 1000;
    private static final long RESEND_COOLDOWN_MS = 60L * 1000;
    private static final int MAX_ATTEMPTS = 5;
    private static final SecureRandom RANDOM = new SecureRandom();

    // Khóa session cho trạng thái OTP đổi mật khẩu (tách biệt hoàn toàn với luồng forgot-password).
    private static final String S_OTP_HASH = "pwChange_otpHash";
    private static final String S_NEWPASS_HASH = "pwChange_newPasswordHash";
    private static final String S_EXPIRES = "pwChange_expiresAt";
    private static final String S_SENT_AT = "pwChange_sentAt";
    private static final String S_ATTEMPTS = "pwChange_attempts";

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
        HttpSession session = req.getSession(false);
        boolean otpPending = session != null && session.getAttribute(S_OTP_HASH) != null
                && isNotExpired(session);
        if (otpPending) {
            req.setAttribute("otpStep", true);
            req.setAttribute("otpEmailMasked", maskEmail(currentUser(req)));
            long remaining = ((Long) session.getAttribute(S_EXPIRES)) - System.currentTimeMillis();
            req.setAttribute("otpRemainingMs", Math.max(remaining, 0));
        }
        req.setAttribute("currentPage", "account");
        req.setAttribute("accountTab", "security");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/account/security.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        switch (req.getServletPath()) {
            case "/account/password/request-otp" -> handleRequestOtp(req, resp);
            case "/account/password/change" -> handleChange(req, resp);
            case "/account/password/resend-otp" -> handleResend(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================================================
    // Bước 1 — POST /account/password/request-otp
    // =========================================================================================

    private void handleRequestOtp(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Mật khẩu thật chỉ dùng trong bộ nhớ để so sánh/hash — không log ở bất kỳ đâu.
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (currentPassword == null || currentPassword.isEmpty()
                || !Passwords.matches(currentPassword, user.getPasswordHash())) {
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

        if (user.getEmail() == null || user.getEmail().isBlank()) {
            flashError(req, "Tài khoản của bạn chưa có email để nhận mã xác minh.");
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        String otp = generateOtp();
        HttpSession session = req.getSession();
        // Lưu HASH của OTP và của mật khẩu mới — không lưu giá trị thô.
        session.setAttribute(S_OTP_HASH, Passwords.hash(otp));
        session.setAttribute(S_NEWPASS_HASH, Passwords.hash(newPassword));
        session.setAttribute(S_EXPIRES, System.currentTimeMillis() + OTP_TTL_MS);
        session.setAttribute(S_SENT_AT, System.currentTimeMillis());
        session.setAttribute(S_ATTEMPTS, 0);

        boolean sent = sendOtpEmail(user.getEmail(), user.getFullName(), otp);
        if (!sent) {
            clearOtpSession(session);
            flashError(req, "Không thể gửi email xác minh lúc này. Vui lòng thử lại sau.");
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        // Không log OTP. Chỉ log hành động yêu cầu.
        AuditLogger.log(req, null, "CUSTOMER_PASSWORD_CHANGE_OTP_REQUEST", user.getEmail(),
                "Yêu cầu mã xác minh đổi mật khẩu");
        flashSuccess(req, "Chúng tôi đã gửi mã OTP đến email của bạn. Vui lòng kiểm tra hộp thư.");
        resp.sendRedirect(req.getContextPath() + "/account/security");
    }

    // =========================================================================================
    // Bước 2 — POST /account/password/change
    // =========================================================================================

    private void handleChange(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute(S_OTP_HASH) == null) {
            flashError(req, "Phiên đổi mật khẩu đã hết hạn. Vui lòng bắt đầu lại.");
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        if (!isNotExpired(session)) {
            clearOtpSession(session);
            flashError(req, "Mã OTP đã hết hạn. Vui lòng yêu cầu gửi lại mã.");
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        int attempts = intAttr(session, S_ATTEMPTS) + 1;
        session.setAttribute(S_ATTEMPTS, attempts);
        if (attempts > MAX_ATTEMPTS) {
            clearOtpSession(session);
            flashError(req, "Bạn đã nhập sai mã quá nhiều lần. Vui lòng yêu cầu mã mới.");
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        String otp = collectOtp(req);
        String otpHash = (String) session.getAttribute(S_OTP_HASH);
        if (otp == null || !Passwords.matches(otp, otpHash)) {
            flashError(req, "Mã OTP không chính xác. Còn " + (MAX_ATTEMPTS - attempts) + " lần thử.");
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        String newPasswordHash = (String) session.getAttribute(S_NEWPASS_HASH);
        if (newPasswordHash == null) {
            clearOtpSession(session);
            flashError(req, "Có lỗi xảy ra. Vui lòng bắt đầu lại.");
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        boolean updated = userDao.updatePasswordHash(user.getUserId(), newPasswordHash);
        clearOtpSession(session);
        if (updated) {
            // Rotate session ID sau khi đổi mật khẩu (giảm rủi ro session fixation / cookie theft).
            req.changeSessionId();
            AuditLogger.log(req, null, "CUSTOMER_PASSWORD_CHANGE", user.getEmail(),
                    "Đổi mật khẩu tài khoản (xác minh OTP)");
            flashSuccess(req, "Đã đổi mật khẩu thành công.");
        } else {
            flashError(req, "Không thể đổi mật khẩu, vui lòng thử lại.");
        }
        resp.sendRedirect(req.getContextPath() + "/account/security");
    }

    // =========================================================================================
    // POST /account/password/resend-otp
    // =========================================================================================

    private void handleResend(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute(S_NEWPASS_HASH) == null) {
            flashError(req, "Phiên đổi mật khẩu đã hết hạn. Vui lòng bắt đầu lại.");
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        Long sentAt = (Long) session.getAttribute(S_SENT_AT);
        if (sentAt != null && System.currentTimeMillis() - sentAt < RESEND_COOLDOWN_MS) {
            flashError(req, "Vui lòng đợi trước khi yêu cầu gửi lại mã.");
            resp.sendRedirect(req.getContextPath() + "/account/security");
            return;
        }

        String otp = generateOtp();
        session.setAttribute(S_OTP_HASH, Passwords.hash(otp));
        session.setAttribute(S_EXPIRES, System.currentTimeMillis() + OTP_TTL_MS);
        session.setAttribute(S_SENT_AT, System.currentTimeMillis());
        session.setAttribute(S_ATTEMPTS, 0);

        boolean sent = (user.getEmail() != null) && sendOtpEmail(user.getEmail(), user.getFullName(), otp);
        if (sent) {
            flashSuccess(req, "Đã gửi lại mã OTP đến email của bạn.");
        } else {
            flashError(req, "Không thể gửi lại email lúc này. Vui lòng thử lại sau.");
        }
        resp.sendRedirect(req.getContextPath() + "/account/security");
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    private boolean isNotExpired(HttpSession session) {
        Long expiresAt = (Long) session.getAttribute(S_EXPIRES);
        return expiresAt != null && System.currentTimeMillis() <= expiresAt;
    }

    private int intAttr(HttpSession session, String key) {
        Object v = session.getAttribute(key);
        return (v instanceof Integer i) ? i : 0;
    }

    private String collectOtp(HttpServletRequest req) {
        // Hỗ trợ cả 1 ô "otp" lẫn 6 ô d1..d6 (giống trang forgot-password).
        String single = req.getParameter("otp");
        if (single != null && !single.isBlank()) {
            String digits = single.replaceAll("[^0-9]", "");
            return digits.length() == 6 ? digits : null;
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 6; i++) {
            String d = req.getParameter("d" + i);
            if (d == null || !d.matches("\\d")) return null;
            sb.append(d);
        }
        return sb.toString();
    }

    private String generateOtp() {
        return String.valueOf(RANDOM.nextInt(900000) + 100000);
    }

    private void clearOtpSession(HttpSession session) {
        session.removeAttribute(S_OTP_HASH);
        session.removeAttribute(S_NEWPASS_HASH);
        session.removeAttribute(S_EXPIRES);
        session.removeAttribute(S_SENT_AT);
        session.removeAttribute(S_ATTEMPTS);
    }

    private User currentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        User sessionUser = (session != null) ? (User) session.getAttribute("user") : null;
        if (sessionUser == null) return null;
        // Đọc lại từ DB để có passwordHash mới nhất (session.user có thể không chứa hash).
        return userDao.findById(sessionUser.getUserId()).orElse(null);
    }

    private String maskEmail(User user) {
        if (user == null || user.getEmail() == null) return "";
        String email = user.getEmail();
        int at = email.indexOf('@');
        if (at <= 1) return email;
        String name = email.substring(0, at);
        String domain = email.substring(at);
        String visible = name.substring(0, Math.min(2, name.length()));
        return visible + "***" + domain;
    }

    private boolean sendOtpEmail(String toEmail, String fullName, String otp) {
        String safeName = (fullName == null || fullName.isBlank()) ? "bạn" : fullName;
        String html = "<!DOCTYPE html>"
            + "<html><head><meta charset='UTF-8'></head><body style='margin:0;padding:0;background:#FDFBF7;font-family:Arial,Helvetica,sans-serif'>"
            + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#FDFBF7;padding:40px 20px'><tr><td align='center'>"
            + "<table width='520' cellpadding='0' cellspacing='0' style='background:#FFFFFF;border-radius:24px;overflow:hidden;box-shadow:0 8px 30px rgba(30,63,39,.08)'>"
            + "<tr><td style='background:linear-gradient(135deg,#2A5C38,#1E3F27);padding:36px 40px;text-align:center'>"
            + "<div style='font-size:28px;margin-bottom:8px'>🔒</div>"
            + "<h1 style='margin:0;color:#fff;font-size:22px;font-weight:600'>Mã xác minh đổi mật khẩu</h1>"
            + "<p style='margin:8px 0 0;color:rgba(255,255,255,.8);font-size:14px'>Tài khoản Nhiệt Đới Xanh</p>"
            + "</td></tr>"
            + "<tr><td style='padding:36px 40px'>"
            + "<p style='margin:0 0 16px;font-size:15px;color:#1A2E1A'>Xin chào <b>" + escape(safeName) + "</b>,</p>"
            + "<p style='margin:0 0 28px;font-size:14.5px;color:#7A8D7A;line-height:1.6'>Chúng tôi nhận được yêu cầu đổi mật khẩu cho tài khoản của bạn. Nhập mã OTP bên dưới để xác nhận:</p>"
            + "<div style='text-align:center;margin:0 0 28px'>"
            + "<div style='display:inline-block;background:#FDFBF7;border:2px dashed #2A5C38;border-radius:16px;padding:20px 36px'>"
            + "<span style='font-size:36px;font-weight:700;letter-spacing:12px;color:#2A5C38;font-family:monospace'>" + otp + "</span>"
            + "</div>"
            + "<p style='margin:12px 0 0;font-size:13px;color:#D9534F;font-weight:600'>⏱ Mã có hiệu lực trong 5 phút</p>"
            + "</div>"
            + "<div style='background:#FBE3E1;border-radius:12px;padding:14px 18px;margin:0 0 24px'>"
            + "<p style='margin:0;font-size:13px;color:#8E1F1F;font-weight:600'>⚠️ Không chia sẻ mã này với bất kỳ ai.</p>"
            + "</div>"
            + "<p style='margin:0;font-size:13.5px;color:#7A8D7A;line-height:1.5'>Nếu bạn không yêu cầu đổi mật khẩu, hãy bỏ qua email này — mật khẩu của bạn vẫn an toàn.</p>"
            + "</td></tr>"
            + "<tr><td style='background:#F5F0E8;padding:20px 40px;text-align:center;border-top:1px solid rgba(42,92,56,.08)'>"
            + "<p style='margin:0;font-size:12px;color:#7A8D7A'>© 2026 Nhiệt Đới Xanh — Trọn vị thanh mát 🍃</p>"
            + "</td></tr>"
            + "</table></td></tr></table></body></html>";
        return EmailUtil.sendEmail(toEmail, "Mã xác minh đổi mật khẩu Nhiệt Đới Xanh", html);
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
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
}
