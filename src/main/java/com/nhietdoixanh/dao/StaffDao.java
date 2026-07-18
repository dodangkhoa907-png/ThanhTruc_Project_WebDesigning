package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.Staff;
import java.util.List;
import java.util.Optional;

public interface StaffDao {
    Optional<Staff> findByUsername(String username);
    Optional<Staff> findById(int staffId);
    List<Staff> findAll();
    boolean updatePassword(int staffId, String newPasswordHash);
}
