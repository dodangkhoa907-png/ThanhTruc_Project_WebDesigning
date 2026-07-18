# PROMPT 9 — Fix luồng điều hướng, gộp Thực Đơn/Sản Phẩm, checkout address autofill, GPS display, account orders routing

## 1. Gộp "Thực Đơn" vào "Sản Phẩm"

**Vấn đề cũ:** dự án bán cây/decor nhưng còn giữ route `/thuc-don` (menu.jsp) song song với
`/san-pham` (product-list.jsp) — hai cổng mua hàng gây nhầm lẫn, và tên "Thực Đơn" chỉ hợp ngành F&B.

**Đã sửa:**
- [`ProductController.java`](../src/main/java/com/nhietdoixanh/controller/ProductController.java) —
  route `/thuc-don` không còn forward sang `menu.jsp` nữa. Handler mới `handleThucDonRedirect()`
  trả **301 Moved Permanently** về `/san-pham`, giữ nguyên `?danhmuc=ID` nếu có để không phá các
  link/bookmark cũ đã trỏ `/thuc-don?danhmuc=...`.
- [`menu.jsp`](../src/main/webapp/WEB-INF/views/menu.jsp) — **đã xóa** vì không còn servlet nào
  forward tới (dead code, không dùng riêng CSS `menu.css` cho trang khách hàng nữa).
- [`customer-header.jsp`](../src/main/webapp/WEB-INF/views/common/customer-header.jsp) — bỏ hẳn
  link "Thực Đơn"; header khách hàng giờ chỉ còn **một** cổng mua hàng chính: "Sản Phẩm".
  Active state của link "Sản Phẩm" nhận cả `currentPage == 'products'` lẫn `currentPage == 'menu'`
  (giá trị "menu" không còn servlet nào set nữa nhưng giữ lại điều kiện để tương thích ngược an toàn).

**Kết quả:** `/thuc-don` không 404, redirect an toàn về `/san-pham`; dữ liệu Product/Category
không đổi; header gọn hơn với đúng 1 mục "Sản Phẩm".

## 2. Landing page — click sản phẩm đi đúng chi tiết theo ID

**Vấn đề cũ:** section "Menu" ở trang chủ (`index.jsp`) hard-code 6 món nước ép giả (Cam, Thơm,
Dưa Hấu, Bưởi, Ổi, Cà Rốt) không có `ProductID` thật, không có link nào trỏ tới trang chi tiết —
mọi CTA chỉ cuộn tới `#checkout` (form liên hệ nhanh cũ, POST `/order`, không tạo Order thật).

**Đã sửa:**
- [`HomeController.java`](../src/main/java/com/nhietdoixanh/controller/HomeController.java)
  (**servlet mới**, `@WebServlet("/")`) — nạp tối đa 6 sản phẩm active thật từ
  `ProductDao.findAllActive()`, set attribute `featuredProducts`, forward sang `/index.jsp`.
- [`index.jsp`](../src/main/webapp/index.jsp) — section "Menu" cũ (best-seller zig-zag + classic
  list, toàn dữ liệu giả) được thay bằng section "Sản Phẩm Nổi Bật" dùng lại đúng class
  `.shop-card`/`.shop-grid` sẵn có trong `product.css` (không viết CSS trùng lặp). Mỗi card:
  - Ảnh + tên sản phẩm đều là `<a href=".../san-pham/chi-tiet?id=${p.productId}">`.
  - Nếu `p.imageUrl` rỗng → placeholder icon 🌿 (không vỡ layout).
  - Chỉ hiển thị sản phẩm active (`findAllActive()` đã lọc `IsActive = 1`).
  - Nút "Xem chi tiết" đi đúng ID, không dùng link chung `/san-pham` cho từng sản phẩm cụ thể.
  - CTA lớn "Xem Tất Cả Sản Phẩm" ở cuối section trỏ `/san-pham` (đúng yêu cầu — trang tổng,
    không phải từng sản phẩm).
  - Rỗng dữ liệu → empty state `.shop-empty` (tái dùng từ `product-list.jsp`), không lỗi.

**Test:** click bất kỳ sản phẩm nào ở trang chủ → URL `.../san-pham/chi-tiet?id=<id thật>` →
`ProductController.handleShopDetail()` (đã có sẵn) chặn ID không tồn tại/không active bằng
404 + empty state đẹp (không đổi hành vi phần này, đã đúng từ trước).

## 3. Checkout — Address Autofill

**Đã có sẵn từ prompt trước** (xác nhận lại, không phá): GET `/checkout` lấy
`UserAddressDao.findDefaultByUserId()` để prefill họ tên/SĐT/tỉnh-thành/quận-huyện/phường-xã/số nhà.

**Bổ sung mới trong prompt này** —
[`CheckoutController.java`](../src/main/java/com/nhietdoixanh/controller/CheckoutController.java)
và [`checkout.jsp`](../src/main/webapp/WEB-INF/views/checkout.jsp):

- **Dropdown chọn địa chỉ đã lưu**: nếu user có nhiều địa chỉ (`UserAddressDao.findByUserId()`),
  hiển thị `<select id="savedAddressSelect">` liệt kê tất cả, mặc định chọn sẵn địa chỉ mặc định.
  Chọn địa chỉ khác → JS (`checkout.js#initSavedAddressSelect`) tự điền lại toàn bộ field: nhãn,
  người nhận, SĐT, tỉnh/thành, quận/huyện, phường/xã, số nhà/đường, và lat/lng nếu địa chỉ đó có.
- **Không có địa chỉ nào** → hiển thị gợi ý thân thiện: "Bạn có thể lưu địa chỉ để lần sau thanh
  toán nhanh hơn." (`.checkout-address-hint`). User vẫn checkout thủ công bình thường — không bắt
  buộc phải có địa chỉ lưu sẵn.
- **Link "Quản lý sổ địa chỉ"** → `${pageContext.request.contextPath}/account/addresses`
  (mở tab mới, không mất tiến trình checkout).
- **Backend (ownership)**: `handlePlaceOrder()` nay đọc thêm `addressId` (hidden field, do JS set
  khi user chọn dropdown). Nếu có `addressId` gửi lên, server **bắt buộc** verify
  `UserAddressDao.findByIdAndUserId(addressId, userId)` — không tồn tại/không thuộc user hiện tại
  → từ chối ngay, redirect về `/cart` kèm lỗi. Dữ liệu địa chỉ thực tế dùng để tạo Order **vẫn luôn**
  đọc từ các field text đã submit và được validate lại toàn bộ từ đầu (độ dài, định dạng...) —
  `addressId` không tự ý ghi đè field nào, chỉ dùng để chặn IDOR (không tin addressId client nếu
  chưa verify ownership, đúng yêu cầu). Không nhận `userId` từ client ở bất kỳ đâu (giữ nguyên).

## 4. Checkout — Hiển thị rõ GPS

**Vấn đề cũ:** có nút "Lấy vị trí hiện tại" nhưng chỉ hiện 1 dòng text trạng thái mờ nhạt, không
có card riêng, không có cách xóa tọa độ đã lấy.

**Đã sửa** — [`checkout.jsp`](../src/main/webapp/WEB-INF/views/checkout.jsp),
[`checkout.js`](../src/main/webapp/js/checkout.js), CSS mới trong
[`product.css`](../src/main/webapp/css/product.css):

- **Chưa lấy vị trí**: dòng trạng thái nhỏ "Chưa lấy vị trí." (`#gpsStateText`).
- **Đang lấy**: nút đổi label "Đang lấy vị trí..." (spinner), trạng thái cập nhật tương ứng.
- **Thành công**: card `.checkout-gps-card` hiện ra — "Đã lấy vị trí hiện tại", hiển thị rõ
  `Latitude: ...` / `Longitude: ...`, kèm nút "Xóa vị trí" (`#gpsClearBtn`) để clear 2 hidden field
  `latitude`/`longitude` và ẩn card lại — **không** tự ý thay thế địa chỉ chữ đã nhập.
- **Lỗi/từ chối quyền**: thông báo thân thiện "Không lấy được vị trí. Bạn vẫn có thể nhập địa chỉ
  thủ công." trong khối `.checkout-gps-error` (không dùng bất kỳ API ngoài/reverse geocoding/API key
  nào — chỉ đọc `navigator.geolocation` của trình duyệt).
- **Địa chỉ mặc định đã có lat/lng sẵn** (từ sổ địa chỉ) → khi vào trang lần đầu, card GPS tự hiện
  sẵn với trạng thái "Địa chỉ này đã có tọa độ." (biến JSP `prefillLat`/`prefillLng` ưu tiên giá trị
  form lỗi cũ, fallback `defaultAddress.latitude/longitude`). User vẫn bấm "Lấy vị trí hiện tại" để
  cập nhật lại nếu muốn.
- GPS hoàn toàn optional — không có ràng buộc bắt buộc để đặt hàng (giữ nguyên, server không
  require lat/lng).

## 5. Fix routing "Đơn hàng" trong account

**Kết quả rà soát:** toàn bộ các vị trí liên quan (`customer-header.jsp` dropdown, `account-sidebar.jsp`,
`account/dashboard.jsp`, `checkout-success.jsp`, `account/orders.jsp`, `account/order-detail.jsp`)
**đã đúng từ các prompt trước** — tất cả dùng
`${pageContext.request.contextPath}/account/orders` (không hard-code context path, không dùng
`<c:url>` nhưng tương đương về mặt an toàn vì EL `pageContext.request.contextPath` luôn chính xác).
Không tìm thấy link sai kiểu `/orders`, `/account/order` (số ít), `/don-hang` (namespace đó là
route admin thật, khác `/account/orders` của customer, không phải lỗi), hay `#orders` chưa
redirect. **Không cần sửa gì thêm ở phần này** — chỉ xác nhận lại bằng cách grep toàn bộ
`src/main/webapp` để chắc chắn không còn sót.

## 6. Rà soát Orders / Order Detail

Xác nhận (không cần sửa, đã đúng sẵn trong `AccountController.java`):

- `/account/orders` — `handleOrdersList()` luôn lọc `WHERE UserID = ?` lấy từ session, có filter
  trạng thái + tìm theo mã đơn + phân trang.
- `/account/orders/detail?id=...` — `handleOrderDetail()` ownership check ngay trong SQL
  (`OrderDAO.findByIdAndUserId`), không tồn tại hoặc thuộc user khác → cùng 1 phản hồi redirect về
  `/account/orders` (không lộ thông tin qua khác biệt lỗi).
- Nút back ở order-detail → `/account/orders` (đúng).
- Nút "Xem chi tiết" ở list → `/account/orders/detail?id=${o.orderId}` (đúng).
- Nhãn trạng thái tiếng Việt lấy từ `OrderStatuses`/`PaymentStatuses` (class dùng chung, không rải
  chuỗi hard-code): Chờ xác nhận / Đang xử lý / Đang giao / Hoàn thành / Đã hủy / Chờ duyệt hủy —
  đúng yêu cầu, không còn status code tiếng Anh trần trên UI.
- Encoding UTF-8 xuyên suốt qua `EncodingFilter` + `page-encoding` JSP config trong `web.xml`.

## 7. Checklist test thủ công

**NAVIGATION**
- [x] Header không còn mục "Thực Đơn" riêng — chỉ còn "Sản Phẩm".
- [x] `/thuc-don` → 301 redirect về `/san-pham` (giữ `?danhmuc=` nếu có).
- [x] `/san-pham` và `/san-pham/chi-tiet` active đúng mục "Sản Phẩm".
- [x] Click sản phẩm ở trang chủ → `/san-pham/chi-tiet?id=<id thật>`.

**CHECKOUT**
- [x] User có địa chỉ mặc định → `/checkout` tự điền toàn bộ field + lat/lng nếu có.
- [x] User có nhiều địa chỉ → chọn dropdown khác tự điền đúng field tương ứng.
- [x] User không có địa chỉ → vẫn checkout thủ công bình thường, có gợi ý lưu địa chỉ.
- [x] Bấm "Lấy vị trí hiện tại" → card hiện rõ Latitude/Longitude.
- [x] Bấm "Xóa vị trí" → hidden lat/lng bị clear, card ẩn lại.
- [x] Submit COD vẫn tạo Order đúng (transaction `OrderDaoImpl.placeOrder`, không đổi).
- [x] PayOS (nếu đã cấu hình) không bị ảnh hưởng — nhánh `handlePlaceOrderPayOS` không đổi logic.

**ACCOUNT**
- [x] Header dropdown / account sidebar / dashboard / checkout-success — tất cả link "Đơn hàng"
      đều đi đúng `/account/orders`.
- [x] `/account/orders` list đúng đơn của user hiện tại.
- [x] `/account/orders/detail?id=...` đúng đơn, chặn xem đơn của user khác (test bằng cách sửa
      `id` sang OrderID không thuộc mình → redirect về `/account/orders`, không lộ dữ liệu).
- [x] Active state "Đơn hàng" đúng ở cả list và detail (`accountTab == 'orders'`).

**REGRESSION**
- [x] `/cart`, `/checkout`, `/account/profile`, `/account/addresses` không đổi hành vi.
- [x] Không CSS/JS 404 mới (chỉ sửa file có sẵn: `product.css`, `checkout.js`; `assetVer` đã tăng
      4 → 5 theo đúng quy ước cache-bust của dự án trong `web.xml`).
- [x] Tiếng Việt không lỗi encoding (UTF-8 xuyên suốt, không đổi filter/encoding config).

## 8. Kết quả `mvn clean package`

```
mvn clean package -q
EXIT_CODE=0
target/NhietDoiXanh_Web.war  (build thành công)
```

## 9. Danh sách file đã thay đổi

- **Mới:** `src/main/java/com/nhietdoixanh/controller/HomeController.java`
- **Sửa:** `src/main/java/com/nhietdoixanh/controller/ProductController.java`
- **Sửa:** `src/main/java/com/nhietdoixanh/controller/CheckoutController.java`
- **Sửa:** `src/main/webapp/WEB-INF/views/common/customer-header.jsp`
- **Sửa:** `src/main/webapp/index.jsp`
- **Sửa:** `src/main/webapp/WEB-INF/views/checkout.jsp`
- **Sửa:** `src/main/webapp/js/checkout.js`
- **Sửa:** `src/main/webapp/css/product.css`
- **Sửa:** `src/main/webapp/WEB-INF/web.xml` (assetVer 4 → 5)
- **Xóa:** `src/main/webapp/WEB-INF/views/menu.jsp` (dead code sau khi gộp route)
