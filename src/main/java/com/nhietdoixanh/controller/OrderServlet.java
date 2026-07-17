package com.nhietdoixanh.controller;

import com.nhietdoixanh.util.AuditLogger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Servlet xử lý form "Đặt hàng nhanh" trên trang chủ (POST) — CHỈ thu thập
 * thông tin liên hệ (tên/SĐT/địa chỉ), KHÔNG có sản phẩm/số lượng/giá thật.
 *
 * ĐÃ VÔ HIỆU HÓA việc tạo Order 0 đồng / không có OrderDetails: trước đây route
 * này gọi placeOrder() với TotalAmount=FinalAmount=0 và danh sách sản phẩm rỗng,
 * tạo ra các đơn hàng "ma" trong bảng Orders. OrderDaoImpl.placeOrder() giờ từ
 * chối đơn không có item / có FinalAmount <= 0 (xem OrderDaoImpl.java).
 *
 * Hành vi mới: lưu yêu cầu liên hệ này lại (audit log) và chuyển hướng người
 * dùng sang trang cảm ơn với thông báo sẽ được liên hệ lại — KHÔNG tạo Order
 * giả trong DB. Route /cart, /checkout thật sẽ thay thế hoàn toàn form này ở
 * prompt sau (giỏ hàng + chọn sản phẩm + giá thật).
 *
 * - Validation: Kiểm tra dữ liệu đầu vào
 * - Chống XSS: Escape HTML entities khi trả lỗi về JSP
 */
@WebServlet(name = "OrderServlet", urlPatterns = "/order")
public class OrderServlet extends HttpServlet {

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

        // ===== GHI NHẬN YÊU CẦU LIÊN HỆ (KHÔNG tạo Order 0 đồng trong DB) =====
        // Form này chưa có sản phẩm/số lượng/giá thật nên KHÔNG đủ dữ liệu để
        // tạo một Order hợp lệ. Route /cart + /checkout thật (giỏ hàng, giá lấy
        // từ ProductVariants) sẽ thay thế hoàn toàn form này.
        String detail = "Tên: " + customerName.trim()
                + " | SĐT: " + phoneNumber.trim()
                + " | Địa chỉ: " + shippingAddress.trim()
                + (orderNote != null && !orderNote.isBlank() ? " | Ghi chú: " + orderNote.trim() : "");
        AuditLogger.log(request, null, "HOMEPAGE_ORDER_FORM_SUBMIT", phoneNumber.trim(), detail);

        // Redirect (PRG Pattern) để tránh duplicate submit
        response.sendRedirect(request.getContextPath() + "/thankyou");
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

