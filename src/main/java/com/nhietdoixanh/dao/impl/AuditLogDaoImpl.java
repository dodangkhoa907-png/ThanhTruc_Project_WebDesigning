package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.AuditLogDao;
import com.nhietdoixanh.model.AuditLog;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AuditLogDaoImpl implements AuditLogDao {

    @Override
    public boolean insert(AuditLog log) {
        String sql = "INSERT INTO AuditLogs (StaffID, Action, Target, Detail, IpAddress) VALUES (?,?,?,?,?)";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (log.getStaffId() == null) ps.setNull(1, Types.INTEGER); else ps.setInt(1, log.getStaffId());
            ps.setNString(2, log.getAction());
            ps.setNString(3, log.getTarget());
            ps.setNString(4, log.getDetail());
            ps.setString(5, log.getIpAddress());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[AuditLog] Không ghi được log: " + e.getMessage());
            return false;
        }
    }

    @Override
    public List<AuditLog> findRecent(int limit) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT TOP (?) a.*, s.FullName AS StaffName " +
                     "FROM AuditLogs a LEFT JOIN Staffs s ON a.StaffID = s.StaffID " +
                     "ORDER BY a.CreatedAt DESC";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog a = new AuditLog();
                    a.setLogId(rs.getInt("LogID"));
                    int sid = rs.getInt("StaffID");
                    a.setStaffId(rs.wasNull() ? null : sid);
                    a.setStaffName(rs.getNString("StaffName"));
                    a.setAction(rs.getNString("Action"));
                    a.setTarget(rs.getNString("Target"));
                    a.setDetail(rs.getNString("Detail"));
                    a.setIpAddress(rs.getString("IpAddress"));
                    a.setCreatedAt(rs.getTimestamp("CreatedAt"));
                    list.add(a);
                }
            }
        } catch (SQLException e) {
            System.err.println("[AuditLog] Không đọc được log: " + e.getMessage());
        }
        return list;
    }
}
