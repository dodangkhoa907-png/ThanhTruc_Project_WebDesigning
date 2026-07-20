package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.config.DbRetry;
import com.nhietdoixanh.dao.CategoryDao;
import com.nhietdoixanh.model.Category;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class CategoryDaoImpl implements CategoryDao {

    private static final String SQL_FIND_ALL =
            "SELECT CategoryID, CategoryName, IsActive FROM Categories WHERE IsActive = 1 ORDER BY CategoryName";

    private static final String SQL_FIND_BY_ID =
            "SELECT CategoryID, CategoryName, IsActive FROM Categories WHERE CategoryID = ?";

    @Override
    public List<Category> findAll() {
        // Load cùng lúc với danh sách sản phẩm ở /san-pham — retry 1 lần nếu gặp lỗi kết nối
        // thoáng qua (xem DbRetry), tránh khách bị lỗi trang chỉ vì mạng chập chờn tới DB ở xa.
        return DbRetry.read(() -> {
            List<Category> list = new ArrayList<>();
            try (Connection con = Database.getConnection();
                 PreparedStatement ps = con.prepareStatement(SQL_FIND_ALL);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            } catch (SQLException e) {
                throw new RuntimeException("CategoryDao.findAll thất bại", e);
            }
            return list;
        });
    }

    @Override
    public Optional<Category> findById(int id) {
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(SQL_FIND_BY_ID)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("CategoryDao.findById thất bại: " + id, e);
        }
        return Optional.empty();
    }

    private Category mapRow(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setCategoryId(rs.getInt("CategoryID"));
        c.setName(rs.getNString("CategoryName"));
        c.setActive(rs.getBoolean("IsActive"));
        return c;
    }
}
