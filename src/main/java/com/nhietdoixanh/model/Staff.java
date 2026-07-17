package com.nhietdoixanh.model;

/** Tài khoản nhân viên/quản trị — ánh xạ bảng Staffs có sẵn trong BanNuoc_Truc. */
public class Staff {
    private int staffId;
    private String username;
    private String passwordHash;
    private String fullName;
    private String role;      // MANAGER | DELIVERY | PROCESSOR | SALES ...
    private boolean active;

    public int getStaffId() { return staffId; }
    public void setStaffId(int staffId) { this.staffId = staffId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
