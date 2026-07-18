# Prompt 6 — Fix Giao Diện Checkout + Dashboard Tài Khoản Khách Hàng

## Phần A — Fix Giao Diện /checkout

### Lỗi thật sự là gì (đã kiểm tra, không đoán)

Trước khi sửa bất cứ gì, đã đọc lại `checkout.jsp` và `product.css` — cả hai **đã sẵn có đầy đủ** layout 2 cột, card, input đẹp, GPS button 3 trạng thái, radio card cho phương thức thanh toán (348 dòng CSS `.checkout-*` đã tồn tại trong working tree, chưa commit). Mở trang bằng trình duyệt tự động (phiên chưa từng cache gì) thì **trang hiển thị đúng như thiết kế** — mâu thuẫn với ảnh chụp màn hình xấu của người dùng.

Đối chiếu `git diff`/`git log` phát hiện nguyên nhân thật: khối CSS `.checkout-*` (348 dòng) được thêm **sau khi** `cart.jsp`/`checkout.jsp` đã dùng chung `product.css?v=2` (gán từ commit "Polish cart page UI"). Filter `CacheHeaderFilter` set `Cache-Control: public, max-age=604800, immutable` cho `/css/*` — trình duyệt nào đã từng mở `/cart` trước đó sẽ cache `product.css?v=2` **vĩnh viễn trong 7 ngày** (do `immutable`) và không bao giờ tải lại, kể cả khi nội dung file đổi. Khi mở `/checkout` (dùng chung URL `?v=2`), trình duyệt phục vụ bản cache CŨ — không có class `.checkout-card` v.v. → trang trông như chưa style gì, đúng y hệt ảnh chụp màn hình.

**Đây không phải lỗi thiếu code, mà là lỗi cache-busting** (quên tăng version khi sửa file CSS dùng chung).

### 2 lỗi thật đã sửa

1. **Cache-busting**: Tăng `?v=2 → ?v=3` cho `style.css`/`product.css` trong `checkout.jsp`, `cart.jsp`, `checkout-success.jsp` — buộc trình duyệt tải lại nội dung mới.
2. **Bug di động thật sự nghiêm trọng** (tự phát hiện qua review CSS, đã xác nhận bằng browser thật ở 375px): `checkout.jsp` tái dùng class `cart-summary` cho khối tóm tắt đơn hàng, nhưng CSS có sẵn `@media (max-width:640px){.cart-summary{display:none}}` — quy tắc này được thiết kế riêng cho `/cart` (có `.cart-mobile-bar` thay thế). Trang `/checkout` **không có** thanh mobile thay thế, và nút "Đặt Hàng" duy nhất nằm trong chính `.cart-summary` → **trên di động, khách hàng không thể đặt hàng vì nút biến mất hoàn toàn** (đã đo `getBoundingClientRect()` = 0×0 trước khi sửa). Đã sửa bằng cách thêm class `checkout-summary` vào thẻ `<aside>` và scope lại CSS: `.cart-summary:not(.checkout-summary){display:none}` — không ảnh hưởng `/cart` (đã kiểm tra lại `/cart` ở 375px vẫn hoạt động như cũ).

### Cải thiện nhỏ khác

- `CheckoutController` (`handleCheckoutPage`, `forwardCheckoutPageWithErrors`) thêm `request.setAttribute("currentPage", "cart")` — icon giỏ hàng trên header giờ active khi đang ở `/checkout` (trước đó không active gì).

### File đã sửa

| File | Thay đổi |
|---|---|
| `src/main/webapp/WEB-INF/views/checkout.jsp` | Bump `?v=3`; thêm class `checkout-summary` vào `<aside>` |
| `src/main/webapp/WEB-INF/views/cart.jsp` | Bump `?v=3` (dùng chung `product.css` với checkout) |
| `src/main/webapp/WEB-INF/views/checkout-success.jsp` | Bump `?v=3` |
| `src/main/webapp/css/product.css` | Scope lại rule ẩn summary trên mobile: `.cart-summary:not(.checkout-summary)` |
| `src/main/java/com/nhietdoixanh/controller/CheckoutController.java` | Set `currentPage=cart` khi forward tới checkout.jsp (2 chỗ) |

**Không sửa** `checkout.js` — đã kiểm tra kỹ, GPS 3 trạng thái (loading/success/error) và chặn double-submit đã đúng chuẩn, không cần đổi gì.

### Kết quả test (browser thật, không phải giả định)

1. Desktop 1280px: `.checkout-layout` = `grid | 744px 380px` (khớp cột trái/phải), `.checkout-card` có border/bo góc/nền trắng đúng thiết kế, `.cart-summary` (khối tóm tắt) `position: sticky`. Body nền `rgb(253,251,247)` = `#FDFBF7` đúng palette.
2. Mobile 375px: `.checkout-summary { display: block }`, nút "Đặt Hàng" hiển thị đầy đủ (284×49px) — bug đã fix. `/cart` ở cùng viewport vẫn `display:none` cho summary + `.cart-mobile-bar` vẫn hoạt động — không phá cart.
3. Đặt hàng COD thật (đơn `#5`) thành công qua giao diện đã fix — không phá logic COD.
4. Console không lỗi, Network không 404 (`product.css?v=3`, `style.css?v=3`, `checkout.js?v=1` đều 200).

## Phần B — Dashboard Tài Khoản Khách Hàng

### Route đã tạo

Tất cả trong `AccountController` (`@WebServlet`, không cần sửa `web.xml`), nằm dưới `/account/*` — đã được `AuthFilter` có sẵn từ trước bắt buộc đăng nhập:

| Route | Method | Chức năng |
|---|---|---|
| `/account` | GET | Dashboard: hồ sơ, cấp bậc, thống kê |
| `/account/orders` | GET | Lịch sử đơn: lọc trạng thái + tìm mã đơn + phân trang |
| `/account/orders/detail?id=` | GET | Chi tiết đơn — ownership kiểm tra trong SQL |
| `/account/orders/status?id=` | GET | JSON nhẹ, poll mỗi 20s để cập nhật badge gần-realtime |
| `/account/order/cancel` | POST | Hủy đơn / gửi yêu cầu hủy theo state machine |

`/account/order/cancel` chỉ nhận POST (GET → `405`, đã test bằng `fetch` trực tiếp).

### File đã tạo/sửa

**Mới:**
- `controller/AccountController.java`
- `util/MemberTierService.java` — enum `Tier` + ngưỡng tập trung một chỗ
- `WEB-INF/views/account/dashboard.jsp`, `orders.jsp`, `order-detail.jsp`
- `WEB-INF/views/common/account-sidebar.jsp` — sidebar dùng chung 3 trang
- `css/account.css`

**Sửa:**
- `model/Order.java` — thêm `userEmail`, `productSummary` (bổ sung cho UI, join sẵn), và 2 getter tính sẵn `getOrderStatusLabel()`/`getPaymentStatusLabel()` (delegate `OrderStatuses.getLabel()`/`PaymentStatuses.getLabel()`) — dùng trực tiếp trong JSP, không hiện mã trạng thái tiếng Anh trần.
- `dao/OrderDAO.java` + `dao/impl/OrderDaoImpl.java` — thêm `findOrdersByUserIdFiltered`/`countOrdersByUserIdFiltered` (lọc trạng thái + tìm mã đơn + phân trang, luôn ràng buộc `UserID` trong SQL). Các method sẵn có từ Prompt 1 (`countOrdersByUserId`, `countDoneOrdersByUserId`, `countProcessingOrdersByUserId`, `sumDoneAmountByUserId`, `findByIdAndUserId`, `findDetailsByOrderIdAndUserId`, `cancelOrder`, `requestCancelOrder`) **tái sử dụng nguyên vẹn**, không sửa.
- `WEB-INF/views/common/customer-header.jsp` — link tên user (trước trỏ về `/`) nay trỏ `/account`, có active state khi `currentPage=='account'`.
- `WEB-INF/views/admin/dashboard.jsp`, `admin/orders/list.jsp`, `admin/orders/detail.jsp` — tiện thể fix luôn phần badge admin (từ Prompt 5) đang hiện mã trạng thái tiếng Anh trần (`PENDING`, `CONFIRMED`...) thay vì nhãn tiếng Việt — dùng lại 2 getter mới thêm ở `Order.java`, không đổi logic.

### DAO/Service đã thêm — chi tiết

- `findOrdersByUserIdFiltered`/`countOrdersByUserIdFiltered`: build `WHERE` động (status optional, `OrderID = ?` optional) giống style `ProductDaoImpl`/admin search đã có — `PreparedStatement` đầy đủ, `OFFSET...FETCH NEXT` phân trang phía SQL Server, **không load hết đơn vào RAM**.
- Truy vấn danh sách kèm subquery `STRING_AGG` lấy "sản phẩm rút gọn" mỗi đơn (`Ép Cam Nguyên Chất (M), ...`) trong **một** câu SQL — tránh N+1 query mà vẫn đáp ứng yêu cầu hiển thị sản phẩm rút gọn trong list.
- `MemberTierService`: enum `Tier` (`MAM_XANH` 0đ, `LA_XANH` 300.000đ, `VUON_NHIET_DOI` 1.000.000đ, `DAI_SU_XANH` 3.000.000đ) — ngưỡng đặt tập trung ở một chỗ, sửa số tiền là đủ. `resolve()`/`nextTier()`/`amountToNextTier()` tính từ `sumDoneAmountByUserId` (chỉ đơn `DONE`, đơn hủy không tính). % thanh tiến độ tính bằng `BigDecimal` ở tầng Java (không chia trong JSP EL — tránh `ArithmeticException` với số thập phân vô hạn tuần hoàn).

### Cách tính member tier

```
sumDoneAmountByUserId(userId)  →  tổng FinalAmount các đơn OrderStatus = 'DONE'
        │
        ▼
MemberTierService.resolve(total)
  ≥ 3.000.000đ → Đại Sứ Xanh
  ≥ 1.000.000đ → Vườn Nhiệt Đới
  ≥   300.000đ → Lá Xanh
  else         → Mầm Xanh
```
Ngưỡng ví dụ, dễ chỉnh — chỉ cần sửa `Tier` enum trong `MemberTierService.java`.

### State machine hủy đơn (khách hàng)

Tái dùng nguyên `OrderStatuses.isCancellableByCustomer(status, paymentStatus)` có sẵn từ Prompt 1 làm cổng kiểm tra đầu tiên (chỉ cho phép khi `PENDING`/`CONFIRMED` và chưa `PAID`). Dựa vào trạng thái hiện tại, dispatch đúng route business đã có sẵn trong `OrderDaoImpl`:

```
PENDING    → cancelOrder()        → CANCELLED ngay lập tức (đơn chưa ai xử lý)
CONFIRMED  → requestCancelOrder() → PENDING_CANCEL (chờ admin duyệt — dùng UI admin đã làm ở Prompt 5)
DONE / CANCELLED / SHIPPING / PENDING_CANCEL → bị chặn (isCancellableByCustomer = false)
```
Validate **hoàn toàn ở backend** (`AccountController` + `OrderDaoImpl`), không chỉ ẩn nút UI. Hành động khách tự hủy được ghi vào `AuditLogs` (tái dùng hạ tầng Prompt 5, `staffId=null`) để hiển thị trong "Timeline trạng thái" — admin cũng thấy được log này.

### Bảo mật

- `AuthFilter` có sẵn (`/account/*`) chặn truy cập chưa đăng nhập — không sửa filter.
- `userId` luôn lấy từ `session.getAttribute("user")`, không nhận từ request.
- Mọi truy vấn đơn của khách đều có `WHERE OrderID = ? AND UserID = ?` **ngay trong SQL** (`findByIdAndUserId`) — không lấy `OrderID` rồi tự so sánh ở tầng khác.
- CSRF: mọi form POST có `_csrf` hidden field; đã test bằng `fetch()` trực tiếp thiếu token → **403** xác nhận.
- `cancelReason` validate độ dài ≤ 500 và không rỗng ở backend.
- Không trả stack trace ra browser — lỗi hệ thống log `System.err`, JSP chỉ hiện flash message tiếng Việt.
- Toàn bộ text người dùng nhập hiển thị qua `<c:out>`.

### Checklist test (browser thật)

| # | Test | Kết quả |
|---|---|---|
| 1 | Chưa login vào `/account` | Redirect `/login` ✓ |
| 2 | Login vào `/account` | Thấy dashboard đầy đủ ✓ |
| 3 | Stats đúng với DB | 2 đơn, 0 hoàn thành, 0 đang xử lý, 0đ chi tiêu — khớp dữ liệu thật ✓ |
| 4 | Member tier tính đúng | "Mầm Xanh" (chưa có đơn DONE) + thanh tiến độ "Chi thêm 300.000đ để lên Lá Xanh" ✓ |
| 5 | `/account/orders` thấy đơn đã đặt | 2 đơn hiển thị, có "sản phẩm rút gọn" đúng ✓ |
| 6 | Filter theo mã đơn (`?q=4`) | Chỉ còn đơn #4 ✓ |
| 7 | Pagination | Có logic (chưa đủ dữ liệu để thấy nhiều trang, code dùng cùng pattern `c:url`/`c:param` đã verify ở admin Prompt 5) |
| 8 | Vào chi tiết đơn #4 | Đúng sản phẩm, địa chỉ, timeline ✓ |
| 9 | Sửa `id=1` (đơn không thuộc user) | Redirect về `/account/orders`, không lộ dữ liệu ✓ |
| 10 | Hủy đơn PENDING (#4) | Thành công → "Đã hủy", timeline ghi nhận lý do + thời điểm ✓ |
| 11 | Hủy đơn đã CANCELLED (thử lại #4) | Bị chặn — "Đơn hàng ở trạng thái hiện tại không thể tự hủy" ✓ |
| — | CSRF thiếu token (`fetch` trực tiếp) | `403` ✓ |
| — | GET vào `/account/order/cancel` | `405` ✓ |
| — | `/account/orders/status?id=1` (không thuộc user) | `404`, không lộ thông tin ✓ |
| 12 | Header active đúng | Link tên user có class `active` khi ở `/account` ✓ |
| 13 | Tiếng Việt không lỗi encoding | Toàn bộ trang, kể cả địa chỉ có dấu nhập tay ("Ệ Đ Ơ Ư") round-trip đúng ✓ |
| 14 | `/cart`, `/checkout`, `/san-pham` không hỏng | Test lại sau khi restart Tomcat — cả 3 vẫn hoạt động, console sạch ✓ |
| 14 | `/admin/don-hang` không hỏng | Redirect `/admin/login` đúng như thiết kế (chưa có phiên đăng nhập admin để test sâu hơn — xem Rủi ro) |

### Kết quả `mvn clean package`

Pass sau cả Phần A và Phần B (chạy lại lần cuối cũng pass, không lỗi biên dịch).

**Lưu ý kỹ thuật**: `AccountController` là servlet mới (`@WebServlet`) — Tomcat chỉ quét annotation servlet mới lúc khởi động context, khác với JSP/CSS được Jasper tự biên dịch lại khi phát hiện file đổi. Đã restart tiến trình Tomcat cục bộ (cùng cấu hình `catalina.base`/`catalina.home` với tiến trình IDE đang chạy) để nạp servlet mới và test được ngay. Đây là thao tác cục bộ, an toàn, có thể khôi phục — nếu dùng lại IDE, chỉ cần bấm Run lại trong SmartTomcat.

## Rủi ro còn lại cho prompt tiếp theo

1. **Admin flow (`/admin/don-hang`) chưa test sâu lại** sau các thay đổi ở Prompt 6 (không có mật khẩu admin thật, giống tình huống ở Prompt 5) — chỉ xác nhận route vẫn redirect đúng về login, không có lỗi 500. Nên test thủ công lại toàn bộ checklist admin sau khi có tài khoản.
2. **Thông tin cá nhân / Sổ địa chỉ / Sở thích / Bảo mật**: để dạng link disabled "Sắp có" trong sidebar theo đúng cho phép của prompt — chưa có route/JSP thật, cần làm ở prompt sau (đổi mật khẩu, quản lý địa chỉ giao hàng CRUD, avatar upload...).
3. **Polling "gần-realtime"**: hiện dùng `setInterval` fetch mỗi 20 giây (không phải WebSocket/SSE) — đủ dùng cho quy mô nhỏ nhưng nếu số lượng khách online tăng, nên cân nhắc SSE để giảm tải server.
4. **Ngưỡng member tier** (300k/1tr/3tr) là số ví dụ hợp lý cho quy mô quán nước ép sinh viên — cần xác nhận với chủ shop trước khi coi là chính thức; đã đặt tập trung ở `MemberTierService.java` nên sửa rất nhanh.
5. **`STRING_AGG`** yêu cầu SQL Server 2017+ compatibility level — đã test thành công trên DB thật của dự án, nhưng nếu sau này đổi sang DB khác/compatibility level cũ hơn cần thay bằng cách khác (vd. `FOR XML PATH`).
6. Việc restart Tomcat cục bộ để nạp servlet mới là giới hạn của môi trường dev (SmartTomcat/annotation scanning) — không ảnh hưởng gì khi deploy WAR thật lên server production (khởi động lại server vốn là bước bình thường của mọi lần deploy).
