package com.nhietdoixanh.model;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.Date;

public class CartItem {
    private int cartItemId;
    private int userId;
    private int variantId;
    private int quantity;
    private Date createdAt;

    // Bổ sung cho UI (JOIN ProductVariants + Products)
    private String productName;
    private String size;
    private BigDecimal price;
    private String imageUrl;
    private boolean variantActive;

    public CartItem() {}

    public int getCartItemId() { return cartItemId; }
    public void setCartItemId(int cartItemId) { this.cartItemId = cartItemId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getVariantId() { return variantId; }
    public void setVariantId(int variantId) { this.variantId = variantId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public boolean isVariantActive() { return variantActive; }
    public void setVariantActive(boolean variantActive) { this.variantActive = variantActive; }

    public BigDecimal getTotalPrice() {
        if (price != null) {
            return price.multiply(new BigDecimal(quantity));
        }
        return BigDecimal.ZERO;
    }

    public String getFormattedTotalPrice() {
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(getTotalPrice()).replace(',', '.');
    }

    public String getFormattedPrice() {
        if (price == null) return "0";
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(price).replace(',', '.');
    }
}
