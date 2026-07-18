package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.UserAddress;
import java.util.List;
import java.util.Optional;

public interface UserAddressDao {
    List<UserAddress> findByUserId(int userId);
    int insert(UserAddress a);
    boolean delete(int addressId, int userId);
    boolean setDefault(int addressId, int userId);

    Optional<UserAddress> findDefaultByUserId(int userId);

    Optional<UserAddress> findByIdAndUserId(int addressId, int userId);

    /** Cập nhật địa chỉ — kiểm tra ownership (WHERE AddressID = ? AND UserID = ?). */
    boolean update(UserAddress a);

    /** Alias rõ nghĩa hơn cho create. */
    default int create(UserAddress a) {
        return insert(a);
    }

    /** Alias rõ nghĩa hơn cho delete. */
    default boolean deleteByIdAndUserId(int addressId, int userId) {
        return delete(addressId, userId);
    }

    /** Alias rõ nghĩa hơn cho setDefault — transaction-safe (chỉ 1 địa chỉ mặc định mỗi user). */
    default boolean setDefaultAddress(int addressId, int userId) {
        return setDefault(addressId, userId);
    }
}
