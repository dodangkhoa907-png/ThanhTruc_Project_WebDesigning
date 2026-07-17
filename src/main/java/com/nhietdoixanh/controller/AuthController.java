package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.CartItemDao;
import com.nhietdoixanh.dao.UserDao;
import com.nhietdoixanh.dao.impl.CartItemDaoImpl;
import com.nhietdoixanh.dao.impl.UserDaoImpl;
import com.nhietdoixanh.model.CartItem;
import com.nhietdoixanh.model.User;
import com.nhietdoixanh.service.UserService;
import com.nhietdoixanh.service.impl.UserServiceImpl;
import com.nhietdoixanh.util.AuditLogger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

/** Đăng ký / đăng nhập / đăng xuất khách hàng — session "user". */
@WebServlet(name = "AuthController", urlPatterns = {"/login", "/register", "/logout"})
public class AuthController extends HttpServlet {

    private UserService userService;
    private UserDao userDao;
    private CartItemDao cartItemDao;

    @Override
    public void init() {
        userService = new UserServiceImpl();
        userDao = new UserDaoImpl();
        cartItemDao = new CartItemDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        HttpSession session = request.getSession(false);

        if ("/logout".equals(path)) {
            // GET không được phép thực hiện hành động có trạng thái (state-changing) — chỉ điều
            // hướng an toàn. Đăng xuất thật sự chỉ thực hiện qua POST /logout (có CSRF) bên dưới.
            response.sendRedirect(request.getContextPath() + (session != null && session.getAttribute("user") != null ? "/account" : "/login"));
            return;
        }

        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        if ("/login".equals(path)) {
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        } else if ("/register".equals(path)) {
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        if ("/login".equals(path)) {
            handleLogin(request, response);
        } else if ("/register".equals(path)) {
            handleRegister(request, response);
        } else if ("/logout".equals(path)) {
            handleLogout(request, response);
        }
    }

    /**
     * Đăng xuất thật — chỉ qua POST (đã được {@link com.nhietdoixanh.filter.CsrfFilter} kiểm tra
     * token "_csrf" trước khi vào đây). Invalidate toàn bộ session (xóa cả "user" lẫn "adminUser"
     * nếu có, giỏ hàng, CSRF token cũ...) rồi redirect về trang chủ.
     */
    private void handleLogout(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object user = session.getAttribute("user");
            if (user instanceof User u) {
                AuditLogger.log(request, null, "CUSTOMER_LOGOUT", u.getEmail(), "Đăng xuất tài khoản khách hàng");
            }
            session.invalidate();
        }
        response.sendRedirect(request.getContextPath() + "/");
    }

    /**
     * Lấy returnUrl đã lưu bởi AuthFilter (khi khách chưa đăng nhập cố truy cập /cart, /checkout, /account)
     * và xóa khỏi session (chỉ dùng 1 lần). Chỉ chấp nhận path nội bộ bắt đầu bằng "/" — chặn open redirect.
     */
    private String resolveReturnUrl(HttpSession session) {
        Object raw = session.getAttribute("returnUrl");
        session.removeAttribute("returnUrl");
        if (raw instanceof String url && url.startsWith("/") && !url.startsWith("//")) {
            return url;
        }
        return "/";
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Optional<User> userOpt = userService.authenticate(email, password);

        if (userOpt.isPresent()) {
            User user = userOpt.get();

            HttpSession session = request.getSession();
            request.changeSessionId(); // chống session fixation
            session.setAttribute("user", user);

            userDao.updateLoginInfo(user.getUserId(), request.getRemoteAddr());
            AuditLogger.log(request, null, "CUSTOMER_LOGIN", user.getEmail(), "Đăng nhập tài khoản khách hàng");

            List<CartItem> cartItems = cartItemDao.findByUserId(user.getUserId());
            int cartCount = cartItemDao.countItems(user.getUserId());
            session.setAttribute("cartItems", cartItems);
            session.setAttribute("cartCount", cartCount);

            response.sendRedirect(request.getContextPath() + resolveReturnUrl(session));
        } else {
            request.setAttribute("errorMessage", "Email hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String agreeTerms = request.getParameter("agreeTerms");

        if (!"on".equals(agreeTerms)) {
            request.setAttribute("errorMessage", "Bạn cần đồng ý với Điều khoản sử dụng và Chính sách bảo mật.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        if (!password.matches("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,}$")) {
            request.setAttribute("errorMessage", "Mật khẩu phải có ít nhất 6 ký tự, gồm chữ hoa, chữ thường và số.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        try {
            User user = userService.register(fullName, email, phone, password);

            HttpSession session = request.getSession();
            request.changeSessionId();
            session.setAttribute("user", user);

            userDao.updateLoginInfo(user.getUserId(), request.getRemoteAddr());
            AuditLogger.log(request, null, "CUSTOMER_REGISTER", user.getEmail(), "Đăng ký tài khoản mới");

            session.setAttribute("cartItems", java.util.Collections.emptyList());
            session.setAttribute("cartCount", 0);

            response.sendRedirect(request.getContextPath() + resolveReturnUrl(session));
        } catch (IllegalArgumentException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Có lỗi hệ thống. Xin vui lòng thử lại.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
        }
    }
}
