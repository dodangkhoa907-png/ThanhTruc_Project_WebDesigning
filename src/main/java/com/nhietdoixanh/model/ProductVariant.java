package com.nhietdoixanh.model;

import java.math.BigDecimal;

/** Biến thể sản phẩm theo size (M/L) — ánh xạ bảng ProductVariants. */
public class ProductVariant {
    private int variantId;
    private int productId;
    private String size;       // M | L
    private BigDecimal price;
    private boolean active;

    /** Populated khi JOIN Products. */
    private String productName;
    private String imageUrl;

    public ProductVariant() { }

    public int getVariantId() { return variantId; }
    public void setVariantId(int variantId) { this.variantId = variantId; }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getFormattedPrice() {
        if (price == null) return "0";
        return String.format("%,.0f", price.doubleValue()).replace(',', '.');
    }

    public String getSizeLabel() {
        if ("L".equalsIgnoreCase(size)) return "Size L";
        if ("M".equalsIgnoreCase(size)) return "Size M";
        return size;
    }
}
