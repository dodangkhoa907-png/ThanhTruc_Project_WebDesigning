package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.AuditLog;
import java.util.List;

public interface AuditLogDao {
    boolean insert(AuditLog log);
    List<AuditLog> findRecent(int limit);

    /** Nhật ký gắn với một đối tượng cụ thể (vd. "Order#4"), cũ nhất trước — dùng dựng timeline. */
    List<AuditLog> findByTarget(String target);
}
