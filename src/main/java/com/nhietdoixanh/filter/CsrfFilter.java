package com.nhietdoixanh.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.Base64;

@WebFilter(filterName = "CsrfFilter", urlPatterns = {"/*"}, asyncSupported = true)
public class CsrfFilter implements Filter {

    public static final String TOKEN_ATTR = "_csrf";
    private static final SecureRandom RNG = new SecureRandom();

    public static String generateToken() {
        byte[] bytes = new byte[24];
        RNG.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(true);

        if (session.getAttribute(TOKEN_ATTR) == null) {
            session.setAttribute(TOKEN_ATTR, generateToken());
        }

        String method = request.getMethod();
        if ("POST".equalsIgnoreCase(method) || "PUT".equalsIgnoreCase(method)
                || "DELETE".equalsIgnoreCase(method)) {

            // Webhook PayOS là POST server-to-server (không có session/_csrf token). Bỏ qua CSRF
            // DUY NHẤT cho đúng path này — bảo mật của webhook do chữ ký HMAC-SHA256 đảm nhiệm
            // (xem PaymentController#handleWebhook → PayOSPaymentService.verifyWebhook). Không nới
            // lỏng CSRF cho bất kỳ endpoint nào khác.
            if ("/payment/payos/webhook".equals(request.getServletPath())) {
                chain.doFilter(req, res);
                return;
            }

            if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
                String origin = request.getHeader("Origin");
                if (origin == null) {
                    String ref = request.getHeader("Referer");
                    if (ref != null) origin = ref.replaceAll("(https?://[^/]+).*", "$1");
                }
                String expected = request.getScheme() + "://" + request.getServerName();
                int port = request.getServerPort();
                if (port != 80 && port != 443) expected += ":" + port;
                if (expected.equals(origin)) {
                    chain.doFilter(req, res);
                    return;
                }
            }

            String sessionToken = (String) session.getAttribute(TOKEN_ATTR);
            String requestToken = request.getParameter(TOKEN_ATTR);

            if (sessionToken == null || !sessionToken.equals(requestToken)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF token invalid");
                return;
            }
        }

        chain.doFilter(req, res);
    }
}
