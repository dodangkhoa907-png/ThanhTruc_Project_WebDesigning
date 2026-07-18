package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.CartItem;
import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.model.OrderAdminFilter;

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

    /**
     * Khách hàng: lịch sử đơn có lọc trạng thái + tìm theo mã đơn, luôn ràng buộc UserID trong SQL.
     * @param orderStatus null/blank = không lọc trạng thái
     * @param searchOrderId null = không tìm theo mã đơn
     */
    List<Order> findOrdersByUserIdFiltered(int userId, String orderStatus, Integer searchOrderId, int offset, int limit);

    /** Đếm khớp {@link #findOrdersByUserIdFiltered} — dùng cho phân trang. */
    int countOrdersByUserIdFiltered(int userId, String orderStatus, Integer searchOrderId);

    List<Order> adminFindOrdersPaged(String statusFilter, int offset, int limit);

    /** Cập nhật trạng thái đơn có kiểm tra transition hợp lệ qua {@link com.nhietdoixanh.util.OrderStatuses#canTransition}. */
    boolean updateStatusWithValidation(int orderId, String newStatus) throws Exception;

    /** Admin: tìm kiếm/lọc đơn hàng có phân trang — filter và OFFSET/FETCH thực hiện trong SQL. */
    List<Order> adminSearchOrders(OrderAdminFilter filter, int offset, int limit);

    /** Admin: đếm số đơn khớp filter (dùng cho phân trang của {@link #adminSearchOrders}). */
    int countAdminSearchOrders(OrderAdminFilter filter);

    /**
     * Admin: hủy trực tiếp đơn còn PENDING/CONFIRMED (không qua yêu cầu hủy của khách).
     * UPDATE có điều kiện WHERE OrderStatus IN (...) để tránh race condition.
     * @return số dòng bị ảnh hưởng (0 nếu đơn không còn ở trạng thái cho phép hủy)
     */
    int adminCancelOrder(int orderId, String reason) throws Exception;

    // =========================================================================================
    // PayOS — xem OrderDaoImpl để biết chi tiết transaction/idempotency.
    // =========================================================================================

    /**
     * Đặt hàng PayOS: lưu Order (PaymentMethod=PAYOS, PaymentStatus=PENDING, PayOSOrderCode
     * unique tự sinh) + OrderDetails + mapping OrderCartItems — KHÔNG xóa CartItems (chỉ xóa
     * sau khi webhook xác nhận PAID, xem {@link #markPaidByPayOSOrderCode}).
     * @return OrderID nếu thành công
     */
    int placeOrderPayOS(Order order, List<CartItem> cartItems) throws Exception;

    /** Gắn kết quả tạo payment link (paymentLinkId/checkoutUrl) sau khi gọi PayOS API thành công. */
    void attachPayOSPaymentLink(int orderId, String paymentLinkId, String checkoutUrl) throws Exception;

    /** Đánh dấu PaymentStatus=FAILED khi gọi PayOS API tạo payment link thất bại (order đã commit trước đó). */
    void markPayOSLinkFailed(int orderId) throws Exception;

    /** Tra đơn theo PayOSOrderCode — dùng cho webhook/return/cancel. */
    Optional<Order> findByPayOSOrderCode(long payOSOrderCode);

    /**
     * Webhook xác nhận thanh toán thành công: UPDATE có điều kiện (chỉ khi chưa PAID) để
     * idempotent — gọi lại nhiều lần không gây lỗi. Nếu đây là lần đầu chuyển sang PAID,
     * đồng thời xóa các CartItems thuộc đúng mapping OrderCartItems của đơn này (KHÔNG xóa
     * toàn bộ giỏ hàng) trong cùng transaction.
     * @return true nếu lần gọi này thực sự chuyển trạng thái (lần đầu PAID), false nếu đã
     *         PAID từ trước hoặc không tìm thấy đơn.
     */
    boolean markPaidByPayOSOrderCode(long payOSOrderCode) throws Exception;

    /**
     * Webhook báo thất bại/hết hạn: UPDATE có điều kiện, CHỈ khi đơn còn PENDING (không bao
     * giờ ghi đè lên PAID/CANCELLED đã có trước đó). Không đụng tới CartItems.
     * @return true nếu có cập nhật
     */
    boolean markNonSuccessByPayOSOrderCode(long payOSOrderCode, String newPaymentStatus) throws Exception;

    /**
     * User bấm hủy trên trang Cancel URL: chỉ hủy nếu đơn thuộc đúng user và còn PENDING.
     * Không đụng tới CartItems (CartItems chưa từng bị xóa ở luồng PayOS cho tới khi PAID).
     * @return true nếu có cập nhật
     */
    boolean cancelPayOSPendingByOrderIdAndUserId(int orderId, int userId) throws Exception;
}
