package com.nhietdoixanh.config;

/**
 * Cấu hình PayOS — ưu tiên đọc từ biến môi trường (PAYOS_CLIENT_ID, PAYOS_API_KEY,
 * PAYOS_CHECKSUM_KEY, PAYOS_RETURN_URL, PAYOS_CANCEL_URL, PAYOS_WEBHOOK_URL), fallback
 * sang db.properties (payos.client_id, payos.api_key, payos.checksum_key, payos.return_url,
 * payos.cancel_url, payos.webhook_url) cho local dev.
 *
 * Nếu thiếu clientId/apiKey/checksumKey: {@link #isConfigured()} trả false, app vẫn chạy
 * bình thường, COD không bị ảnh hưởng — chỉ tùy chọn PayOS bị ẩn/disable ở checkout.
 *
 * KHÔNG BAO GIỜ log apiKey/checksumKey ra console hay trả về JSP/JSON.
 */
public final class PayOSConfig {

    private static final String CLIENT_ID = resolve("PAYOS_CLIENT_ID", "payos.client_id");
    private static final String API_KEY = resolve("PAYOS_API_KEY", "payos.api_key");
    private static final String CHECKSUM_KEY = resolve("PAYOS_CHECKSUM_KEY", "payos.checksum_key");
    private static final String RETURN_URL = resolve("PAYOS_RETURN_URL", "payos.return_url");
    private static final String CANCEL_URL = resolve("PAYOS_CANCEL_URL", "payos.cancel_url");
    private static final String WEBHOOK_URL = resolve("PAYOS_WEBHOOK_URL", "payos.webhook_url");

    private PayOSConfig() {}

    /** true nếu đủ 3 credential bắt buộc để gọi API PayOS (client id / api key / checksum key). */
    public static boolean isConfigured() {
        return !isBlank(CLIENT_ID) && !isBlank(API_KEY) && !isBlank(CHECKSUM_KEY);
    }

    public static String getClientId() { return CLIENT_ID; }

    public static String getApiKey() { return API_KEY; }

    public static String getChecksumKey() { return CHECKSUM_KEY; }

    /** URL tuyệt đối đã cấu hình (nếu có) — null nếu chưa cấu hình, caller tự suy ra từ request. */
    public static String getReturnUrl() { return RETURN_URL; }

    public static String getCancelUrl() { return CANCEL_URL; }

    public static String getWebhookUrl() { return WEBHOOK_URL; }

    private static String resolve(String envKey, String propKey) {
        String fromEnv = System.getenv(envKey);
        if (!isBlank(fromEnv)) return fromEnv.trim();
        String fromProps = AppConfig.get(propKey, "");
        return isBlank(fromProps) ? null : fromProps.trim();
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
