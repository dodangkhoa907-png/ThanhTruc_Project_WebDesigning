/* ================================================================
   Nhiệt Đới Xanh — Migration PayOS, BẢN 5
   SQL Server · database BanNuoc_Truc
   File IDEMPOTENT: chạy lại nhiều lần không lỗi, không drop dữ liệu,
   không rename cột cũ, không xóa bảng cũ.

   Mục tiêu:
   1) Xác nhận lại các cột PayOS trên Orders đã có từ
      migration_ecommerce_account_v3.sql (phòng trường hợp môi trường
      nào đó chưa chạy v3 — ALTER có điều kiện, không ảnh hưởng COD).
   2) Tạo bảng OrderCartItems: ghi lại CartItemID nào thuộc về đơn
      PayOS nào tại thời điểm tạo đơn, để webhook PAID xóa ĐÚNG các
      dòng giỏ hàng đó — không được xóa CartItems ngay khi tạo payment
      link (khi chưa chắc thanh toán thành công), và không được xóa
      toàn bộ giỏ hàng của user.
   ================================================================ */

USE BanNuoc_Truc;
GO


/* ================================================================
   A. Orders — xác nhận lại cột PayOS (idempotent, nhắc lại từ v3)
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

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_Orders_PayOSOrderCode')
BEGIN
    CREATE UNIQUE INDEX UQ_Orders_PayOSOrderCode
        ON Orders(PayOSOrderCode)
        WHERE PayOSOrderCode IS NOT NULL;
    PRINT N'Đã tạo unique index UQ_Orders_PayOSOrderCode.';
END
GO


/* ================================================================
   B. OrderCartItems — mapping CartItemID đã "đóng băng" vào một đơn
      PayOS tại thời điểm tạo payment link. KHÔNG có khóa ngoại tới
      CartItems (dòng giỏ hàng vẫn có thể bị người dùng xóa/sửa trong
      lúc chờ thanh toán — webhook PAID sẽ chỉ xóa CartItemID nào
      TRÙNG UserID và vẫn còn tồn tại, không lỗi nếu đã bị xóa trước).
   ================================================================ */
IF OBJECT_ID('dbo.OrderCartItems', 'U') IS NULL
BEGIN
    CREATE TABLE OrderCartItems (
        ID          INT IDENTITY PRIMARY KEY,
        OrderID     INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
        UserID      INT NOT NULL,
        CartItemID  INT NOT NULL,
        CreatedAt   DATETIME2 NOT NULL DEFAULT SYSDATETIME()
    );
    PRINT N'Đã tạo bảng OrderCartItems.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderCartItems_OrderID')
    CREATE INDEX IX_OrderCartItems_OrderID ON OrderCartItems(OrderID);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderCartItems_UserID')
    CREATE INDEX IX_OrderCartItems_UserID ON OrderCartItems(UserID);
GO


/* ================================================================
   C. KIỂM TRA KẾT QUẢ
   ================================================================ */
PRINT N'';
PRINT N'BanNuoc_Truc — migration_payos_v5 hoàn tất!';

SELECT 'TABLES' AS [Type], COUNT(*) AS [Count] FROM sys.tables WHERE type = 'U'
UNION ALL SELECT 'ORDERS', COUNT(*) FROM Orders
UNION ALL SELECT 'ORDER_CART_ITEMS', COUNT(*) FROM OrderCartItems;
GO
