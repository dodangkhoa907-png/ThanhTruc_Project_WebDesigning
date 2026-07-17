package com.nhietdoixanh.util;

/**
 * Whitelist các kiểu sắp xếp cho phép ở khu sản phẩm. KHÔNG nhận raw SQL/ORDER BY
 * từ request — mọi giá trị "sort" từ client phải map qua {@link #fromParam(String)}.
 */
public enum ProductSort {
    DEFAULT("moi-nhat"),
    PRICE_ASC("gia-tang"),
    PRICE_DESC("gia-giam"),
    NAME_ASC("ten-az");

    private final String param;

    ProductSort(String param) {
        this.param = param;
    }

    public String getParam() {
        return param;
    }

    public static ProductSort fromParam(String raw) {
        if (raw == null) return DEFAULT;
        for (ProductSort s : values()) {
            if (s.param.equals(raw.trim())) return s;
        }
        return DEFAULT;
    }
}
