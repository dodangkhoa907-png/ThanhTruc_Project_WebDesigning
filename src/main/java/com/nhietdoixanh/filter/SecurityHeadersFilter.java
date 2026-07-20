package com.nhietdoixanh.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebFilter(filterName = "SecurityHeadersFilter", urlPatterns = {"/*"}, asyncSupported = true)
public class SecurityHeadersFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        if (response instanceof HttpServletResponse res) {
            // Trang tài khoản chứa dữ liệu nhạy cảm — không cho trình duyệt cache lại để
            // nút Back không thể "xem lại" sau khi đã đăng xuất.
            if (request instanceof HttpServletRequest hreq && hreq.getServletPath().startsWith("/account")) {
                res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
                res.setHeader("Pragma", "no-cache");
            }
            res.setHeader("X-Content-Type-Options", "nosniff");
            res.setHeader("X-Frame-Options", "SAMEORIGIN");
            res.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
            res.setHeader("Permissions-Policy", "geolocation=(self), microphone=(), camera=()");
            res.setHeader("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
            res.setHeader("Content-Security-Policy",
                    "default-src 'self'; "
                    + "script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; "
                    + "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdnjs.cloudflare.com; "
                    + "font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; "
                    // checkout-addr-map (Leaflet): tile ảnh bản đồ tải từ các subdomain a/b/c.tile.openstreetmap.org.
                    + "img-src 'self' data: blob: https://images.unsplash.com https://*.tile.openstreetmap.org; "
                    // checkout-addr-map: reverse-geocode (tự điền địa chỉ từ tọa độ) qua Nominatim.
                    + "connect-src 'self' https://nominatim.openstreetmap.org; "
                    + "frame-ancestors 'self'");
        }
        chain.doFilter(request, response);
    }
}
