-- Migration: Update admin account username to trucdttty00312@gmail.com
-- Database: BanNuoc_Truc

UPDATE Staffs
SET Username = 'trucdttty00312@gmail.com'
WHERE StaffID = 7 OR Username = 'khoaddty00210@gmail.com';
GO

PRINT N'Đã cập nhật tên đăng nhập admin thành trucdttty00312@gmail.com.';
GO
