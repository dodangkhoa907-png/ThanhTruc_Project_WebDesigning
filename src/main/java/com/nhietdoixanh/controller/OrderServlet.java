package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.model.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Servlet xử lý đơn đặt hàng (POST).
 * - Validation: Kiểm tra dữ liệu đầu vào
 * - Chống XSS: Escape HTML entities khi trả lỗi về JSP
 * - Thành công: Redirect về trang cảm ơn
 */
@WebServlet(name = "OrderServlet", urlPatterns = "/order")
public class OrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Lấy dữ liệu từ form
        String customerName = request.getParameter("customerName");
        String phoneNumber = request.getParameter("phoneNumber");
        String shippingAddress = request.getParameter("shippingAddress");
        String orderNote = request.getParameter("orderNote");

        // ===== VALIDATION =====
        StringBuilder errors = new StringBuilder();

        if (customerName == null || customerName.trim().isEmpty()) {
            errors.append("Vui lòng nhập Họ và Tên. ");
        }
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            errors.append("Vui lòng nhập Số Điện Thoại. ");
        } else if (!phoneNumber.trim().matches("^(0|\\+84)[0-9]{9,10}$")) {
            errors.append("Số điện thoại không hợp lệ. ");
        }
        if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
            errors.append("Vui lòng nhập Địa Chỉ Giao Hàng. ");
        }

        // Nếu có lỗi validation → forward về index.jsp kèm thông báo (đã escape XSS)
        if (!errors.isEmpty()) {
            request.setAttribute("errorMessage", escapeHtml(errors.toString()));
            // Giữ lại dữ liệu đã nhập (escape XSS)
            request.setAttribute("prevName", escapeHtml(customerName != null ? customerName : ""));
            request.setAttribute("prevPhone", escapeHtml(phoneNumber != null ? phoneNumber : ""));
            request.setAttribute("prevAddress", escapeHtml(shippingAddress != null ? shippingAddress : ""));
            request.setAttribute("prevNote", escapeHtml(orderNote != null ? orderNote : ""));
            request.getRequestDispatcher("/index.jsp").forward(request, response);
            return;
        }

        // ===== XỬ LÝ ĐẶT HÀNG =====
        Order order = new Order(
                customerName.trim(),
                phoneNumber.trim(),
                shippingAddress.trim(),
                orderNote != null ? orderNote.trim() : ""
        );

        boolean success = orderDAO.insertOrder(order);

        if (success) {
            // Redirect (PRG Pattern) để tránh duplicate submit
            response.sendRedirect(request.getContextPath() + "/thankyou");
        } else {
            request.setAttribute("errorMessage", "Hệ thống đang bận, vui lòng thử lại sau.");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Không cho phép GET → redirect về trang chủ
        response.sendRedirect(request.getContextPath() + "/");
    }

    /**
     * Escape HTML entities để chống XSS.
     * Thay thế các ký tự đặc biệt: & < > " '
     */
    private String escapeHtml(String input) {
        if (input == null) return "";
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
}
