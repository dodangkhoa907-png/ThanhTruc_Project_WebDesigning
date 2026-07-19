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

    /**
     * Danh sách phản hồi cho trang quản trị — lọc theo trạng thái (null/rỗng = tất cả) và
     * từ khóa (LIKE trên Name/Phone/Email/Message, null/rỗng = không lọc), phân trang.
     */
    List<Feedback> findFiltered(String status, String keyword, int offset, int limit);

    /** Đếm số dòng khớp cùng bộ lọc với {@link #findFiltered} — dùng tính tổng số trang. */
    int countFiltered(String status, String keyword);
}
