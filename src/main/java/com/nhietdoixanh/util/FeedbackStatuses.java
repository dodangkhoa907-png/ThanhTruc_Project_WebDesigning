package com.nhietdoixanh.util;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Quản lý tập trung trạng thái phản hồi khách hàng (Feedback.Status).
 * Không rải chuỗi trạng thái hard-code khắp servlet/JSP mới — dùng class này.
 */
public final class FeedbackStatuses {

    /** Vừa gửi, chưa admin nào xem. */
    public static final String NEW = "NEW";
    /** Admin đã xem qua nhưng chưa duyệt hiển thị công khai. */
    public static final String SEEN = "SEEN";
    /** Đã duyệt — hiển thị công khai trên trang chủ (widget testimonials). */
    public static final String RESOLVED = "RESOLVED";

    private static final Map<String, String> LABELS = new LinkedHashMap<>();
    static {
        LABELS.put(NEW, "Chờ duyệt");
        LABELS.put(SEEN, "Đã xem");
        LABELS.put(RESOLVED, "Đã duyệt, hiện công khai");
    }

    private FeedbackStatuses() {}

    public static boolean isValid(String status) {
        return status != null && LABELS.containsKey(status.trim());
    }

    public static String getLabel(String status) {
        if (status == null) return "";
        return LABELS.getOrDefault(status.trim(), status);
    }
}
