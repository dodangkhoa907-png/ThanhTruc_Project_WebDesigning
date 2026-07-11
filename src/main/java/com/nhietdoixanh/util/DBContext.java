package com.nhietdoixanh.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Lớp tiện ích kết nối Database.
 * Đọc cấu hình từ file db.properties và trả về Connection thông qua DriverManager.
 */
public class DBContext {

    private static final Properties properties = new Properties();

    // Static initializer: Load db.properties 1 lần duy nhất khi class được load
    static {
        try (InputStream input = DBContext.class.getClassLoader()
                .getResourceAsStream("db.properties")) {
            if (input == null) {
                throw new RuntimeException("Không tìm thấy file db.properties trong classpath!");
            }
            properties.load(input);

            // Load JDBC driver
            String driver = properties.getProperty("db.driver");
            Class.forName(driver);
        } catch (IOException e) {
            throw new RuntimeException("Lỗi đọc file db.properties: " + e.getMessage(), e);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Không tìm thấy JDBC Driver: " + e.getMessage(), e);
        }
    }

    /**
     * Trả về Connection tới SQL Server.
     * Mỗi lần gọi sẽ tạo connection mới — caller có trách nhiệm đóng connection.
     *
     * @return Connection đến database
     * @throws SQLException nếu không thể kết nối
     */
    public static Connection getConnection() throws SQLException {
        String url = properties.getProperty("db.url");
        String username = properties.getProperty("db.username");
        String password = properties.getProperty("db.password");

        return DriverManager.getConnection(url, username, password);
    }
}
