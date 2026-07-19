package com.nhietdoixanh.util;

import java.util.regex.Pattern;

/** Validate input phía server (không phụ thuộc frontend). */
public final class Validators {

    private static final Pattern EMAIL =
            Pattern.compile("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$");

    private static final Pattern PHONE =
            Pattern.compile("^0\\d{9,10}$");

    private static final Pattern USERNAME =
            Pattern.compile("^[a-zA-Z0-9._-]{3,32}$");

    private Validators() { }

    public static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL.matcher(email.trim()).matches();
    }

    public static boolean isValidPhone(String phone) {
        if (phone == null) return false;
        String normalized = phone.replaceAll("[\\s.\\-]", "");
        return PHONE.matcher(normalized).matches();
    }

    /** Username đăng nhập nhân viên: 3-32 ký tự, chữ/số/chấm/gạch dưới/gạch ngang. */
    public static boolean isValidUsername(String username) {
        return username != null && USERNAME.matcher(username.trim()).matches();
    }

    public static int parsePositiveInt(String raw, int fallback) {
        try {
            int v = Integer.parseInt(raw.trim());
            return v > 0 ? v : fallback;
        } catch (Exception e) {
            return fallback;
        }
    }
}
