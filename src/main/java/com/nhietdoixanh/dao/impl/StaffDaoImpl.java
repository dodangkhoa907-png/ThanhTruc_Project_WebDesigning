package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.StaffDao;
import com.nhietdoixanh.model.Staff;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class StaffDaoImpl implements StaffDao {

    @Override
    public Optional<Staff> findByUsername(String username) {
        String sql = "SELECT * FROM Staffs WHERE Username = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("[StaffDao] findByUsername: " + e.getMessage());
        }
        return Optional.empty();
    }

    @Override
    public Optional<Staff> findById(int staffId) {
        String sql = "SELECT * FROM Staffs WHERE StaffID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, staffId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("[StaffDao] findById: " + e.getMessage());
        }
        return Optional.empty();
    }

    @Override
    public List<Staff> findAll() {
        List<Staff> list = new ArrayList<>();
        String sql = "SELECT * FROM Staffs ORDER BY FullName";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("[StaffDao] findAll: " + e.getMessage());
        }
        return list;
    }

    @Override
    public boolean updatePassword(int staffId, String newPasswordHash) {
        String sql = "UPDATE Staffs SET PasswordHash = ? WHERE StaffID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, staffId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[StaffDao] updatePassword: " + e.getMessage());
            return false;
        }
    }

    private Staff map(ResultSet rs) throws SQLException {
        Staff s = new Staff();
        s.setStaffId(rs.getInt("StaffID"));
        s.setUsername(rs.getString("Username"));
        s.setPasswordHash(rs.getString("PasswordHash"));
        s.setFullName(rs.getNString("FullName"));
        s.setRole(rs.getString("Role"));
        s.setActive(rs.getBoolean("IsActive"));
        return s;
    }
}
