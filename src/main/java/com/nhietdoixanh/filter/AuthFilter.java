package com.nhietdoixanh.filter;

import com.nhietdoixanh.model.Staff;
import com.nhietdoixanh.model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/cart", "/cart/*", "/checkout/*", "/account/*", "/admin/*"}, asyncSupported = true)
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String servletPath = req.getServletPath();

        if ("/admin/login".equals(servletPath) || "/cart/count".equals(servletPath)) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        boolean isAdminArea = servletPath.startsWith("/admin");
        String loginUri = req.getContextPath() + (isAdminArea ? "/admin/login" : "/login");

        if (isAdminArea) {
            Staff admin = (session != null) ? (Staff) session.getAttribute("adminUser") : null;
            if (admin != null && admin.isActive()) {
                chain.doFilter(request, response);
            } else {
                res.sendRedirect(loginUri);
            }
            return;
        }

        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user != null) {
            chain.doFilter(request, response);
            return;
        }

        if (isAjax(req)) {
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.setContentType("application/json; charset=UTF-8");
            res.getWriter().write("{\"success\":false,\"requireLogin\":true,\"loginUrl\":\""
                    + loginUri + "\",\"message\":\"Vui lòng đăng nhập để tiếp tục.\"}");
            return;
        }

        // Lưu returnUrl an toàn (chỉ path nội bộ) để quay lại sau khi login.
        String returnUrl = req.getServletPath();
        if (req.getQueryString() != null) returnUrl += "?" + req.getQueryString();
        req.getSession().setAttribute("returnUrl", returnUrl);

        res.sendRedirect(loginUri);
    }

    private boolean isAjax(HttpServletRequest req) {
        if ("XMLHttpRequest".equals(req.getHeader("X-Requested-With"))) return true;
        String accept = req.getHeader("Accept");
        return accept != null && accept.contains("application/json");
    }

    @Override
    public void destroy() {
    }
}
