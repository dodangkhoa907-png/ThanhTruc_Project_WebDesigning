package com.nhietdoixanh.model;

import java.math.BigDecimal;

/** Dòng chi tiết đơn hàng — ánh xạ bảng OrderDetails. */
public class OrderDetail {
    private int orderDetailId;
    private int orderId;
    private int variantId;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal subTotal;

    // Bổ sung cho UI
    private String productName;
    private String size;

    public OrderDetail() {}

    public int getOrderDetailId() { return orderDetailId; }
    public void setOrderDetailId(int orderDetailId) { this.orderDetailId = orderDetailId; }

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public int getVariantId() { return variantId; }
    public void setVariantId(int variantId) { this.variantId = variantId; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public BigDecimal getUnitPrice() { return unitPrice; }
    public void setUnitPrice(BigDecimal unitPrice) { this.unitPrice = unitPrice; }

    public BigDecimal getSubTotal() { return subTotal; }
    public void setSubTotal(BigDecimal subTotal) { this.subTotal = subTotal; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getSize() { return size; }
    public void setSize(String size) { this.size = size; }
}
