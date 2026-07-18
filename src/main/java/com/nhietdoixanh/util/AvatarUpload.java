package com.nhietdoixanh.util;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

/**
 * Lưu ảnh đại diện người dùng — validate bằng magic bytes (không tin content-type/đuôi file
 * client gửi lên), giới hạn dung lượng, chỉ chấp nhận JPG/PNG/WEBP (không SVG — SVG có thể
 * chứa script, nguy cơ XSS nếu render trực tiếp).
 */
public final class AvatarUpload {

    private static final long MAX_BYTES = 1_000_000L; // ~1MB
    private static final String UPLOAD_SUBPATH = "/uploads/avatars";

    private AvatarUpload() {}

    /**
     * @return đường dẫn context-relative (vd. "/uploads/avatars/u5_1737000000000.jpg") để lưu vào
     *         Users.ProfileImage, hoặc null nếu không có file nào được chọn (giữ avatar cũ).
     * @throws IllegalArgumentException nếu file không hợp lệ (quá lớn / không phải ảnh cho phép)
     */
    public static String store(Part filePart, ServletContext context, int userId) throws IOException {
        if (filePart == null || filePart.getSize() <= 0) return null;

        if (filePart.getSize() > MAX_BYTES) {
            throw new IllegalArgumentException("Ảnh đại diện tối đa 1MB.");
        }

        byte[] header = new byte[12];
        int read;
        try (InputStream in = filePart.getInputStream()) {
            read = in.readNBytes(header, 0, header.length);
        }

        String ext = detectExtension(header, read);
        if (ext == null) {
            throw new IllegalArgumentException("Chỉ chấp nhận ảnh định dạng JPG, PNG hoặc WEBP.");
        }

        String realDir = context.getRealPath(UPLOAD_SUBPATH);
        if (realDir == null) {
            throw new IOException("Không xác định được thư mục lưu ảnh trên server.");
        }
        Path dir = Path.of(realDir);
        Files.createDirectories(dir);

        // Tên file tự sinh (userId + timestamp) — không dùng tên file client gửi lên, tránh path traversal.
        String filename = "u" + userId + "_" + System.currentTimeMillis() + "." + ext;
        Path target = dir.resolve(filename);

        try (InputStream in = filePart.getInputStream()) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }

        return UPLOAD_SUBPATH + "/" + filename;
    }

    /** Xóa ảnh cũ khi thay avatar mới — best-effort, không ném lỗi nếu không xóa được. */
    public static void deleteQuietly(String contextRelativePath, ServletContext context) {
        if (contextRelativePath == null || !contextRelativePath.startsWith(UPLOAD_SUBPATH)) return;
        try {
            String realPath = context.getRealPath(contextRelativePath);
            if (realPath != null) Files.deleteIfExists(Path.of(realPath));
        } catch (IOException ignored) {
            // best-effort — không để lỗi xóa file cũ làm hỏng luồng cập nhật hồ sơ
        }
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
