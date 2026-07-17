package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.ProductVariant;
import java.util.List;
import java.util.Optional;

public interface ProductVariantDao {
    List<ProductVariant> findByProductId(int productId);
    Optional<ProductVariant> findById(int variantId);
    int insert(ProductVariant v);
    boolean update(ProductVariant v);
    boolean setActive(int variantId, boolean active);
    boolean delete(int variantId);
}
