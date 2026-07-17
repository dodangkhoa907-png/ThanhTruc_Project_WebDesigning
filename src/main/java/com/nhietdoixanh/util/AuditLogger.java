package com.nhietdoixanh.util;

import com.nhietdoixanh.dao.AuditLogDao;
import com.nhietdoixanh.dao.impl.AuditLogDaoImpl;
import com.nhietdoixanh.model.AuditLog;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Tiện ích ghi nhật ký hành động quản trị.
 * Non-fatal: mọi lỗi được nuốt để không ảnh hưởng luồng nghiệp vụ.
 */
public final class AuditLogger {

    private static final AuditLogDao DAO = new AuditLogDaoImpl();

    private AuditLogger() {}

    public static void log(HttpServletRequest req, Integer staffId, String action, String target, String detail) {
        try {
            AuditLog log = new AuditLog();
            log.setStaffId(staffId);
            log.setAction(action);
            log.setTarget(target);
            log.setDetail(detail);
            log.setIpAddress(clientIp(req));
            DAO.insert(log);
        } catch (Exception e) {
            System.err.println("[AuditLogger] " + e.getMessage());
        }
    }

    private static String clientIp(HttpServletRequest req) {
        if (req == null) return null;
        String xff = req.getHeader("X-Forwarded-For");
        if (xff != null && !xff.isBlank()) return xff.split(",")[0].trim();
        return req.getRemoteAddr();
    }
}
