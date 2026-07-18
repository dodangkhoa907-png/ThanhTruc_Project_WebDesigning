package com.nhietdoixanh.model;

import com.nhietdoixanh.util.Slugs;
import java.util.List;

/**
 * Ánh xạ bảng dbo.Products. Giá KHÔNG nằm ở đây — mỗi sản phẩm có nhiều
 * {@link ProductVariant} (size M/L) với giá riêng, xem bảng ProductVariants.
 */
public class Product {

    private int productId;
    private int categoryId;
    private String name;
    private String imageUrl;
    private String description;
    private boolean active;

    /** Populated khi JOIN Categories. */
    private String categoryName;
    /** Populated khi JOIN ProductVariants. */
    private List<ProductVariant> variants;

    public Product() { }

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public List<ProductVariant> getVariants() { return variants; }
    public void setVariants(List<ProductVariant> variants) { this.variants = variants; }

    /** Slug tạo động từ tên (bảng Products không lưu cột Slug riêng). */
    public String getSlug() {
        return Slugs.of(name) + "-" + productId;
    }

    /** Giá thấp nhất trong các size — dùng hiển thị "từ X đ" ở danh sách sản phẩm. */
    public java.math.BigDecimal getFromPrice() {
        if (variants == null || variants.isEmpty()) return java.math.BigDecimal.ZERO;
        return variants.stream()
                .map(ProductVariant::getPrice)
                .filter(java.util.Objects::nonNull)
                .min(java.math.BigDecimal::compareTo)
                .orElse(java.math.BigDecimal.ZERO);
    }
}
