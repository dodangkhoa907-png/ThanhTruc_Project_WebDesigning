package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.CartItem;
import java.util.List;

public interface CartItemDao {
    int insertOrUpdate(int userId, int variantId, int quantity);
    List<CartItem> findByUserId(int userId);
    void updateQuantity(int cartItemId, int userId, int quantity);
    int countItems(int userId);
    void delete(int cartItemId, int userId);
    void clearCart(int userId);
}
