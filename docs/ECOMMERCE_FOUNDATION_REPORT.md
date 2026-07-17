# Báo cáo: Củng cố nền tảng E-commerce (Prompt 1)

Ngày: 2026-07-17
Phạm vi: Rà soát toàn dự án, chuẩn hóa DB/model/DAO, vá hành vi nguy hiểm — **chưa xây** khu sản phẩm/giỏ hàng/checkout thật (dành cho prompt sau).

## 1. Trạng thái build

- Baseline (trước khi sửa): `mvn clean package` → **PASS**.
- Sau khi sửa (`mvn clean package`) → **PASS**. WAR sinh ra tại `target/NhietDoiXanh_Web.war`.
- JDK đang dùng: OpenJDK 21.0.11 — khớp `maven.compiler.source/target=21` trong `pom.xml`. Không cần đổi JDK.

## 2. File mới

| File | Mục đích |
|---|---|
| `sql/migration_ecommerce_account_v3.sql` | Migration idempotent, bổ sung cột/bảng cho tài khoản khách hàng + đơn hàng + thanh toán |
| `src/main/java/com/nhietdoixanh/util/OrderStatuses.java` | Quản lý tập trung trạng thái đơn hàng |
| `src/main/java/com/nhietdoixanh/util/PaymentStatuses.java` | Quản lý tập trung trạng thái thanh toán |
| `src/main/java/com/nhietdoixanh/model/UserPreferences.java` | Model sở thích khách hàng |
| `src/main/java/com/nhietdoixanh/dao/UserPreferencesDao.java` | Interface DAO sở thích khách hàng |
| `src/main/java/com/nhietdoixanh/dao/impl/UserPreferencesDaoImpl.java` | Implementation (dùng `MERGE` — upsert theo UserID) |
| `docs/ECOMMERCE_FOUNDATION_REPORT.md` | Báo cáo này |

## 3. File đã sửa

| File | Thay đổi |
|---|---|
| `model/User.java` | + `nickname`, `updatedAt` (getter/setter) |
| `model/UserAddress.java` | + `provinceCity`, `district`, `ward`, `houseNumberStreet`, `latitude`, `longitude` (BigDecimal), `updatedAt`. Giữ nguyên `street`, `label`, `recipientName`, `phone`, `isDefault` |
| `model/Order.java` | + `paymentStatus`, `statusUpdatedAt`, `payOSOrderCode`, `payOSPaymentLinkId`, `payOSCheckoutUrl`, `paidAt`, `recipientName`, `recipientPhone`, `shippingLatitude`, `shippingLongitude` |
| `dao/CartItemDao.java` + `impl/CartItemDaoImpl.java` | + `findByIdAndUserId`, `findSelectedByIdsAndUserId`, `deleteSelectedByUserId`, alias `addOrIncrease`/`countItemsByUserId`. Giữ nguyên toàn bộ method cũ |
| `dao/OrderDAO.java` + `impl/OrderDaoImpl.java` | + `findByIdAndUserId`, `findDetailsByOrderIdAndUserId`, `countOrdersByUserId`, `countDoneOrdersByUserId`, `countProcessingOrdersByUserId`, `sumDoneAmountByUserId`, `findOrdersByUserIdPaged`, `adminFindOrdersPaged`, `updateStatusWithValidation`. **Sửa `placeOrder`**: chặn đơn 0 item / FinalAmount ≤ 0; chỉ xóa các dòng giỏ hàng đã đặt (không xóa toàn bộ giỏ) |
| `dao/UserAddressDao.java` + `impl/UserAddressDaoImpl.java` | + `findDefaultByUserId`, `findByIdAndUserId`, `update`, alias `create`/`deleteByIdAndUserId`/`setDefaultAddress`. **Sửa `setDefault`**: rollback khi lỗi, khôi phục `autoCommit`, đóng connection đúng cách (trước đây thiếu) |
| `dao/UserDao.java` + `impl/UserDaoImpl.java` | + `emailExistsForOtherUser`, alias `updateAvatar`/`updatePasswordHash`. `updateProfile` giờ set `UpdatedAt` |
| `controller/OrderServlet.java` | **Vô hiệu hóa tạo Order 0 đồng** — xem mục 5 |
| `filter/SecurityHeadersFilter.java` | `Permissions-Policy: geolocation=()` → `geolocation=(self)` |

## 4. Migration mới — cột/bảng bổ sung

`sql/migration_ecommerce_account_v3.sql` — idempotent (dùng `COL_LENGTH`/`OBJECT_ID`/`IF NOT EXISTS`), không drop dữ liệu, không rename cột cũ, không xóa bảng.

- **Users**: + `Nickname`, `UpdatedAt`
- **UserAddresses**: + `ProvinceCity`, `District`, `Ward`, `HouseNumberStreet`, `Latitude`, `Longitude`, `UpdatedAt`. Giữ nguyên `Street`, `Label`, `RecipientName`, `Phone`, `IsDefault` (cột cũ từ `migration_purenut_port_v2.sql`). Thêm **filtered unique index** `UQ_UserAddresses_DefaultPerUser` đảm bảo mỗi user tối đa 1 địa chỉ mặc định (tự dọn trùng lặp an toàn trước khi tạo index).
- **Orders**: + `PaymentStatus` (default `UNPAID`), `StatusUpdatedAt`, `PayOSOrderCode`, `PayOSPaymentLinkId`, `PayOSCheckoutUrl`, `PaidAt`, `RecipientName`, `RecipientPhone`, `ShippingLatitude`, `ShippingLongitude`. Cột `CancelReason`/`CancelledAt`/`OrderNote` đã có sẵn — không thêm lại. Unique filtered index `UQ_Orders_PayOSOrderCode` (khi khác NULL).
- **UserPreferences** (bảng mới): `PreferenceID`, `UserID` (UNIQUE, FK → Users), `PlantInterests`, `DecorStyles`, `SpaceType`, `CareLevel`, `Notes`, `UpdatedAt`.

**Chưa chạy migration này trên DB thật** — cần chạy thủ công trên SQL Server (`BanNuoc_Truc`) trước khi các DAO mới (đọc cột `PaymentStatus`, `ProvinceCity`, v.v.) hoạt động đúng. Trước khi migration chạy, code build được nhưng các cột mới sẽ ném `SQLException` (cột không tồn tại) nếu DAO mới được gọi.

## 5. Hành vi nguy hiểm đã xử lý

1. **Order 0 đồng (nghiêm trọng nhất)** — `OrderServlet` (`/order`, form "Đặt hàng nhanh" ở trang chủ) trước đây gọi `orderDAO.placeOrder(order, Collections.emptyList())` với `TotalAmount=ShippingFee=FinalAmount=BigDecimal.ZERO` — tạo ra Order "ma" trong DB không có `OrderDetails`. Form này thực chất chỉ thu thập tên/SĐT/địa chỉ, **không có** lựa chọn sản phẩm/số lượng/giá thật.
   - **Đã sửa 2 lớp**:
     - Lớp DAO (`OrderDaoImpl.placeOrder`): từ chối mọi đơn có `cartItems` rỗng hoặc `FinalAmount <= 0` bằng `IllegalArgumentException` — chặn tận gốc, áp dụng cho mọi caller tương lai (kể cả checkout thật sau này nếu có bug).
     - Lớp Servlet (`OrderServlet`): không gọi `placeOrder` nữa. Yêu cầu liên hệ được ghi vào `AuditLogs` (qua `AuditLogger`) rồi redirect `/thankyou`. Không tạo Order giả trong DB. Giao diện trang chủ **không đổi** — form vẫn hoạt động, chỉ thay đổi hành vi backend.
2. **Xóa toàn bộ giỏ hàng khi chỉ checkout một phần** — `OrderDaoImpl.placeOrder` trước đây `DELETE FROM CartItems WHERE UserID = ?` (xóa sạch giỏ). Đã sửa thành `DELETE ... WHERE UserID = ? AND CartItemID IN (...)` — chỉ xóa đúng các dòng đã đặt trong `cartItems` truyền vào.
3. **Tin giá tiền từ frontend** — chưa có route checkout thật nào nhận giá từ client; `CartItemDaoImpl` luôn lấy `Price` bằng JOIN `ProductVariants` (giá thật trong DB), không có input giá từ form. Không phát hiện vi phạm hiện tại — **cần giữ nguyên nguyên tắc này** khi xây `CheckoutController` ở prompt sau (không bao giờ nhận `price`/`totalAmount` từ request parameter).
4. **IDOR (xem đơn/địa chỉ/giỏ hàng của user khác)** — các method DAO hiện có (`cancelOrder`, `requestCancelOrder`, `UserAddressDao.delete`) đã kiểm tra `WHERE ... AND UserID = ?` đúng chuẩn. Các method mới thêm (`findByIdAndUserId`, `findDetailsByOrderIdAndUserId`, `findByIdAndUserId` của UserAddressDao/CartItemDao) đều theo đúng pattern này.
5. **CSRF thiếu ở POST** — `CsrfFilter` áp dụng toàn cục cho POST/PUT/DELETE (`urlPatterns = "/*"`) — không có route nào bị bỏ sót. Không sửa gì.
6. **GET để đổi dữ liệu** — `OrderServlet.doGet` redirect về trang chủ (không xử lý), không phát hiện route ghi dữ liệu qua GET.
7. **Route `/order` cũ** — xem mục 1. Route vẫn tồn tại (không đổi URL, không phá giao diện) nhưng không còn tạo Order giả.

## 6. Bảo mật & Filter — hiện trạng

- `AuthFilter`: đã bảo vệ `/cart/*`, `/checkout/*`, `/account/*`, `/admin/*` — sẵn sàng cho các route mới ở prompt sau. Không sửa.
- `CsrfFilter`: áp dụng toàn cục cho POST/PUT/DELETE, có bypass hợp lệ cho AJAX same-origin (kiểm tra `Origin`/`Referer`). Không sửa.
- `SecurityHeadersFilter`: **đã sửa** `Permissions-Policy` — `geolocation=()` → `geolocation=(self)` để chuẩn bị cho tính năng định vị giao hàng (Latitude/Longitude) ở prompt sau. `microphone`/`camera` vẫn chặn hoàn toàn (không cần dùng).
- `GzipFilter`: buffer toàn bộ response vào bộ nhớ trước khi ghi (`ByteArrayOutputStream`) — **sẽ xung đột với SSE** (Server-Sent Events) nếu dùng cho tính năng real-time trạng thái đơn hàng sau này, vì SSE cần flush từng phần ngay lập tức. Ghi nhận rủi ro, **chưa sửa** (ngoài phạm vi prompt này — chưa có route SSE nào).

## 7. Model/DAO — nền tảng đã sẵn sàng cho prompt sau

- Money: toàn bộ `Order`, `OrderDetail`, `CartItem`, `ProductVariant`, `UserAddress` (Latitude/Longitude) dùng `BigDecimal` — không có `double` ở đâu.
- Ownership luôn kiểm tra trong SQL (`WHERE ... AND UserID = ?`), không dùng `SELECT *` cho code DAO mới (trừ các SELECT cũ đã có sẵn, giữ nguyên để không phá hành vi).
- Transaction: `UserAddressDao.setDefault` (sửa), `OrderDaoImpl.placeOrder`, `OrderDaoImpl.updateStatusWithValidation` dùng transaction/kiểm tra trạng thái đúng cách với rollback + khôi phục autoCommit.
- `OrderStatuses`/`PaymentStatuses` sẵn sàng dùng cho JSP/Servlet mới — có `normalize()` tương thích ngược nếu DB từng lưu nhãn tiếng Việt (dù kiểm tra thực tế cho thấy `Order.orderStatus` hiện tại đã dùng mã tiếng Anh `PENDING/CONFIRMED/...` đúng chuẩn, không phát hiện dữ liệu cũ dạng nhãn Việt).

## 8. Rủi ro còn lại cho prompt sau

1. **Chưa chạy migration_ecommerce_account_v3.sql trên SQL Server thật** — cần DBA/người có quyền chạy trước khi deploy các tính năng dùng cột mới.
2. Chưa có `CartController`/`CheckoutController`/`AccountController` thật — route `/cart`, `/checkout`, `/account` chưa tồn tại (dù đã được `AuthFilter` bảo vệ sẵn).
3. `GzipFilter` buffer toàn bộ response — cần loại trừ route SSE tương lai (`Accept: text/event-stream` hoặc path riêng) trước khi bật real-time.
4. Form "Đặt hàng nhanh" ở trang chủ hiện chỉ ghi audit log, không phản hồi gì cho khách ngoài "cảm ơn" — nên cân nhắc thay hẳn bằng luồng giỏ hàng thật ở prompt sau thay vì giữ mãi dạng thu thập liên hệ.
5. `PayOSOrderCode`/`PayOSPaymentLinkId`/`PayOSCheckoutUrl` mới có cột DB + field model, chưa có logic gọi PayOS API — để dành đúng như yêu cầu prompt.
6. Chưa viết test tự động (dự án hiện không có JUnit/dependency test nào trong `pom.xml`) — mọi xác minh ở prompt này dựa trên đọc code + build thành công, chưa chạy ứng dụng thật trên Tomcat với DB SQL Server (không có sẵn môi trường DB trong phiên làm việc này).
