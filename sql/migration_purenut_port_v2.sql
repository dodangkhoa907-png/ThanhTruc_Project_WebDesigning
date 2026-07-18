/* ================================================================
   Nhiệt Đới Xanh — PORT TỪ PureNut, BẢN 2 (khớp schema thật đã có sẵn)
   SQL Server · database BanNuoc_Truc
   File IDEMPOTENT: chạy lại nhiều lần không lỗi.

   THAY THẾ migration_purenut_port.sql (bản cũ SAI — tưởng nhầm Orders
   là bảng đơn giản cũ và sẽ đổi tên bảng Orders thật đang dùng).
   KHÔNG CHẠY migration_purenut_port.sql nữa — chỉ chạy file này.

   Bảng ĐÃ CÓ SẴN (giữ nguyên, không đổi cấu trúc):
     Categories, Products, ProductVariants, Orders, OrderDetails,
     Feedback, Staffs

   Bảng MỚI (bổ sung cho auth khách hàng + giỏ hàng + audit):
     Users, CartItems, UserAddresses, AuditLogs, Coupons

   Cột MỚI thêm vào bảng có sẵn:
     Orders.UserID (nullable — link đơn hàng với tài khoản, vẫn cho
                     phép đặt hàng khách vãng lai như thiết kế gốc)
   ================================================================ */

USE BanNuoc_Truc;
GO


/* ================================================================
   0. DỌN DỮ LIỆU SEED BỊ TRÙNG (chạy 2 lần script cũ trước đây)
      An toàn vì Orders/OrderDetails đang rỗng.
   ================================================================ */
IF EXISTS (SELECT 1 FROM ProductVariants WHERE VariantID BETWEEN 7 AND 12)
BEGIN
    DELETE FROM ProductVariants WHERE VariantID BETWEEN 7 AND 12;
    PRINT N'Đã xóa ProductVariants trùng (ID 7-12).';
END
IF EXISTS (SELECT 1 FROM Products WHERE ProductID BETWEEN 4 AND 6)
BEGIN
    DELETE FROM Products WHERE ProductID BETWEEN 4 AND 6;
    PRINT N'Đã xóa Products trùng (ID 4-6).';
END
IF EXISTS (SELECT 1 FROM Categories WHERE CategoryID BETWEEN 4 AND 6)
BEGIN
    DELETE FROM Categories WHERE CategoryID BETWEEN 4 AND 6;
    PRINT N'Đã xóa Categories trùng (ID 4-6).';
END
GO


/* ================================================================
   1. Users — tài khoản khách hàng (đăng ký/đăng nhập/giỏ hàng/địa chỉ)
      Admin/nhân viên tiếp tục dùng bảng Staffs có sẵn, KHÔNG dùng bảng này.
   ================================================================ */
IF OBJECT_ID('dbo.Users', 'U') IS NULL
CREATE TABLE Users (
  UserID       INT IDENTITY PRIMARY KEY,
  FullName     NVARCHAR(150)  NOT NULL,
  Email        NVARCHAR(150)  UNIQUE NOT NULL,
  Phone        NVARCHAR(20),
  PasswordHash NVARCHAR(255)  NOT NULL,
  Role         NVARCHAR(20)   DEFAULT 'CUSTOMER',     -- luôn CUSTOMER (admin ở bảng Staffs)
  CreatedAt    DATETIME       DEFAULT GETDATE(),
  LastLoginIP  NVARCHAR(45),
  LastLoginAt  DATETIME,
  AgreedTermsAt DATETIME,
  ProfileImage NVARCHAR(MAX)  NULL                    -- avatar base64
);
GO


/* ================================================================
   2. CartItems — giỏ hàng (theo ProductVariants vì giá tính theo size)
   ================================================================ */
IF OBJECT_ID('dbo.CartItems', 'U') IS NULL
CREATE TABLE CartItems (
  CartItemID INT IDENTITY PRIMARY KEY,
  UserID     INT       NOT NULL FOREIGN KEY REFERENCES Users(UserID),
  VariantID  INT       NOT NULL FOREIGN KEY REFERENCES ProductVariants(VariantID),
  Quantity   INT       NOT NULL DEFAULT 1,
  CreatedAt  DATETIME  DEFAULT GETDATE(),
  CONSTRAINT UQ_CartItems_User_Variant UNIQUE (UserID, VariantID)
);
GO


/* ================================================================
   3. UserAddresses — sổ địa chỉ giao hàng
   ================================================================ */
IF OBJECT_ID('dbo.UserAddresses', 'U') IS NULL
CREATE TABLE UserAddresses (
  AddressID     INT IDENTITY(1,1) PRIMARY KEY,
  UserID        INT            NOT NULL FOREIGN KEY REFERENCES Users(UserID),
  Label         NVARCHAR(50)   NOT NULL DEFAULT N'Nhà riêng',
  RecipientName NVARCHAR(100),
  Phone         VARCHAR(15),
  Street        NVARCHAR(500)  NOT NULL,
  IsDefault     BIT            DEFAULT 0,
  CreatedAt     DATETIME2      DEFAULT GETDATE()
);
GO


/* ================================================================
   4. AuditLogs — nhật ký hành động Staffs (thay AuditLogs.UserID trỏ Staffs)
   ================================================================ */
IF OBJECT_ID('dbo.AuditLogs', 'U') IS NULL
CREATE TABLE AuditLogs (
  LogID     INT IDENTITY PRIMARY KEY,
  StaffID   INT           NULL FOREIGN KEY REFERENCES Staffs(StaffID),
  Action    NVARCHAR(100) NOT NULL,
  Target    NVARCHAR(200),
  Detail    NVARCHAR(MAX),
  IpAddress NVARCHAR(60),
  CreatedAt DATETIME      DEFAULT GETDATE()
);
GO


/* ================================================================
   5. Coupons — mã giảm giá
   ================================================================ */
IF OBJECT_ID('dbo.Coupons', 'U') IS NULL
CREATE TABLE Coupons (
  CouponID      INT IDENTITY PRIMARY KEY,
  Code          NVARCHAR(30)   UNIQUE NOT NULL,
  Description   NVARCHAR(200),
  DiscountType  NVARCHAR(20)   NOT NULL DEFAULT 'PERCENT',
  DiscountValue DECIMAL(10,2)  NOT NULL,
  MinOrderAmount DECIMAL(12,2) DEFAULT 0,
  MaxDiscount   DECIMAL(12,2)  NULL,
  UsageLimit    INT            DEFAULT NULL,
  UsedCount     INT            DEFAULT 0,
  StartDate     DATETIME       DEFAULT GETDATE(),
  EndDate       DATETIME       NULL,
  IsActive      BIT            DEFAULT 1,
  CreatedAt     DATETIME       DEFAULT GETDATE()
);
GO


/* ================================================================
   6. Orders — thêm UserID (nullable, giữ tương thích khách vãng lai)
   ================================================================ */
IF COL_LENGTH('dbo.Orders', 'UserID') IS NULL
BEGIN
    ALTER TABLE Orders ADD UserID INT NULL FOREIGN KEY REFERENCES Users(UserID);
    PRINT N'Đã thêm cột Orders.UserID.';
END
GO

-- Đơn hàng khách tự hủy / admin duyệt hủy (tương thích luồng PureNut)
IF COL_LENGTH('dbo.Orders', 'CancelReason') IS NULL
    ALTER TABLE Orders ADD CancelReason NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.Orders', 'CancelledAt') IS NULL
    ALTER TABLE Orders ADD CancelledAt DATETIME NULL;
IF COL_LENGTH('dbo.Orders', 'CouponCode') IS NULL
    ALTER TABLE Orders ADD CouponCode NVARCHAR(30) NULL;
GO


/* ================================================================
   7. INDEXES
   ================================================================ */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CartItems_User')
  CREATE INDEX IX_CartItems_User ON CartItems(UserID);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UserAddresses_UserID')
  CREATE INDEX IX_UserAddresses_UserID ON UserAddresses(UserID);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AuditLogs_Staff')
  CREATE INDEX IX_AuditLogs_Staff ON AuditLogs(StaffID, CreatedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Coupons_Code')
  CREATE UNIQUE INDEX IX_Coupons_Code ON Coupons(Code);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_User')
  CREATE INDEX IX_Orders_User ON Orders(UserID, CreatedAt DESC);
GO


/* ================================================================
   8. RESET MẬT KHẨU TEST cho 5 tài khoản Staffs hiện có
      Mật khẩu mới: Staff@123  (đổi lại sau khi test xong!)
   ================================================================ */
UPDATE Staffs
SET PasswordHash = '$2a$10$i4o.Sf9WvWc3PANdPT/LquxbEKMRw3531X0YVR7tyidyONALM2JZm'
WHERE Username IN ('oanhttk','tienlpm','kylu','thutna','tructdt');
PRINT N'Đã reset mật khẩu 5 tài khoản Staffs về Staff@123.';
GO


/* ================================================================
   9. Coupon mẫu
   ================================================================ */
IF NOT EXISTS (SELECT 1 FROM Coupons WHERE Code = 'NDXANH10')
INSERT INTO Coupons (Code, Description, DiscountType, DiscountValue, MinOrderAmount, MaxDiscount)
VALUES ('NDXANH10', N'Giảm 10% cho đơn đầu tiên', 'PERCENT', 10, 40000, 20000);
GO


/* ================================================================
   10. KIỂM TRA KẾT QUẢ
   ================================================================ */
PRINT N'';
PRINT N'BanNuoc_Truc — Port từ PureNut (bản 2) hoàn tất!';

SELECT 'TABLES' AS [Type], COUNT(*) AS [Count] FROM sys.tables WHERE type = 'U'
UNION ALL SELECT 'CATEGORIES', COUNT(*) FROM Categories
UNION ALL SELECT 'PRODUCTS', COUNT(*) FROM Products
UNION ALL SELECT 'VARIANTS', COUNT(*) FROM ProductVariants
UNION ALL SELECT 'STAFFS', COUNT(*) FROM Staffs
UNION ALL SELECT 'COUPONS', COUNT(*) FROM Coupons;
GO

/* ================================================================
   TÀI KHOẢN TEST:
     Staff (5 tài khoản, role MANAGER/DELIVERY/PROCESSOR/SALES):
       oanhttk / Staff@123   (MANAGER)
       tienlpm / Staff@123   (DELIVERY — vai trò giao hàng, KHÔNG xây
                               tính năng shipper riêng theo yêu cầu)
       kylu    / Staff@123   (PROCESSOR)
       thutna  / Staff@123   (SALES)
       tructdt / Staff@123   (SALES)
     Customer (do app tự seed lúc khởi động — xem AppContextListener.java):
       khachhang@gmail.com / Customer@123
   ================================================================ */
