package com.nhietdoixanh.service;

import com.nhietdoixanh.model.User;
import java.util.Optional;

public interface UserService {
    Optional<User> authenticate(String email, String rawPassword);
    User register(String fullName, String email, String phone, String rawPassword);
}
