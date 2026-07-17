package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.UserPreferences;
import java.util.Optional;

public interface UserPreferencesDao {
    Optional<UserPreferences> findByUserId(int userId);

    /** Tạo mới nếu chưa có, cập nhật nếu đã có (UserID UNIQUE). */
    boolean upsertByUserId(UserPreferences prefs);
}
