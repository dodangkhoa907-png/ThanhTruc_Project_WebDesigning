package com.nhietdoixanh.model;

import java.time.LocalDate;

/**
 * Tiêu chí lọc/tìm kiếm nhật ký hành động phía admin (/admin/nhat-ky).
 * Chỉ mang dữ liệu — việc build SQL nằm trong AuditLogDaoImpl.
 */
public class AuditLogFilter {
    private String keyword;
    private Integer staffId;
    private LocalDate fromDate;
    private LocalDate toDate;

    public String getKeyword() { return keyword; }
    public void setKeyword(String keyword) { this.keyword = keyword; }

    public Integer getStaffId() { return staffId; }
    public void setStaffId(Integer staffId) { this.staffId = staffId; }

    public LocalDate getFromDate() { return fromDate; }
    public void setFromDate(LocalDate fromDate) { this.fromDate = fromDate; }

    public LocalDate getToDate() { return toDate; }
    public void setToDate(LocalDate toDate) { this.toDate = toDate; }
}
