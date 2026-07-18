# PayOS / VietQR Integration Report — Nhiệt Đới Xanh

## Trạng thái: HOÀN TẤT (COD không bị ảnh hưởng; thiếu config → PayOS tự ẩn an toàn)

## 1. Nguồn tham chiếu API
Repo PureNut (`com.purenut.shop.config`) **không tồn tại** trên máy. Vì vậy toàn bộ endpoint,
tên field JSON và thuật toán chữ ký được đối chiếu trực tiếp với **SDK chính thức**
`vn.payos:payos-java:2.0.1` (đọc từ `payos-java-2.0.1-sources.jar` trong `~/.m2`) — KHÔNG đoán API.
Dự án **không** nhúng SDK đó (nó kéo theo OkHttp + Jackson + Lombok); thay vào đó gọi REST API v2
trực tiếp bằng `java.net.http.HttpClient` + Gson sẵn có, giữ dự án tối giản.

## 2. Files
| File | Vai trò |
|------|---------|
| `config/PayOSConfig.java` | Đọc credential: ưu tiên ENV (`PAYOS_CLIENT_ID/API_KEY/CHECKSUM_KEY/RETURN_URL/CANCEL_URL/WEBHOOK_URL`), fallback `db.properties` (`payos.*`). `isConfigured()` = đủ 3 credential bắt buộc. |
| `service/PayOSPaymentService.java` | Tạo payment link (`POST /v2/payment-requests`, ký HMAC-SHA256 trên 5 field `amount,cancelUrl,description,orderCode,returnUrl`) + verify webhook (sort field theo alphabet, HMAC-SHA256, so với `signature`). |
| `controller/CheckoutController.java` | Nhánh `paymentMethod=PAYOS` trong `place-order`: tạo Order (PENDING, PayOSOrderCode unique), **không** xóa cart, gọi tạo link, redirect sang `checkoutUrl`. |
| `controller/PaymentController.java` | **MỚI** — webhook / return / cancel (mô tả bên dưới). |
| `dao/OrderDAO.java` + `dao/impl/OrderDaoImpl.java` | `placeOrderPayOS`, `attachPayOSPaymentLink`, `markPayOSLinkFailed`, `findByPayOSOrderCode`, `markPaidByPayOSOrderCode` (idempotent + xóa đúng CartItems), `markNonSuccessByPayOSOrderCode`, `cancelPayOSPendingByOrderIdAndUserId`. |
| `sql/migration_payos_v5.sql` | Cột `PayOSOrderCode/PayOSPaymentLinkId/PayOSCheckoutUrl/PaidAt` + bảng mapping `OrderCartItems` (idempotent). |

## 3. Endpoint mới (`PaymentController`)
- **POST `/payment/payos/webhook`** — server-to-server. **Bỏ qua CSRF DUY NHẤT cho path này**
  (thêm ngoại lệ hẹp trong `CsrfFilter`); bảo mật bằng chữ ký HMAC-SHA256. `verifyWebhook` trả
  `null` → coi là TỪ CHỐI (HTTP 401, **không** chạm DB). Thành công (`code=00`) →
  `markPaidByPayOSOrderCode` (idempotent, chỉ lần đầu chuyển PAID + xóa đúng CartItems của đơn).
  Thất bại → `markNonSuccessByPayOSOrderCode(FAILED)` chỉ khi đơn còn PENDING; không đụng cart.
- **GET `/payment/payos/return`** — **KHÔNG tự đánh dấu PAID**; chỉ đọc trạng thái thật từ DB,
  ownership check (UserID), render `payment-return.jsp` (PAID → "thành công", chưa → "đang chờ").
- **GET `/payment/payos/cancel`** — hủy đơn PENDING nếu đúng chủ sở hữu, **không xóa cart**,
  redirect về `/cart` với thông báo giữ nguyên giỏ hàng.

## 4. Checkout UI
`checkout.jsp` hiển thị PayOS trong danh sách phương thức: **enable + chọn được** khi
`payosConfigured=true`, ngược lại hiển thị disabled "Chưa cấu hình". COD luôn là mặc định.

## 5. An toàn khi thiếu config
`isConfigured()=false` → app vẫn start, COD chạy bình thường, PayOS disabled ở UI,
`createPaymentLink` ném lỗi có kiểm soát, `verifyWebhook` trả null (webhook 401).
Test thực tế (môi trường này chưa cấu hình PayOS): webhook chữ ký sai → **HTTP 401**, không chạm DB. ✓

## 6. Bảo mật đã kiểm
- Không tin amount/userId từ client — tính lại từ DB.
- Webhook bắt buộc verify chữ ký; idempotent; chữ ký sai không update.
- Return URL không tự PAID.
- CSRF chỉ bỏ qua đúng `/payment/payos/webhook`.
- Không log apiKey/checksumKey/response body nhạy cảm.
- `db.properties` các key `payos.*` để **trống** (không commit secret).
