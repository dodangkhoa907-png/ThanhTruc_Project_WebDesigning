package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.model.CartItem;
import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.model.OrderDetail;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDaoImpl implements OrderDAO {

    private static final String LIST_SELECT =
            "SELECT o.*, s.FullName AS HandledByName " +
            "FROM Orders o LEFT JOIN Staffs s ON o.HandledBy = s.StaffID ";

    @Override
    public int placeOrder(Order order, List<CartItem> cartItems) throws Exception {
        Connection conn = null;
        int orderId = 0;
        try {
            conn = Database.getConnection();
            conn.setAutoCommit(false);

            String sqlOrder = "INSERT INTO Orders (UserID, CustomerName, PhoneNumber, ShippingAddress, OrderNote, " +
                    "TotalAmount, ShippingFee, FinalAmount, PaymentMethod, OrderStatus, CouponCode) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?)";
            try (PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                if (order.getUserId() != null) psOrder.setInt(1, order.getUserId());
                else psOrder.setNull(1, Types.INTEGER);
                psOrder.setNString(2, order.getCustomerName());
                psOrder.setString(3, order.getPhoneNumber());
                psOrder.setNString(4, order.getShippingAddress());
                psOrder.setNString(5, order.getOrderNote());
                psOrder.setBigDecimal(6, order.getTotalAmount());
                psOrder.setBigDecimal(7, order.getShippingFee());
                psOrder.setBigDecimal(8, order.getFinalAmount());
                psOrder.setString(9, order.getPaymentMethod());
                psOrder.setString(10, order.getCouponCode());
                psOrder.executeUpdate();
                try (ResultSet rsKeys = psOrder.getGeneratedKeys()) {
                    if (rsKeys.next()) orderId = rsKeys.getInt(1);
                    else throw new SQLException("Không thể lấy OrderID");
                }
            }

            String sqlDetail = "INSERT INTO OrderDetails (OrderID, VariantID, Quantity, UnitPrice, SubTotal) VALUES (?,?,?,?,?)";
            try (PreparedStatement psDetail = conn.prepareStatement(sqlDetail)) {
                for (CartItem item : cartItems) {
                    psDetail.setInt(1, orderId);
                    psDetail.setInt(2, item.getVariantId());
                    psDetail.setInt(3, item.getQuantity());
                    psDetail.setBigDecimal(4, item.getPrice());
                    psDetail.setBigDecimal(5, item.getTotalPrice());
                    psDetail.addBatch();
                }
                psDetail.executeBatch();
            }

            if (order.getUserId() != null) {
                try (PreparedStatement psDeleteCart = conn.prepareStatement(
                        "DELETE FROM CartItems WHERE UserID = ?")) {
                    psDeleteCart.setInt(1, order.getUserId());
                    psDeleteCart.executeUpdate();
                }
            }

            conn.commit();
            return orderId;
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            throw e;
        } finally {
            if (conn != null) { conn.setAutoCommit(true); conn.close(); }
        }
    }

    @Override
    public List<Order> findAllOrders() {
        List<Order> list = new ArrayList<>();
        String sql = LIST_SELECT + "ORDER BY o.CreatedAt DESC";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Order> findAllOrdersPaged(int offset, int limit) {
        List<Order> list = new ArrayList<>();
        String sql = LIST_SELECT + "ORDER BY o.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int countOrders() {
        String sql = "SELECT COUNT(*) FROM Orders";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public Order findOrderById(int orderId) {
        Order o = null;
        String sqlOrder = LIST_SELECT + "WHERE o.OrderID = ?";
        String sqlItems = "SELECT od.*, p.ProductName, v.Size " +
                "FROM OrderDetails od " +
                "JOIN ProductVariants v ON od.VariantID = v.VariantID " +
                "JOIN Products p ON v.ProductID = p.ProductID " +
                "WHERE od.OrderID = ?";

        try (Connection con = Database.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sqlOrder)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) o = mapRow(rs);
                }
            }
            if (o != null) {
                List<OrderDetail> items = new ArrayList<>();
                try (PreparedStatement ps = con.prepareStatement(sqlItems)) {
                    ps.setInt(1, orderId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            OrderDetail d = new OrderDetail();
                            d.setOrderDetailId(rs.getInt("OrderDetailID"));
                            d.setOrderId(rs.getInt("OrderID"));
                            d.setVariantId(rs.getInt("VariantID"));
                            d.setQuantity(rs.getInt("Quantity"));
                            d.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                            d.setSubTotal(rs.getBigDecimal("SubTotal"));
                            d.setProductName(rs.getNString("ProductName"));
                            d.setSize(rs.getString("Size"));
                            items.add(d);
                        }
                    }
                }
                o.setItems(items);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return o;
    }

    @Override
    public List<Order> findOrdersByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = LIST_SELECT + "WHERE o.UserID = ? ORDER BY o.CreatedAt DESC";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int updateOrderStatus(int orderId, String status) {
        String sql = "UPDATE Orders SET OrderStatus = ? WHERE OrderID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int cancelOrder(int orderId, int userId, String reason) throws Exception {
        try (Connection con = Database.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT OrderStatus, UserID FROM Orders WHERE OrderID = ?")) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) throw new IllegalStateException("Đơn hàng không tồn tại");
                    if (rs.getInt("UserID") != userId) throw new SecurityException("Không có quyền hủy đơn này");
                    String st = rs.getString("OrderStatus");
                    if (!"PENDING".equals(st) && !"CONFIRMED".equals(st))
                        throw new IllegalStateException("Không thể hủy đơn ở trạng thái " + st);
                }
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE Orders SET OrderStatus='CANCELLED', CancelReason=?, CancelledAt=DATEADD(HOUR,7,GETUTCDATE()) WHERE OrderID=?")) {
                ps.setNString(1, reason);
                ps.setInt(2, orderId);
                return ps.executeUpdate();
            }
        }
    }

    @Override
    public int requestCancelOrder(int orderId, int userId, String reason) throws Exception {
        try (Connection con = Database.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT OrderStatus, UserID FROM Orders WHERE OrderID = ?")) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) throw new IllegalStateException("Đơn hàng không tồn tại");
                    if (rs.getInt("UserID") != userId) throw new SecurityException("Không có quyền hủy đơn này");
                    String st = rs.getString("OrderStatus");
                    if (!"PENDING".equals(st) && !"CONFIRMED".equals(st))
                        throw new IllegalStateException("Không thể hủy đơn ở trạng thái " + st);
                }
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE Orders SET OrderStatus='PENDING_CANCEL', CancelReason=? WHERE OrderID=?")) {
                ps.setNString(1, reason);
                ps.setInt(2, orderId);
                return ps.executeUpdate();
            }
        }
    }

    @Override
    public int approveCancelOrder(int orderId) throws Exception {
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Orders SET OrderStatus='CANCELLED', CancelledAt=DATEADD(HOUR,7,GETUTCDATE()) " +
                     "WHERE OrderID=? AND OrderStatus NOT IN ('DONE','CANCELLED','SHIPPING')")) {
            ps.setInt(1, orderId);
            return ps.executeUpdate();
        }
    }

    @Override
    public int rejectCancelOrder(int orderId) throws Exception {
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Orders SET OrderStatus='CONFIRMED', CancelReason=NULL WHERE OrderID=? AND OrderStatus='PENDING_CANCEL'")) {
            ps.setInt(1, orderId);
            return ps.executeUpdate();
        }
    }

    @Override
    public boolean assignHandler(int orderId, int staffId) {
        String sql = "UPDATE Orders SET HandledBy = ? WHERE OrderID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("OrderID"));
        int uid = rs.getInt("UserID");
        o.setUserId(rs.wasNull() ? null : uid);
        o.setCustomerName(rs.getNString("CustomerName"));
        o.setPhoneNumber(rs.getString("PhoneNumber"));
        o.setShippingAddress(rs.getNString("ShippingAddress"));
        o.setOrderNote(rs.getNString("OrderNote"));
        o.setTotalAmount(rs.getBigDecimal("TotalAmount"));
        o.setShippingFee(rs.getBigDecimal("ShippingFee"));
        o.setFinalAmount(rs.getBigDecimal("FinalAmount"));
        o.setPaymentMethod(rs.getString("PaymentMethod"));
        o.setOrderStatus(rs.getString("OrderStatus"));
        o.setCreatedAt(rs.getTimestamp("CreatedAt"));
        int handledBy = rs.getInt("HandledBy");
        o.setHandledBy(rs.wasNull() ? null : handledBy);
        o.setHandledByName(rs.getNString("HandledByName"));
        o.setCancelReason(rs.getNString("CancelReason"));
        o.setCancelledAt(rs.getTimestamp("CancelledAt"));
        o.setCouponCode(rs.getString("CouponCode"));
        return o;
    }
}
