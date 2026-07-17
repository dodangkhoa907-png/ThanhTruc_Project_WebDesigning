package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.dao.impl.OrderDaoImpl;
import com.nhietdoixanh.model.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Collections;

/**
 * Servlet xử lý đơn đặt hàng KHÁCH VÃNG LAI, KHÔNG giỏ hàng (POST).
 * TẠM THỜI — sẽ thay bằng CheckoutController (giỏ hàng thật) ở Phase giỏ hàng/checkout.
 * - Validation: Kiểm tra dữ liệu đầu vào
 * - Chống XSS: Escape HTML entities khi trả lỗi về JSP
 * - Thành công: Redirect về trang cảm ơn
 */
@WebServlet(name = "OrderServlet", urlPatterns = "/order")
public class OrderServlet extends HttpServlet {

    private final OrderDAO orderDAO = new OrderDaoImpl();

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

        // ===== XỬ LÝ ĐẶT HÀNG (khách vãng lai, không giỏ hàng — tạm thời) =====
        Order order = new Order();
        order.setCustomerName(customerName.trim());
        order.setPhoneNumber(phoneNumber.trim());
        order.setShippingAddress(shippingAddress.trim());
        order.setOrderNote(orderNote != null ? orderNote.trim() : "");
        order.setTotalAmount(BigDecimal.ZERO);
        order.setShippingFee(BigDecimal.ZERO);
        order.setFinalAmount(BigDecimal.ZERO);
        order.setPaymentMethod("COD");

        try {
            int orderId = orderDAO.placeOrder(order, Collections.emptyList());
            if (orderId > 0) {
                // Redirect (PRG Pattern) để tránh duplicate submit
                response.sendRedirect(request.getContextPath() + "/thankyou");
                return;
            }
        } catch (Exception e) {
            System.err.println("[OrderServlet] Lỗi đặt hàng: " + e.getMessage());
        }
        request.setAttribute("errorMessage", "Hệ thống đang bận, vui lòng thử lại sau.");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
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

