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
}
