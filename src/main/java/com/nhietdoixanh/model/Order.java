package com.nhietdoixanh.model;

import java.time.LocalDateTime;

/**
 * Model đại diện cho một Đơn hàng (Order).
 * Mapping với bảng Orders trong database BanNuoc.
 */
public class Order {

    private int orderId;
    private String customerName;
    private String phoneNumber;
    private String shippingAddress;
    private String orderNote;
    private LocalDateTime orderDate;

    // ===== Constructors =====

    public Order() {
    }

    public Order(String customerName, String phoneNumber, String shippingAddress, String orderNote) {
        this.customerName = customerName;
        this.phoneNumber = phoneNumber;
        this.shippingAddress = shippingAddress;
        this.orderNote = orderNote;
        this.orderDate = LocalDateTime.now();
    }

    public Order(int orderId, String customerName, String phoneNumber,
                 String shippingAddress, String orderNote, LocalDateTime orderDate) {
        this.orderId = orderId;
        this.customerName = customerName;
        this.phoneNumber = phoneNumber;
        this.shippingAddress = shippingAddress;
        this.orderNote = orderNote;
        this.orderDate = orderDate;
    }

    // ===== Getters & Setters =====

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public String getOrderNote() {
        return orderNote;
    }

    public void setOrderNote(String orderNote) {
        this.orderNote = orderNote;
    }

    public LocalDateTime getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(LocalDateTime orderDate) {
        this.orderDate = orderDate;
    }

    @Override
    public String toString() {
        return "Order{" +
                "orderId=" + orderId +
                ", customerName='" + customerName + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                ", shippingAddress='" + shippingAddress + '\'' +
                ", orderNote='" + orderNote + '\'' +
                ", orderDate=" + orderDate +
                '}';
    }
}

