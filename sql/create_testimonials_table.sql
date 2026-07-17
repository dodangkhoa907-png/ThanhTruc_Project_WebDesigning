-- ================================================
-- SQL Script: Tạo bảng Testimonials cho database BanNuoc
-- Database: SQL Server (SSMS 22)
-- ================================================

USE BanNuoc;
GO

-- Xóa bảng cũ nếu tồn tại
IF OBJECT_ID('dbo.Testimonials', 'U') IS NOT NULL
    DROP TABLE dbo.Testimonials;
GO

-- Tạo bảng Testimonials
CREATE TABLE dbo.Testimonials (
    TestimonialId   INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName    NVARCHAR(100)   NOT NULL,
    DrinkName       NVARCHAR(100)   NOT NULL,
    Rating          INT             NOT NULL CHECK (Rating >= 1 AND Rating <= 5),
    AvatarUrl       NVARCHAR(500)   NULL,
    FeedbackText    NVARCHAR(150)   NOT NULL,
    CreatedDate     DATETIME2       NOT NULL DEFAULT GETDATE()
);
GO

-- Chèn dữ liệu mẫu ban đầu
INSERT INTO dbo.Testimonials (CustomerName, DrinkName, Rating, AvatarUrl, FeedbackText)
VALUES 
(N'Khánh Linh', N'Ép Cam Dứa Hấu', 5, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=120', N'Nước ép ngon lắm nha mọi người ơi! Cam rất ngọt thanh, không bị gắt đường hóa học. Giao hàng hỏa tốc trong trường siêu nhanh luôn, 10 điểm!'),
(N'Đăng Khoa', N'Ép Mix Cam Cà Rốt', 4, 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=120', N'Hương vị thơm ngon tự nhiên từ hoa quả chín mọng. Mình rất thích vị chua nhẹ xen lẫn bùi bùi của cà rốt. Sẽ ủng hộ Nhiệt Đới Xanh dài dài.'),
(N'Minh Thư', N'Nước Ép Thơm', 5, 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&q=80&w=120', N'Trái cây siêu tươi, ly nước ép đầy đặn uống đã ghê luôn. Các bạn phục vụ rất nhiệt tình, chu đáo. Cực kỳ recommend vị dứa!');
GO

PRINT N'✅ Bảng Testimonials đã được tạo và chèn dữ liệu mẫu thành công!';
GO
