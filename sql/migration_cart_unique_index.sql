/* ================================================================
   Nhiệt Đới Xanh — Migration: Unique index chống trùng CartItems
   SQL Server · database BanNuoc_Truc
   File IDEMPOTENT: chạy lại nhiều lần không lỗi, không drop dữ liệu.

   Mục tiêu:
   CartItemDaoImpl.insertOrUpdate() trước đây đọc-rồi-ghi (SELECT rồi
   UPDATE/INSERT) trong 2 câu SQL tách rời — 2 request "Thêm vào giỏ"
   cùng lúc cho cùng 1 (UserID, VariantID) có thể cùng thấy "chưa có
   dòng nào" rồi cùng INSERT, tạo 2 dòng CartItems trùng variant cho
   cùng 1 user (lost-update race). Đã sửa insertOrUpdate() dùng UPDATE
   atomic trước, chỉ INSERT khi UPDATE báo 0 dòng — nhưng vẫn cần
   unique index này làm lưới an toàn cuối cùng ở tầng DB (bắt lỗi
   duplicate-key, DAO tự retry sang UPDATE — xem insertOrUpdate()).
   ================================================================ */

USE BanNuoc_Truc;
GO

-- Dọn trùng lặp trước khi tạo unique index (an toàn: gộp Quantity vào dòng cũ nhất,
-- xóa các dòng trùng còn lại — không mất dữ liệu số lượng của khách).
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_CartItems_User_Variant')
BEGIN
    ;WITH DupGroups AS (
        SELECT CartItemID, UserID, VariantID,
               ROW_NUMBER() OVER (PARTITION BY UserID, VariantID ORDER BY CartItemID ASC) AS rn
        FROM CartItems
    )
    UPDATE c
    SET c.Quantity = (
        SELECT SUM(c2.Quantity) FROM CartItems c2
        WHERE c2.UserID = c.UserID AND c2.VariantID = c.VariantID
    )
    FROM CartItems c
    JOIN DupGroups d ON c.CartItemID = d.CartItemID AND d.rn = 1;

    ;WITH DupGroups AS (
        SELECT CartItemID,
               ROW_NUMBER() OVER (PARTITION BY UserID, VariantID ORDER BY CartItemID ASC) AS rn
        FROM CartItems
    )
    DELETE c FROM CartItems c
    JOIN DupGroups d ON c.CartItemID = d.CartItemID
    WHERE d.rn > 1;

    -- Cap lại 99 nếu gộp Quantity vượt giới hạn (khớp MAX_QUANTITY trong CartController).
    UPDATE CartItems SET Quantity = 99 WHERE Quantity > 99;

    CREATE UNIQUE INDEX UX_CartItems_User_Variant ON CartItems(UserID, VariantID);
    PRINT N'Đã tạo unique index UX_CartItems_User_Variant.';
END
GO
