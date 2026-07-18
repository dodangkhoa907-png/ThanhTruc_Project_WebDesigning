package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.model.CartItem;
import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.model.OrderAdminFilter;
import com.nhietdoixanh.model.OrderDetail;

import java.math.BigDecimal;
import java.security.SecureRandom;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class OrderDaoImpl implements OrderDAO {

    private static final String LIST_SELECT =
            "SELECT o.*, s.FullName AS HandledByName " +
            "FROM Orders o LEFT JOIN Staffs s ON o.HandledBy = s.StaffID ";

    private static final String ADMIN_SEARCH_SELECT =
            "SELECT o.*, s.FullName AS HandledByName, u.Email AS CustomerEmail " +
            "FROM Orders o " +
            "LEFT JOIN Staffs s ON o.HandledBy = s.StaffID " +
            "LEFT JOIN Users u ON o.UserID = u.UserID ";

    @Override
    public int placeOrder(Order order, List<CartItem> cartItems) throws Exception {
        if (cartItems == null || cartItems.isEmpty()) {
            throw new IllegalArgumentException("Đơn hàng phải có ít nhất một sản phẩm");
        }
        if (order.getFinalAmount() == null || order.getFinalAmount().signum() <= 0) {
            throw new IllegalArgumentException("Giá trị đơn hàng không hợp lệ");
        }

        Connection conn = null;
        int orderId = 0;
        try {
            conn = Database.getConnection();
            conn.setAutoCommit(false);

            String sqlOrder = "INSERT INTO Orders (UserID, CustomerName, PhoneNumber, ShippingAddress, OrderNote, " +
                    "TotalAmount, ShippingFee, FinalAmount, PaymentMethod, OrderStatus, CouponCode, " +
                    "RecipientName, RecipientPhone, ShippingLatitude, ShippingLongitude, StatusUpdatedAt) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING', ?, ?, ?, ?, ?, SYSDATETIME())";
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
                psOrder.setNString(11, order.getRecipientName());
                psOrder.setString(12, order.getRecipientPhone());
                psOrder.setBigDecimal(13, order.getShippingLatitude());
                psOrder.setBigDecimal(14, order.getShippingLongitude());
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

            // Chỉ xóa các dòng giỏ hàng THỰC SỰ đã đặt (checkout một phần vẫn giữ lại phần chưa chọn).
            // KHÔNG xóa toàn bộ giỏ hàng theo UserID — đó là hành vi nguy hiểm đã bị loại bỏ.
            if (order.getUserId() != null && !cartItems.isEmpty()) {
                String placeholders = String.join(",", java.util.Collections.nCopies(cartItems.size(), "?"));
                String sqlDeleteCart = "DELETE FROM CartItems WHERE UserID = ? AND CartItemID IN (" + placeholders + ")";
                try (PreparedStatement psDeleteCart = conn.prepareStatement(sqlDeleteCart)) {
                    int idx = 1;
                    psDeleteCart.setInt(idx++, order.getUserId());
                    for (CartItem item : cartItems) {
                        psDeleteCart.setInt(idx++, item.getCartItemId());
                    }
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
        o.setPaymentStatus(rs.getString("PaymentStatus"));
        o.setStatusUpdatedAt(rs.getTimestamp("StatusUpdatedAt"));
        long payOSOrderCode = rs.getLong("PayOSOrderCode");
        o.setPayOSOrderCode(rs.wasNull() ? null : payOSOrderCode);
        o.setPayOSPaymentLinkId(rs.getString("PayOSPaymentLinkId"));
        o.setPayOSCheckoutUrl(rs.getString("PayOSCheckoutUrl"));
        o.setPaidAt(rs.getTimestamp("PaidAt"));
        o.setRecipientName(rs.getNString("RecipientName"));
        o.setRecipientPhone(rs.getString("RecipientPhone"));
        o.setShippingLatitude(rs.getBigDecimal("ShippingLatitude"));
        o.setShippingLongitude(rs.getBigDecimal("ShippingLongitude"));
        return o;
    }

    @Override
    public Optional<Order> findByIdAndUserId(int orderId, int userId) {
        String sql = LIST_SELECT + "WHERE o.OrderID = ? AND o.UserID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public List<OrderDetail> findDetailsByOrderIdAndUserId(int orderId, int userId) {
        List<OrderDetail> items = new ArrayList<>();
        String sqlOwnerCheck = "SELECT 1 FROM Orders WHERE OrderID = ? AND UserID = ?";
        String sqlItems = "SELECT od.*, p.ProductName, v.Size " +
                "FROM OrderDetails od " +
                "JOIN ProductVariants v ON od.VariantID = v.VariantID " +
                "JOIN Products p ON v.ProductID = p.ProductID " +
                "WHERE od.OrderID = ?";

        try (Connection con = Database.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sqlOwnerCheck)) {
                ps.setInt(1, orderId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return items;
                }
            }
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
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    @Override
    public int countOrdersByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE UserID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int countDoneOrdersByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE UserID = ? AND OrderStatus = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, com.nhietdoixanh.util.OrderStatuses.DONE);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int countProcessingOrdersByUserId(int userId) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE UserID = ? AND OrderStatus IN (?, ?, ?)";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, com.nhietdoixanh.util.OrderStatuses.CONFIRMED);
            ps.setString(3, com.nhietdoixanh.util.OrderStatuses.SHIPPING);
            ps.setString(4, com.nhietdoixanh.util.OrderStatuses.PENDING_CANCEL);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public BigDecimal sumDoneAmountByUserId(int userId) {
        String sql = "SELECT COALESCE(SUM(FinalAmount), 0) FROM Orders WHERE UserID = ? AND OrderStatus = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, com.nhietdoixanh.util.OrderStatuses.DONE);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    @Override
    public List<Order> findOrdersByUserIdPaged(int userId, int offset, int limit) {
        List<Order> list = new ArrayList<>();
        String sql = LIST_SELECT + "WHERE o.UserID = ? ORDER BY o.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Order> adminFindOrdersPaged(String statusFilter, int offset, int limit) {
        List<Order> list = new ArrayList<>();
        boolean hasFilter = statusFilter != null && !statusFilter.isBlank();
        String sql = LIST_SELECT + (hasFilter ? "WHERE o.OrderStatus = ? " : "")
                + "ORDER BY o.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = 1;
            if (hasFilter) ps.setString(idx++, statusFilter);
            ps.setInt(idx++, offset);
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean updateStatusWithValidation(int orderId, String newStatus) throws Exception {
        String normalizedNew = com.nhietdoixanh.util.OrderStatuses.normalize(newStatus);
        if (!com.nhietdoixanh.util.OrderStatuses.isValid(normalizedNew)) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ: " + newStatus);
        }
        try (Connection con = Database.getConnection()) {
            String currentStatus;
            try (PreparedStatement ps = con.prepareStatement("SELECT OrderStatus FROM Orders WHERE OrderID = ?")) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) throw new IllegalStateException("Đơn hàng không tồn tại");
                    currentStatus = rs.getString("OrderStatus");
                }
            }
            if (!com.nhietdoixanh.util.OrderStatuses.canTransition(currentStatus, normalizedNew)) {
                throw new IllegalStateException("Không thể chuyển trạng thái từ " + currentStatus + " sang " + normalizedNew);
            }
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE Orders SET OrderStatus = ?, StatusUpdatedAt = SYSDATETIME() WHERE OrderID = ?")) {
                ps.setString(1, normalizedNew);
                ps.setInt(2, orderId);
                return ps.executeUpdate() > 0;
            }
        }
    }

    private static final String PRODUCT_SUMMARY_SUBQUERY =
            "(SELECT STRING_AGG(p.ProductName + ' (' + v.Size + ')', ', ') " +
            "FROM OrderDetails od JOIN ProductVariants v ON od.VariantID = v.VariantID " +
            "JOIN Products p ON v.ProductID = p.ProductID WHERE od.OrderID = o.OrderID) AS ProductSummary";

    @Override
    public List<Order> findOrdersByUserIdFiltered(int userId, String orderStatus, Integer searchOrderId, int offset, int limit) {
        List<Order> list = new ArrayList<>();
        boolean hasStatus = orderStatus != null && !orderStatus.isBlank();
        StringBuilder sql = new StringBuilder("SELECT o.*, s.FullName AS HandledByName, ")
                .append(PRODUCT_SUMMARY_SUBQUERY)
                .append(" FROM Orders o LEFT JOIN Staffs s ON o.HandledBy = s.StaffID WHERE o.UserID = ? ");
        if (hasStatus) sql.append("AND o.OrderStatus = ? ");
        if (searchOrderId != null) sql.append("AND o.OrderID = ? ");
        sql.append("ORDER BY o.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, userId);
            if (hasStatus) ps.setString(idx++, orderStatus);
            if (searchOrderId != null) ps.setInt(idx++, searchOrderId);
            ps.setInt(idx++, offset);
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setProductSummary(rs.getNString("ProductSummary"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int countOrdersByUserIdFiltered(int userId, String orderStatus, Integer searchOrderId) {
        boolean hasStatus = orderStatus != null && !orderStatus.isBlank();
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Orders o WHERE o.UserID = ? ");
        if (hasStatus) sql.append("AND o.OrderStatus = ? ");
        if (searchOrderId != null) sql.append("AND o.OrderID = ? ");

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            ps.setInt(idx++, userId);
            if (hasStatus) ps.setString(idx++, orderStatus);
            if (searchOrderId != null) ps.setInt(idx, searchOrderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<Order> adminSearchOrders(OrderAdminFilter filter, int offset, int limit) {
        List<Order> list = new ArrayList<>();
        FilterSql f = buildAdminFilterSql(filter);
        String sql = ADMIN_SEARCH_SELECT + f.whereClause + "ORDER BY o.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = bindFilterParams(ps, f.params);
            ps.setInt(idx++, offset);
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setUserEmail(rs.getString("CustomerEmail"));
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int countAdminSearchOrders(OrderAdminFilter filter) {
        FilterSql f = buildAdminFilterSql(filter);
        String sql = "SELECT COUNT(*) FROM Orders o LEFT JOIN Users u ON o.UserID = u.UserID " + f.whereClause;
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            bindFilterParams(ps, f.params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int adminCancelOrder(int orderId, String reason) throws Exception {
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE Orders SET OrderStatus='CANCELLED', CancelReason=?, " +
                     "CancelledAt=DATEADD(HOUR,7,GETUTCDATE()), StatusUpdatedAt=SYSDATETIME() " +
                     "WHERE OrderID=? AND OrderStatus IN ('PENDING','CONFIRMED')")) {
            ps.setNString(1, reason);
            ps.setInt(2, orderId);
            return ps.executeUpdate();
        }
    }

    /** Kết quả build WHERE cho tìm kiếm admin: mệnh đề SQL (rỗng nếu không filter) + tham số theo đúng thứ tự. */
    private static final class FilterSql {
        final String whereClause;
        final List<Object> params;
        FilterSql(String whereClause, List<Object> params) {
            this.whereClause = whereClause;
            this.params = params;
        }
    }

    private FilterSql buildAdminFilterSql(OrderAdminFilter filter) {
        List<String> clauses = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (filter != null) {
            String keyword = filter.getKeyword();
            if (keyword != null && !keyword.isBlank()) {
                clauses.add("(CAST(o.OrderID AS NVARCHAR(20)) LIKE ? OR o.RecipientName LIKE ? OR o.CustomerName LIKE ? " +
                        "OR o.RecipientPhone LIKE ? OR o.PhoneNumber LIKE ? OR u.Email LIKE ?)");
                String kw = "%" + keyword.trim() + "%";
                for (int i = 0; i < 6; i++) params.add(kw);
            }
            if (filter.getOrderStatus() != null && !filter.getOrderStatus().isBlank()) {
                clauses.add("o.OrderStatus = ?");
                params.add(com.nhietdoixanh.util.OrderStatuses.normalize(filter.getOrderStatus()));
            }
            if (filter.getPaymentStatus() != null && !filter.getPaymentStatus().isBlank()) {
                clauses.add("o.PaymentStatus = ?");
                params.add(filter.getPaymentStatus());
            }
            if (filter.getPaymentMethod() != null && !filter.getPaymentMethod().isBlank()) {
                clauses.add("o.PaymentMethod = ?");
                params.add(filter.getPaymentMethod());
            }
            if (filter.getFromDate() != null) {
                clauses.add("o.CreatedAt >= ?");
                params.add(Timestamp.valueOf(filter.getFromDate().atStartOfDay()));
            }
            if (filter.getToDate() != null) {
                clauses.add("o.CreatedAt < ?");
                params.add(Timestamp.valueOf(filter.getToDate().plusDays(1).atStartOfDay()));
            }
        }

        String where = clauses.isEmpty() ? "" : "WHERE " + String.join(" AND ", clauses) + " ";
        return new FilterSql(where, params);
    }

    private int bindFilterParams(PreparedStatement ps, List<Object> params) throws SQLException {
        int idx = 1;
        for (Object p : params) {
            if (p instanceof Timestamp t) ps.setTimestamp(idx++, t);
            else ps.setNString(idx++, String.valueOf(p));
        }
        return idx;
    }

    // =========================================================================================
    // PayOS
    // =========================================================================================

    private static final SecureRandom PAYOS_RANDOM = new SecureRandom();

    @Override
    public int placeOrderPayOS(Order order, List<CartItem> cartItems) throws Exception {
        if (cartItems == null || cartItems.isEmpty()) {
            throw new IllegalArgumentException("Đơn hàng phải có ít nhất một sản phẩm");
        }
        if (order.getFinalAmount() == null || order.getFinalAmount().signum() <= 0) {
            throw new IllegalArgumentException("Giá trị đơn hàng không hợp lệ");
        }
        if (order.getUserId() == null) {
            throw new IllegalArgumentException("Đơn PayOS bắt buộc phải gắn với tài khoản đã đăng nhập");
        }

        Connection conn = null;
        int orderId = 0;
        try {
            conn = Database.getConnection();
            conn.setAutoCommit(false);

            long payOSOrderCode = generateUniquePayOSOrderCode(conn);

            String sqlOrder = "INSERT INTO Orders (UserID, CustomerName, PhoneNumber, ShippingAddress, OrderNote, " +
                    "TotalAmount, ShippingFee, FinalAmount, PaymentMethod, OrderStatus, PaymentStatus, CouponCode, " +
                    "RecipientName, RecipientPhone, ShippingLatitude, ShippingLongitude, PayOSOrderCode, StatusUpdatedAt) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PAYOS', 'PENDING', 'PENDING', ?, ?, ?, ?, ?, ?, SYSDATETIME())";
            try (PreparedStatement psOrder = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                psOrder.setInt(1, order.getUserId());
                psOrder.setNString(2, order.getCustomerName());
                psOrder.setString(3, order.getPhoneNumber());
                psOrder.setNString(4, order.getShippingAddress());
                psOrder.setNString(5, order.getOrderNote());
                psOrder.setBigDecimal(6, order.getTotalAmount());
                psOrder.setBigDecimal(7, order.getShippingFee());
                psOrder.setBigDecimal(8, order.getFinalAmount());
                psOrder.setString(9, order.getCouponCode());
                psOrder.setNString(10, order.getRecipientName());
                psOrder.setString(11, order.getRecipientPhone());
                psOrder.setBigDecimal(12, order.getShippingLatitude());
                psOrder.setBigDecimal(13, order.getShippingLongitude());
                psOrder.setLong(14, payOSOrderCode);
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

            // Ghi mapping CartItemID -> OrderID để webhook PAID biết cần xóa đúng dòng nào —
            // KHÔNG xóa CartItems ở đây, chỉ xóa sau khi PayOS xác nhận thanh toán thành công.
            String sqlMapping = "INSERT INTO OrderCartItems (OrderID, UserID, CartItemID) VALUES (?, ?, ?)";
            try (PreparedStatement psMapping = conn.prepareStatement(sqlMapping)) {
                for (CartItem item : cartItems) {
                    psMapping.setInt(1, orderId);
                    psMapping.setInt(2, order.getUserId());
                    psMapping.setInt(3, item.getCartItemId());
                    psMapping.addBatch();
                }
                psMapping.executeBatch();
            }

            order.setOrderId(orderId);
            order.setPayOSOrderCode(payOSOrderCode);
            order.setPaymentStatus(com.nhietdoixanh.util.PaymentStatuses.PENDING);

            conn.commit();
            return orderId;
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            throw e;
        } finally {
            if (conn != null) { conn.setAutoCommit(true); conn.close(); }
        }
    }

    /** Sinh PayOSOrderCode duy nhất: mốc mili-giây + random 0-999, kiểm tra tồn tại trước khi dùng. */
    private long generateUniquePayOSOrderCode(Connection conn) throws SQLException {
        for (int attempt = 0; attempt < 10; attempt++) {
            long candidate = System.currentTimeMillis() * 1000L + PAYOS_RANDOM.nextInt(1000);
            try (PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM Orders WHERE PayOSOrderCode = ?")) {
                ps.setLong(1, candidate);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return candidate;
                }
            }
        }
        throw new SQLException("Không thể sinh PayOSOrderCode duy nhất sau nhiều lần thử");
    }

    @Override
    public void attachPayOSPaymentLink(int orderId, String paymentLinkId, String checkoutUrl) throws Exception {
        String sql = "UPDATE Orders SET PayOSPaymentLinkId = ?, PayOSCheckoutUrl = ? WHERE OrderID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, paymentLinkId);
            ps.setString(2, checkoutUrl);
            ps.setInt(3, orderId);
            ps.executeUpdate();
        }
    }

    @Override
    public void markPayOSLinkFailed(int orderId) throws Exception {
        // Điều kiện WHERE PaymentStatus = 'PENDING' — không ghi đè nếu webhook đã chạy trước
        // (race hiếm: webhook PAID tới trước khi request tạo link kịp nhận response lỗi).
        String sql = "UPDATE Orders SET PaymentStatus = ?, StatusUpdatedAt = SYSDATETIME() " +
                "WHERE OrderID = ? AND PaymentStatus = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, com.nhietdoixanh.util.PaymentStatuses.FAILED);
            ps.setInt(2, orderId);
            ps.setString(3, com.nhietdoixanh.util.PaymentStatuses.PENDING);
            ps.executeUpdate();
        }
    }

    @Override
    public Optional<Order> findByPayOSOrderCode(long payOSOrderCode) {
        String sql = LIST_SELECT + "WHERE o.PayOSOrderCode = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, payOSOrderCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return Optional.empty();
    }

    @Override
    public boolean markPaidByPayOSOrderCode(long payOSOrderCode) throws Exception {
        Connection conn = null;
        try {
            conn = Database.getConnection();
            conn.setAutoCommit(false);

            int orderId = 0;
            int userId = 0;
            // UPDATE có điều kiện WHERE PaymentStatus <> 'PAID' — atomic, idempotent: nếu webhook
            // được gọi lại (retry của PayOS), lần thứ 2 trở đi sẽ không khớp điều kiện và no-op.
            String sqlUpdate = "UPDATE Orders SET PaymentStatus = 'PAID', PaidAt = SYSDATETIME(), " +
                    "StatusUpdatedAt = SYSDATETIME() " +
                    "OUTPUT INSERTED.OrderID, INSERTED.UserID " +
                    "WHERE PayOSOrderCode = ? AND PaymentStatus <> 'PAID'";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setLong(1, payOSOrderCode);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        orderId = rs.getInt("OrderID");
                        userId = rs.getInt("UserID");
                    } else {
                        conn.rollback();
                        return false; // Không tìm thấy đơn, hoặc đã PAID từ trước — idempotent no-op.
                    }
                }
            }

            // Xóa ĐÚNG các CartItems thuộc mapping của đơn này — không đụng tới các dòng khác
            // trong giỏ hàng của cùng user (checkout một phần vẫn giữ lại phần chưa chọn).
            String sqlDeleteCart = "DELETE ci FROM CartItems ci " +
                    "JOIN OrderCartItems oci ON oci.CartItemID = ci.CartItemID AND oci.UserID = ci.UserID " +
                    "WHERE oci.OrderID = ? AND oci.UserID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlDeleteCart)) {
                ps.setInt(1, orderId);
                ps.setInt(2, userId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            throw e;
        } finally {
            if (conn != null) { conn.setAutoCommit(true); conn.close(); }
        }
    }

    @Override
    public boolean markNonSuccessByPayOSOrderCode(long payOSOrderCode, String newPaymentStatus) throws Exception {
        // Điều kiện WHERE PaymentStatus = 'PENDING' — không bao giờ ghi đè PAID/CANCELLED đã có.
        String sql = "UPDATE Orders SET PaymentStatus = ?, StatusUpdatedAt = SYSDATETIME() " +
                "WHERE PayOSOrderCode = ? AND PaymentStatus = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newPaymentStatus);
            ps.setLong(2, payOSOrderCode);
            ps.setString(3, com.nhietdoixanh.util.PaymentStatuses.PENDING);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean cancelPayOSPendingByOrderIdAndUserId(int orderId, int userId) throws Exception {
        String sql = "UPDATE Orders SET PaymentStatus = 'CANCELLED', StatusUpdatedAt = SYSDATETIME() " +
                "WHERE OrderID = ? AND UserID = ? AND PaymentMethod = 'PAYOS' AND PaymentStatus = 'PENDING'";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        }
    }
}
