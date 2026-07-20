package com.nhietdoixanh.controller.admin;

import com.nhietdoixanh.dao.StaffDao;
import com.nhietdoixanh.dao.impl.StaffDaoImpl;
import com.nhietdoixanh.model.Staff;
import com.nhietdoixanh.util.AdminAuth;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.Passwords;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Optional;

/**
 * Đăng nhập/đăng xuất khu vực quản trị — dùng bảng Staffs có sẵn (Username,
 * KHÔNG phải Email). Đăng nhập qua cookie riêng {@link AdminAuth}, hoàn toàn tách biệt
 * HttpSession/session "user" của khách hàng (xem AdminAuth để biết lý do).
 * Chỉ tài khoản Role = ADMIN mới được vào /admin (nhân viên MANAGER/DELIVERY/
 * PROCESSOR/SALES bị chặn ở đây, giống logic bên PureNut).
 */
@WebServlet(name = "AdminAuthController", urlPatterns = {"/admin/login", "/admin/logout"})
public class AdminAuthController extends HttpServlet {

    private StaffDao staffDao;

    @Override
    public void init() {
        staffDao = new StaffDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/admin/logout".equals(path)) {
            // GET không thực hiện đăng xuất (tránh CSRF/logout qua link/prefetch) — chỉ chuyển
            // hướng an toàn. Đăng xuất thật chỉ qua POST /admin/logout (có CSRF) bên dưới.
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        Staff current = AdminAuth.currentAdmin(request);
        if (current != null && "ADMIN".equals(current.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if ("/admin/logout".equals(request.getServletPath())) {
            AdminAuth.logout(request, response);
            response.sendRedirect(request.getContextPath() + "/admin/login");
            return;
        }

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Optional<Staff> staffOpt = staffDao.findByUsername(username);
        boolean credentialsOk = staffOpt.isPresent() && staffOpt.get().isActive()
                && Passwords.matches(password, staffOpt.get().getPasswordHash());

        if (credentialsOk && "ADMIN".equals(staffOpt.get().getRole())) {
            Staff staff = staffOpt.get();
            AdminAuth.login(request, response, staff);
            AuditLogger.log(request, staff.getStaffId(), "ADMIN_LOGIN", staff.getUsername(), "Đăng nhập khu vực quản trị");
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else if (credentialsOk) {
            // Đúng tài khoản nhưng không phải ADMIN (MANAGER/DELIVERY/PROCESSOR/SALES) → chặn
            request.setAttribute("errorMessage", "Tài khoản này không có quyền quản trị.");
            request.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Tên đăng nhập hoặc mật khẩu không đúng.");
            request.getRequestDispatcher("/WEB-INF/views/admin/login.jsp").forward(request, response);
        }
    }
}
