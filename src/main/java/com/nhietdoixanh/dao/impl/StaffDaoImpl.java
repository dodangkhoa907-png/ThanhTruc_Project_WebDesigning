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

    @Override
    public boolean existsByUsername(String username) {
        String sql = "SELECT 1 FROM Staffs WHERE Username = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new RuntimeException("StaffDao.existsByUsername thất bại", e);
        }
    }

    @Override
    public int insert(Staff s) {
        String sql = "INSERT INTO Staffs (Username, PasswordHash, FullName, Role, IsActive) VALUES (?,?,?,?,?)";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, s.getUsername());
            ps.setString(2, s.getPasswordHash());
            ps.setNString(3, s.getFullName());
            ps.setString(4, s.getRole());
            ps.setBoolean(5, s.isActive());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("StaffDao.insert thất bại", e);
        }
        return -1;
    }

    @Override
    public boolean update(Staff s) {
        String sql = "UPDATE Staffs SET FullName = ?, Role = ? WHERE StaffID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setNString(1, s.getFullName());
            ps.setString(2, s.getRole());
            ps.setInt(3, s.getStaffId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("StaffDao.update thất bại", e);
        }
    }

    @Override
    public boolean setActive(int staffId, boolean active) {
        String sql = "UPDATE Staffs SET IsActive = ? WHERE StaffID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, staffId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("StaffDao.setActive thất bại", e);
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
