package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.CartItem;
import com.nhietdoixanh.model.CartLineItemDto;
import java.util.List;
import java.util.Optional;

public interface CartItemDao {
    int insertOrUpdate(int userId, int variantId, int quantity);
    List<CartItem> findByUserId(int userId);
    void updateQuantity(int cartItemId, int userId, int quantity);
    int countItems(int userId);
    void delete(int cartItemId, int userId);
    void clearCart(int userId);

    /** Alias rõ nghĩa hơn cho insertOrUpdate — dùng cho "Thêm vào giỏ". */
    default int addOrIncrease(int userId, int variantId, int quantity) {
        return insertOrUpdate(userId, variantId, quantity);
    }

    /** Kiểm tra ownership: chỉ trả về item nếu thuộc đúng userId. */
    Optional<CartItem> findByIdAndUserId(int cartItemId, int userId);

    /**
     * Lấy các dòng giỏ hàng đã CHỌN để checkout một phần (không phải toàn bộ giỏ).
     * Chỉ trả về item thuộc đúng userId — chống IDOR khi FE gửi ID của user khác.
     */
    List<CartItem> findSelectedByIdsAndUserId(List<Integer> cartItemIds, int userId);

    /** Xóa các dòng giỏ hàng đã chọn (sau khi đặt hàng thành công) — KHÔNG xóa toàn bộ giỏ. */
    void deleteSelectedByUserId(List<Integer> cartItemIds, int userId);

    /** Alias rõ nghĩa hơn cho countItems. */
    default int countItemsByUserId(int userId) {
        return countItems(userId);
    }

    /**
     * Danh sách đầy đủ cho trang /cart — JOIN Products + Categories + ProductVariants,
     * gồm cả trạng thái active của product/variant để cảnh báo hàng ngừng bán.
     */
    List<CartLineItemDto> findLineItemsByUserId(int userId);

    /** Ownership + validate: chỉ update nếu item thuộc đúng userId. Trả false nếu không tìm thấy. */
    boolean updateQuantityChecked(int cartItemId, int userId, int quantity);

    /** Ownership: chỉ xóa nếu item thuộc đúng userId. Trả false nếu không tìm thấy/không thuộc user. */
    boolean deleteByIdAndUserId(int cartItemId, int userId);

    /** Như deleteSelectedByUserId nhưng trả về SỐ DÒNG thực sự đã xóa (chỉ tính item thuộc user). */
    int deleteSelectedByUserIdCounted(List<Integer> cartItemIds, int userId);

    /**
     * Alias rõ nghĩa cho countItems/countItemsByUserId — badge navbar toàn dự án tính theo
     * TỔNG SỐ LƯỢNG (SUM Quantity), KHÔNG phải số dòng CartItem. Giữ nhất quán ở mọi nơi gọi.
     */
    default int countQuantityByUserId(int userId) {
        return countItems(userId);
    }
}
