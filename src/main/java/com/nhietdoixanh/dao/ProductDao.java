package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.Product;
import java.util.List;
import java.util.Optional;

public interface ProductDao {
    /** Sản phẩm đang bán, kèm giá các size (JOIN ProductVariants). */
    List<Product> findAllActive();

    List<Product> findByCategoryId(int categoryId);

    Optional<Product> findById(int productId);

    /** Tìm theo tên gần đúng (dùng cho search). */
    List<Product> search(String keyword);

    /** Admin: toàn bộ sản phẩm kể cả đã ẩn. */
    List<Product> findAllForAdmin();

    int insert(Product p);

    boolean update(Product p);

    boolean setActive(int productId, boolean active);

    boolean existsByName(String name, Integer excludeId);
}
