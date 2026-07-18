package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.ProductDao;
import com.nhietdoixanh.model.Product;
import com.nhietdoixanh.model.ProductVariant;
import com.nhietdoixanh.util.ProductSort;

import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class ProductDaoImpl implements ProductDao {

    private static final String BASE_SELECT =
            "SELECT p.ProductID, p.CategoryID, p.ProductName, p.ImageURL, p.Description, p.IsActive, " +
            "c.CategoryName " +
            "FROM Products p LEFT JOIN Categories c ON p.CategoryID = c.CategoryID ";

    /** Giá thấp nhất trong các variant active — dùng để sort theo giá (Products không có cột giá). */
    private static final String MIN_PRICE_SUBQUERY =
            "(SELECT MIN(v.Price) FROM ProductVariants v WHERE v.ProductID = p.ProductID AND v.IsActive = 1)";

    @Override
    public List<Product> findAllActive() {
        List<Product> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE p.IsActive = 1 ORDER BY p.ProductName";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.findAllActive thất bại", e);
        }
        attachVariants(list);
        return list;
    }

    @Override
    public List<Product> findByCategoryId(int categoryId) {
        List<Product> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE p.IsActive = 1 AND p.CategoryID = ? ORDER BY p.ProductName";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.findByCategoryId thất bại", e);
        }
        attachVariants(list);
        return list;
    }

    @Override
    public Optional<Product> findById(int productId) {
        String sql = BASE_SELECT + "WHERE p.ProductID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = mapRow(rs);
                    p.setVariants(loadVariants(con, p.getProductId()));
                    return Optional.of(p);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.findById thất bại: " + productId, e);
        }
        return Optional.empty();
    }

    @Override
    public Optional<Product> findActiveById(int productId) {
        String sql = BASE_SELECT + "WHERE p.ProductID = ? AND p.IsActive = 1";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Product p = mapRow(rs);
                    p.setVariants(loadVariants(con, p.getProductId()));
                    return Optional.of(p);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.findActiveById thất bại: " + productId, e);
        }
        return Optional.empty();
    }

    @Override
    public List<Product> findActiveForShop(Integer categoryId, String keyword, ProductSort sort) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT).append("WHERE p.IsActive = 1 ");

        boolean hasCategory = categoryId != null;
        boolean hasKeyword = keyword != null && !keyword.isBlank();

        if (hasCategory) sql.append("AND p.CategoryID = ? ");
        if (hasKeyword) sql.append("AND p.ProductName LIKE ? ");

        ProductSort effectiveSort = sort != null ? sort : ProductSort.DEFAULT;
        switch (effectiveSort) {
            case PRICE_ASC -> sql.append("ORDER BY ").append(MIN_PRICE_SUBQUERY).append(" ASC, p.ProductName");
            case PRICE_DESC -> sql.append("ORDER BY ").append(MIN_PRICE_SUBQUERY).append(" DESC, p.ProductName");
            case NAME_ASC -> sql.append("ORDER BY p.ProductName ASC");
            default -> sql.append("ORDER BY p.ProductID DESC");
        }

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (hasCategory) ps.setInt(idx++, categoryId);
            if (hasKeyword) ps.setNString(idx, "%" + keyword.trim() + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.findActiveForShop thất bại", e);
        }
        attachVariants(list);
        return list;
    }

    @Override
    public List<Product> search(String keyword) {
        List<Product> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE p.IsActive = 1 AND p.ProductName LIKE ? ORDER BY p.ProductName";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setNString(1, "%" + keyword + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.search thất bại", e);
        }
        attachVariants(list);
        return list;
    }

    @Override
    public List<Product> findAllForAdmin() {
        List<Product> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY p.ProductID DESC";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.findAllForAdmin thất bại", e);
        }
        attachVariants(list);
        return list;
    }

    @Override
    public int insert(Product p) {
        String sql = "INSERT INTO Products (CategoryID, ProductName, ImageURL, Description, IsActive) VALUES (?,?,?,?,?)";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, p.getCategoryId());
            ps.setNString(2, p.getName());
            ps.setString(3, p.getImageUrl());
            ps.setNString(4, p.getDescription());
            ps.setBoolean(5, p.isActive());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.insert thất bại", e);
        }
        return -1;
    }

    @Override
    public boolean update(Product p) {
        String sql = "UPDATE Products SET CategoryID=?, ProductName=?, ImageURL=?, Description=? WHERE ProductID=?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, p.getCategoryId());
            ps.setNString(2, p.getName());
            ps.setString(3, p.getImageUrl());
            ps.setNString(4, p.getDescription());
            ps.setInt(5, p.getProductId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.update thất bại", e);
        }
    }

    @Override
    public boolean setActive(int productId, boolean active) {
        String sql = "UPDATE Products SET IsActive = ? WHERE ProductID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.setActive thất bại", e);
        }
    }

    @Override
    public boolean existsByName(String name, Integer excludeId) {
        String sql = "SELECT 1 FROM Products WHERE ProductName = ?" + (excludeId != null ? " AND ProductID <> ?" : "");
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setNString(1, name);
            if (excludeId != null) ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.existsByName thất bại", e);
        }
    }

    private void attachVariants(List<Product> products) {
        if (products.isEmpty()) return;
        try (Connection con = Database.getConnection()) {
            for (Product p : products) {
                p.setVariants(loadVariants(con, p.getProductId()));
            }
        } catch (SQLException e) {
            throw new RuntimeException("ProductDao.attachVariants thất bại", e);
        }
    }

    private List<ProductVariant> loadVariants(Connection con, int productId) throws SQLException {
        List<ProductVariant> variants = new ArrayList<>();
        String sql = "SELECT VariantID, ProductID, Size, Price, IsActive FROM ProductVariants " +
                     "WHERE ProductID = ? AND IsActive = 1 ORDER BY Price";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ProductVariant v = new ProductVariant();
                    v.setVariantId(rs.getInt("VariantID"));
                    v.setProductId(rs.getInt("ProductID"));
                    v.setSize(rs.getString("Size"));
                    v.setPrice(rs.getBigDecimal("Price"));
                    v.setActive(rs.getBoolean("IsActive"));
                    variants.add(v);
                }
            }
        }
        return variants;
    }

    private Product mapRow(ResultSet rs) throws SQLException {
        Product p = new Product();
        p.setProductId(rs.getInt("ProductID"));
        int catId = rs.getInt("CategoryID");
        p.setCategoryId(rs.wasNull() ? 0 : catId);
        p.setName(rs.getNString("ProductName"));
        p.setImageUrl(rs.getString("ImageURL"));
        p.setDescription(rs.getNString("Description"));
        p.setActive(rs.getBoolean("IsActive"));
        p.setCategoryName(rs.getNString("CategoryName"));
        return p;
    }
}
