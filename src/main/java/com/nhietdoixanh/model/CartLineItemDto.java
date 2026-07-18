package com.nhietdoixanh.model;

import java.math.BigDecimal;
import java.text.DecimalFormat;

/**
 * DTO hiển thị đầy đủ 1 dòng giỏ hàng cho trang /cart — JOIN CartItems +
 * ProductVariants + Products + Categories. Tách khỏi {@link CartItem} (entity
 * gọn cho các thao tác insert/update) để không làm CartItem rối thêm field
 * chỉ dùng cho UI.
 */
public class CartLineItemDto {
    private int cartItemId;
    private int productId;
    private int variantId;
    private String productName;
    private String imageUrl;
    private String categoryName;
    private String size;
    private BigDecimal unitPrice;
    private int quantity;
    private boolean productActive;
    private boolean variantActive;

    public CartLineItemDto() {}

    public int getCartItemId() { return cartItemId; }
    public void setCartItemId(int cartItemId) { this.cartItemId = cartItemId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getVariantId() { return variantId; }
    public void setVariantId(int variantId) { this.variantId = variantId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public boolean isProductActive() { return productActive; }
    public void setProductActive(boolean productActive) { this.productActive = productActive; }

    public boolean isVariantActive() { return variantActive; }
    public void setVariantActive(boolean variantActive) { this.variantActive = variantActive; }

    /** true nếu sản phẩm hoặc biến thể đã ngừng bán — không được phép chọn để checkout. */
    public boolean isUnavailable() {
        return !productActive || !variantActive;
    }

    public BigDecimal getSubtotal() {
        if (unitPrice == null) return BigDecimal.ZERO;
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }

    public String getSizeLabel() {
        if ("L".equalsIgnoreCase(size)) return "Size L";
        if ("M".equalsIgnoreCase(size)) return "Size M";
        return size;
    }

    public String getFormattedUnitPrice() {
        return formatVnd(unitPrice);
    }

    public String getFormattedSubtotal() {
        return formatVnd(getSubtotal());
    }

    private String formatVnd(BigDecimal value) {
        if (value == null) return "0";
        DecimalFormat df = new DecimalFormat("#,###");
        return df.format(value).replace(',', '.');
    }
}
