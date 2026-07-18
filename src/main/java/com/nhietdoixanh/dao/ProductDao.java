package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.Product;
import java.util.List;
import java.util.Optional;

public interface ProductDao {
    /** Sản phẩm đang bán, kèm giá các size (JOIN ProductVariants). */
    List<Product> findAllActive();

    List<Product> findByCategoryId(int categoryId);

    /** Chỉ trả về sản phẩm active. Dùng cho trang chi tiết khách hàng (không lộ sản phẩm đã ẩn). */
    Optional<Product> findActiveById(int productId);

    Optional<Product> findById(int productId);

    /** Tìm theo tên gần đúng (dùng cho search). */
    List<Product> search(String keyword);

    /**
     * Khu sản phẩm khách hàng: kết hợp lọc danh mục + tìm kiếm + sắp xếp, chỉ sản phẩm active.
     * @param categoryId null = tất cả danh mục
     * @param keyword null/blank = không lọc theo tên
     * @param sort whitelist — xem {@link com.nhietdoixanh.util.ProductSort}
     */
    List<Product> findActiveForShop(Integer categoryId, String keyword, com.nhietdoixanh.util.ProductSort sort);

    /** Admin: toàn bộ sản phẩm kể cả đã ẩn. */
    List<Product> findAllForAdmin();

    int insert(Product p);

    boolean update(Product p);

    boolean setActive(int productId, boolean active);

    boolean existsByName(String name, Integer excludeId);
}
