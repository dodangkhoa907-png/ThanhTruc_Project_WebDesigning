package com.nhietdoixanh.config;

import com.nhietdoixanh.util.Passwords;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Khởi tạo connection pool khi web app start và seed 1 tài khoản khách hàng
 * mẫu (bảng Users) nếu chưa tồn tại — mật khẩu hash BCrypt.
 * Admin/nhân viên dùng bảng Staffs có sẵn (không seed ở đây), xem
 * sql/migration_purenut_port_v2.sql để reset mật khẩu test.
 */
@WebListener
public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AppInit] Khởi tạo Database pool...");
        Database.init();
        System.out.println("[AppInit] Database pool ready");

        new Thread(this::seedUsers, "UserSeedThread").start();
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        Database.close();
    }

    private void seedUsers() {
        try {
            seedUser("khachhang@gmail.com", "Khách Hàng Mẫu", "0911111111", "Customer@123");
            System.out.println("[Seed] Hoàn tất seeding users");
        } catch (Exception e) {
            System.err.println("[Seed] Lỗi khi seeding users: " + e.getMessage());
        }
    }

    private void seedUser(String email, String fullName, String phone, String rawPassword) {
        try (Connection con = Database.getConnection()) {
            if (userExists(con, email)) {
                return;
            }
            String sql = "INSERT INTO Users (FullName, Email, Phone, PasswordHash, Role) VALUES (?,?,?,?,'CUSTOMER')";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, fullName);
                ps.setString(2, email);
                ps.setString(3, phone);
                ps.setString(4, Passwords.hash(rawPassword));
                ps.executeUpdate();
            }
            System.out.println("[Seed] Đã tạo tài khoản khách hàng: " + email);
        } catch (SQLException e) {
            System.err.println("[Seed] Lỗi seed user " + email + ": " + e.getMessage());
        }
    }

    private boolean userExists(Connection con, String email) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("SELECT 1 FROM Users WHERE Email = ?")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }
}
