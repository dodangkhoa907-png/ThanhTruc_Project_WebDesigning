package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.FeedbackDao;
import com.nhietdoixanh.model.Feedback;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDaoImpl implements FeedbackDao {

    @Override
    public int insert(Feedback fb) {
        String sql = "INSERT INTO Feedback (UserID, Name, Phone, Email, Rating, Message, Status) VALUES (?, ?, ?, ?, ?, ?, 'NEW')";
        try (Connection conn = Database.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            if (fb.getUserId() != null) ps.setInt(1, fb.getUserId()); else ps.setNull(1, Types.INTEGER);
            ps.setNString(2, fb.getName());
            ps.setString(3, fb.getPhone());
            ps.setString(4, fb.getEmail());
            if (fb.getRating() != null) ps.setInt(5, fb.getRating()); else ps.setNull(5, Types.INTEGER);
            ps.setNString(6, fb.getMessage());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<Feedback> findAll() {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT * FROM Feedback ORDER BY CreatedAt DESC";
        try (Connection conn = Database.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Feedback> findAllPaged(int offset, int limit) {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT * FROM Feedback ORDER BY CreatedAt DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection conn = Database.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, offset);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Feedback> findPublic(int limit) {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT TOP (?) * FROM Feedback WHERE Status = 'RESOLVED' AND Rating IS NOT NULL ORDER BY CreatedAt DESC";
        try (Connection conn = Database.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Feedback WHERE Status = ?";
        try (Connection conn = Database.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int countAll() {
        String sql = "SELECT COUNT(*) FROM Feedback";
        try (Connection conn = Database.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int updateStatus(int feedbackId, String status) {
        String sql = "UPDATE Feedback SET Status = ? WHERE FeedbackID = ?";
        try (Connection conn = Database.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, feedbackId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Feedback map(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setFeedbackId(rs.getInt("FeedbackID"));
        int uid = rs.getInt("UserID");
        f.setUserId(rs.wasNull() ? null : uid);
        f.setName(rs.getNString("Name"));
        f.setPhone(rs.getString("Phone"));
        f.setEmail(rs.getString("Email"));
        int rating = rs.getInt("Rating");
        f.setRating(rs.wasNull() ? null : rating);
        f.setMessage(rs.getNString("Message"));
        f.setStatus(rs.getString("Status"));
        f.setCreatedAt(rs.getTimestamp("CreatedAt"));
        return f;
    }
}
