package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * Data Access Object cho bảng Orders.
 * Sử dụng PreparedStatement để chống SQL Injection.
 */
public class OrderDAO {

    /**
     * Chèn đơn hàng mới vào bảng Orders.
     *
     * @param order đối tượng Order chứa thông tin đơn hàng
     * @return true nếu insert thành công, false nếu thất bại
     */
    public boolean insertOrder(Order order) {
        String sql = "INSERT INTO Orders (CustomerName, PhoneNumber, ShippingAddress, OrderNote, OrderDate) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, order.getCustomerName());
            ps.setString(2, order.getPhoneNumber());
            ps.setString(3, order.getShippingAddress());
            ps.setString(4, order.getOrderNote());
            ps.setTimestamp(5, Timestamp.valueOf(
                    order.getOrderDate() != null ? order.getOrderDate() : LocalDateTime.now()
            ));

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("Lỗi khi chèn đơn hàng: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}

