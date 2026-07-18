package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.UserAddressDao;
import com.nhietdoixanh.model.UserAddress;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class UserAddressDaoImpl implements UserAddressDao {

    @Override
    public List<UserAddress> findByUserId(int userId) {
        List<UserAddress> list = new ArrayList<>();
        String sql = "SELECT * FROM UserAddresses WHERE UserID = ? ORDER BY IsDefault DESC, CreatedAt DESC";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDao.findByUserId failed", e);
        }
        return list;
    }

    @Override
    public int insert(UserAddress a) {
        String sql = "INSERT INTO UserAddresses " +
                "(UserID,Label,RecipientName,Phone,Street,IsDefault,ProvinceCity,District,Ward,HouseNumberStreet,Latitude,Longitude) " +
                "VALUES (?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, a.getUserId());
            ps.setNString(2, a.getLabel());
            ps.setNString(3, a.getRecipientName());
            ps.setString(4, a.getPhone());
            ps.setNString(5, a.getStreet());
            ps.setBoolean(6, a.isDefault());
            ps.setNString(7, a.getProvinceCity());
            ps.setNString(8, a.getDistrict());
            ps.setNString(9, a.getWard());
            ps.setNString(10, a.getHouseNumberStreet());
            ps.setBigDecimal(11, a.getLatitude());
            ps.setBigDecimal(12, a.getLongitude());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDao.insert failed", e);
        }
        return -1;
    }

    @Override
    public boolean update(UserAddress a) {
        String sql = "UPDATE UserAddresses SET Label=?, RecipientName=?, Phone=?, Street=?, " +
                "ProvinceCity=?, District=?, Ward=?, HouseNumberStreet=?, Latitude=?, Longitude=?, UpdatedAt=SYSDATETIME() " +
                "WHERE AddressID=? AND UserID=?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setNString(1, a.getLabel());
            ps.setNString(2, a.getRecipientName());
            ps.setString(3, a.getPhone());
            ps.setNString(4, a.getStreet());
            ps.setNString(5, a.getProvinceCity());
            ps.setNString(6, a.getDistrict());
            ps.setNString(7, a.getWard());
            ps.setNString(8, a.getHouseNumberStreet());
            ps.setBigDecimal(9, a.getLatitude());
            ps.setBigDecimal(10, a.getLongitude());
            ps.setInt(11, a.getAddressId());
            ps.setInt(12, a.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDao.update failed", e);
        }
    }

    @Override
    public Optional<UserAddress> findDefaultByUserId(int userId) {
        String sql = "SELECT * FROM UserAddresses WHERE UserID = ? AND IsDefault = 1";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDao.findDefaultByUserId failed", e);
        }
        return Optional.empty();
    }

    @Override
    public Optional<UserAddress> findByIdAndUserId(int addressId, int userId) {
        String sql = "SELECT * FROM UserAddresses WHERE AddressID = ? AND UserID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, addressId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDao.findByIdAndUserId failed", e);
        }
        return Optional.empty();
    }

    @Override
    public boolean delete(int addressId, int userId) {
        String sql = "DELETE FROM UserAddresses WHERE AddressID = ? AND UserID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, addressId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("UserAddressDao.delete failed", e);
        }
    }

    @Override
    public boolean setDefault(int addressId, int userId) {
        Connection con = null;
        try {
            con = Database.getConnection();
            con.setAutoCommit(false);
            try (PreparedStatement resetPs = con.prepareStatement(
                    "UPDATE UserAddresses SET IsDefault = 0 WHERE UserID = ?")) {
                resetPs.setInt(1, userId);
                resetPs.executeUpdate();
            }
            int updated;
            try (PreparedStatement setPs = con.prepareStatement(
                    "UPDATE UserAddresses SET IsDefault = 1 WHERE AddressID = ? AND UserID = ?")) {
                setPs.setInt(1, addressId);
                setPs.setInt(2, userId);
                updated = setPs.executeUpdate();
            }
            con.commit();
            return updated > 0;
        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }
            throw new RuntimeException("UserAddressDao.setDefault failed", e);
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException closeEx) {
                    throw new RuntimeException("UserAddressDao.setDefault cleanup failed", closeEx);
                }
            }
        }
    }

    private UserAddress map(ResultSet rs) throws SQLException {
        UserAddress a = new UserAddress();
        a.setAddressId(rs.getInt("AddressID"));
        a.setUserId(rs.getInt("UserID"));
        a.setLabel(rs.getNString("Label"));
        a.setRecipientName(rs.getNString("RecipientName"));
        a.setPhone(rs.getString("Phone"));
        a.setStreet(rs.getNString("Street"));
        a.setDefault(rs.getBoolean("IsDefault"));
        a.setCreatedAt(rs.getTimestamp("CreatedAt"));
        a.setProvinceCity(rs.getNString("ProvinceCity"));
        a.setDistrict(rs.getNString("District"));
        a.setWard(rs.getNString("Ward"));
        a.setHouseNumberStreet(rs.getNString("HouseNumberStreet"));
        a.setLatitude(rs.getBigDecimal("Latitude"));
        a.setLongitude(rs.getBigDecimal("Longitude"));
        a.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return a;
    }
}
