package com.nhietdoixanh.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/*
 * LƯU Ý: phải map cả "/js/*". Trước đây chỉ map /css/* và /images/* nên toàn bộ file JS
 * (cart.js, checkout.js, avatar-crop.js ~44KB) KHÔNG hề được cache — mỗi lần chuyển trang
 * trình duyệt tải lại từ đầu, gây cảm giác "chuyển trang chậm/khựng". Nhánh xử lý ".js"
 * bên dưới đã có sẵn từ trước, chỉ thiếu url-pattern nên không bao giờ chạy.
 */
@WebFilter(filterName = "CacheHeaderFilter",
        urlPatterns = {"/css/*", "/js/*", "/images/*"}, asyncSupported = true)
public class CacheHeaderFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getRequestURI().toLowerCase();

        if (path.endsWith(".css") || path.endsWith(".js")) {
            response.setHeader("Cache-Control", "public, max-age=604800, immutable");
        } else if (path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".jpeg")
                || path.endsWith(".webp") || path.endsWith(".gif") || path.endsWith(".svg")
                || path.endsWith(".ico")) {
            response.setHeader("Cache-Control", "public, max-age=2592000, immutable");
        } else if (path.endsWith(".woff2") || path.endsWith(".woff") || path.endsWith(".ttf")) {
            response.setHeader("Cache-Control", "public, max-age=31536000, immutable");
        }

        chain.doFilter(req, res);
    }
}
