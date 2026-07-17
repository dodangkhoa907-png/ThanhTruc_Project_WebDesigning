package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.AuditLog;
import java.util.List;

public interface AuditLogDao {
    boolean insert(AuditLog log);
    List<AuditLog> findRecent(int limit);
}
