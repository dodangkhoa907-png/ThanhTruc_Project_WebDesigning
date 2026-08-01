package com.nhietdoixanh.util;

import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;

/**
 * Validate ảnh sản phẩm bằng magic bytes (không tin content-type/đuôi file client gửi lên),
 * giới hạn dung lượng, chỉ chấp nhận JPG/PNG/WEBP.
 *
 * Ảnh được LƯU VÀO DB (Products.ImageData) qua {@link com.nhietdoixanh.dao.ProductDao#saveImageBlob}
 * — KHÔNG ghi ra đĩa cục bộ như trước, vì đĩa của container trên Render là ephemeral (mất sạch
 * mỗi lần deploy lại/khởi động lại), khiến ảnh admin upload biến mất sau mỗi lần deploy.
 * Xem thêm: sql/migration_image_blob_storage.sql.
 */
public final class ProductImageUpload {

    private static final long MAX_BYTES = 15_000_000L; // ~15MB

    private ProductImageUpload() {}

    public record Uploaded(byte[] data, String contentType) {}

    /**
     * @return dữ liệu ảnh đã validate, hoặc null nếu không có file nào được chọn (giữ ảnh cũ).
     * @throws IllegalArgumentException nếu file không hợp lệ (quá lớn / không phải ảnh cho phép)
     */
    public static Uploaded validate(Part filePart) throws IOException {
        if (filePart == null || filePart.getSize() <= 0) return null;

        if (filePart.getSize() > MAX_BYTES) {
            throw new IllegalArgumentException("Ảnh sản phẩm tối đa 15MB.");
        }

        byte[] data;
        try (InputStream in = filePart.getInputStream()) {
            data = in.readAllBytes();
        }

        String ext = detectExtension(data, data.length);
        if (ext == null) {
            throw new IllegalArgumentException("Chỉ chấp nhận ảnh định dạng JPG, PNG hoặc WEBP.");
        }

        return new Uploaded(data, contentTypeFor(ext));
    }

    private static String contentTypeFor(String ext) {
        return switch (ext) {
            case "jpg" -> "image/jpeg";
            case "png" -> "image/png";
            case "webp" -> "image/webp";
            default -> "application/octet-stream";
        };
    }

    private static String detectExtension(byte[] h, int len) {
        if (len >= 3 && (h[0] & 0xFF) == 0xFF && (h[1] & 0xFF) == 0xD8 && (h[2] & 0xFF) == 0xFF) {
            return "jpg";
        }
        if (len >= 8 && (h[0] & 0xFF) == 0x89 && h[1] == 'P' && h[2] == 'N' && h[3] == 'G'
                && (h[4] & 0xFF) == 0x0D && (h[5] & 0xFF) == 0x0A && (h[6] & 0xFF) == 0x1A && (h[7] & 0xFF) == 0x0A) {
            return "png";
        }
        if (len >= 12 && h[0] == 'R' && h[1] == 'I' && h[2] == 'F' && h[3] == 'F'
                && h[8] == 'W' && h[9] == 'E' && h[10] == 'B' && h[11] == 'P') {
            return "webp";
        }
        return null;
    }
}
