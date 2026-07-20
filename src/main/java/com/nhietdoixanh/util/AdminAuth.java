package com.nhietdoixanh.util;

import com.nhietdoixanh.model.Staff;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Đăng nhập khu vực quản trị dùng cookie + registry RIÊNG — KHÔNG dùng chung HttpSession
 * với khách hàng.
 *
 * Lý do: HttpSession (cookie JSESSIONID) dùng chung cho TOÀN BỘ webapp context, không tách
 * theo path. Nếu admin và khách hàng cùng đăng nhập trong 1 trình duyệt (2 tab), họ vô tình
 * dùng chung 1 HttpSession — bất kỳ thao tác nào đụng tới vòng đời session ở một bên (admin
 * login gọi request.changeSessionId() chống session fixation, admin/customer logout gọi
 * session.invalidate()) sẽ vô tình đăng xuất luôn bên còn lại. Cookie "ADMIN_SID" riêng,
 * scope theo path "/admin" (trình duyệt chỉ gửi cookie này cho request dưới /admin/*),
 * tách biệt hoàn toàn 2 phiên đăng nhập — không còn phụ thuộc vào HttpSession của khách hàng.
 */
public final class AdminAuth {

    private static final String COOKIE_NAME = "ADMIN_SID";
    // Khớp session-timeout mặc định của Tomcat (30 phút) — trượt hạn theo hoạt động (touch mỗi request).
    private static final int MAX_AGE_SECONDS = 30 * 60;

    private static final Map<String, Entry> SESSIONS = new ConcurrentHashMap<>();
    private static final SecureRandom RNG = new SecureRandom();
    // Trước đây cleanupExpired() chỉ chạy lúc login — admin đăng nhập 1 lần rồi thôi thì entry
    // hết hạn nằm lại registry vô thời hạn (rò rỉ bộ nhớ chậm). Quét định kỳ luôn cả lúc đọc.
    private static final AtomicInteger READ_COUNT = new AtomicInteger();
    private static final int SWEEP_EVERY_N_READS = 50;

    private AdminAuth() {}

    private static final class Entry {
        final Staff staff;
        volatile long expiresAtMillis;

        Entry(Staff staff, long expiresAtMillis) {
            this.staff = staff;
            this.expiresAtMillis = expiresAtMillis;
        }
    }

    /** Gọi ngay sau khi xác thực username/password thành công — tạo token mới, set cookie riêng. */
    public static void login(HttpServletRequest req, HttpServletResponse resp, Staff staff) {
        cleanupExpired();
        String token = generateToken();
        SESSIONS.put(token, new Entry(staff, System.currentTimeMillis() + MAX_AGE_SECONDS * 1000L));
        setCookie(req, resp, token, MAX_AGE_SECONDS);
    }

    /** Đọc admin đang đăng nhập từ cookie riêng — trượt hạn (touch) nếu còn hợp lệ. */
    public static Staff currentAdmin(HttpServletRequest req) {
        if (READ_COUNT.incrementAndGet() % SWEEP_EVERY_N_READS == 0) cleanupExpired();

        String token = readToken(req);
        if (token == null) return null;

        Entry entry = SESSIONS.get(token);
        if (entry == null) return null;

        long now = System.currentTimeMillis();
        if (entry.expiresAtMillis < now) {
            SESSIONS.remove(token);
            return null;
        }
        entry.expiresAtMillis = now + MAX_AGE_SECONDS * 1000L;
        return entry.staff;
    }

    /** Đăng xuất — xóa token khỏi registry và hết hạn cookie ngay, không đụng tới HttpSession. */
    public static void logout(HttpServletRequest req, HttpServletResponse resp) {
        String token = readToken(req);
        if (token != null) SESSIONS.remove(token);
        setCookie(req, resp, "", 0);
    }

    /**
     * Set-Cookie dựng thủ công (không dùng {@code Cookie.setAttribute("SameSite",...)}) — API đó
     * chỉ có ở Servlet 6.0, và classpath biên dịch cục bộ của project đôi khi lẫn cả jakarta.servlet-api
     * 5.0.0, gây lỗi biên dịch khó lường. Header thủ công chạy đúng trên mọi phiên bản Servlet API.
     */
    private static void setCookie(HttpServletRequest req, HttpServletResponse resp, String value, int maxAgeSeconds) {
        StringBuilder sb = new StringBuilder();
        sb.append(COOKIE_NAME).append('=').append(value)
                .append("; Path=").append(req.getContextPath()).append("/admin")
                .append("; Max-Age=").append(maxAgeSeconds)
                .append("; HttpOnly")
                .append("; SameSite=Strict");
        if (req.isSecure()) sb.append("; Secure");
        resp.addHeader("Set-Cookie", sb.toString());
    }

    private static String readToken(HttpServletRequest req) {
        Cookie[] cookies = req.getCookies();
        if (cookies == null) return null;
        for (Cookie c : cookies) {
            if (COOKIE_NAME.equals(c.getName())) return c.getValue();
        }
        return null;
    }

    private static String generateToken() {
        byte[] bytes = new byte[32];
        RNG.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private static void cleanupExpired() {
        long now = System.currentTimeMillis();
        SESSIONS.entrySet().removeIf(e -> e.getValue().expiresAtMillis < now);
    }
}
