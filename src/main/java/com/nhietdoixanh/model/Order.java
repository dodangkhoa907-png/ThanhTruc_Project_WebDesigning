package com.nhietdoixanh.model;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 * Ánh xạ bảng dbo.Orders. Hỗ trợ cả đơn khách vãng lai (UserID null) lẫn
 * đơn của tài khoản đã đăng nhập.
 */
public class Order {
    private int orderId;
    private Integer userId;         // null = khách vãng lai
    private String customerName;
    private String phoneNumber;
    private String shippingAddress;
    private String orderNote;
    private BigDecimal totalAmount;
    private BigDecimal shippingFee;
    private BigDecimal finalAmount;
    private String paymentMethod;   // COD | BANK_TRANSFER
    private String orderStatus;     // PENDING | CONFIRMED | SHIPPING | DONE | CANCELLED | PENDING_CANCEL
    private Date createdAt;
    private Integer handledBy;      // FK Staffs.StaffID, null = chưa xử lý
    private String cancelReason;
    private Date cancelledAt;
    private String couponCode;

    // Bổ sung — thanh toán / PayOS (xem migration_ecommerce_account_v3.sql)
    private String paymentStatus;   // xem util.PaymentStatuses
    private Date statusUpdatedAt;
    private Long payOSOrderCode;
    private String payOSPaymentLinkId;
    private String payOSCheckoutUrl;
    private Date paidAt;

    // Bổ sung — giao hàng chi tiết
    private String recipientName;
    private String recipientPhone;
    private BigDecimal shippingLatitude;
    private BigDecimal shippingLongitude;

    // Bổ sung cho UI
    private String handledByName;
    private List<OrderDetail> items;

    public Order() {}

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getShippingAddress() { return shippingAddress; }
    public void setShippingAddress(String shippingAddress) { this.shippingAddress = shippingAddress; }

    public String getOrderNote() { return orderNote; }
    public void setOrderNote(String orderNote) { this.orderNote = orderNote; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public BigDecimal getShippingFee() { return shippingFee; }
    public void setShippingFee(BigDecimal shippingFee) { this.shippingFee = shippingFee; }

    public BigDecimal getFinalAmount() { return finalAmount; }
    public void setFinalAmount(BigDecimal finalAmount) { this.finalAmount = finalAmount; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public Integer getHandledBy() { return handledBy; }
    public void setHandledBy(Integer handledBy) { this.handledBy = handledBy; }

    public String getCancelReason() { return cancelReason; }
    public void setCancelReason(String cancelReason) { this.cancelReason = cancelReason; }

    public Date getCancelledAt() { return cancelledAt; }
    public void setCancelledAt(Date cancelledAt) { this.cancelledAt = cancelledAt; }

    public String getCouponCode() { return couponCode; }
    public void setCouponCode(String couponCode) { this.couponCode = couponCode; }

    public String getHandledByName() { return handledByName; }
    public void setHandledByName(String handledByName) { this.handledByName = handledByName; }

    public List<OrderDetail> getItems() { return items; }
    public void setItems(List<OrderDetail> items) { this.items = items; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public Date getStatusUpdatedAt() { return statusUpdatedAt; }
    public void setStatusUpdatedAt(Date statusUpdatedAt) { this.statusUpdatedAt = statusUpdatedAt; }

    public Long getPayOSOrderCode() { return payOSOrderCode; }
    public void setPayOSOrderCode(Long payOSOrderCode) { this.payOSOrderCode = payOSOrderCode; }

    public String getPayOSPaymentLinkId() { return payOSPaymentLinkId; }
    public void setPayOSPaymentLinkId(String payOSPaymentLinkId) { this.payOSPaymentLinkId = payOSPaymentLinkId; }

    public String getPayOSCheckoutUrl() { return payOSCheckoutUrl; }
    public void setPayOSCheckoutUrl(String payOSCheckoutUrl) { this.payOSCheckoutUrl = payOSCheckoutUrl; }

    public Date getPaidAt() { return paidAt; }
    public void setPaidAt(Date paidAt) { this.paidAt = paidAt; }

    public String getRecipientName() { return recipientName; }
    public void setRecipientName(String recipientName) { this.recipientName = recipientName; }

    public String getRecipientPhone() { return recipientPhone; }
    public void setRecipientPhone(String recipientPhone) { this.recipientPhone = recipientPhone; }

    public BigDecimal getShippingLatitude() { return shippingLatitude; }
    public void setShippingLatitude(BigDecimal shippingLatitude) { this.shippingLatitude = shippingLatitude; }

    public BigDecimal getShippingLongitude() { return shippingLongitude; }
    public void setShippingLongitude(BigDecimal shippingLongitude) { this.shippingLongitude = shippingLongitude; }
}
