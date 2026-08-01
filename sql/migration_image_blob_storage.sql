-- ============================================================================
-- Lưu ảnh sản phẩm/avatar trong DB thay vì đĩa cục bộ.
--
-- LÝ DO: đĩa của container trên Render (và hầu hết PaaS) là EPHEMERAL — mọi file
-- ghi lúc runtime (ProductImageUpload/AvatarUpload trước đây dùng context.getRealPath()
-- để ghi vào /uploads/products, /uploads/avatars trong webapp đang chạy) sẽ MẤT SẠCH
-- mỗi khi deploy lại hoặc container khởi động lại (kể cả khi service "ngủ" rồi "thức"
-- ở gói free). Đó là lý do admin phải tải lại ảnh sau mỗi lần deploy.
--
-- DB (SQL Server) đã có sẵn và bền vững qua mọi lần deploy — chuyển ảnh vào đây,
-- serve qua ImageServlet (/uploads/products/{id}, /uploads/avatars/{id}) thay vì file
-- tĩnh. URL không đổi format nên JSP không cần sửa gì (<img src="${ctx}${x.imageUrl}">).
-- ============================================================================
USE BanNuoc_Truc;

IF COL_LENGTH('dbo.Products', 'ImageData') IS NULL
    ALTER TABLE Products ADD ImageData VARBINARY(MAX) NULL;
GO

IF COL_LENGTH('dbo.Products', 'ImageContentType') IS NULL
    ALTER TABLE Products ADD ImageContentType NVARCHAR(50) NULL;
GO

IF COL_LENGTH('dbo.Users', 'AvatarData') IS NULL
    ALTER TABLE Users ADD AvatarData VARBINARY(MAX) NULL;
GO

IF COL_LENGTH('dbo.Users', 'AvatarContentType') IS NULL
    ALTER TABLE Users ADD AvatarContentType NVARCHAR(50) NULL;
GO
