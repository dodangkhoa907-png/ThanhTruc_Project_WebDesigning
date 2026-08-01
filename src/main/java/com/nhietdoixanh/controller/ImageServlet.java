package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.ProductDao;
import com.nhietdoixanh.dao.UserDao;
import com.nhietdoixanh.dao.impl.ProductDaoImpl;
import com.nhietdoixanh.dao.impl.UserDaoImpl;
import com.nhietdoixanh.model.ImageBlob;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Optional;

/**
 * Serve ảnh sản phẩm/avatar được admin/khách hàng upload, đọc trực tiếp từ DB
 * (Products.ImageData, Users.AvatarData) thay vì đĩa cục bộ — xem lý do ở
 * sql/migration_image_blob_storage.sql.
 *
 * URL giữ NGUYÊN format cũ ("/uploads/products/{id}", "/uploads/avatars/{id}") nên các JSP
 * dùng ${ctx}${product.imageUrl} / ${ctx}${user.profileImage} không cần sửa gì — chỉ có
 * ProductImageUpload/AvatarUpload lưu ImageURL/ProfileImage dạng "{path}/{id}?v={timestamp}"
 * thay vì tên file ngẫu nhiên trên đĩa. Query string ?v= chỉ để cache-bust khi ảnh đổi.
 */
@WebServlet(name = "ImageServlet", urlPatterns = {"/uploads/products/*", "/uploads/avatars/*"})
public class ImageServlet extends HttpServlet {

    private ProductDao productDao;
    private UserDao userDao;

    @Override
    public void init() {
        productDao = new ProductDaoImpl();
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String pathInfo = req.getPathInfo(); // "/{id}"
        if (pathInfo == null || pathInfo.length() < 2) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        int id;
        try {
            id = Integer.parseInt(pathInfo.substring(1));
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        boolean isAvatar = req.getServletPath().endsWith("/avatars");
        Optional<ImageBlob> blob = isAvatar ? userDao.findAvatarBlob(id) : productDao.findImageBlob(id);

        if (blob.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        ImageBlob img = blob.get();
        resp.setContentType(img.contentType());
        resp.setContentLength(img.data().length);
        // URL luôn kèm ?v=timestamp khi ảnh đổi (xem AdminProductController/AccountProfileController)
        // nên cache dài hạn + immutable ở đây an toàn: ảnh đổi => URL khác => cache cũ tự bỏ qua.
        resp.setHeader("Cache-Control", "public, max-age=31536000, immutable");
        resp.getOutputStream().write(img.data());
    }
}
