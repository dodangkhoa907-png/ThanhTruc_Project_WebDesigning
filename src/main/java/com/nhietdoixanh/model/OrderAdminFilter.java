package com.nhietdoixanh.model;

import java.time.LocalDate;

/**
 * Tiêu chí lọc/tìm kiếm đơn hàng phía admin (/admin/don-hang).
 * Chỉ mang dữ liệu — việc build SQL nằm trong OrderDaoImpl.
 */
public class OrderAdminFilter {
    private String keyword;
    private String orderStatus;
    private String paymentStatus;
    private String paymentMethod;
    private LocalDate fromDate;
    private LocalDate toDate;
    /** Chỉ có ý nghĩa khi orderStatus=DONE: null = không lọc, TRUE = đã đối soát, FALSE = chờ xác nhận. */
    private Boolean receivedConfirmed;

    public String getKeyword() { return keyword; }
    public void setKeyword(String keyword) { this.keyword = keyword; }

    public String getOrderStatus() { return orderStatus; }
    public void setOrderStatus(String orderStatus) { this.orderStatus = orderStatus; }

    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }

    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }

    public LocalDate getFromDate() { return fromDate; }
    public void setFromDate(LocalDate fromDate) { this.fromDate = fromDate; }

    public LocalDate getToDate() { return toDate; }
    public void setToDate(LocalDate toDate) { this.toDate = toDate; }

    public Boolean getReceivedConfirmed() { return receivedConfirmed; }
    public void setReceivedConfirmed(Boolean receivedConfirmed) { this.receivedConfirmed = receivedConfirmed; }
}
