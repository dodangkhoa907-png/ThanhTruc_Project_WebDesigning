package com.nhietdoixanh.dao.impl;

import com.nhietdoixanh.config.Database;
import com.nhietdoixanh.dao.UserPreferencesDao;
import com.nhietdoixanh.model.UserPreferences;

import java.sql.*;
import java.util.Optional;

public class UserPreferencesDaoImpl implements UserPreferencesDao {

    @Override
    public Optional<UserPreferences> findByUserId(int userId) {
        String sql = "SELECT * FROM UserPreferences WHERE UserID = ?";
        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("UserPreferencesDao.findByUserId failed", e);
        }
        return Optional.empty();
    }

    @Override
    public boolean upsertByUserId(UserPreferences prefs) {
        String mergeSql =
                "MERGE INTO UserPreferences AS target " +
                "USING (SELECT ? AS UserID) AS src ON target.UserID = src.UserID " +
                "WHEN MATCHED THEN UPDATE SET " +
                "  PlantInterests = ?, DecorStyles = ?, SpaceType = ?, CareLevel = ?, Notes = ?, UpdatedAt = SYSDATETIME() " +
                "WHEN NOT MATCHED THEN INSERT (UserID, PlantInterests, DecorStyles, SpaceType, CareLevel, Notes, UpdatedAt) " +
                "  VALUES (src.UserID, ?, ?, ?, ?, ?, SYSDATETIME());";

        try (Connection con = Database.getConnection();
             PreparedStatement ps = con.prepareStatement(mergeSql)) {
            ps.setInt(1, prefs.getUserId());
            ps.setNString(2, prefs.getPlantInterests());
            ps.setNString(3, prefs.getDecorStyles());
            ps.setNString(4, prefs.getSpaceType());
            ps.setNString(5, prefs.getCareLevel());
            ps.setNString(6, prefs.getNotes());
            ps.setNString(7, prefs.getPlantInterests());
            ps.setNString(8, prefs.getDecorStyles());
            ps.setNString(9, prefs.getSpaceType());
            ps.setNString(10, prefs.getCareLevel());
            ps.setNString(11, prefs.getNotes());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("UserPreferencesDao.upsertByUserId failed", e);
        }
    }

    private UserPreferences map(ResultSet rs) throws SQLException {
        UserPreferences p = new UserPreferences();
        p.setPreferenceId(rs.getInt("PreferenceID"));
        p.setUserId(rs.getInt("UserID"));
        p.setPlantInterests(rs.getNString("PlantInterests"));
        p.setDecorStyles(rs.getNString("DecorStyles"));
        p.setSpaceType(rs.getNString("SpaceType"));
        p.setCareLevel(rs.getNString("CareLevel"));
        p.setNotes(rs.getNString("Notes"));
        p.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        return p;
    }
}
