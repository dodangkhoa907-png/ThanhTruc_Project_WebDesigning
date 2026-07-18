# Báo cáo: Khu Sản Phẩm & Thêm Vào Giỏ (Prompt 2)

Ngày: 2026-07-17
Phạm vi: Xây khu sản phẩm thật từ DB (danh sách + chi tiết + filter/search/sort) và chức năng thêm vào giỏ hàng AJAX. Chưa xây sửa số lượng/xóa/checkout trong giỏ hàng (để dành prompt sau).

## 1. File đã tạo

| File | Mục đích |
|---|---|
| `src/main/java/com/nhietdoixanh/util/ProductSort.java` | Whitelist các kiểu sắp xếp (enum) — không nhận raw SQL/ORDER BY từ request |
| `src/main/java/com/nhietdoixanh/controller/CartController.java` | Servlet: GET `/cart`, POST `/cart/add`, GET `/cart/count` |
| `src/main/webapp/css/product.css` | CSS khu sản phẩm mới — theme Modern Tropical, palette Nhiệt Đới Xanh, có `prefers-reduced-motion` |
| `src/main/webapp/js/cart.js` | AJAX add-to-cart, cập nhật badge, toast thông báo — dùng chung cho mọi trang |
| `src/main/webapp/WEB-INF/views/product-list.jsp` | Trang khu sản phẩm: hero, toolbar filter/search/sort, grid, empty state |
| `src/main/webapp/WEB-INF/views/product-detail.jsp` | Trang chi tiết sản phẩm: chọn biến thể, số lượng, thêm vào giỏ |
| `src/main/webapp/WEB-INF/views/cart.jsp` | Trang xem giỏ hàng (chỉ đọc — chưa có sửa/xóa/checkout) |
| `docs/ECOMMERCE_PRODUCT_CART_REPORT.md` | Báo cáo này |

## 2. File đã sửa

| File | Thay đổi |
|---|---|
| `dao/ProductDao.java` + `impl/ProductDaoImpl.java` | + `findActiveById` (chỉ sản phẩm active, dùng cho trang chi tiết khách hàng), + `findActiveForShop(categoryId, keyword, sort)` kết hợp lọc danh mục + tìm kiếm + sắp xếp trong 1 query, dùng subquery `MIN(Price) WHERE IsActive=1` để sort theo giá (Products không có cột giá). Giữ nguyên mọi method cũ |
| `dao/impl/CartItemDaoImpl.java` | `insertOrUpdate`: cap tổng quantity tối đa 99 khi merge (`Math.min(rs.getInt("Quantity") + quantity, 99)`) |
| `controller/ProductController.java` | Thêm route `/san-pham` (danh sách) và `/san-pham/chi-tiet` (chi tiết). Route `/thuc-don` giữ nguyên logic cũ, không đổi hành vi |
| `controller/AuthController.java` | Thêm `resolveReturnUrl()` — sau khi login/register, quay lại đúng trang khách đang cố truy cập (chỉ chấp nhận path nội bộ bắt đầu bằng "/", chặn open redirect qua "//") |
| `filter/AuthFilter.java` | Thêm `/cart` vào urlPatterns (trước chỉ có `/cart/*`, không khớp path `/cart` trần). Với request AJAX (`X-Requested-With: XMLHttpRequest` hoặc `Accept: application/json`) chưa đăng nhập → trả 401 JSON `{success:false, requireLogin:true, loginUrl, message}` thay vì redirect (fetch không tự "đăng nhập" được qua redirect HTML). Với request thường → lưu `returnUrl` vào session rồi redirect `/login` |
| `index.jsp` | Thêm link "Sản Phẩm", cart badge, trạng thái đăng nhập vào navbar (không xóa gì cũ). Thêm `<meta name="csrf-token">`, link `product.css`, script `cart.js` |
| `WEB-INF/views/menu.jsp` | Tương tự `index.jsp` — chỉ thêm, không sửa/xóa nội dung cũ |

## 3. Route mới

| Route | Method | Auth | Mô tả |
|---|---|---|---|
| `/san-pham` | GET | Public | Danh sách sản phẩm — lọc danh mục (`?danhmuc=`), tìm kiếm (`?q=`), sắp xếp (`?sort=`) |
| `/san-pham/chi-tiet` | GET | Public | Chi tiết 1 sản phẩm (`?id=`) — 404 nếu không tồn tại/inactive/id không hợp lệ |
| `/cart` | GET | **Yêu cầu login** (AuthFilter) | Xem giỏ hàng (chỉ đọc) |
| `/cart/add` | POST | **Yêu cầu login** (AuthFilter) | Thêm vào giỏ — trả JSON |
| `/cart/count` | GET | Public (AuthFilter bỏ qua) | Đếm số lượng giỏ hàng cho badge — trả `cartCount:0` nếu chưa login |
| `/thuc-don` | GET | Public | **Không đổi** — vẫn dùng `menu.jsp`, logic y hệt trước |

## 4. JSON contract

### POST `/cart/add`

Request (`application/x-www-form-urlencoded`):
```
variantId=<int>
quantity=<int 1-99>
_csrf=<token từ session>
```

Response thành công (200):
```json
{"success": true, "message": "Đã thêm vào giỏ hàng.", "cartCount": 5}
```

Response lỗi validate (400):
```json
{"success": false, "message": "Số lượng phải từ 1 đến 99."}
```

Response chưa đăng nhập (401, do AuthFilter chặn trước khi vào servlet):
```json
{"success": false, "requireLogin": true, "loginUrl": "/login", "message": "Vui lòng đăng nhập để tiếp tục."}
```

Response variant không tồn tại (404) / đã ngừng bán (409): message tiếng Việt tương ứng, không có stack trace.

### GET `/cart/count`

```json
{"success": true, "cartCount": 3}
```

## 5. Cách test đã thực hiện

Vì môi trường này không có Tomcat cài sẵn (dự án dùng SmartTomcat plugin của IDE), đã dựng **Embedded Tomcat 10.1.54** tạm thời (dùng đúng jar `tomcat-embed-core/jasper/el` version khớp dự án) để deploy WAR thật và test qua HTTP thực tế, kết nối tới **SQL Server thật** (đã cấu hình sẵn trong `db.properties`). Kết quả:

| Test | Kết quả |
|---|---|
| `GET /` (trang chủ) | 200, hero content nguyên vẹn, có cart badge |
| `GET /san-pham` | 200, hiển thị đúng 3 sản phẩm thật từ DB |
| `GET /thuc-don` | 200, không đổi (27 `product-card` như cũ) |
| `GET /login`, `/register` | 200 |
| `GET /admin/login` | 200, `/admin` vẫn redirect (302) như cũ |
| `GET /san-pham?q=cam` | Lọc đúng 2/3 sản phẩm khớp "cam" |
| `GET /san-pham?danhmuc=1` | Lọc đúng 2 sản phẩm thuộc danh mục 1 |
| `GET /san-pham?sort=gia-tang` | Thứ tự id 1,2,3 (giá tăng dần) |
| `GET /san-pham?sort=gia-giam` | Thứ tự id 3,1,2 (giá giảm dần) |
| `GET /san-pham/chi-tiet?id=1` | 200, hiển thị đúng biến thể + giá |
| `GET /san-pham/chi-tiet?id=99999` | 404 (không tồn tại) |
| `GET /san-pham/chi-tiet?id=abc` | 404 (id không hợp lệ) |
| `GET /san-pham/chi-tiet` (thiếu id) | 404 |
| Login `khachhang@gmail.com` (tài khoản seed sẵn) | Thành công, session tạo đúng |
| `POST /cart/add` (variant=1, qty=2) khi đã login | `{"success":true,...,"cartCount":2}` |
| `POST /cart/add` (variant=1, qty=3) lần 2 | Gộp thành `cartCount:5` — **không tạo dòng trùng** |
| `GET /cart` sau khi thêm | Hiển thị đúng "Ép Cam Nguyên Chất · M · Số lượng: 5 · 100.000đ" |
| `POST /cart/add` quantity=0 | 400, "Số lượng phải từ 1 đến 99." |
| `POST /cart/add` quantity=100 | 400, "Số lượng phải từ 1 đến 99." |
| `POST /cart/add` variantId=999999 | 404, "Sản phẩm không tồn tại." |
| `POST /cart/add` variantId=abc | 400, "Sản phẩm không hợp lệ." |
| `POST /cart/add` thiếu/sai `_csrf`, không có `X-Requested-With` | 403 "CSRF token invalid" (CsrfFilter chặn trước) |
| `POST /cart/add` chưa login, có CSRF hợp lệ, có `X-Requested-With` (AJAX) | 401 JSON `{requireLogin:true,...}` |
| `POST /cart/add` chưa login, có CSRF hợp lệ, form thường | 302 → `/login` |
| `GET /cart/count` chưa login | `{"success":true,"cartCount":0}` — không lỗi |
| `GET /cart` chưa login | 302 → `/login` |

Chưa test được trên UI trình duyệt thật (không có màn hình trong môi trường này) — các test trên dùng `curl` gọi trực tiếp HTTP, xác nhận đúng response code/JSON/HTML, nhưng chưa xác nhận trực quan CSS/animation/responsive trên trình duyệt thật. **Khuyến nghị: mở `/san-pham` trên trình duyệt thật (qua SmartTomcat) để kiểm tra giao diện trước khi bàn giao.**

## 6. Kết quả `mvn clean package`

Chạy trước khi sửa: **PASS** (baseline).
Chạy sau khi sửa: **PASS**, WAR sinh ra tại `target/NhietDoiXanh_Web.war`, không có lỗi compile.

## 7. Rủi ro còn lại cho prompt sau

1. **Dữ liệu sản phẩm hiện tại vẫn là nước ép (từ seed PureNut cũ)** — khu sản phẩm mới đã sẵn sàng về mặt kỹ thuật (không hard-code gì trong JSP) nhưng nội dung thật cần đổi qua dữ liệu DB (Categories/Products/ProductVariants) sang cây cảnh/decor — đây là việc nhập liệu, không phải code.
2. **Trang `/cart` mới chỉ đọc** — chưa có sửa số lượng, xóa sản phẩm, hay checkout. Cần route `/cart/update`, `/cart/remove`, `/checkout` ở prompt sau (đã có nền DAO `CartItemDao.updateQuantity`, `deleteSelectedByUserId` từ Prompt 1).
3. **Trang `/account` chưa tồn tại** — link tên người dùng trong navbar tạm trỏ về trang chủ (`/`) thay vì trang tài khoản, vì `/account` chưa được xây (đúng phạm vi — đó là hạng mục "tài khoản khách hàng" của prompt sau).
4. **`menu.jsp` (route `/thuc-don`) không được kết nối với giỏ hàng mới** — nút "Đặt ngay" trên `/thuc-don` vẫn trỏ `#checkout` như cũ (hành vi cũ, cố tình không đổi để tránh phá trang cũ ngoài phạm vi). Khách nên dùng `/san-pham` để có trải nghiệm giỏ hàng đầy đủ.
5. **Chưa test trên trình duyệt thật** — chỉ test qua `curl`/HTTP trực tiếp (xem mục 5), chưa xác nhận trực quan animation/hover/responsive.
6. **`GzipFilter` buffer toàn bộ response** (đã ghi nhận từ Prompt 1) — chưa ảnh hưởng gì ở đây vì `/cart/add`, `/cart/count` không phải SSE, nhưng vẫn là rủi ro treo lại cho tính năng real-time sau này.
7. **`CartItemDaoImpl.insertOrUpdate` cap quantity ở tầng DAO** — nếu sau này có thêm entrypoint khác gọi thẳng `insertOrUpdate` mà không qua `CartController`, giới hạn 99 vẫn tự động áp dụng (an toàn), nhưng UI hiện tại chưa thông báo rõ khi bị cap (chỉ trả về `cartCount` mới, không có message riêng "đã đạt giới hạn 99") — có thể cải thiện UX ở prompt sau.
