package com.nhietdoixanh.model;

import java.math.BigDecimal;

/** Một dòng doanh thu sản phẩm (đơn không hủy) — dùng tính cơ cấu doanh thu theo danh mục và top sản phẩm bán chạy trên dashboard admin. */
public class ProductRevenueRow {
    private String categoryName;
    private String productName;
    private int quantity;
    private BigDecimal subTotal;

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public BigDecimal getSubTotal() { return subTotal; }
    public void setSubTotal(BigDecimal subTotal) { this.subTotal = subTotal; }
}
