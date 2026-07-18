package com.nhietdoixanh.service;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.nhietdoixanh.config.PayOSConfig;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.time.Duration;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * Client gọi PayOS REST API v2 trực tiếp (KHÔNG dùng SDK Java chính thức
 * vn.payos:payos-java — SDK đó kéo theo OkHttp + Jackson + Lombok, không hợp với một dự án
 * Servlet/JSP đang cố tình tối giản chỉ dùng Gson + java.net.http.HttpClient có sẵn trong JDK).
 *
 * QUAN TRỌNG: repo PureNut (com.purenut.shop.config) không tìm thấy ở bất kỳ đâu trên máy —
 * xem docs/ECOMMERCE_PAYOS_REPORT.md. Toàn bộ endpoint, tên field JSON và thuật toán chữ ký
 * HMAC-SHA256 dưới đây được đối chiếu TRỰC TIẾP với source code thật của SDK chính thức
 * (vn.payos:payos-java:2.0.1, đọc từ payos-java-2.0.1-sources.jar trong local Maven repo:
 * ~/.m2/repository/vn/payos/payos-java/2.0.1/) — KHÔNG đoán API.
 *
 * Đối chiếu cụ thể:
 * - vn.payos.PayOS / vn.payos.core.Client — base URL https://api-merchant.payos.vn,
 *   header x-client-id / x-api-key, POST /v2/payment-requests.
 * - vn.payos.crypto.CryptoProviderImpl#createSignatureFromPaymentRequest — chữ ký request
 *   tạo payment link chỉ tính trên 5 field theo thứ tự amount, cancelUrl, description,
 *   orderCode, returnUrl.
 * - vn.payos.service.blocking.webhooks.WebhooksServiceImpl#verify +
 *   CryptoProviderImpl#createSignatureFromObject — chữ ký webhook: sort toàn bộ field của
 *   WebhookData theo alphabet, nối "key=value" bằng "&" (KHÔNG url-encode, null → ""),
 *   HMAC-SHA256 rồi so với field "signature".
 */
public final class PayOSPaymentService {

    private static final String BASE_URL = "https://api-merchant.payos.vn";
    private static final Gson GSON = new Gson();
    private static final HttpClient HTTP = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    private PayOSPaymentService() {}

    public static boolean isConfigured() {
        return PayOSConfig.isConfigured();
    }

    // =========================================================================================
    // Tạo payment link — POST /v2/payment-requests
    // =========================================================================================

    public static final class CreatePaymentLinkRequest {
        public final long orderCode;
        public final long amount;
        public final String description;
        public final String returnUrl;
        public final String cancelUrl;
        public final String buyerName;
        public final String buyerPhone;

        public CreatePaymentLinkRequest(long orderCode, long amount, String description,
                String returnUrl, String cancelUrl, String buyerName, String buyerPhone) {
            this.orderCode = orderCode;
            this.amount = amount;
            this.description = description;
            this.returnUrl = returnUrl;
            this.cancelUrl = cancelUrl;
            this.buyerName = buyerName;
            this.buyerPhone = buyerPhone;
        }
    }

    public static final class CreatePaymentLinkResult {
        public final String paymentLinkId;
        public final String checkoutUrl;
        public final String qrCode;

        public CreatePaymentLinkResult(String paymentLinkId, String checkoutUrl, String qrCode) {
            this.paymentLinkId = paymentLinkId;
            this.checkoutUrl = checkoutUrl;
            this.qrCode = qrCode;
        }
    }

    public static class PayOSApiException extends Exception {
        public PayOSApiException(String message) { super(message); }
        public PayOSApiException(String message, Throwable cause) { super(message, cause); }
    }

    public static CreatePaymentLinkResult createPaymentLink(CreatePaymentLinkRequest req) throws PayOSApiException {
        if (!isConfigured()) {
            throw new PayOSApiException("PayOS chưa được cấu hình.");
        }

        JsonObject body = new JsonObject();
        body.addProperty("orderCode", req.orderCode);
        body.addProperty("amount", req.amount);
        body.addProperty("description", req.description);
        body.addProperty("cancelUrl", req.cancelUrl);
        body.addProperty("returnUrl", req.returnUrl);
        if (req.buyerName != null && !req.buyerName.isBlank()) body.addProperty("buyerName", req.buyerName);
        if (req.buyerPhone != null && !req.buyerPhone.isBlank()) body.addProperty("buyerPhone", req.buyerPhone);
        body.addProperty("signature", hmacSha256Hex(paymentRequestSignaturePayload(req), PayOSConfig.getChecksumKey()));

        HttpRequest httpReq = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/v2/payment-requests"))
                .timeout(Duration.ofSeconds(20))
                .header("Content-Type", "application/json")
                .header("x-client-id", PayOSConfig.getClientId())
                .header("x-api-key", PayOSConfig.getApiKey())
                .POST(HttpRequest.BodyPublishers.ofString(GSON.toJson(body), StandardCharsets.UTF_8))
                .build();

        JsonObject responseJson;
        try {
            HttpResponse<String> httpResp = HTTP.send(httpReq, HttpResponse.BodyHandlers.ofString());
            responseJson = JsonParser.parseString(httpResp.body()).getAsJsonObject();
        } catch (Exception e) {
            // KHÔNG log response body (có thể chứa dữ liệu nhạy cảm) — chỉ log loại lỗi kết nối.
            throw new PayOSApiException("Không thể kết nối tới PayOS: " + e.getClass().getSimpleName(), e);
        }

        String code = getAsStringOrNull(responseJson, "code");
        if (!"00".equals(code)) {
            String desc = getAsStringOrNull(responseJson, "desc");
            throw new PayOSApiException("PayOS từ chối tạo link thanh toán: " + (desc != null ? desc : "mã lỗi " + code));
        }

        JsonObject data = responseJson.has("data") && responseJson.get("data").isJsonObject()
                ? responseJson.getAsJsonObject("data") : null;
        if (data == null) {
            throw new PayOSApiException("Phản hồi PayOS không hợp lệ (thiếu data).");
        }
        String paymentLinkId = getAsStringOrNull(data, "paymentLinkId");
        String checkoutUrl = getAsStringOrNull(data, "checkoutUrl");
        String qrCode = getAsStringOrNull(data, "qrCode");
        if (checkoutUrl == null) {
            throw new PayOSApiException("Phản hồi PayOS không hợp lệ (thiếu checkoutUrl).");
        }
        return new CreatePaymentLinkResult(paymentLinkId, checkoutUrl, qrCode);
    }

    private static String paymentRequestSignaturePayload(CreatePaymentLinkRequest req) {
        return "amount=" + req.amount
                + "&cancelUrl=" + nullToEmpty(req.cancelUrl)
                + "&description=" + nullToEmpty(req.description)
                + "&orderCode=" + req.orderCode
                + "&returnUrl=" + nullToEmpty(req.returnUrl);
    }

    // =========================================================================================
    // Verify webhook
    // =========================================================================================

    private static final List<String> WEBHOOK_DATA_FIELDS = List.of(
            "accountNumber", "amount", "code", "counterAccountBankId", "counterAccountBankName",
            "counterAccountName", "counterAccountNumber", "currency", "desc", "description",
            "orderCode", "paymentLinkId", "reference", "transactionDateTime",
            "virtualAccountName", "virtualAccountNumber"
    );

    public static final class WebhookVerifyResult {
        public final long orderCode;
        public final String code;
        public final String desc;

        public WebhookVerifyResult(long orderCode, String code, String desc) {
            this.orderCode = orderCode;
            this.code = code;
            this.desc = desc;
        }

        public boolean isPaymentSuccess() { return "00".equals(code); }
    }

    /**
     * Verify chữ ký webhook PayOS bằng checksum key. Trả về null nếu payload không hợp lệ
     * hoặc chữ ký sai — caller PHẢI coi null là "từ chối", tuyệt đối không suy diễn thành công.
     */
    public static WebhookVerifyResult verifyWebhook(String rawJsonBody) {
        if (rawJsonBody == null || rawJsonBody.isBlank() || !isConfigured()) return null;

        JsonObject root;
        try {
            JsonElement parsed = JsonParser.parseString(rawJsonBody);
            if (!parsed.isJsonObject()) return null;
            root = parsed.getAsJsonObject();
        } catch (Exception e) {
            return null;
        }

        String signature = getAsStringOrNull(root, "signature");
        JsonObject data = root.has("data") && root.get("data").isJsonObject() ? root.getAsJsonObject("data") : null;
        if (signature == null || signature.isBlank() || data == null) return null;

        TreeMap<String, String> sorted = new TreeMap<>();
        for (String field : WEBHOOK_DATA_FIELDS) {
            sorted.put(field, jsonElementToSignatureValue(data.get(field)));
        }
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> e : sorted.entrySet()) {
            if (sb.length() > 0) sb.append('&');
            sb.append(e.getKey()).append('=').append(e.getValue());
        }

        String expected = hmacSha256Hex(sb.toString(), PayOSConfig.getChecksumKey());
        if (!expected.equalsIgnoreCase(signature)) return null;

        JsonElement orderCodeEl = data.get("orderCode");
        if (orderCodeEl == null || orderCodeEl.isJsonNull() || !orderCodeEl.isJsonPrimitive()) return null;
        long orderCode;
        try {
            orderCode = orderCodeEl.getAsLong();
        } catch (NumberFormatException e) {
            return null;
        }

        return new WebhookVerifyResult(orderCode, getAsStringOrNull(data, "code"), getAsStringOrNull(data, "desc"));
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    private static String jsonElementToSignatureValue(JsonElement el) {
        if (el == null || el.isJsonNull()) return "";
        if (el.isJsonPrimitive() && el.getAsJsonPrimitive().isNumber()) {
            // amount/orderCode là số nguyên — tránh Gson in ra dạng "150000.0".
            double d = el.getAsDouble();
            if (!Double.isInfinite(d) && !Double.isNaN(d) && d == Math.floor(d)) {
                return String.valueOf((long) d);
            }
        }
        return el.getAsString();
    }

    private static String getAsStringOrNull(JsonObject obj, String key) {
        if (obj == null || !obj.has(key) || obj.get(key).isJsonNull()) return null;
        return obj.get(key).getAsString();
    }

    private static String nullToEmpty(String s) { return s == null ? "" : s; }

    private static String hmacSha256Hex(String data, String key) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(raw.length * 2);
            for (byte b : raw) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            throw new IllegalStateException("Lỗi tạo chữ ký HMAC-SHA256", e);
        }
    }
}
