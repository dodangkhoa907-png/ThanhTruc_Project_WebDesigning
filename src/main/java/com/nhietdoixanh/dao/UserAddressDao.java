package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.UserAddress;
import java.util.List;

public interface UserAddressDao {
    List<UserAddress> findByUserId(int userId);
    int insert(UserAddress a);
    boolean delete(int addressId, int userId);
    boolean setDefault(int addressId, int userId);
}
