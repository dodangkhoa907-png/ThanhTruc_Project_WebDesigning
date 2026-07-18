package com.nhietdoixanh.model;

import java.util.Date;

/** Phản hồi khách hàng — ánh xạ bảng Feedback (thay thế widget Testimonials cũ). */
public class Feedback {
    private int feedbackId;
    private Integer userId;   // null nếu khách vãng lai
    private String name;
    private String phone;
    private String email;
    private Integer rating;   // 1..5, null nếu không đánh giá
    private String message;
    private String status;    // NEW | SEEN | RESOLVED
    private Date createdAt;

    public Feedback() {}

    public int getFeedbackId() { return feedbackId; }
    public void setFeedbackId(int feedbackId) { this.feedbackId = feedbackId; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public Integer getRating() { return rating; }
    public void setRating(Integer rating) { this.rating = rating; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
