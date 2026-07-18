package com.nhietdoixanh.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebFilter(filterName = "CacheHeaderFilter", urlPatterns = {"/css/*", "/images/*"}, asyncSupported = true)
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
