package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.AuditLogDao;
import com.nhietdoixanh.model.AuditLog;
import com.nhietdoixanh.model.AuditLogFilter;

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
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[AuditLog] Không đọc được log: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<AuditLog> findByTarget(String target) {
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT a.*, s.FullName AS StaffName " +
                     "FROM AuditLogs a LEFT JOIN Staffs s ON a.StaffID = s.StaffID " +
                     "WHERE a.Target = ? ORDER BY a.CreatedAt ASC";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setNString(1, target);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[AuditLog] Không đọc được log theo target: " + e.getMessage());
        }
        return list;
    }

    @Override
    public List<AuditLog> searchPaged(AuditLogFilter filter, int offset, int limit) {
        List<AuditLog> list = new ArrayList<>();
        FilterSql f = buildFilterSql(filter);
        String sql = "SELECT a.*, s.FullName AS StaffName " +
                     "FROM AuditLogs a LEFT JOIN Staffs s ON a.StaffID = s.StaffID "
                     + f.whereClause + "ORDER BY a.CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int idx = bindFilterParams(ps, f.params);
            ps.setInt(idx++, offset);
            ps.setInt(idx, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("[AuditLog] Không tìm kiếm được log: " + e.getMessage());
        }
        return list;
    }

    @Override
    public int countSearch(AuditLogFilter filter) {
        FilterSql f = buildFilterSql(filter);
        String sql = "SELECT COUNT(*) FROM AuditLogs a LEFT JOIN Staffs s ON a.StaffID = s.StaffID " + f.whereClause;
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            bindFilterParams(ps, f.params);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[AuditLog] Không đếm được log: " + e.getMessage());
        }
        return 0;
    }

    private AuditLog mapRow(ResultSet rs) throws SQLException {
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
        return a;
    }

    /** Kết quả build WHERE cho tìm kiếm nhật ký: mệnh đề SQL (rỗng nếu không filter) + tham số theo đúng thứ tự. */
    private static final class FilterSql {
        final String whereClause;
        final List<Object> params;
        FilterSql(String whereClause, List<Object> params) {
            this.whereClause = whereClause;
            this.params = params;
        }
    }

    private FilterSql buildFilterSql(AuditLogFilter filter) {
        List<String> clauses = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        if (filter != null) {
            String keyword = filter.getKeyword();
            if (keyword != null && !keyword.isBlank()) {
                clauses.add("(a.Action LIKE ? OR a.Target LIKE ? OR a.Detail LIKE ?)");
                String kw = "%" + keyword.trim() + "%";
                for (int i = 0; i < 3; i++) params.add(kw);
            }
            if (filter.getStaffId() != null) {
                clauses.add("a.StaffID = ?");
                params.add(filter.getStaffId());
            }
            if (filter.getFromDate() != null) {
                clauses.add("a.CreatedAt >= ?");
                params.add(Timestamp.valueOf(filter.getFromDate().atStartOfDay()));
            }
            if (filter.getToDate() != null) {
                clauses.add("a.CreatedAt < ?");
                params.add(Timestamp.valueOf(filter.getToDate().plusDays(1).atStartOfDay()));
            }
        }

        String where = clauses.isEmpty() ? "" : "WHERE " + String.join(" AND ", clauses) + " ";
        return new FilterSql(where, params);
    }

    private int bindFilterParams(PreparedStatement ps, List<Object> params) throws SQLException {
        int idx = 1;
        for (Object p : params) {
            if (p instanceof Timestamp t) ps.setTimestamp(idx++, t);
            else if (p instanceof Integer i) ps.setInt(idx++, i);
            else ps.setNString(idx++, String.valueOf(p));
        }
        return idx;
    }
}
