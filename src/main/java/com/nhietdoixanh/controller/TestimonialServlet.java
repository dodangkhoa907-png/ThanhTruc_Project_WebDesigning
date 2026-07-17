package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.TestimonialDAO;
import com.nhietdoixanh.model.Testimonial;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * Servlet xử lý các yêu cầu AJAX quản lý Phản hồi Khách hàng (Testimonials).
 * Cung cấp API dạng JSON cho các hành động GET, POST (Create, Update, Delete).
 */
@WebServlet(name = "TestimonialServlet", urlPatterns = {"/admin/testimonials", "/testimonials"})
public class TestimonialServlet extends HttpServlet {

    private final TestimonialDAO testimonialDAO = new TestimonialDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        List<Testimonial> list = testimonialDAO.getAllTestimonials();
        String jsonResponse = listToJson(list);
        
        try (PrintWriter out = response.getWriter()) {
            out.print(jsonResponse);
            out.flush();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        String action = request.getParameter("action");
        boolean result = false;
        String message = "";
        
        if (action == null) {
            action = "create";
        }
        
        try {
            if ("create".equalsIgnoreCase(action)) {
                String name = request.getParameter("name");
                String drink = request.getParameter("drink");
                String ratingStr = request.getParameter("rating");
                String avatar = request.getParameter("avatar");
                String text = request.getParameter("text");
                
                if (name == null || name.trim().isEmpty() ||
                    drink == null || drink.trim().isEmpty() ||
                    ratingStr == null || text == null || text.trim().isEmpty()) {
                    message = "Vui lòng nhập đầy đủ thông tin bắt buộc!";
                } else {
                    int rating = Integer.parseInt(ratingStr);
                    Testimonial t = new Testimonial(
                            escapeHtml(name.trim()),
                            escapeHtml(drink.trim()),
                            rating,
                            avatar != null ? escapeHtml(avatar.trim()) : "",
                            escapeHtml(text.trim())
                    );
                    result = testimonialDAO.insertTestimonial(t);
                    if (!result) {
                        message = "Lỗi hệ thống khi thêm phản hồi.";
                    }
                }
                
            } else if ("update".equalsIgnoreCase(action)) {
                String idStr = request.getParameter("id");
                String name = request.getParameter("name");
                String drink = request.getParameter("drink");
                String ratingStr = request.getParameter("rating");
                String avatar = request.getParameter("avatar");
                String text = request.getParameter("text");
                
                if (idStr == null || name == null || name.trim().isEmpty() ||
                    drink == null || drink.trim().isEmpty() ||
                    ratingStr == null || text == null || text.trim().isEmpty()) {
                    message = "Vui lòng nhập đầy đủ thông tin bắt buộc!";
                } else {
                    int id = Integer.parseInt(idStr);
                    int rating = Integer.parseInt(ratingStr);
                    Testimonial t = new Testimonial(
                            id,
                            escapeHtml(name.trim()),
                            escapeHtml(drink.trim()),
                            rating,
                            avatar != null ? escapeHtml(avatar.trim()) : "",
                            escapeHtml(text.trim()),
                            java.time.LocalDateTime.now()
                    );
                    result = testimonialDAO.updateTestimonial(t);
                    if (!result) {
                        message = "Lỗi hệ thống khi cập nhật phản hồi.";
                    }
                }
                
            } else if ("delete".equalsIgnoreCase(action)) {
                String idStr = request.getParameter("id");
                if (idStr == null || idStr.trim().isEmpty()) {
                    message = "Thiếu ID phản hồi cần xóa!";
                } else {
                    int id = Integer.parseInt(idStr);
                    result = testimonialDAO.deleteTestimonial(id);
                    if (!result) {
                        message = "Lỗi hệ thống khi xóa phản hồi.";
                    }
                }
            } else {
                message = "Hành động không hợp lệ!";
            }
        } catch (NumberFormatException e) {
            result = false;
            message = "Định dạng dữ liệu không hợp lệ!";
            e.printStackTrace();
        }
        
        String jsonResponse = "{\"success\":" + result + ",\"message\":\"" + escapeJson(message) + "\"}";
        try (PrintWriter out = response.getWriter()) {
            out.print(jsonResponse);
            out.flush();
        }
    }

    // ===== Helpers =====

    private String listToJson(List<Testimonial> list) {
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        for (int i = 0; i < list.size(); i++) {
            sb.append(list.get(i).toJson());
            if (i < list.size() - 1) {
                sb.append(",");
            }
        }
        sb.append("]");
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

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
