package com.nhietdoixanh.model;

import com.nhietdoixanh.util.Slugs;

/** Danh mục sản phẩm — ánh xạ bảng Categories. */
public class Category {
    private int categoryId;
    private String name;
    private boolean active;

    public Category() { }

    public Category(int categoryId, String name) {
        this.categoryId = categoryId;
        this.name = name;
    }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    /** Slug tạo động từ tên (bảng Categories không lưu cột Slug riêng). */
    public String getSlug() {
        return Slugs.of(name);
    }
}
