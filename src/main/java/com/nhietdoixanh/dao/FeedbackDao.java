package com.nhietdoixanh.dao;

import com.nhietdoixanh.model.Feedback;
import java.util.List;

public interface FeedbackDao {
    int insert(Feedback fb);
    List<Feedback> findAll();
    List<Feedback> findAllPaged(int offset, int limit);
    /** Feedback đã duyệt (RESOLVED) hiển thị công khai trên trang chủ. */
    List<Feedback> findPublic(int limit);
    int countByStatus(String status);
    int countAll();
    int updateStatus(int feedbackId, String status);
}
