package com.nhietdoixanh.model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Snapshot các CartItemID khách đã chọn để thanh toán — lưu vào session key
 * "checkoutSelection" ở POST /checkout/prepare, đọc lại ở bước /checkout (prompt sau).
 *
 * KHÔNG lưu tổng tiền/giá ở đây — nguồn sự thật luôn là DB, đọc lại qua
 * CartItemDao.findSelectedByIdsAndUserId khi thực sự tạo Order.
 */
public class CheckoutSelection implements Serializable {

    private static final long serialVersionUID = 1L;

    public static final int TTL_MINUTES = 20;

    private final int userId;
    private final List<Integer> cartItemIds;
    private final LocalDateTime createdAt;
    private final LocalDateTime expiresAt;

    public CheckoutSelection(int userId, List<Integer> cartItemIds, LocalDateTime createdAt) {
        this.userId = userId;
        this.cartItemIds = List.copyOf(cartItemIds);
        this.createdAt = createdAt;
        this.expiresAt = createdAt.plusMinutes(TTL_MINUTES);
    }

    public int getUserId() { return userId; }

    public List<Integer> getCartItemIds() { return cartItemIds; }

    public LocalDateTime getCreatedAt() { return createdAt; }

    public LocalDateTime getExpiresAt() { return expiresAt; }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(expiresAt);
    }

    public boolean belongsTo(int userId) {
        return this.userId == userId;
    }

    /** Hợp lệ để dùng cho bước checkout: đúng user, chưa hết hạn, còn ít nhất 1 item. */
    public boolean isUsableBy(int userId) {
        return belongsTo(userId) && !isExpired() && !cartItemIds.isEmpty();
    }
}
