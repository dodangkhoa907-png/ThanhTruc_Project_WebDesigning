package com.nhietdoixanh.util;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

/**
 * Quản lý tập trung trạng thái đơn hàng (Orders.OrderStatus).
 * Không rải chuỗi trạng thái hard-code khắp servlet/JSP mới — dùng class này.
 */
public final class OrderStatuses {

    public static final String PENDING = "PENDING";
    public static final String CONFIRMED = "CONFIRMED";
    public static final String SHIPPING = "SHIPPING";
    public static final String DONE = "DONE";
    public static final String CANCELLED = "CANCELLED";
    public static final String PENDING_CANCEL = "PENDING_CANCEL";

    private static final Map<String, String> LABELS = new LinkedHashMap<>();
    static {
        LABELS.put(PENDING, "Chờ xác nhận");
        LABELS.put(CONFIRMED, "Đang xử lý");
        LABELS.put(SHIPPING, "Đang giao");
        LABELS.put(DONE, "Hoàn thành");
        LABELS.put(CANCELLED, "Đã hủy");
        LABELS.put(PENDING_CANCEL, "Chờ duyệt hủy");
    }

    /** Map nhãn tiếng Việt cũ (nếu DB còn lưu dạng cũ) về mã chuẩn — tương thích ngược, không làm mất đơn cũ. */
    private static final Map<String, String> LEGACY_LABEL_TO_CODE = new LinkedHashMap<>();
    static {
        LEGACY_LABEL_TO_CODE.put("chờ xác nhận", PENDING);
        LEGACY_LABEL_TO_CODE.put("đang xử lý", CONFIRMED);
        LEGACY_LABEL_TO_CODE.put("đang giao", SHIPPING);
        LEGACY_LABEL_TO_CODE.put("hoàn thành", DONE);
        LEGACY_LABEL_TO_CODE.put("đã hủy", CANCELLED);
        LEGACY_LABEL_TO_CODE.put("chờ duyệt hủy", PENDING_CANCEL);
    }

    private static final Map<String, Set<String>> TRANSITIONS = new LinkedHashMap<>();
    static {
        TRANSITIONS.put(PENDING, Set.of(CONFIRMED, CANCELLED));
        TRANSITIONS.put(CONFIRMED, Set.of(SHIPPING, PENDING_CANCEL, CANCELLED));
        TRANSITIONS.put(SHIPPING, Set.of(DONE));
        TRANSITIONS.put(PENDING_CANCEL, Set.of(CANCELLED, CONFIRMED));
        TRANSITIONS.put(DONE, Set.of());
        TRANSITIONS.put(CANCELLED, Set.of());
    }

    private OrderStatuses() {}

    /** Chuẩn hóa mã trạng thái: chấp nhận cả mã chuẩn lẫn nhãn tiếng Việt cũ. */
    public static String normalize(String status) {
        if (status == null) return null;
        String trimmed = status.trim();
        if (LABELS.containsKey(trimmed)) return trimmed;
        String mapped = LEGACY_LABEL_TO_CODE.get(trimmed.toLowerCase());
        return mapped != null ? mapped : trimmed;
    }

    public static boolean isValid(String status) {
        return status != null && LABELS.containsKey(normalize(status));
    }

    public static String getLabel(String status) {
        String code = normalize(status);
        return LABELS.getOrDefault(code, status);
    }

    public static boolean canTransition(String from, String to) {
        String f = normalize(from);
        String t = normalize(to);
        if (!isValid(f) || !isValid(t)) return false;
        return TRANSITIONS.getOrDefault(f, Set.of()).contains(t);
    }

    public static boolean isProcessing(String status) {
        String code = normalize(status);
        return CONFIRMED.equals(code) || SHIPPING.equals(code) || PENDING_CANCEL.equals(code);
    }

    public static boolean isCompleted(String status) {
        String code = normalize(status);
        return DONE.equals(code) || CANCELLED.equals(code);
    }

    /**
     * Khách hàng chỉ được tự hủy khi đơn còn PENDING/CONFIRMED và chưa thanh toán
     * (đơn đã PAID phải qua luồng yêu cầu hủy để admin duyệt hoàn tiền).
     */
    public static boolean isCancellableByCustomer(String status, String paymentStatus) {
        String code = normalize(status);
        if (!PENDING.equals(code) && !CONFIRMED.equals(code)) return false;
        return !PaymentStatuses.isPaid(paymentStatus);
    }
}
