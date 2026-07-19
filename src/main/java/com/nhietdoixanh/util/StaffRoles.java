package com.nhietdoixanh.util;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Quản lý tập trung vai trò nhân viên (Staffs.Role). Chỉ ADMIN được vào /admin
 * (xem {@link com.nhietdoixanh.controller.admin.AdminAuthController}) — các vai trò còn lại
 * là chỗ đứng dữ liệu cho các vai trò vận hành sẽ mở khóa sau (shipper/dispatcher...).
 */
public final class StaffRoles {

    public static final String ADMIN = "ADMIN";
    public static final String MANAGER = "MANAGER";
    public static final String PROCESSOR = "PROCESSOR";
    public static final String SALES = "SALES";
    public static final String DELIVERY = "DELIVERY";

    private static final Map<String, String> LABELS = new LinkedHashMap<>();
    static {
        LABELS.put(ADMIN, "Quản trị viên");
        LABELS.put(MANAGER, "Quản lý");
        LABELS.put(PROCESSOR, "Xử lý đơn");
        LABELS.put(SALES, "Kinh doanh");
        LABELS.put(DELIVERY, "Giao hàng");
    }

    private StaffRoles() {}

    public static boolean isValid(String role) {
        return role != null && LABELS.containsKey(role);
    }

    public static String getLabel(String role) {
        return LABELS.getOrDefault(role, role);
    }

    public static Map<String, String> all() {
        return java.util.Collections.unmodifiableMap(LABELS);
    }
}
