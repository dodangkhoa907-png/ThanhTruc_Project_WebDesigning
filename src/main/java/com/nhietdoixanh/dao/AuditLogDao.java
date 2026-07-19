package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.AuditLog;
import com.nhietdoixanh.model.AuditLogFilter;
import java.util.List;

public interface AuditLogDao {
    boolean insert(AuditLog log);
    List<AuditLog> findRecent(int limit);

    /** Nhật ký gắn với một đối tượng cụ thể (vd. "Order#4"), cũ nhất trước — dùng dựng timeline. */
    List<AuditLog> findByTarget(String target);

    /** Tìm kiếm/lọc nhật ký có phân trang cho /admin/nhat-ky, mới nhất trước. */
    List<AuditLog> searchPaged(AuditLogFilter filter, int offset, int limit);

    /** Đếm tổng số bản ghi khớp bộ lọc — dùng tính tổng số trang. */
    int countSearch(AuditLogFilter filter);
}
