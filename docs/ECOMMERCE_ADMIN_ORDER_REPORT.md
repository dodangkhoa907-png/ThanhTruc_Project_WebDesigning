# Prompt 5 — Fix Encoding Toàn Dự Án + Admin Quản Lý Đơn Hàng

## Phần A — Lỗi Encoding Tiếng Việt

### Nguyên nhân gốc (đã xác minh, không đoán)

Đã kiểm tra bằng hexdump — nội dung trên đĩa **là UTF-8 hợp lệ** (vd. "ệ" → `E1 BB 87`, đúng chuẩn), và mọi trang JSP top-level đều có `<%@ page contentType="text/html;charset=UTF-8" %>` đúng. Vậy lỗi không nằm ở file bị lưu sai charset, cũng không nằm ở filter/response.

Nguyên nhân thật: [`customer-header.jsp`](../src/main/webapp/WEB-INF/views/common/customer-header.jsp) là **fragment được include tĩnh** (`<%@ include %>`) vào 7 trang (index, cart, checkout, checkout-success, menu, product-list, product-detail) nhưng **không có page directive riêng**. Jasper (JSP engine của Tomcat) xác định encoding nguồn cho từng file trong translation unit — file fragment không khai báo `pageEncoding` sẽ bị đọc bằng encoding mặc định (không phải UTF-8) dù trang cha khai UTF-8. Kết quả: mỗi byte UTF-8 trong fragment bị đọc thành 1 ký tự Latin-1/Windows-1252 riêng lẻ, sau đó bị ghi lại thành UTF-8 ở output → mojibake dạng "double-encode" (`ệ` → `ệ` hiển thị thành `á»‡`, đúng khớp `E1→á, BB→», 87→‡` theo bảng Windows-1252).

Bằng chứng xác nhận: nội dung tĩnh của chính `index.jsp` (hero section, nút "Đặt Hàng Ngay") hiển thị đúng tiếng Việt trên cùng trang bị lỗi — chỉ phần include từ `customer-header.jsp` mới hỏng. Nếu lỗi nằm ở filter/response/Tomcat connector, toàn bộ trang phải hỏng đồng loạt, không chỉ riêng fragment.

`WEB-INF/views/admin/layout/footer.jsp` có cùng vấn đề (không có page directive) nhưng chưa gây lỗi hiển thị vì file chỉ chứa `</main></body></html>`, không có text tiếng Việt.

### File đã sửa

| File | Thay đổi |
|---|---|
| [`WEB-INF/views/common/customer-header.jsp`](../src/main/webapp/WEB-INF/views/common/customer-header.jsp) | Thêm `<%@ page pageEncoding="UTF-8" %>` — fix trực tiếp root cause |
| [`WEB-INF/views/admin/layout/footer.jsp`](../src/main/webapp/WEB-INF/views/admin/layout/footer.jsp) | Thêm `<%@ page pageEncoding="UTF-8" %>` — phòng ngừa, chưa có text nên chưa từng lỗi |
| [`WEB-INF/web.xml`](../src/main/webapp/WEB-INF/web.xml) | Thêm `<jsp-config><jsp-property-group>` đặt `page-encoding=UTF-8` mặc định cho mọi `*.jsp`/`*.jspf` — phòng thủ chiều sâu: fragment mới trong tương lai quên khai `pageEncoding` vẫn được đọc đúng UTF-8 |

### Các phần đã kiểm tra nhưng KHÔNG cần sửa (đã xác minh, không phải nguyên nhân)

- `EncodingFilter` (`util/EncodingFilter.java`) — đã set `request/response.setCharacterEncoding("UTF-8")`, chạy đầu tiên trong chain (chỉ filter duy nhất khai trong `web.xml`, các filter khác dùng `@WebFilter` nên chạy sau). Đúng, không đổi.
- Toàn bộ JSP top-level khác (index, cart, checkout, checkout-success, menu, product-list, product-detail, login, register, admin/*) — đều đã có `contentType="text/html;charset=UTF-8"` đúng.
- `pom.xml` — đã có `project.build.sourceEncoding=UTF-8` và `maven-compiler-plugin` encoding UTF-8. Không ảnh hưởng JSP (JSP không được Maven precompile, không có plugin `jasper`/`jspc`).
- Tomcat `URIEncoding` — project chạy Tomcat 10.1 (Jakarta Servlet 6.0), mặc định `URIEncoding=UTF-8` từ Tomcat 8.5+. `.smarttomcat/` là config cục bộ do IDE sinh ra, đã nằm trong `.gitignore`, không sửa (đúng yêu cầu không hard-code path máy cá nhân).
- Dữ liệu tiếng Việt trong SQL Server — xem mục audit bên dưới, **DB không bị lỗi**, không sửa.

### Audit dữ liệu DB (chỉ đọc, không sửa)

Thay vì đoán, đã xác minh trực tiếp qua ứng dụng đang chạy (Tomcat cục bộ, docBase trỏ thẳng `src/main/webapp`): mở `/thuc-don` và `/san-pham`, các trường lấy từ SQL Server (`Products.ProductName`, `Products.Description`, `Categories.CategoryName`, vd. "Ép Cam Nguyên Chất", "Cam tươi 100%, bổ sung vitamin C", "Dòng phổ thông (Ép nguyên chất)") hiển thị đúng tiếng Việt có dấu, không mojibake. Kết luận: **DB lưu đúng UTF-8/NVARCHAR, không cần script repair**.

### Cách đã test

Test trực tiếp trên Tomcat cục bộ (docBase trỏ `src/main/webapp`, JSP tự biên dịch lại khi file thay đổi — không cần deploy lại):

1. `/` (trang chủ, gồm `#story`) — header, nav, hero, story section, menu preview, đội ngũ, form đặt hàng: **đúng tiếng Việt hoàn toàn**, không còn `Nhiá»‡t`, `Thá»±c`, `Ä‘`.
2. `/thuc-don`, `/san-pham` — đúng, kể cả dữ liệu từ DB.
3. `/login`, `/register` — đúng.
4. Đăng ký tài khoản test (`Test Encoding QA`) → `/cart` → thêm sản phẩm → `/checkout` → **chủ động điền địa chỉ có dấu tiếng Việt** ("123 Nguyen Hue - Test Encoding QA Ệ Đ Ơ Ư") → đặt hàng COD thành công (đơn `#4`) → `/checkout/success` hiển thị đúng dấu tiếng Việt vừa nhập, xác nhận round-trip đầy đủ: browser → EncodingFilter → servlet → DB → JSP → browser, không lệch một khâu nào.
5. Console trình duyệt: không có lỗi JS. Network: không có request 404 (css/js/images đều 200).

**Kết luận Phần A: đã fix triệt để, không phá checkout COD, không phá cart/product/login/register.**

## Phần B — Admin Quản Lý Đơn Hàng

### Route đã tạo

Tất cả nằm dưới `AdminOrderController` (`urlPatterns` khai trực tiếp trong `@WebServlet`, không cần sửa `web.xml`):

| Route | Method | Chức năng |
|---|---|---|
| `/admin/don-hang` | GET | Danh sách + tìm kiếm/lọc/phân trang |
| `/admin/don-hang/chi-tiet?id=` | GET | Chi tiết đơn + timeline + khu vực thao tác |
| `/admin/don-hang/cap-nhat-trang-thai` | POST | Chuyển trạng thái (xác nhận/giao/hoàn thành/hủy trực tiếp) |
| `/admin/don-hang/duyet-huy` | POST | Duyệt yêu cầu hủy (`PENDING_CANCEL → CANCELLED`) |
| `/admin/don-hang/tu-choi-huy` | POST | Từ chối yêu cầu hủy (`PENDING_CANCEL → CONFIRMED`) |

3 route hành động **chỉ nhận POST** — GET vào các route này trả `405 Method Not Allowed` (chặn thao tác qua link/prefetch).

### File đã tạo/sửa

**Mới:**
- [`controller/admin/AdminOrderController.java`](../src/main/java/com/nhietdoixanh/controller/admin/AdminOrderController.java) — servlet xử lý cả 5 route trên.
- [`model/OrderAdminFilter.java`](../src/main/java/com/nhietdoixanh/model/OrderAdminFilter.java) — POJO mang tiêu chí lọc (keyword, orderStatus, paymentStatus, paymentMethod, fromDate, toDate).
- `WEB-INF/views/admin/orders/list.jsp` — trang danh sách.
- `WEB-INF/views/admin/orders/detail.jsp` — trang chi tiết.

**Sửa:**
- `model/Order.java` — thêm field `userEmail` (bổ sung cho UI, cùng kiểu với `handledByName` đã có sẵn).
- `dao/OrderDAO.java` + `dao/impl/OrderDaoImpl.java` — thêm `adminSearchOrders`, `countAdminSearchOrders`, `adminCancelOrder`. **Không sửa** các method sẵn có (`updateStatusWithValidation`, `approveCancelOrder`, `rejectCancelOrder` đã có từ trước, viết đúng chuẩn state machine, tái sử dụng nguyên vẹn).
- `dao/AuditLogDao.java` + `dao/impl/AuditLogDaoImpl.java` — thêm `findByTarget(String target)` để dựng timeline từ `AuditLogs` có sẵn (không tạo bảng mới).
- `WEB-INF/views/admin/layout/header.jsp` — thêm CSS badge cho `PENDING_CANCEL` và các trạng thái thanh toán (`UNPAID/PAID/FAILED/REFUND_PENDING`). Sidebar "Đơn hàng" đã trỏ sẵn `/admin/don-hang` từ trước (do prompt trước chuẩn bị) — tự động hết "Sắp có" khi route tồn tại, không cần sửa logic.

### DAO/Service đã thêm — chi tiết

- **`OrderDaoImpl.adminSearchOrders` / `countAdminSearchOrders`**: build `WHERE` động bằng `StringBuilder`/`List<Object>` (theo đúng convention có sẵn ở `ProductDaoImpl.findActiveForShop`), dùng chung một hàm `buildAdminFilterSql()` cho cả 2 method để đảm bảo thứ tự tham số SQL và WHERE clause luôn khớp nhau — tránh lệch tham số giữa query lấy dữ liệu và query đếm. Toàn bộ dùng `PreparedStatement` (không nối chuỗi SQL với input). Phân trang bằng `OFFSET ... FETCH NEXT ... ROWS ONLY` phía SQL Server — **không load toàn bộ Orders vào RAM**.
- Tìm kiếm khớp: mã đơn (`CAST(OrderID AS NVARCHAR)`), tên người nhận, tên khách, SĐT người nhận, SĐT khách, email (`LEFT JOIN Users`).
- **`OrderDaoImpl.adminCancelOrder`**: `UPDATE ... WHERE OrderStatus IN ('PENDING','CONFIRMED')` — atomic, race-safe (cùng pattern với `approveCancelOrder`/`rejectCancelOrder` có sẵn), tránh race condition kiểu SELECT-rồi-UPDATE.
- **`AuditLogDaoImpl.findByTarget`**: `SELECT ... WHERE Target = ? ORDER BY CreatedAt ASC` — tái dùng bảng `AuditLogs` có sẵn để dựng "Timeline trạng thái" thay vì tạo bảng lịch sử mới (đúng yêu cầu không sửa DB nếu không cần).

### State machine áp dụng

Dùng nguyên `OrderStatuses.canTransition()` có sẵn từ Prompt 1 (`util/OrderStatuses.java`) — **không viết lại luật chuyển trạng thái ở servlet/JSP**:

```
PENDING        → CONFIRMED, CANCELLED
CONFIRMED      → SHIPPING, PENDING_CANCEL, CANCELLED
SHIPPING       → DONE
PENDING_CANCEL → CANCELLED (qua "duyệt hủy"), CONFIRMED (qua "từ chối hủy")
DONE           → (không có transition nào)
CANCELLED      → (không có transition nào)
```

Validate nằm ở **backend** (`OrderDaoImpl.updateStatusWithValidation` ném `IllegalStateException` nếu transition sai; `adminCancelOrder` chỉ update nếu `OrderStatus IN ('PENDING','CONFIRMED')`), JSP chỉ **ẩn/hiện nút** dựa trên cờ boolean servlet tính sẵn (`canConfirm/canShip/canDone/canCancelDirect/canReviewCancelRequest`) — ẩn nút không phải là validation, chỉ là UX; chặn thật nằm ở DAO.

**Bug tự phát hiện khi review lại (không test được qua browser — xem mục Rủi ro):** `PENDING_CANCEL → CANCELLED` là transition hợp lệ theo `canTransition()`, nhưng transition này **chỉ được thực hiện qua "duyệt hủy"**, không qua nút hủy trực tiếp (vì `adminCancelOrder` không match `WHERE` khi status là `PENDING_CANCEL`). Ban đầu cờ `canCancelDirect` tính thẳng từ `canTransition()` nên sẽ hiện đồng thời cả nút "Hủy đơn" lẫn "Duyệt/Từ chối hủy" khi đơn đang `PENDING_CANCEL`, và bấm "Hủy đơn" sẽ luôn báo lỗi. Đã sửa: `canCancelDirect` loại trừ rõ trạng thái `PENDING_CANCEL`.

### Payment status

Đúng theo yêu cầu: **không tự động đổi `PaymentStatus` khi admin chuyển đơn sang DONE**. Cột `PaymentStatus` cho COD giữ nguyên `UNPAID` do DB default khi tạo đơn (`OrderDaoImpl.placeOrder` không insert cột này). Nếu sau này cần nghiệp vụ "COD giao xong tự đánh dấu đã thu tiền" thì phải làm ở prompt riêng, có xác nhận rõ ràng — **chưa làm trong prompt này**.

### Bảo mật

- **AuthFilter** (có sẵn) chặn toàn bộ `/admin/*` — chỉ Staff có session `adminUser` + `isActive()` mới vào được; không sửa filter này.
- **CsrfFilter** (có sẵn, áp dụng toàn site) chặn mọi POST thiếu/sai token `_csrf` — mọi form admin đều có `<input type="hidden" name="_csrf" value="${sessionScope._csrf}">`.
- Người thao tác (`staffId` cho `AuditLogger`) luôn lấy từ `session.getAttribute("adminUser")`, **không bao giờ** nhận từ request param.
- Toàn bộ SQL dùng `PreparedStatement`, không nối chuỗi input.
- Validate `orderId` (số nguyên dương), `newStatus` (chuẩn hóa + kiểm tra hợp lệ qua `OrderStatuses.isValid`) trước khi chạm DB.
- Filter danh sách (orderStatus/paymentStatus/paymentMethod) được đối chiếu với whitelist hợp lệ trước khi đưa vào truy vấn — tránh query rác dù đã dùng PreparedStatement.
- Lỗi hệ thống (SQLException...) chỉ log ra `System.err`, JSP chỉ hiện thông báo tiếng Việt chung chung qua flash message — **không trả stack trace ra browser**.
- 3 route hành động chỉ nhận POST (405 với GET).
- Toàn bộ text người dùng nhập (tên, SĐT, địa chỉ, ghi chú, lý do hủy, audit log detail) hiển thị qua `<c:out>` — chống XSS.

### Audit log

Mọi hành động admin ghi qua `AuditLogger.log()` có sẵn (không tạo cơ chế mới), `Target = "Order#" + orderId` để có thể truy vấn lại theo đơn:

| Action code | Khi nào |
|---|---|
| `ORDER_STATUS_CONFIRMED` / `ORDER_STATUS_SHIPPING` / `ORDER_STATUS_DONE` | Xác nhận / chuyển giao / hoàn thành |
| `ORDER_STATUS_CANCELLED` | Admin hủy trực tiếp (kèm lý do trong `Detail`) |
| `ORDER_CANCEL_APPROVED` | Duyệt yêu cầu hủy |
| `ORDER_CANCEL_REJECTED` | Từ chối yêu cầu hủy |

Trang chi tiết đơn hiển thị **Timeline trạng thái** dựng từ các log này (`AuditLogDao.findByTarget`) cộng mốc "Đơn hàng được tạo" (`Orders.CreatedAt`) — không cần bảng lịch sử riêng.

### UI Admin

- Tái sử dụng 100% design system có sẵn trong `admin/layout/header.jsp` (biến CSS `--admin-*`, class `.card/.btn/.admin-table/.badge`) — không tạo hệ màu mới.
- Badge trạng thái tiếng Việt rõ ràng qua CSS class theo mã trạng thái (`badge-PENDING`, `badge-CONFIRMED`, `badge-SHIPPING`, `badge-DONE`, `badge-CANCELLED`, `badge-PENDING_CANCEL` mới thêm) + nhãn hiển thị dùng `OrderStatuses.getLabel()`/`PaymentStatuses.getLabel()` — không hiện mã tiếng Anh trần cho badge trạng thái thanh toán, order status hiện tại hiển thị mã (đơn giản, đồng nhất với `dashboard.jsp` sẵn có dùng cùng pattern).
- Empty state khi không có đơn khớp bộ lọc.
- Phân trang dùng `<c:url>`/`<c:param>` của JSTL (tự động URL-encode) thay vì nối chuỗi query string thủ công — tránh vỡ link khi từ khóa tìm kiếm chứa ký tự đặc biệt (`&`, `#`...).
- `table-responsive` (overflow-x: auto) có sẵn từ trước — responsive cơ bản đã đáp ứng trên mobile.

## Kết quả test

### Phần Encoding — đã test đầy đủ qua browser (xem mục "Cách đã test" ở trên)
Tất cả pass: header/nav, story, menu, sản phẩm, login, register, cart, checkout, checkout-success — không còn mojibake, không lỗi console, không lỗi 404.

### Phần Admin — **chưa test được qua browser trong phiên này**
Lý do: không có mật khẩu admin hợp lệ (chỉ có bcrypt hash trong DB `Staffs`, không thể đảo ngược). Đã hỏi và người dùng chọn "tự test, bỏ qua bước browser" thay vì cấp mật khẩu thật hoặc cho phép tạo tài khoản test tạm trong DB thật (DB dùng chung, không phải sandbox local).

Đã bù lại bằng:
1. `mvn clean package` **pass** — toàn bộ code (bao gồm `AdminOrderController`, DAO mới, model mới) biên dịch sạch, không lỗi.
2. Review thủ công kỹ từng route, JSP (đếm cặp thẻ JSTL cân bằng), luồng CSRF/auth/state machine.
3. Tự phát hiện và sửa 1 bug logic thật (mục "State machine áp dụng" ở trên) chỉ nhờ đọc lại code cẩn thận — đây là bằng chứng cho thấy review thủ công không thể thay thế hoàn toàn test qua browser thật.

## Rủi ro còn lại cho prompt sau

1. **Admin flow (Phần B) chưa được xác minh bằng browser thật** — người dùng cần tự đăng nhập `/admin/login` (dùng tài khoản Staff thật, vd. `oanhttk`) và chạy qua checklist 16 bước đã cho trong yêu cầu gốc trước khi coi tính năng là "done". Ưu tiên kiểm tra: xác nhận → giao → hoàn thành đúng thứ tự; thử `DONE → PENDING` phải bị chặn; thử customer (session `user`, không phải `adminUser`) truy cập `/admin/don-hang` phải bị redirect về `/login`; thử POST thiếu `_csrf` phải nhận `403`.
2. `updateStatusWithValidation` (code có sẵn từ trước, không sửa trong prompt này) dùng pattern SELECT-rồi-UPDATE không nằm trong transaction — về lý thuyết có khe hở race condition nhỏ nếu 2 admin bấm nút cùng lúc trên cùng 1 đơn (khác với `approveCancelOrder`/`rejectCancelOrder`/`adminCancelOrder` dùng UPDATE có điều kiện, an toàn hơn). Rủi ro thấp với quy mô admin console nội bộ, nhưng nên biết nếu sau này thấy trạng thái đơn "nhảy" bất thường.
3. Chưa có UI lọc/xem theo `HandledBy` (nhân viên xử lý) hay chức năng `assignHandler` (đã có sẵn ở DAO từ trước nhưng chưa có route/UI gọi tới) — nếu nghiệp vụ cần phân công đơn cho từng nhân viên, cần route riêng ở prompt sau.
4. Nghiệp vụ "COD hoàn thành → tự đánh dấu PAID" cố tình chưa làm (đúng yêu cầu) — cần quyết định rõ trước khi thêm.
5. `PaymentMethod` hiện chỉ có 2 giá trị cứng (`COD`/`PAYOS`) trong bộ lọc — nếu thêm phương thức mới phải cập nhật cả `AdminOrderController` (whitelist) và `list.jsp` (dropdown).
