package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.CategoryDao;
import com.nhietdoixanh.dao.ProductDao;
import com.nhietdoixanh.dao.impl.CategoryDaoImpl;
import com.nhietdoixanh.dao.impl.ProductDaoImpl;
import com.nhietdoixanh.model.Category;
import com.nhietdoixanh.model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Trang thực đơn đầy đủ — danh mục + sản phẩm thật từ DB (thay cho menu
 * tĩnh trong index.jsp). Lọc theo danh mục qua query param ?danhmuc=ID.
 */
@WebServlet(name = "ProductController", urlPatterns = {"/thuc-don"})
public class ProductController extends HttpServlet {

    private CategoryDao categoryDao;
    private ProductDao productDao;

    @Override
    public void init() {
        categoryDao = new CategoryDaoImpl();
        productDao = new ProductDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Category> categories = categoryDao.findAll();

        String catParam = req.getParameter("danhmuc");
        List<Product> products;
        Integer activeCategoryId = null;
        if (catParam != null && !catParam.isBlank()) {
            try {
                activeCategoryId = Integer.parseInt(catParam.trim());
                products = productDao.findByCategoryId(activeCategoryId);
            } catch (NumberFormatException e) {
                products = productDao.findAllActive();
            }
        } else {
            products = productDao.findAllActive();
        }

        req.setAttribute("categories", categories);
        req.setAttribute("products", products);
        req.setAttribute("activeCategoryId", activeCategoryId);
        req.getRequestDispatcher("/WEB-INF/views/menu.jsp").forward(req, resp);
    }
}
