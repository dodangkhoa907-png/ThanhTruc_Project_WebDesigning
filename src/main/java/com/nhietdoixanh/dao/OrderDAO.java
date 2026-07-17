package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.CartItem;
import com.nhietdoixanh.model.Order;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * THAY THẾ interface OrderDAO cũ (đơn giản, không giỏ hàng/tài khoản).
 * Đơn hàng giờ đi qua giỏ hàng + checkout (xem OrderDaoImpl, CheckoutController).
 */
public interface OrderDAO {
    /**
     * Đặt hàng theo Transaction: lưu Order + OrderDetails, xóa CartItems (nếu có).
     * @return OrderID nếu thành công
     */
    int placeOrder(Order order, List<CartItem> cartItems) throws Exception;

    /** Admin: tất cả đơn hàng (kèm tên người xử lý). */
    List<Order> findAllOrders();

    List<Order> findAllOrdersPaged(int offset, int limit);

    int countOrders();

    /** Admin: chi tiết đơn hàng (gồm items). */
    Order findOrderById(int orderId);

    /** Khách hàng: lịch sử đơn hàng của tài khoản mình. */
    List<Order> findOrdersByUserId(int userId);

    int updateOrderStatus(int orderId, String status);

    /** Khách hàng: hủy ngay nếu đơn còn PENDING/CONFIRMED. */
    int cancelOrder(int orderId, int userId, String reason) throws Exception;

    /** Khách hàng chuyển khoản: gửi yêu cầu hủy → PENDING_CANCEL. */
    int requestCancelOrder(int orderId, int userId, String reason) throws Exception;

    /** Admin duyệt hủy → CANCELLED. */
    int approveCancelOrder(int orderId) throws Exception;

    /** Admin từ chối hủy → CONFIRMED. */
    int rejectCancelOrder(int orderId) throws Exception;

    /** Admin: phân công nhân viên xử lý đơn (Staffs.StaffID). */
    boolean assignHandler(int orderId, int staffId);

    /** Khách hàng: xem chi tiết đơn của chính mình — kiểm tra ownership trong SQL. */
    Optional<Order> findByIdAndUserId(int orderId, int userId);

    /** Khách hàng: chi tiết các dòng sản phẩm của đơn, chỉ khi đơn thuộc về mình. */
    List<com.nhietdoixanh.model.OrderDetail> findDetailsByOrderIdAndUserId(int orderId, int userId);

    int countOrdersByUserId(int userId);

    int countDoneOrdersByUserId(int userId);

    int countProcessingOrdersByUserId(int userId);

    BigDecimal sumDoneAmountByUserId(int userId);

    List<Order> findOrdersByUserIdPaged(int userId, int offset, int limit);

    List<Order> adminFindOrdersPaged(String statusFilter, int offset, int limit);

    /** Cập nhật trạng thái đơn có kiểm tra transition hợp lệ qua {@link com.nhietdoixanh.util.OrderStatuses#canTransition}. */
    boolean updateStatusWithValidation(int orderId, String newStatus) throws Exception;
}
