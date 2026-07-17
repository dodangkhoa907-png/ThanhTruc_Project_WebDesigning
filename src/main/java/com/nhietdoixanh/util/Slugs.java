package com.nhietdoixanh.util;

import java.text.Normalizer;
import java.util.regex.Pattern;

/** Tạo slug URL-friendly từ chuỗi tiếng Việt có dấu (Categories/Products không lưu cột Slug riêng). */
public final class Slugs {

    private static final Pattern DIACRITICS = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
    private static final Pattern NON_ALNUM = Pattern.compile("[^a-z0-9]+");

    private Slugs() { }

    public static String of(String input) {
        if (input == null || input.isBlank()) return "";
        String normalized = Normalizer.normalize(input.trim(), Normalizer.Form.NFD);
        String noDiacritics = DIACRITICS.matcher(normalized).replaceAll("");
        noDiacritics = noDiacritics.replace('đ', 'd').replace('Đ', 'D');
        String lower = noDiacritics.toLowerCase();
        String slug = NON_ALNUM.matcher(lower).replaceAll("-");
        return slug.replaceAll("^-+|-+$", "");
    }
}
