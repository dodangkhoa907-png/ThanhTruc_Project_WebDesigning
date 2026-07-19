package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.Staff;
import java.util.List;
import java.util.Optional;

public interface StaffDao {
    Optional<Staff> findByUsername(String username);
    Optional<Staff> findById(int staffId);
    List<Staff> findAll();
    boolean updatePassword(int staffId, String newPasswordHash);

    boolean existsByUsername(String username);

    /** @return StaffID mới sinh, hoặc -1 nếu thất bại. */
    int insert(Staff s);

    /** Chỉ cập nhật FullName + Role — KHÔNG đổi Username (định danh đăng nhập) hay mật khẩu ở đây. */
    boolean update(Staff s);

    boolean setActive(int staffId, boolean active);
}
