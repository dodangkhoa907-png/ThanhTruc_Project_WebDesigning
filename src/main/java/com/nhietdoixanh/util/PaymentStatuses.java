package com.nhietdoixanh.util;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Quản lý tập trung trạng thái thanh toán (Orders.PaymentStatus).
 */
public final class PaymentStatuses {

    public static final String UNPAID = "UNPAID";
    public static final String PENDING = "PENDING";
    public static final String PAID = "PAID";
    public static final String FAILED = "FAILED";
    public static final String CANCELLED = "CANCELLED";
    public static final String REFUND_PENDING = "REFUND_PENDING";

    private static final Map<String, String> LABELS = new LinkedHashMap<>();
    static {
        LABELS.put(UNPAID, "Chưa thanh toán");
        LABELS.put(PENDING, "Chờ thanh toán");
        LABELS.put(PAID, "Đã thanh toán");
        LABELS.put(FAILED, "Thanh toán thất bại");
        LABELS.put(CANCELLED, "Đã hủy thanh toán");
        LABELS.put(REFUND_PENDING, "Chờ xử lý hoàn tiền");
    }

    private PaymentStatuses() {}

    public static boolean isValid(String status) {
        return status != null && LABELS.containsKey(status.trim());
    }

    public static String getLabel(String status) {
        if (status == null) return null;
        return LABELS.getOrDefault(status.trim(), status);
    }

    public static boolean isPaid(String status) {
        return PAID.equals(status);
    }

    public static boolean isPending(String status) {
        return PENDING.equals(status);
    }
}
