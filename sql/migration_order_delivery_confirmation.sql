/* ================================================================
   Nhiệt Đới Xanh — Migration: Đối soát/chốt hoàn thành đơn hàng
   SQL Server · database BanNuoc_Truc
   File IDEMPOTENT: chạy lại nhiều lần không lỗi, không drop dữ liệu.

   Mục tiêu:
   Thêm Orders.ReceivedConfirmedAt — dùng để tách tab "Chờ xác nhận"
   (DONE nhưng chưa đối soát) và "Thành công" (DONE + admin đã chốt)
   trên /admin/don-hang, KHÔNG thêm giá trị mới vào state machine
   OrderStatuses. Xem AdminOrderController.handleConfirmDelivery /
   OrderDaoImpl.confirmDeliveryByAdmin / countOrdersByTab.
   ================================================================ */

USE BanNuoc_Truc;
GO

IF COL_LENGTH('dbo.Orders', 'ReceivedConfirmedAt') IS NULL
BEGIN
    ALTER TABLE Orders ADD ReceivedConfirmedAt DATETIME2 NULL;
    PRINT N'Đã thêm cột Orders.ReceivedConfirmedAt.';
END
GO
