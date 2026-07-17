package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.Testimonial;
import com.nhietdoixanh.util.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object cho bảng Testimonials.
 * Thực hiện các thao tác CRUD lên Database SQL Server.
 */
public class TestimonialDAO {

    /**
     * Lấy toàn bộ phản hồi từ database, sắp xếp theo thời gian tạo mới nhất.
     */
    public List<Testimonial> getAllTestimonials() {
        List<Testimonial> list = new ArrayList<>();
        String sql = "SELECT TestimonialId, CustomerName, DrinkName, Rating, AvatarUrl, FeedbackText, CreatedDate "
                   + "FROM Testimonials ORDER BY CreatedDate DESC, TestimonialId DESC";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                int id = rs.getInt("TestimonialId");
                String customerName = rs.getString("CustomerName");
                String drinkName = rs.getString("DrinkName");
                int rating = rs.getInt("Rating");
                String avatarUrl = rs.getString("AvatarUrl");
                String feedbackText = rs.getString("FeedbackText");
                
                Timestamp ts = rs.getTimestamp("CreatedDate");
                LocalDateTime createdDate = ts != null ? ts.toLocalDateTime() : LocalDateTime.now();

                list.add(new Testimonial(id, customerName, drinkName, rating, avatarUrl, feedbackText, createdDate));
            }

        } catch (SQLException e) {
            System.err.println("Lỗi khi truy vấn danh sách phản hồi: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Chèn một phản hồi mới vào database.
     */
    public boolean insertTestimonial(Testimonial t) {
        String sql = "INSERT INTO Testimonials (CustomerName, DrinkName, Rating, AvatarUrl, FeedbackText, CreatedDate) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, t.getCustomerName());
            ps.setString(2, t.getDrinkName());
            ps.setInt(3, t.getRating());
            ps.setString(4, t.getAvatarUrl());
            ps.setString(5, t.getFeedbackText());
            ps.setTimestamp(6, Timestamp.valueOf(
                    t.getCreatedDate() != null ? t.getCreatedDate() : LocalDateTime.now()
            ));

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Lỗi khi thêm phản hồi mới: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Cập nhật thông tin phản hồi đã tồn tại.
     */
    public boolean updateTestimonial(Testimonial t) {
        String sql = "UPDATE Testimonials SET CustomerName = ?, DrinkName = ?, Rating = ?, AvatarUrl = ?, FeedbackText = ? "
                   + "WHERE TestimonialId = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, t.getCustomerName());
            ps.setString(2, t.getDrinkName());
            ps.setInt(3, t.getRating());
            ps.setString(4, t.getAvatarUrl());
            ps.setString(5, t.getFeedbackText());
            ps.setInt(6, t.getTestimonialId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Lỗi khi cập nhật phản hồi: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Xóa một phản hồi ra khỏi database.
     */
    public boolean deleteTestimonial(int id) {
        String sql = "DELETE FROM Testimonials WHERE TestimonialId = ?";

        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Lỗi khi xóa phản hồi: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
