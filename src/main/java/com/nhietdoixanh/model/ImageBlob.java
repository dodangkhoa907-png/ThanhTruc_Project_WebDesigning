package com.nhietdoixanh.model;

/**
 * Ảnh nhị phân đọc từ DB (Products.ImageData / Users.AvatarData) — thay cho việc lưu file
 * trên đĩa cục bộ. Đĩa của container trên Render là ephemeral (mất sạch mỗi lần deploy lại
 * hoặc container khởi động lại), nên ảnh admin/khách hàng upload phải nằm trong DB mới bền
 * vững được qua các lần deploy.
 */
public record ImageBlob(byte[] data, String contentType) {
}
