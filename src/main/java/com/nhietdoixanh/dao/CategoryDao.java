package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.Category;
import java.util.List;
import java.util.Optional;

public interface CategoryDao {
    List<Category> findAll();
    Optional<Category> findById(int id);
}
