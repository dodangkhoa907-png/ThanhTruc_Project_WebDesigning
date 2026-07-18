# UI EMERGENCY FIX REPORT — Nhiệt Đới Xanh

## Triệu chứng
Mở `http://localhost:8080/NhietDoiXanh_Web/`: giao diện vỡ hoàn toàn — link HTML mặc định
màu tím/xanh, logo lá cây phóng to thành mảng đen khổng lồ, CSS gần như không apply.

## 1. Nguyên nhân gốc (KHÔNG phải asset 404, KHÔNG phải sai contextPath)

**Nguyên nhân: `HomeController` được map vào `urlPatterns = {"/"}`** ở prompt trước.

Trong Jakarta Servlet, pattern `"/"` biến servlet thành **default servlet** của webapp — nó nhận
MỌI request không khớp servlet/JSP khác, **bao gồm tất cả tài nguyên tĩnh** (`/css/*`, `/js/*`,
ảnh). Do đó khi trình duyệt xin `/css/style.css`, request rơi vào `HomeController`, servlet này
bỏ qua đường dẫn và `forward` về `index.jsp` → **trả về HTML của trang chủ** với
`Content-Type: text/html` cho MỌI file CSS/JS.

Vì response còn kèm header `X-Content-Type-Options: nosniff`, trình duyệt **từ chối áp dụng**
stylesheet có Content-Type `text/html` → toàn bộ CSS bị bỏ, trang hiện link thô, logo SVG không có
CSS giới hạn kích thước nên bung to hết khung nhìn (mảng đen).

### Bằng chứng (trước khi sửa)
```
GET /NhietDoiXanh_Web/css/style.css  → HTTP 200, Content-Type: text/html;charset=UTF-8
body 200 byte đầu:  <!DOCTYPE html><html lang="vi">...  (chính là HTML trang chủ, không phải CSS)
```
CSS **không** bị 404 — nó trả 200 nhưng **sai MIME type**, đó là lý do dễ nhầm.

## 2. CSS/JS/image nào bị ảnh hưởng
Tất cả `/css/*.css`, `/js/*.js`, `/images/*` — đều trả HTML `text/html` thay vì đúng loại.
Không có file nào 404; vấn đề thuần là default-servlet bị chiếm chỗ.

## 3. Cách sửa
| File | Thay đổi |
|------|----------|
| `controller/HomeController.java` | **Đổi mapping từ `/` → `/index.jsp`.** Không còn là default servlet nên KHÔNG chặn tài nguyên tĩnh. Welcome-file `index.jsp` (web.xml) khiến request `/` phân giải sang `/index.jsp` → khớp servlet → nạp `featuredProducts` → forward tới `/WEB-INF/views/home.jsp`. `DefaultServlet` thật của Tomcat phục vụ lại `/css`, `/js`, ảnh với đúng Content-Type. |
| `WEB-INF/views/home.jsp` | **MỚI** — nội dung trang chủ (copy từ index.jsp cũ) đặt trong `/WEB-INF` để servlet forward tới mà không đụng mapping `/index.jsp` (tránh vòng lặp). |
| `webapp/index.jsp` (cũ) | **XÓA** — đã bị servlet mapping shadow; nội dung chuyển sang `home.jsp`. |

**Không** đổi CSS, không đổi contextPath (các `<link>` đã đúng `/NhietDoiXanh_Web/css/...`),
không đổi backend/DAO/service, không đổi database.

## 4. Header đã khôi phục thế nào
Header vốn đã đúng — chỉ cần CSS load lại là hiển thị chuẩn. Sau khi Content-Type CSS đúng
(`text/css`), `.navbar`, `.navbar-logo`, `.nav-links`, `.nav-cta`... apply bình thường: logo trái,
menu (Câu Chuyện / Giá Trị / Sản Phẩm / Đội Ngũ), giỏ hàng + badge, đăng nhập/dropdown, nút Đặt Hàng.
Không còn "Thực Đơn" riêng (đã gộp từ trước).

## 5. Logo/icon phóng to đã fix thế nào
Không cần sửa CSS logo riêng. CSS sẵn có đã đúng:
```
.navbar-logo svg { width: 24px; height: 24px; fill: var(--white); }
```
Mảng đen khổng lồ chỉ là **hệ quả** của việc CSS không load (SVG mất ràng buộc kích thước).
CSS load lại → logo tự về 24px. Root cause được xử lý, không vá triệu chứng.

## 6. Kết quả `mvn clean package`
```
BUILD SUCCESS (exit 0)
target/NhietDoiXanh_Web.war
```

## 7. Trang/tài nguyên đã test (live trên :8080)
**Content-Type tài nguyên tĩnh (đã đúng):**
```
/css/style.css     → 200  text/css
/css/product.css   → 200  text/css
/css/account.css   → 200  text/css
/js/cart.js        → 200  text/javascript
/js/checkout.js    → 200  text/javascript
/js/avatar-crop.js → 200  text/javascript
/images/cam.png    → 200  image/png
```
**Routes:**
```
/                          → 200  (render đủ 24 shop-card featured products thật, link chi-tiet?id=1,2,3...)
/san-pham                  → 200
/san-pham/chi-tiet?id=1    → 200
/cart /checkout /account*  → 302 → login (đúng, AuthFilter)
/admin/login /login /register → 200
/thuc-don                  → 301 → /san-pham
```
Home HTML tham chiếu `href="/NhietDoiXanh_Web/css/style.css?v=6"` — contextPath đúng.

## 8. Vấn đề còn lại
- **App đang chạy ở port 8080** (V-SPORT hiện không chiếm 8080 nữa nên SmartTomcat quay lại 8080).
  Mở `http://localhost:8080/NhietDoiXanh_Web/`. Nếu V-SPORT cần 8080, đổi lại port app này sang 8081.
- **Trình duyệt đang cache CSS hỏng cũ** (Content-Type text/html đã bị cache). Cần **hard refresh
  (Ctrl+Shift+R)** một lần để nạp lại CSS với Content-Type đúng.
- Không có blocker code nào còn lại. Product/cart/checkout/account/admin/PayOS/COD không bị đụng.

## Bài học
`@WebServlet("/")` **không** phải "map trang chủ" — nó thay thế DefaultServlet và chặn toàn bộ
tài nguyên tĩnh. Trang chủ cần servlet xử lý thì map vào `/index.jsp` (kết hợp welcome-file),
tuyệt đối không map `/`.
