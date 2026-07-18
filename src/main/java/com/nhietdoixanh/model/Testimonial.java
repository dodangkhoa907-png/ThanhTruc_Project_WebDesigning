package com.nhietdoixanh.model;

import java.time.LocalDateTime;

/**
 * Model đại diện cho một Phản Hồi Khách Hàng (Testimonial).
 * Mapping với bảng Testimonials trong database BanNuoc.
 */
public class Testimonial {

    private int testimonialId;
    private String customerName;
    private String drinkName;
    private int rating;
    private String avatarUrl;
    private String feedbackText;
    private LocalDateTime createdDate;

    // ===== Constructors =====

    public Testimonial() {
    }

    public Testimonial(String customerName, String drinkName, int rating, String avatarUrl, String feedbackText) {
        this.customerName = customerName;
        this.drinkName = drinkName;
        this.rating = rating;
        this.avatarUrl = avatarUrl;
        this.feedbackText = feedbackText;
        this.createdDate = LocalDateTime.now();
    }

    public Testimonial(int testimonialId, String customerName, String drinkName, int rating, 
                       String avatarUrl, String feedbackText, LocalDateTime createdDate) {
        this.testimonialId = testimonialId;
        this.customerName = customerName;
        this.drinkName = drinkName;
        this.rating = rating;
        this.avatarUrl = avatarUrl;
        this.feedbackText = feedbackText;
        this.createdDate = createdDate;
    }

    // ===== Getters & Setters =====

    public int getTestimonialId() {
        return testimonialId;
    }

    public void setTestimonialId(int testimonialId) {
        this.testimonialId = testimonialId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getDrinkName() {
        return drinkName;
    }

    public void setDrinkName(String drinkName) {
        this.drinkName = drinkName;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getFeedbackText() {
        return feedbackText;
    }

    public void setFeedbackText(String feedbackText) {
        this.feedbackText = feedbackText;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    // ===== JSON Serialization Helper =====

    /**
     * Chuyển đổi đối tượng Testimonial thành chuỗi JSON tự tạo để trả về cho AJAX.
     * Tránh việc import thêm thư viện JSON bên ngoài.
     */
    public String toJson() {
        return "{"
                + "\"id\":" + testimonialId + ","
                + "\"name\":\"" + escapeJson(customerName) + "\","
                + "\"drink\":\"" + escapeJson(drinkName) + "\","
                + "\"rating\":" + rating + ","
                + "\"text\":\"" + escapeJson(feedbackText) + "\","
                + "\"avatar\":\"" + escapeJson(avatarUrl != null ? avatarUrl : "") + "\""
                + "}";
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    @Override
    public String toString() {
        return "Testimonial{" +
                "testimonialId=" + testimonialId +
                ", customerName='" + customerName + '\'' +
                ", drinkName='" + drinkName + '\'' +
                ", rating=" + rating +
                ", avatarUrl='" + avatarUrl + '\'' +
                ", feedbackText='" + feedbackText + '\'' +
                ", createdDate=" + createdDate +
                '}';
    }
}
