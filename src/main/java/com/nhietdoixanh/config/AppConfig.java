package com.nhietdoixanh.config;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public final class AppConfig {

    private static final Properties props = new Properties();

    static {
        try (InputStream in = AppConfig.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in != null) props.load(in);
        } catch (IOException e) {
            throw new IllegalStateException("Lỗi đọc db.properties", e);
        }
    }

    private AppConfig() {}

    public static String get(String key) {
        return props.getProperty(key, "");
    }

    public static String get(String key, String fallback) {
        return props.getProperty(key, fallback);
    }
}
