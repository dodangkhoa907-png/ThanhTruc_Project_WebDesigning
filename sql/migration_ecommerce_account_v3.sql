/* ================================================================
   Nhiệt Đới Xanh — Migration E-commerce Foundation, BẢN 3
   SQL Server · database BanNuoc_Truc
   File IDEMPOTENT: chạy lại nhiều lần không lỗi, không drop dữ liệu,
   không rename cột cũ, không xóa bảng cũ.

   Chuẩn bị nền tảng cho: khu sản phẩm, giỏ hàng, checkout COD,
   PayOS (sau này), tài khoản khách hàng, lịch sử đơn hàng.

   Bảng đã có sẵn trước migration này (giữ nguyên, chỉ ALTER thêm cột):
     Categories, Products, ProductVariants, Staffs, Feedback,
     Users, CartItems, UserAddresses, AuditLogs, Coupons, Orders,
     OrderDetails
   (xem sql/migration_purenut_port_v2.sql cho lịch sử tạo các bảng này)

   Bảng MỚI trong migration này:
     UserPreferences
   ================================================================ */

USE BanNuoc_Truc;
GO


/* ================================================================
   A. Users — bổ sung cột hồ sơ khách hàng
   ================================================================ */
IF COL_LENGTH('dbo.Users', 'Nickname') IS NULL
BEGIN
    ALTER TABLE Users ADD Nickname NVARCHAR(100) NULL;
    PRINT N'Đã thêm cột Users.Nickname.';
END
GO

IF COL_LENGTH('dbo.Users', 'UpdatedAt') IS NULL
BEGIN
    ALTER TABLE Users ADD UpdatedAt DATETIME2 NULL;
    PRINT N'Đã thêm cột Users.UpdatedAt.';
END
GO


/* ================================================================
   B. UserAddresses — bổ sung cột địa chỉ chi tiết + tọa độ giao hàng
      Giữ nguyên cột Street cũ (đang được UserAddressDaoImpl dùng).
   ================================================================ */
IF COL_LENGTH('dbo.UserAddresses', 'ProvinceCity') IS NULL
BEGIN
    ALTER TABLE UserAddresses ADD ProvinceCity NVARCHAR(100) NULL;
    PRINT N'Đã thêm cột UserAddresses.ProvinceCity.';
END
GO

IF COL_LENGTH('dbo.UserAddresses', 'District') IS NULL
BEGIN
    ALTER TABLE UserAddresses ADD District NVARCHAR(100) NULL;
    PRINT N'Đã thêm cột UserAddresses.District.';
END
GO

IF COL_LENGTH('dbo.UserAddresses', 'Ward') IS NULL
BEGIN
    ALTER TABLE UserAddresses ADD Ward NVARCHAR(100) NULL;
    PRINT N'Đã thêm cột UserAddresses.Ward.';
END
GO

IF COL_LENGTH('dbo.UserAddresses', 'HouseNumberStreet') IS NULL
BEGIN
    ALTER TABLE UserAddresses ADD HouseNumberStreet NVARCHAR(300) NULL;
    PRINT N'Đã thêm cột UserAddresses.HouseNumberStreet.';
END
GO

IF COL_LENGTH('dbo.UserAddresses', 'Latitude') IS NULL
BEGIN
    ALTER TABLE UserAddresses ADD Latitude DECIMAL(10,7) NULL;
    PRINT N'Đã thêm cột UserAddresses.Latitude.';
END
GO

IF COL_LENGTH('dbo.UserAddresses', 'Longitude') IS NULL
BEGIN
    ALTER TABLE UserAddresses ADD Longitude DECIMAL(10,7) NULL;
    PRINT N'Đã thêm cột UserAddresses.Longitude.';
END
GO

IF COL_LENGTH('dbo.UserAddresses', 'UpdatedAt') IS NULL
BEGIN
    ALTER TABLE UserAddresses ADD UpdatedAt DATETIME2 NULL;
    PRINT N'Đã thêm cột UserAddresses.UpdatedAt.';
END
GO

-- Cột Label/RecipientName/IsDefault đã có sẵn (xem migration_purenut_port_v2.sql).
-- Cột "Phone" hiện có đóng vai trò RecipientPhone — KHÔNG rename, KHÔNG thêm cột trùng.
-- Đảm bảo IsDefault NOT NULL DEFAULT 0 (cột cũ có thể đang NULLable) mà không phá dữ liệu:
IF COL_LENGTH('dbo.UserAddresses', 'IsDefault') IS NOT NULL
BEGIN
    UPDATE UserAddresses SET IsDefault = 0 WHERE IsDefault IS NULL;
END
GO

-- Mỗi user tối đa 1 địa chỉ mặc định — filtered unique index an toàn (không lỗi nếu đã tồn tại).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_UserAddresses_DefaultPerUser')
BEGIN
    -- Dọn trùng lặp trước khi tạo index (an toàn: chỉ giữ lại địa chỉ mặc định mới nhất mỗi user).
    ;WITH DupDefaults AS (
        SELECT AddressID,
               ROW_NUMBER() OVER (PARTITION BY UserID ORDER BY AddressID DESC) AS rn
        FROM UserAddresses
        WHERE IsDefault = 1
    )
    UPDATE ua SET ua.IsDefault = 0
    FROM UserAddresses ua
    JOIN DupDefaults d ON ua.AddressID = d.AddressID
    WHERE d.rn > 1;

    CREATE UNIQUE INDEX UQ_UserAddresses_DefaultPerUser
        ON UserAddresses(UserID)
        WHERE IsDefault = 1;
    PRINT N'Đã tạo unique index UQ_UserAddresses_DefaultPerUser.';
END
GO


/* ================================================================
   C. Orders — bổ sung cột thanh toán / PayOS / giao hàng
      Giữ nguyên toàn bộ cột cũ (CustomerName, PhoneNumber, ShippingAddress,
      OrderNote, TotalAmount, ShippingFee, FinalAmount, PaymentMethod,
      OrderStatus, CancelReason, CancelledAt, CouponCode, UserID, HandledBy).
   ================================================================ */
IF COL_LENGTH('dbo.Orders', 'PaymentStatus') IS NULL
BEGIN
    ALTER TABLE Orders ADD PaymentStatus NVARCHAR(30) NOT NULL DEFAULT 'UNPAID';
    PRINT N'Đã thêm cột Orders.PaymentStatus.';
END
GO

IF COL_LENGTH('dbo.Orders', 'StatusUpdatedAt') IS NULL
BEGIN
    ALTER TABLE Orders ADD StatusUpdatedAt DATETIME2 NULL;
    PRINT N'Đã thêm cột Orders.StatusUpdatedAt.';
END
GO

IF COL_LENGTH('dbo.Orders', 'PayOSOrderCode') IS NULL
BEGIN
    ALTER TABLE Orders ADD PayOSOrderCode BIGINT NULL;
    PRINT N'Đã thêm cột Orders.PayOSOrderCode.';
END
GO

IF COL_LENGTH('dbo.Orders', 'PayOSPaymentLinkId') IS NULL
BEGIN
    ALTER TABLE Orders ADD PayOSPaymentLinkId NVARCHAR(100) NULL;
    PRINT N'Đã thêm cột Orders.PayOSPaymentLinkId.';
END
GO

IF COL_LENGTH('dbo.Orders', 'PayOSCheckoutUrl') IS NULL
BEGIN
    ALTER TABLE Orders ADD PayOSCheckoutUrl NVARCHAR(1000) NULL;
    PRINT N'Đã thêm cột Orders.PayOSCheckoutUrl.';
END
GO

IF COL_LENGTH('dbo.Orders', 'PaidAt') IS NULL
BEGIN
    ALTER TABLE Orders ADD PaidAt DATETIME2 NULL;
    PRINT N'Đã thêm cột Orders.PaidAt.';
END
GO

-- CancelReason / CancelledAt đã có sẵn (migration_purenut_port_v2.sql) — không thêm lại.

IF COL_LENGTH('dbo.Orders', 'RecipientName') IS NULL
BEGIN
    ALTER TABLE Orders ADD RecipientName NVARCHAR(100) NULL;
    PRINT N'Đã thêm cột Orders.RecipientName.';
END
GO

IF COL_LENGTH('dbo.Orders', 'RecipientPhone') IS NULL
BEGIN
    ALTER TABLE Orders ADD RecipientPhone NVARCHAR(20) NULL;
    PRINT N'Đã thêm cột Orders.RecipientPhone.';
END
GO

IF COL_LENGTH('dbo.Orders', 'ShippingLatitude') IS NULL
BEGIN
    ALTER TABLE Orders ADD ShippingLatitude DECIMAL(10,7) NULL;
    PRINT N'Đã thêm cột Orders.ShippingLatitude.';
END
GO

IF COL_LENGTH('dbo.Orders', 'ShippingLongitude') IS NULL
BEGIN
    ALTER TABLE Orders ADD ShippingLongitude DECIMAL(10,7) NULL;
    PRINT N'Đã thêm cột Orders.ShippingLongitude.';
END
GO

-- "Note" tương đương OrderNote đã có sẵn — KHÔNG thêm cột Note trùng nghĩa.

-- Unique index cho PayOSOrderCode khi khác NULL.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_Orders_PayOSOrderCode')
BEGIN
    CREATE UNIQUE INDEX UQ_Orders_PayOSOrderCode
        ON Orders(PayOSOrderCode)
        WHERE PayOSOrderCode IS NOT NULL;
    PRINT N'Đã tạo unique index UQ_Orders_PayOSOrderCode.';
END
GO


/* ================================================================
   D. UserPreferences — sở thích khách hàng (bảng mới)
   ================================================================ */
IF OBJECT_ID('dbo.UserPreferences', 'U') IS NULL
BEGIN
    CREATE TABLE UserPreferences (
        PreferenceID   INT IDENTITY PRIMARY KEY,
        UserID         INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Users(UserID),
        PlantInterests NVARCHAR(1000) NULL,
        DecorStyles    NVARCHAR(1000) NULL,
        SpaceType      NVARCHAR(255)  NULL,
        CareLevel      NVARCHAR(100)  NULL,
        Notes          NVARCHAR(1000) NULL,
        UpdatedAt      DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
    PRINT N'Đã tạo bảng UserPreferences.';
END
GO


/* ================================================================
   E. INDEXES bổ sung
   ================================================================ */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_PaymentStatus')
    CREATE INDEX IX_Orders_PaymentStatus ON Orders(PaymentStatus);
GO


/* ================================================================
   F. KIỂM TRA KẾT QUẢ
   ================================================================ */
PRINT N'';
PRINT N'BanNuoc_Truc — migration_ecommerce_account_v3 hoàn tất!';

SELECT 'TABLES' AS [Type], COUNT(*) AS [Count] FROM sys.tables WHERE type = 'U'
UNION ALL SELECT 'USERS', COUNT(*) FROM Users
UNION ALL SELECT 'USER_ADDRESSES', COUNT(*) FROM UserAddresses
UNION ALL SELECT 'USER_PREFERENCES', COUNT(*) FROM UserPreferences
UNION ALL SELECT 'ORDERS', COUNT(*) FROM Orders
UNION ALL SELECT 'CART_ITEMS', COUNT(*) FROM CartItems;
GO
