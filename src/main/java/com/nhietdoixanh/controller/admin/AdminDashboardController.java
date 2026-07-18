package com.nhietdoixanh.controller.admin;

import com.nhietdoixanh.dao.FeedbackDao;
import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.dao.ProductDao;
import com.nhietdoixanh.dao.impl.FeedbackDaoImpl;
import com.nhietdoixanh.dao.impl.OrderDaoImpl;
import com.nhietdoixanh.dao.impl.ProductDaoImpl;
import com.nhietdoixanh.model.Order;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {

    private ProductDao productDao;
    private OrderDAO orderDao;
    private FeedbackDao feedbackDao;

    @Override
    public void init() {
        productDao = new ProductDaoImpl();
        orderDao = new OrderDaoImpl();
        feedbackDao = new FeedbackDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Order> allOrders = orderDao.findAllOrders();
        long pendingCount = allOrders.stream().filter(o -> "PENDING".equals(o.getOrderStatus())).count();
        long doneCount = allOrders.stream().filter(o -> "DONE".equals(o.getOrderStatus())).count();
        List<Order> recentOrders = allOrders.stream().limit(6).collect(Collectors.toList());

        req.setAttribute("totalProducts", productDao.findAllForAdmin().size());
        req.setAttribute("totalOrders", allOrders.size());
        req.setAttribute("pendingOrders", pendingCount);
        req.setAttribute("doneOrders", doneCount);
        req.setAttribute("newFeedback", feedbackDao.countByStatus("NEW"));
        req.setAttribute("recentOrders", recentOrders);
        req.setAttribute("pageTitle", "Dashboard");
        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }
}
