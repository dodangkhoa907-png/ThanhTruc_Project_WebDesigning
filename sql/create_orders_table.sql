-- ================================================
-- SQL Script: Tạo bảng Orders cho database BanNuoc
-- Database: SQL Server (SSMS 22)
-- ================================================

USE BanNuoc;
GO

-- Xóa bảng cũ nếu tồn tại
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL
    DROP TABLE dbo.Orders;
GO

-- Tạo bảng Orders
CREATE TABLE dbo.Orders (
    OrderId         INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName    NVARCHAR(100)   NOT NULL,
    PhoneNumber     VARCHAR(15)     NOT NULL,
    ShippingAddress NVARCHAR(255)   NOT NULL,
    OrderNote       NVARCHAR(500)   NULL,
    OrderDate       DATETIME2       NOT NULL DEFAULT GETDATE()
);
GO

-- Tạo index cho tra cứu nhanh theo số điện thoại
CREATE INDEX IX_Orders_PhoneNumber ON dbo.Orders (PhoneNumber);
GO

PRINT N'✅ Bảng Orders đã được tạo thành công trong database BanNuoc!';
GO
