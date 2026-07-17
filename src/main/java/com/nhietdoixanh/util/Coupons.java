package com.nhietdoixanh.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Logic mã giảm giá nhanh dùng ở giỏ hàng. Hỗ trợ mã NDXANH10 (giảm 10%).
 * Mã đầy đủ hơn (giới hạn số lần dùng, hạn dùng...) tra ở bảng Coupons qua CouponDao.
 */
public final class Coupons {

    public static final String NDXANH10 = "NDXANH10";

    private Coupons() { }

    public static boolean isValid(String code) {
        return code != null && NDXANH10.equalsIgnoreCase(code.trim());
    }

    public static BigDecimal discountFor(String code, BigDecimal subtotal) {
        if (subtotal == null || !isValid(code)) return BigDecimal.ZERO;
        return subtotal.multiply(new BigDecimal("0.10"))
                       .setScale(0, RoundingMode.HALF_UP);
    }

    public static BigDecimal applyDiscount(String code, BigDecimal subtotal) {
        if (subtotal == null) return BigDecimal.ZERO;
        return subtotal.subtract(discountFor(code, subtotal));
    }
}
