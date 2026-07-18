# BÁO CÁO HOÀN THIỆN CUỐI — Nhiệt Đới Xanh (NhietDoiXanh_Web)

> Mega-prompt hoàn thiện: PayOS, gộp menu, home product link, checkout autofill/GPS,
> account routing, đổi mật khẩu OTP, avatar crop, polish UI/UX, security regression.
> **`mvn clean package` → BUILD SUCCESS.** App chạy trên Tomcat 10.1 tại
> `http://localhost:8081/NhietDoiXanh_Web/`.

---

## 1. Tổng quan module đã hoàn thành
| Module | Trạng thái |
|--------|-----------|
| Sản phẩm / danh mục / tìm kiếm / sắp xếp | ✅ có sẵn, không phá |
| Giỏ hàng (chọn từng phần / total / update / remove) | ✅ có sẵn, không phá |
| Checkout COD (transaction thật) | ✅ có sẵn, không phá |
| Checkout PayOS/VietQR | ✅ **hoàn thiện** (thêm PaymentController) |
| Account: dashboard / orders / order-detail / profile / addresses / preferences / security | ✅ |
| Đổi mật khẩu xác minh OTP qua email | ✅ **mới** |
| Avatar crop/căn chỉnh trước khi lưu | ✅ **mới** |
| Admin orders (list/detail/status/pagination) | ✅ có sẵn, không phá |
| Gộp "Thực Đơn" → "Sản Phẩm" | ✅ (prompt trước, xác nhận lại) |
| Home product click → detail theo id | ✅ (prompt trước, xác nhận lại) |

## 2. PayOS
- **Hoàn tất.** Chi tiết: `docs/ECOMMERCE_PAYOS_REPORT.md`.
- Đã bổ sung `PaymentController` (webhook / return / cancel) — trước đó CheckoutController đã tạo
  link nhưng thiếu các callback này.
- **Config cần thiết** (ENV ưu tiên, fallback `db.properties`): `PAYOS_CLIENT_ID`, `PAYOS_API_KEY`,
  `PAYOS_CHECKSUM_KEY`, (tùy chọn) `PAYOS_RETURN_URL`, `PAYOS_CANCEL_URL`, `PAYOS_WEBHOOK_URL`.
- **Thiếu config → an toàn**: PayOS ẩn ở checkout, COD chạy bình thường, app không crash.
- **Test result**: webhook chữ ký sai → **HTTP 401, không chạm DB** (đã test thực tế). Return URL
  không tự PAID (chỉ đọc DB). Webhook PAID idempotent + xóa đúng CartItems của đơn.

## 3. Navigation — gộp Thực Đơn vào Sản Phẩm
- Header customer chỉ còn 1 cổng mua hàng: **Sản Phẩm**.
- `/thuc-don` → **301 redirect** sang `/san-pham` (giữ `?danhmuc=`), không 404.
- `menu.jsp` (dead code) đã xóa. Active state "Sản Phẩm" nhận cả `products` lẫn `menu` (tương thích).

## 4. Home product detail linking
- `HomeController` (`@WebServlet("/")`) nạp sản phẩm active thật (`ProductDao.findAllActive`, tối đa 6).
- `index.jsp` khu "Sản Phẩm Nổi Bật": mỗi card link `/san-pham/chi-tiet?id=<ProductID>` thật;
  ảnh thiếu → placeholder 🌿; CTA "Xem Tất Cả Sản Phẩm" → `/san-pham`.

## 5. Checkout autofill address
- GET `/checkout`: prefill từ `UserAddressDao.findDefaultByUserId`; nếu không có default → prefill
  họ tên/SĐT từ user.
- Dropdown chọn địa chỉ đã lưu (nhiều địa chỉ) → JS autofill toàn bộ field + lat/lng.
- Link "Quản lý sổ địa chỉ" → `/account/addresses`. Chưa có địa chỉ → gợi ý lưu.
- **Backend ownership**: submit kèm `addressId` → verify `findByIdAndUserId(addressId, userId)`;
  không thuộc user → từ chối. Dữ liệu ghi Order vẫn re-validate từ field text (không tin addressId
  để ghi đè). userId luôn từ session.

## 6. GPS display
- Trạng thái: "Chưa lấy vị trí" / "Đang lấy vị trí..." / card "Đã lấy vị trí hiện tại" + Latitude/
  Longitude + nút "Xóa vị trí" / lỗi thân thiện "Không lấy được vị trí. Bạn vẫn có thể nhập thủ công."
- Địa chỉ mặc định có sẵn tọa độ → hiển thị "Địa chỉ này đã có tọa độ", cho cập nhật lại.
- Không gọi API ngoài / không API key / GPS optional.

## 7. Account order routing
- Tất cả link "Đơn hàng" (header dropdown, sidebar, dashboard, checkout-success) → `/account/orders`
  qua `${pageContext.request.contextPath}`. Không còn `/orders`, `/account/order`, `#orders`.
- `/account/orders/detail?id=...` query kèm UserID (chống IDOR) — không xem được đơn user khác.
- Status tiếng Việt qua `OrderStatuses`/`PaymentStatuses` (Chờ xác nhận/Đang xử lý/Đang giao/
  Hoàn thành/Đã hủy/Chờ duyệt hủy...). Active state đúng cho mọi tab account.

## 8. Đổi mật khẩu OTP (`AccountSecurityController`)
- Route: `GET /account/security`, `POST /account/password/request-otp`,
  `POST /account/password/change`, `POST /account/password/resend-otp`.
- Bước 1: verify mật khẩu hiện tại (BCrypt) + validate mật khẩu mới → sinh OTP 6 số, gửi email.
- Bước 2: nhập OTP → hợp lệ mới đổi mật khẩu, rotate session.
- **Bảo mật**: OTP và mật khẩu mới lưu trong session dưới dạng **BCrypt hash** (không lưu thô);
  TTL 5 phút; tối đa 5 lần thử; cooldown gửi lại 60s; không log password/OTP; auth + CSRF; không
  nhận userId từ client. Email tiếng Việt UTF-8, subject "Mã xác minh đổi mật khẩu Nhiệt Đới Xanh".
- UI: show/hide password, thanh đo độ mạnh mật khẩu, đếm ngược hết hạn OTP, cooldown nút gửi lại.
- **Thiếu SMTP config → an toàn**: đã test, hiển thị lỗi thân thiện, không crash, không đổi mật khẩu.

## 9. Avatar crop (`js/avatar-crop.js` + `profile.jsp`)
- Canvas thuần (không thư viện ngoài → an toàn CSP). Chọn ảnh → validate type/size client → modal
  crop (kéo di chuyển + slider zoom, vùng 1:1) → xuất JPEG 512×512 → nhồi vào `<input name=avatar>`
  qua DataTransfer → backend multipart hiện có xử lý nguyên vẹn.
- **Backend `AvatarUpload`** (đã có): validate **magic bytes** (JPG/PNG/WEBP), chặn SVG, chặn >1MB,
  tên file tự sinh (chống path traversal), không dùng filename client. Refresh `session.user` sau update.

## 10. UI/UX polish
- Thay ảnh avatar mặc định `ui-avatars.com` (**bị CSP chặn**) bằng ô chữ cái gradient CSS ở
  `profile.jsp`, `account/dashboard.jsp`, `admin/layout/header.jsp`.
- Theme Modern Tropical đồng bộ (cream/green/gold, Be Vietnam Pro). Không status code tiếng Anh trần.
- Card đổi mật khẩu, GPS card, address dropdown, crop modal đều responsive.

## 11. Security checklist
| # | Mục | Kết quả |
|---|-----|---------|
| 1 | Logout customer POST + CSRF | ✅ có sẵn |
| 2 | Logout admin GET → **POST + CSRF** | ✅ **đã sửa** (GET không còn logout) |
| 3 | Không order 0 đồng (route `/order` cũ) | ✅ vô hiệu từ trước |
| 4 | Không xóa toàn bộ cart khi checkout một phần | ✅ (COD xóa đúng item; PayOS chỉ xóa khi PAID) |
| 5 | Không userId từ client cho action nhạy cảm | ✅ |
| 6 | Không IDOR order/address/cartItem | ✅ query kèm UserID |
| 7 | Webhook PayOS verify chữ ký | ✅ (401 khi sai) |
| 8 | Return URL không tự PAID | ✅ |
| 9 | CSRF cho POST thường; bypass chỉ webhook | ✅ |
| 10 | PreparedStatement, không nối SQL với input | ✅ |
| 11 | Không log password/OTP/PayOS secret | ✅ |
| 12 | Không commit secret (`payos.*`, `mail.*` để trống) | ✅ |

## 12. Routes cuối cùng (mới/liên quan)
```
GET  /                              → HomeController (featured products thật)
GET  /thuc-don                      → 301 → /san-pham
GET  /san-pham, /san-pham/chi-tiet  → ProductController
GET/POST /checkout/*                → CheckoutController (COD + PayOS)
POST /payment/payos/webhook         → PaymentController (verify chữ ký, no CSRF)
GET  /payment/payos/return|cancel   → PaymentController
GET  /account/security              → AccountSecurityController (OTP UI)
POST /account/password/request-otp|change|resend-otp → AccountSecurityController
POST /account/profile               → AccountProfileController (avatar multipart + crop)
GET  /account/orders, /account/orders/detail        → AccountController (ownership)
POST /logout (customer), POST /admin/logout (admin)  → CSRF
```

## 13. Files created / modified (prompt này)
**Mới:**
- `src/main/java/com/nhietdoixanh/controller/PaymentController.java`
- `src/main/webapp/WEB-INF/views/payment-return.jsp`
- `src/main/webapp/js/avatar-crop.js`
- `docs/ECOMMERCE_PAYOS_REPORT.md`, `docs/ECOMMERCE_FINAL_COMPLETION_REPORT.md`

**Sửa:**
- `controller/AccountSecurityController.java` (OTP flow), `filter/CsrfFilter.java` (webhook exempt),
  `controller/admin/AdminAuthController.java` (logout GET→POST)
- `WEB-INF/views/checkout.jsp` + `js/checkout.js` (PayOS option + payment sync)
- `WEB-INF/views/account/security.jsp`, `WEB-INF/views/account/profile.jsp`,
  `WEB-INF/views/account/dashboard.jsp`, `WEB-INF/views/admin/layout/header.jsp`
- `css/product.css`, `css/account.css`, `WEB-INF/web.xml` (assetVer 5→6)

## 14. Migration mới
Không thêm migration mới trong prompt này. PayOS đã có `sql/migration_payos_v5.sql`
(cột PayOS trên Orders + bảng OrderCartItems, idempotent) — chạy 1 lần trên SQL Server nếu chưa.

## 15. Test cases
| Nhóm | Test | Kết quả |
|------|------|---------|
| Nav | `/` 200, `/san-pham` 200, `/thuc-don` → 301 → `/san-pham` | ✅ |
| Auth | `/cart /checkout /account/*` → 302 login khi chưa đăng nhập | ✅ |
| Login | customer `khachhang@gmail.com` → 302 dashboard | ✅ |
| Security | `/account/security` 200, render OTP UI + strength meter | ✅ |
| OTP | request-otp mật khẩu đúng → xử lý; SMTP trống → lỗi thân thiện, không crash | ✅ |
| Avatar | `/account/profile` 200, modal crop + canvas + js present | ✅ |
| PayOS | webhook chữ ký sai → **401**, không chạm DB | ✅ |
| Admin | `/admin/login` 200; logout chuyển sang POST+CSRF | ✅ |
| CSP | không còn ảnh ngoài `ui-avatars.com` bị chặn | ✅ |

## 16. Kết quả `mvn clean package`
```
BUILD SUCCESS  (exit 0)
target/NhietDoiXanh_Web.war
```

## 17. Lỗi còn lại / blocker (môi trường, không phải code)
1. **Port 8080 bị dự án V-SPORT chiếm** → app này chạy ở **8081** (cấu hình SmartTomcat đã đổi:
   HTTP 8081, shutdown 8006). Mở `http://localhost:8081/NhietDoiXanh_Web/`.
2. **PayOS chưa cấu hình** trong môi trường này (`payos.*` trống) → PayOS ẩn ở checkout, COD hoạt
   động. Điền credential vào ENV/`db.properties` để bật.
3. **Gmail SMTP chưa cấu hình** (`mail.smtp.*` trống) → gửi OTP thất bại có kiểm soát (thông báo
   thân thiện). Điền `mail.smtp.username` + app password để bật gửi OTP thật.
4. JDK runtime hiện là 17 (Microsoft build) — build & runtime OK. Nếu leader muốn chuẩn hóa JDK 21,
   đổi Project SDK/Tomcat JRE; không phải blocker.

## 18. Hướng dẫn demo nhanh cho leader
1. Mở `http://localhost:8081/NhietDoiXanh_Web/` → click 1 card sản phẩm ở trang chủ → sang đúng
   `/san-pham/chi-tiet?id=...`.
2. Đăng nhập `khachhang@gmail.com` / `Customer@123`.
3. Thêm sản phẩm vào giỏ → chọn item → Thanh toán → xem địa chỉ tự điền + card GPS + phương thức COD.
4. Đặt COD → xem đơn ở `/account/orders` → mở chi tiết.
5. `/account/profile` → "Đổi ảnh đại diện" → cắt/zoom trong modal → Lưu.
6. `/account/security` → nhập mật khẩu → "Gửi mã xác minh" (cần cấu hình SMTP để nhận OTP thật).
7. (Nếu cấu hình PayOS) chọn "Thanh toán qua PayOS" ở checkout để tạo link VietQR.
