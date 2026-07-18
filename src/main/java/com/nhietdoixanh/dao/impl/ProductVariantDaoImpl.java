package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.ProductVariantDao;
import com.nhietdoixanh.model.ProductVariant;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ProductVariantDaoImpl implements ProductVariantDao {

    private static final String BASE_SELECT =
            "SELECT v.VariantID, v.ProductID, v.Size, v.Price, v.IsActive, p.ProductName, p.ImageURL " +
            "FROM ProductVariants v JOIN Products p ON v.ProductID = p.ProductID ";

    @Override
    public List<ProductVariant> findByProductId(int productId) {
        List<ProductVariant> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE v.ProductID = ? ORDER BY v.Price";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductVariantDao.findByProductId thất bại", e);
        }
        return list;
    }

    @Override
    public Optional<ProductVariant> findById(int variantId) {
        String sql = BASE_SELECT + "WHERE v.VariantID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductVariantDao.findById thất bại", e);
        }
        return Optional.empty();
    }

    @Override
    public int insert(ProductVariant v) {
        String sql = "INSERT INTO ProductVariants (ProductID, Size, Price, IsActive) VALUES (?,?,?,?)";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, v.getProductId());
            ps.setString(2, v.getSize());
            ps.setBigDecimal(3, v.getPrice());
            ps.setBoolean(4, v.isActive());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductVariantDao.insert thất bại", e);
        }
        return -1;
    }

    @Override
    public boolean update(ProductVariant v) {
        String sql = "UPDATE ProductVariants SET Size=?, Price=? WHERE VariantID=?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, v.getSize());
            ps.setBigDecimal(2, v.getPrice());
            ps.setInt(3, v.getVariantId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductVariantDao.update thất bại", e);
        }
    }

    @Override
    public boolean setActive(int variantId, boolean active) {
        String sql = "UPDATE ProductVariants SET IsActive = ? WHERE VariantID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, variantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductVariantDao.setActive thất bại", e);
        }
    }

    @Override
    public boolean delete(int variantId) {
        String sql = "DELETE FROM ProductVariants WHERE VariantID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductVariantDao.delete thất bại", e);
        }
    }

    private ProductVariant mapRow(ResultSet rs) throws SQLException {
        ProductVariant v = new ProductVariant();
        v.setVariantId(rs.getInt("VariantID"));
        v.setProductId(rs.getInt("ProductID"));
        v.setSize(rs.getString("Size"));
        v.setPrice(rs.getBigDecimal("Price"));
        v.setActive(rs.getBoolean("IsActive"));
        v.setProductName(rs.getNString("ProductName"));
        v.setImageUrl(rs.getString("ImageURL"));
        return v;
    }
}
