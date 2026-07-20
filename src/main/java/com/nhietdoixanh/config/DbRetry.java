package com.nhietdoixanh.config;

import java.sql.SQLException;
import java.util.concurrent.Callable;

/**
 * Retry đúng 1 lần cho các lỗi kết nối DB thoáng qua (network blip tới SQL Server ở xa —
 * vd. "Connection reset" SQLSTATE 08S01 mà HikariCP đã log WARN và loại bỏ connection hỏng
 * khỏi pool, nhưng không tự retry query đang chạy dở).
 *
 * CHỈ dùng cho truy vấn ĐỌC (idempotent, an toàn chạy lại). KHÔNG dùng cho INSERT/UPDATE/DELETE —
 * nếu lần đầu thực ra đã ghi thành công ở server nhưng response bị rớt giữa đường, retry có thể
 * gây hiệu ứng phụ (ghi trùng).
 */
public final class DbRetry {

    private DbRetry() {}

    public static <T> T read(Callable<T> action) {
        try {
            return action.call();
        } catch (RuntimeException e) {
            if (!isTransientConnectionError(e)) throw e;
            try {
                return action.call();
            } catch (Exception retryEx) {
                throw asRuntimeException(retryEx);
            }
        } catch (Exception e) {
            throw asRuntimeException(e);
        }
    }

    private static boolean isTransientConnectionError(Throwable t) {
        Throwable cause = t.getCause();
        if (cause instanceof SQLException se) {
            String state = se.getSQLState();
            // Lớp "08" theo chuẩn SQL = connection exception (mất kết nối, reset, không tới được server...).
            if (state != null && state.startsWith("08")) return true;
        }
        String msg = t.getMessage();
        return msg != null && (msg.contains("Connection reset")
                || msg.contains("connection is not available")
                || msg.contains("marked as broken"));
    }

    private static RuntimeException asRuntimeException(Exception e) {
        return (e instanceof RuntimeException re) ? re : new RuntimeException(e);
    }
}
