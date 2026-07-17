package com.nhietdoixanh.filter;

import com.nhietdoixanh.model.Staff;
import com.nhietdoixanh.model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {"/cart/*", "/checkout/*", "/account/*", "/admin/*"}, asyncSupported = true)
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
        } else {
            res.sendRedirect(loginUri);
        }
    }

    @Override
    public void destroy() {
    }
}
