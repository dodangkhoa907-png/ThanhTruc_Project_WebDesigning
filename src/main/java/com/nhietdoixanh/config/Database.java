package com.nhietdoixanh.config;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Connection pool dùng chung toàn ứng dụng (HikariCP).
 * Đọc cấu hình từ src/main/resources/db.properties.
 * Mọi DAO lấy Connection qua {@link #getConnection()}.
 */
public final class Database {

    private static volatile HikariDataSource dataSource;

    private Database() { }

    /** Khởi tạo pool 1 lần khi app start (gọi từ AppContextListener). */
    public static synchronized void init() {
        if (dataSource != null) return;

        Properties props = new Properties();
        try (InputStream in = Database.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new IllegalStateException("Không tìm thấy db.properties trong classpath");
            }
            props.load(in);
        } catch (IOException e) {
            throw new IllegalStateException("Lỗi đọc db.properties", e);
        }

        String jdbcUrl = props.getProperty("db.url");
        if (jdbcUrl != null && !jdbcUrl.toLowerCase().contains("statementpoolingcachesize")) {
            jdbcUrl += (jdbcUrl.endsWith(";") ? "" : ";") + "statementPoolingCacheSize=512;disableStatementPooling=false";
        }

        HikariConfig cfg = new HikariConfig();
        cfg.setJdbcUrl(jdbcUrl);
        cfg.setUsername(props.getProperty("db.username"));
        cfg.setPassword(props.getProperty("db.password"));
        cfg.setDriverClassName(props.getProperty("db.driver"));
        cfg.setPoolName("NhietDoiXanhPool");
        cfg.setMaximumPoolSize(8);
        cfg.setMinimumIdle(2);
        cfg.setConnectionTimeout(10_000);
        cfg.setIdleTimeout(300_000);
        cfg.setMaxLifetime(900_000);
        cfg.setKeepaliveTime(120_000);
        cfg.setValidationTimeout(3_000);
        cfg.setLeakDetectionThreshold(30_000);

        System.out.println("[DB] Creating HikariCP pool (MinIdle=2, MaxSize=8)...");
        dataSource = new HikariDataSource(cfg);
        System.out.println("[DB] HikariCP pool initialized");
    }

    public static DataSource getDataSource() {
        if (dataSource == null) init();
        return dataSource;
    }

    public static Connection getConnection() throws SQLException {
        return getDataSource().getConnection();
    }

    public static synchronized void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            dataSource = null;
        }
    }
}
