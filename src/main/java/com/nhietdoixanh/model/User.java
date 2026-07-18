package com.nhietdoixanh.model;

import java.util.Date;

public class User {
    private int userId;
    private String fullName;
    private String email;
    private String phone;
    private String passwordHash;
    private String role; // CUSTOMER | ADMIN
    private Date createdAt;
    private String lastLoginIP;
    private Date lastLoginAt;
    private Date agreedTermsAt;
    private String profileImage;
    private String nickname;
    private Date updatedAt;

    public User() {}

    public User(String fullName, String email, String phone, String passwordHash, String role) {
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.passwordHash = passwordHash;
        this.role = role;
    }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public String getLastLoginIP() { return lastLoginIP; }
    public void setLastLoginIP(String lastLoginIP) { this.lastLoginIP = lastLoginIP; }

    public Date getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(Date lastLoginAt) { this.lastLoginAt = lastLoginAt; }

    public Date getAgreedTermsAt() { return agreedTermsAt; }
    public void setAgreedTermsAt(Date agreedTermsAt) { this.agreedTermsAt = agreedTermsAt; }

    public String getProfileImage() { return profileImage; }
    public void setProfileImage(String profileImage) { this.profileImage = profileImage; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public Date getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Date updatedAt) { this.updatedAt = updatedAt; }
}
