# Prompt 4 — Checkout & Thanh Toán Tiền Mặt COD

Trạng thái: **Hoàn thành, đã build pass, đã test end-to-end trên Tomcat thật với DB thật.**

## 1. File đã tạo

| File | Vai trò |
|---|---|
| `src/main/webapp/WEB-INF/views/checkout.jsp` | Trang `/checkout` — form giao hàng + tóm tắt đơn hàng sticky, theme Modern Tropical |
| `src/main/webapp/WEB-INF/views/checkout-success.jsp` | Trang `/checkout/success` — xác nhận đặt hàng thành công |
| `src/main/webapp/js/checkout.js` | GPS (chỉ chạy khi bấm nút) + vô hiệu hóa nút "Đặt Hàng" khi submit |

## 2. File đã sửa

| File | Thay đổi |
|---|---|
| `src/main/java/com/nhietdoixanh/controller/CheckoutController.java` | Thêm `GET /checkout`, `POST /checkout/place-order`, `GET /checkout/success` bên cạnh `POST /checkout/prepare` sẵn có |
| `src/main/java/com/nhietdoixanh/dao/impl/OrderDaoImpl.java` | `placeOrder()` INSERT giờ ghi thêm `RecipientName, RecipientPhone, ShippingLatitude, ShippingLongitude, StatusUpdatedAt` (trước đây các cột này bỏ trống dù model/DB đã có) |
| `src/main/java/com/nhietdoixanh/controller/OrderServlet.java` | `GET /order` → redirect `/san-pham`; `POST /order` → nếu user đã login và có `checkoutSelection` hợp lệ thì redirect `/checkout` thay vì xử lý như form liên hệ nhanh trang chủ |
| `src/main/webapp/WEB-INF/views/cart.jsp` | Thêm banner `flashError` (session `cartFlashError`, đọc + xóa một lần) để hiển thị lý do khi bị đá về `/cart` từ `/checkout` |
| `src/main/webapp/css/product.css` | Thêm toàn bộ CSS cho `/checkout`, `/checkout/success`, và `.flash-error-banner` dùng chung |

Không cần migration SQL mới — `migration_ecommerce_account_v3.sql` (đã có từ trước) đã cấp đủ mọi cột cần thiết: `Orders.PaymentStatus/StatusUpdatedAt/RecipientName/RecipientPhone/ShippingLatitude/ShippingLongitude`. `OrderDetails` không có cột snapshot tên sản phẩm (đọc lại qua JOIN `Products`/`ProductVariants` khi hiển thị) — giữ nguyên pattern đã dùng ở `findOrderById`/`findDetailsByOrderIdAndUserId`, không đổi schema.

Trong quá trình làm việc, một phiên khác đang song song chuyển toàn bộ navbar khách hàng sang include chung `WEB-INF/views/common/customer-header.jsp` (menu.jsp, product-list.jsp, product-detail.jsp, cart.jsp). `checkout.jsp`/`checkout-success.jsp` được viết theo đúng pattern mới đó ngay từ đầu để nhất quán.

## 3. Route checkout

```
GET  /checkout                — hiển thị trang checkout cho selection hiện tại (yêu cầu login)
POST /checkout/prepare        — (đã có từ Prompt 3) xác thực selection từ /cart, lưu vào session
POST /checkout/place-order    — tạo Order + OrderDetails thật, COD only
GET  /checkout/success        — trang xác nhận, chỉ xem đơn của chính mình
```

`AuthFilter` (`urlPatterns = {"/checkout/*", ...}`) đã chặn cả 4 route này cho user chưa login; servlet tự kiểm tra lại `session.getAttribute("user")` một lần nữa (belt-and-suspenders).

## 4. Transaction flow (COD)

`OrderDaoImpl.placeOrder(Order, List<CartItem>)` — 1 connection, `setAutoCommit(false)`:

1. `INSERT INTO Orders (...)` — `OrderStatus='PENDING'` hard-code trong SQL, `PaymentStatus` dùng `DEFAULT 'UNPAID'` của cột, `StatusUpdatedAt = SYSDATETIME()`.
2. `INSERT INTO OrderDetails (...)` theo batch, từ `List<CartItem>` đã đọc lại từ DB (không phải từ form).
3. `DELETE FROM CartItems WHERE UserID = ? AND CartItemID IN (...)` — chỉ xóa đúng các dòng đã chọn.
4. `commit()`. Bất kỳ bước nào lỗi → `rollback()`, ném lại exception, controller không dọn session/cart.

`CheckoutController.handlePlaceOrder()` chuẩn bị dữ liệu cho transaction trên:
- Đọc lại `CheckoutSelection` từ session (kiểm tra `isUsableBy(userId)` — đúng user, chưa hết hạn, còn item).
- Đọc lại `CartItemDao.findSelectedByIdsAndUserId(ids, userId)` — nguồn sự thật giá/số lượng/trạng thái active.
- Validate lại từng item (variant active, quantity 1–99, price > 0) — trùng logic với `/checkout/prepare` và GET `/checkout` để chặn race-condition (item bị đổi giữa hai bước).
- Tính `TotalAmount/ShippingFee(0)/Discount(0)/FinalAmount` bằng `BigDecimal`, không cho âm.

## 5. Session `checkoutSelection` + one-time token chống double-submit

- `checkoutSelection` (đã có từ Prompt 3): `userId`, `cartItemIds`, `createdAt`, TTL 20 phút (`CheckoutSelection.TTL_MINUTES`).
- `checkoutToken` (mới): sinh bằng `CsrfFilter.generateToken()`, lưu session mỗi lần `GET /checkout` thành công, render vào hidden field.
- `POST /checkout/place-order`: so khớp token trong `synchronized (session)` rồi **tiêu thụ ngay** (`session.removeAttribute`) trước khi làm bất kỳ việc gì khác — request thứ hai (double-click, back+resubmit) luôn thấy token đã bị xóa.
  - Nếu token không khớp/đã dùng: có `lastOrderId` trong session → redirect `/checkout/success?orderId=...` (đơn đã tạo, không tạo thêm); không có → redirect `/cart` với thông báo lỗi.
  - Nếu validate form thất bại sau khi token đã tiêu thụ: cấp token mới, forward lại `checkout.jsp` (không mất khả năng thử lại).
- Sau khi tạo đơn thành công: xóa `checkoutSelection`, set `lastOrderId`, cập nhật `cartCount`, **redirect** (PRG pattern) sang `/checkout/success?orderId=...` — refresh trang không tạo đơn mới vì đó là GET.

## 6. Validation rules (server-side, `handlePlaceOrder`)

| Field | Rule |
|---|---|
| `recipientName` | required, trim, 2–100 ký tự |
| `recipientPhone` | required, regex `^(0|\+84)[0-9]{9,10}$` (kiểu String, không parse int) |
| `provinceCity` / `district` / `ward` | required, ≤100 ký tự |
| `houseNumberStreet` | required, ≤300 ký tự |
| `note` | optional, ≤500 ký tự |
| `latitude` | optional, parse `BigDecimal`, khoảng [-90, 90] |
| `longitude` | optional, parse `BigDecimal`, khoảng [-180, 180] |
| `paymentMethod` | chỉ chấp nhận đúng chuỗi `"COD"` |

Lỗi → **không** tạo order, **không** xóa cart, forward lại `checkout.jsp`, giữ nguyên dữ liệu đã nhập (`old*` request attributes), lỗi hiển thị cạnh từng field bằng tiếng Việt. Mọi giá trị echo lại vào `value="..."`/`<textarea>` đều qua `fn:escapeXml()`/`<c:out>` — đã tự phát hiện và vá một lỗ hổng XSS phản chiếu trong lúc code review nội bộ trước khi build (giá trị `old*` ban đầu được nhúng thẳng vào attribute không escape).

## 7. GPS

`SecurityHeadersFilter` đã có sẵn `Permissions-Policy: geolocation=(self)` từ Prompt 1 — không cần đổi.

`checkout.js`: `navigator.geolocation.getCurrentPosition` chỉ gọi trong handler `click` của nút "Lấy vị trí hiện tại" (không tự động khi vào trang). Xử lý đủ 4 trường hợp: thành công (điền hidden lat/lng + text "Đã lấy vị trí hiện tại"), từ chối quyền (`PERMISSION_DENIED`), timeout, và trình duyệt không hỗ trợ `geolocation`. Không tích hợp reverse-geocoding/API bản đồ — đúng phạm vi prompt này.

## 8. Kết quả test COD (chạy thật trên Tomcat + SQL Server thật)

Đã build WAR, deploy lên Tomcat 10.1.55 cục bộ (context có sẵn từ SmartTomcat, trỏ thẳng `src/main/webapp` + `target/classes`), chạy thật với DB `BanNuoc_Truc`, tài khoản test seed sẵn `khachhang@gmail.com` / `Customer@123`.

| # | Test case | Kết quả |
|---|---|---|
| 1 | Chưa login vào `/checkout` | Redirect `/login` ✅ |
| 2 | Login, không có `checkoutSelection`, vào `/checkout` | Redirect `/cart` kèm flash message "Phiên thanh toán đã hết hạn hoặc không hợp lệ..." ✅ |
| 3–5 | Chọn sản phẩm ở `/cart` → "Tiến hành thanh toán" → `/checkout` hiển thị đúng sản phẩm đã chọn (tên, size, số lượng, đơn giá, tạm tính) | ✅ |
| 6 | Prefill Họ tên/SĐT từ session user (chưa có `UserAddresses` mặc định cho user test) | ✅ (`Khách Hàng Mẫu`, `0911111111`) |
| 7–10 | Submit thiếu tên/SĐT/địa chỉ, SĐT sai định dạng | Lỗi tiếng Việt đúng field, không tạo order, giữ nguyên dữ liệu đã nhập ✅ |
| 11 | Bấm "Lấy vị trí hiện tại" (mock `geolocation`) | Điền đúng hidden lat/lng, hiện "Đã lấy vị trí hiện tại" ✅ |
| 12–13 | Chọn COD, đặt hàng | Tạo `Order #1/#2/#3` thật trong DB — đã `SELECT` trực tiếp xác nhận: `PaymentMethod=COD`, `PaymentStatus=UNPAID`, `OrderStatus=PENDING`, `StatusUpdatedAt`/`CreatedAt` có giá trị, `ShippingLatitude/Longitude` đúng giá trị GPS mock, `ShippingAddress` ghép đúng 4 phần ✅ |
| 14 | Redirect sang `/checkout/success?orderId=...` sau đặt hàng | ✅ (PRG, không forward trực tiếp) |
| 15 | Refresh trang success | Không tạo đơn mới (GET không có side-effect) ✅ |
| 16 | Double-submit: gọi lại `POST /checkout/place-order` với token đã dùng | Redirect thẳng về `/checkout/success?orderId=<đơn cũ>`, **không** tạo đơn thứ hai (đã verify: order count không tăng) ✅ |
| 17–18 | Giỏ có 2 sản phẩm, chỉ chọn 1 để checkout | Sau khi đặt hàng: item đã chọn bị xóa khỏi `CartItems`, item còn lại **vẫn còn nguyên** trong giỏ ✅ (verify bằng `SELECT` DB + `GET /cart`) |
| 19 | Sửa `orderId` trên URL success sang đơn không tồn tại/không thuộc user (`orderId=99999`) | Redirect `/san-pham`, không lộ dữ liệu ✅ |
| 20 | `/order` cũ: `GET` | Redirect `/san-pham` ✅ |
| 20b | `/order` cũ: `POST` không có `checkoutSelection` | Vẫn chạy flow lead-capture cũ (audit log, redirect `/thankyou`), **không** tạo Order 0đ ✅ |
| 20c | `/order` cũ: `POST` có `checkoutSelection` hợp lệ | Redirect `/checkout` thay vì xử lý form liên hệ ✅ |
| 21 | `/san-pham`, `/login`, `/register`, `/admin/login`, `/cart`, `/` | Tất cả `200 OK`, không hỏng ✅ |
| XSS | Nhập `"><script>...</script>` vào Họ tên, ép lỗi validate khác để form re-render | Giá trị echo lại an toàn, không thực thi script, không lọt vào HTML thô ✅ |

**Ghi chú:** trong quá trình test đã tạo 3 order thật (`OrderID 1, 2, 3`) trên tài khoản test `khachhang@gmail.com` trong DB dev `BanNuoc_Truc` — đây là dữ liệu test hợp lệ (tài khoản mẫu, không phải khách hàng thật), giữ nguyên để dễ đối chiếu ở Prompt 5 (trang quản lý đơn hàng admin).

**Hạn chế công cụ:** trình duyệt tự động trong phiên này không chụp được screenshot (timeout) và một số `click` trực tiếp không kích hoạt được form gắn `form="checkoutForm"` từ bên ngoài thẻ `<form>` — đã vòng qua bằng `element.requestSubmit()`/`fetch()` chạy trong trang thật, vẫn đi qua đúng toàn bộ pipeline server (CSRF thật, session thật, DB thật). Giao diện đã được xác minh qua DOM/CSS class thay vì ảnh chụp; đề nghị người dùng tự mở `/checkout` để xem trực quan.

## 9. Kết quả `mvn clean package`

```
mvn clean package -q   →  BUILD SUCCESS (không output lỗi, WAR sinh ra tại target/NhietDoiXanh_Web.war)
```

Chạy 2 lần trong quá trình làm (trước và sau khi sửa code) — cả hai lần đều pass.

## 10. Rủi ro còn lại cho Prompt 5 (admin quản lý đơn hàng, realtime trạng thái)

- **OrderDetails không snapshot tên sản phẩm/variant**: nếu sản phẩm bị đổi tên hoặc xóa sau khi đặt hàng, lịch sử đơn cũ sẽ hiển thị tên/size *hiện tại* (đọc qua JOIN), không phải tên tại thời điểm mua. Muốn đúng snapshot cần thêm cột `ProductNameSnapshot`/`VariantNameSnapshot` — migration riêng, không làm ở Prompt 4 vì chưa thật sự cần và ảnh hưởng nhiều DAO khác đang đọc theo JOIN.
- **Phí giao hàng hard-code 0đ**: chưa có rule tính phí theo khu vực/khoảng cách dù đã có `ShippingLatitude/Longitude`. Prompt 5 hoặc sau có thể dùng tọa độ này để tính phí.
- **`AddressLabel` (Nhà riêng/Công ty/Khác)**: chỉ là UI, chưa có cột lưu trong `Orders` (không nằm trong danh sách field bắt buộc của prompt này) — nếu cần lưu, thêm cột `Orders.AddressLabel` ở migration sau.
- **Route `/order` cũ vẫn còn sống** cho form liên hệ nhanh trang chủ (không phải giỏ hàng thật) — nay chỉ redirect sang `/checkout` khi phát hiện `checkoutSelection`, còn lại vẫn giữ nguyên hành vi ghi audit log cũ. Có thể cân nhắc gỡ bỏ hẳn form này ở prompt sau khi `/cart` + `/checkout` đã thay thế hoàn toàn.
- **Chưa có PayOS**: nút thanh toán online đã có UI "Sắp hỗ trợ" (disabled), chưa có backend — đúng phạm vi Prompt 4.
- **`OrderDaoImpl.placeOrder`** dùng `System.err.println`/`e.printStackTrace()` để log lỗi thay vì logger có cấu trúc (`slf4j` đã có trong classpath nhưng chưa dùng nhất quán toàn project) — không phải lỗi mới do Prompt 4, giữ nguyên convention hiện có.
- **3 order test còn trong DB dev** (`OrderID 1–3`, tài khoản `khachhang@gmail.com`) — nên được admin dashboard ở Prompt 5 lọc/xóa nếu cần dữ liệu sạch trước demo.
