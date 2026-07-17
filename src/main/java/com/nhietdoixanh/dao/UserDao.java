package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.User;
import java.util.Optional;

public interface UserDao {
    int insert(User user);
    Optional<User> findByEmail(String email);
    Optional<User> findById(int userId);
    boolean existsByEmail(String email);
    boolean updatePassword(int userId, String passwordHash);
    boolean updateProfile(int userId, String fullName, String phone);
    boolean updateProfileImage(int userId, String profileImage);
    boolean updateLoginInfo(int userId, String ip);

    /** true nếu email đã tồn tại ở MỘT user KHÁC userId (dùng khi đổi email hồ sơ). */
    boolean emailExistsForOtherUser(String email, int userId);

    /** Alias rõ nghĩa hơn cho updateProfileImage. */
    default boolean updateAvatar(int userId, String profileImage) {
        return updateProfileImage(userId, profileImage);
    }

    /** Alias rõ nghĩa hơn cho updatePassword. */
    default boolean updatePasswordHash(int userId, String passwordHash) {
        return updatePassword(userId, passwordHash);
    }
}
