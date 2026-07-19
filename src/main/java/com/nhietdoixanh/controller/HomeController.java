package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.ProductDao;
import com.nhietdoixanh.dao.impl.ProductDaoImpl;
import com.nhietdoixanh.model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

/**
 * GET / — trang chủ. Nạp sản phẩm active thật từ DB cho khu "Sản phẩm nổi bật"
 * (trước đây index.jsp hard-code card sản phẩm F&amp;B giả, không có ProductID
 * thật nên không thể trỏ tới /san-pham/chi-tiet?id=).
 *
 * QUAN TRỌNG — bài học từ sự cố vỡ giao diện:
 * TUYỆT ĐỐI KHÔNG map servlet này vào "/" (default-servlet). Khi map "/", servlet này nhận MỌI
 * request tĩnh (/css/*, /js/*, ảnh...) và forward về JSP → trả HTML với Content-Type text/html;
 * kèm header nosniff, trình duyệt từ chối áp dụng CSS → giao diện vỡ hoàn toàn.
 *
 * Cách đúng: chỉ map "/index.jsp". Welcome-file (index.jsp trong web.xml) khiến request "/" được
 * container phân giải sang "/index.jsp" → khớp servlet này → nạp featuredProducts → forward tới
 * /WEB-INF/views/home.jsp. DefaultServlet thật của Tomcat vẫn phục vụ /css, /js, ảnh với đúng
 * Content-Type.
 */
@WebServlet(name = "HomeController", urlPatterns = {"/index.jsp"})
public class HomeController extends HttpServlet {

    private static final int FEATURED_LIMIT = 6;

    private ProductDao productDao;

    @Override
    public void init() {
        productDao = new ProductDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Product> active = productDao.findAllActive();
        List<Product> featured = active.size() > FEATURED_LIMIT
                ? active.subList(0, FEATURED_LIMIT)
                : active;

        req.setAttribute("featuredProducts", featured.isEmpty() ? Collections.emptyList() : featured);
        // Forward tới view trong /WEB-INF (KHÔNG map servlet) để tránh vòng lặp với chính
        // urlPattern "/index.jsp" của servlet này.
        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
