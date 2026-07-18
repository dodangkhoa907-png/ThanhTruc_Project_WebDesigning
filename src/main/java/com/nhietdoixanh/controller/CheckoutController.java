package com.nhietdoixanh.controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.nhietdoixanh.dao.CartItemDao;
import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.dao.UserAddressDao;
import com.nhietdoixanh.dao.impl.CartItemDaoImpl;
import com.nhietdoixanh.dao.impl.OrderDaoImpl;
import com.nhietdoixanh.dao.impl.UserAddressDaoImpl;
import com.nhietdoixanh.filter.CsrfFilter;
import com.nhietdoixanh.model.CartItem;
import com.nhietdoixanh.model.CheckoutSelection;
import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.model.OrderDetail;
import com.nhietdoixanh.model.User;
import com.nhietdoixanh.model.UserAddress;
import com.nhietdoixanh.service.PayOSPaymentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Checkout COD:
 * - POST /checkout/prepare      — xác thực selection từ /cart, lưu {@link CheckoutSelection} vào session.
 * - GET  /checkout               — hiển thị trang checkout cho selection hiện tại.
 * - POST /checkout/place-order   — tạo Order + OrderDetails thật (transaction), chỉ COD.
 * - GET  /checkout/success        — trang xác nhận đặt hàng thành công (chỉ xem đơn của chính mình).
 *
 * Nguyên tắc xuyên suốt: KHÔNG tin giá/tổng tiền/userId từ client — mọi thứ đọc
 * lại từ session (user đăng nhập) + DB (CartItemDao) ngay tại thời điểm tạo đơn.
 */
@WebServlet(name = "CheckoutController", urlPatterns = {
        "/checkout", "/checkout/prepare", "/checkout/place-order", "/checkout/success"
})
public class CheckoutController extends HttpServlet {

    private static final Gson GSON = new Gson();
    private static final String PHONE_REGEX = "^(0|\\+84)[0-9]{9,10}$";

    private CartItemDao cartItemDao;
    private OrderDAO orderDao;
    private UserAddressDao userAddressDao;

    @Override
    public void init() {
        cartItemDao = new CartItemDaoImpl();
        orderDao = new OrderDaoImpl();
        userAddressDao = new UserAddressDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/checkout" -> handleCheckoutPage(req, resp);
            case "/checkout/success" -> handleSuccessPage(req, resp);
            case "/checkout/prepare" ->
                    // Chuẩn bị checkout là một hành động ghi (tạo session state) — không cho phép GET.
                    resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        switch (path) {
            case "/checkout/prepare" -> handlePrepare(req, resp);
            case "/checkout/place-order" -> handlePlaceOrder(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================================================
    // POST /checkout/prepare — giữ nguyên hành vi cũ (đã hoàn thành ở prompt trước)
    // =========================================================================================

    private void handlePrepare(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập để tiếp tục.");
            return;
        }
        int userId = user.getUserId();

        List<Integer> requestedIds = CartController.parseIdList(req.getParameterValues("cartItemIds"));
        if (requestedIds.isEmpty()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn ít nhất một sản phẩm để thanh toán.");
            return;
        }

        List<CartItem> items = cartItemDao.findSelectedByIdsAndUserId(requestedIds, userId);

        if (items.size() != requestedIds.size()) {
            writeError(resp, HttpServletResponse.SC_CONFLICT,
                    "Một số sản phẩm đã chọn không còn trong giỏ hàng của bạn. Vui lòng tải lại trang.");
            return;
        }

        String validationError = findFirstInvalidItemMessage(items);
        if (validationError != null) {
            writeError(resp, HttpServletResponse.SC_CONFLICT, validationError);
            return;
        }

        BigDecimal previewSubtotal = sumTotal(items);

        CheckoutSelection selection = new CheckoutSelection(userId, requestedIds, LocalDateTime.now());
        session.setAttribute("checkoutSelection", selection);

        JsonObject json = new JsonObject();
        json.addProperty("success", true);
        json.addProperty("message", "Đã chuẩn bị thanh toán.");
        json.addProperty("redirectUrl", req.getContextPath() + "/checkout");
        json.addProperty("itemCount", items.size());
        json.addProperty("previewSubtotal", previewSubtotal);
        writeJson(resp, HttpServletResponse.SC_OK, json);
    }

    // =========================================================================================
    // GET /checkout
    // =========================================================================================

    private void handleCheckoutPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        int userId = user.getUserId();

        CheckoutSelection selection = (CheckoutSelection) session.getAttribute("checkoutSelection");
        if (selection == null || !selection.isUsableBy(userId)) {
            session.removeAttribute("checkoutSelection");
            redirectToCartWithError(session, req, resp,
                    "Phiên thanh toán đã hết hạn hoặc không hợp lệ. Vui lòng chọn lại sản phẩm.");
            return;
        }

        List<CartItem> items = cartItemDao.findSelectedByIdsAndUserId(selection.getCartItemIds(), userId);
        if (items.size() != selection.getCartItemIds().size()) {
            session.removeAttribute("checkoutSelection");
            redirectToCartWithError(session, req, resp,
                    "Một số sản phẩm đã chọn không còn trong giỏ hàng của bạn. Vui lòng chọn lại.");
            return;
        }

        String validationError = findFirstInvalidItemMessage(items);
        if (validationError != null) {
            session.removeAttribute("checkoutSelection");
            redirectToCartWithError(session, req, resp, validationError);
            return;
        }

        String checkoutToken = CsrfFilter.generateToken();
        session.setAttribute("checkoutToken", checkoutToken);

        UserAddress defaultAddress = userAddressDao.findDefaultByUserId(userId).orElse(null);

        req.setAttribute("checkoutItems", items);
        req.setAttribute("subtotal", sumTotal(items));
        req.setAttribute("checkoutToken", checkoutToken);
        req.setAttribute("defaultAddress", defaultAddress);
        req.setAttribute("payosConfigured", PayOSPaymentService.isConfigured());
        // Checkout là bước tiếp theo của giỏ hàng — giữ icon giỏ hàng active trên header thay vì không active gì.
        req.setAttribute("currentPage", "cart");
        req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
    }

    // =========================================================================================
    // POST /checkout/place-order
    // =========================================================================================

    private void handlePlaceOrder(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        int userId = user.getUserId();

        // ---- Chống double-submit: token dùng một lần, tiêu thụ (consume) trước khi làm gì khác ----
        String submittedToken = req.getParameter("checkoutToken");
        synchronized (session) {
            String sessionToken = (String) session.getAttribute("checkoutToken");
            if (sessionToken == null || !sessionToken.equals(submittedToken)) {
                Object lastOrderId = session.getAttribute("lastOrderId");
                if (lastOrderId instanceof Integer orderId) {
                    resp.sendRedirect(req.getContextPath() + "/checkout/success?orderId=" + orderId);
                    return;
                }
                redirectToCartWithError(session, req, resp,
                        "Đơn hàng đã được xử lý hoặc phiên đặt hàng đã hết hạn. Vui lòng thử lại.");
                return;
            }
            // Tiêu thụ ngay trong cùng khối synchronized — request thứ 2 (double-click) tới sau
            // sẽ luôn thấy sessionToken == null và không thể tạo đơn thứ hai.
            session.removeAttribute("checkoutToken");
        }

        // ---- Đọc lại checkoutSelection + giỏ hàng từ DB (không tin dữ liệu form) ----
        CheckoutSelection selection = (CheckoutSelection) session.getAttribute("checkoutSelection");
        if (selection == null || !selection.isUsableBy(userId)) {
            session.removeAttribute("checkoutSelection");
            redirectToCartWithError(session, req, resp, "Phiên thanh toán đã hết hạn. Vui lòng chọn lại sản phẩm.");
            return;
        }

        List<CartItem> items = cartItemDao.findSelectedByIdsAndUserId(selection.getCartItemIds(), userId);
        if (items.size() != selection.getCartItemIds().size()) {
            session.removeAttribute("checkoutSelection");
            redirectToCartWithError(session, req, resp,
                    "Một số sản phẩm đã chọn không còn trong giỏ hàng của bạn. Vui lòng chọn lại.");
            return;
        }
        String validationError = findFirstInvalidItemMessage(items);
        if (validationError != null) {
            session.removeAttribute("checkoutSelection");
            redirectToCartWithError(session, req, resp, validationError);
            return;
        }

        // ---- Validate form thông tin giao hàng ----
        Map<String, String> errors = new LinkedHashMap<>();

        String recipientName = trimOrNull(req.getParameter("recipientName"));
        String recipientPhone = trimOrNull(req.getParameter("recipientPhone"));
        String addressLabel = trimOrNull(req.getParameter("addressLabel"));
        String provinceCity = trimOrNull(req.getParameter("provinceCity"));
        String district = trimOrNull(req.getParameter("district"));
        String ward = trimOrNull(req.getParameter("ward"));
        String houseNumberStreet = trimOrNull(req.getParameter("houseNumberStreet"));
        String note = trimOrNull(req.getParameter("note"));
        String latitudeRaw = trimOrNull(req.getParameter("latitude"));
        String longitudeRaw = trimOrNull(req.getParameter("longitude"));
        String paymentMethod = trimOrNull(req.getParameter("paymentMethod"));

        if (recipientName == null || recipientName.length() < 2 || recipientName.length() > 100) {
            errors.put("recipientName", "Họ và tên người nhận phải từ 2 đến 100 ký tự.");
        }
        if (recipientPhone == null || !recipientPhone.matches(PHONE_REGEX)) {
            errors.put("recipientPhone", "Số điện thoại không hợp lệ.");
        }
        if (provinceCity == null) {
            errors.put("provinceCity", "Vui lòng nhập Tỉnh/Thành phố.");
        } else if (provinceCity.length() > 100) {
            errors.put("provinceCity", "Tỉnh/Thành phố tối đa 100 ký tự.");
        }
        if (district == null) {
            errors.put("district", "Vui lòng nhập Quận/Huyện.");
        } else if (district.length() > 100) {
            errors.put("district", "Quận/Huyện tối đa 100 ký tự.");
        }
        if (ward == null) {
            errors.put("ward", "Vui lòng nhập Phường/Xã.");
        } else if (ward.length() > 100) {
            errors.put("ward", "Phường/Xã tối đa 100 ký tự.");
        }
        if (houseNumberStreet == null) {
            errors.put("houseNumberStreet", "Vui lòng nhập số nhà/tên đường.");
        } else if (houseNumberStreet.length() > 300) {
            errors.put("houseNumberStreet", "Số nhà/Tên đường tối đa 300 ký tự.");
        }
        if (note != null && note.length() > 500) {
            errors.put("note", "Ghi chú tối đa 500 ký tự.");
        }

        BigDecimal latitude = null;
        if (latitudeRaw != null) {
            try {
                latitude = new BigDecimal(latitudeRaw);
                if (latitude.compareTo(BigDecimal.valueOf(-90)) < 0 || latitude.compareTo(BigDecimal.valueOf(90)) > 0) {
                    errors.put("latitude", "Vĩ độ không hợp lệ.");
                }
            } catch (NumberFormatException e) {
                errors.put("latitude", "Vĩ độ không hợp lệ.");
            }
        }
        BigDecimal longitude = null;
        if (longitudeRaw != null) {
            try {
                longitude = new BigDecimal(longitudeRaw);
                if (longitude.compareTo(BigDecimal.valueOf(-180)) < 0 || longitude.compareTo(BigDecimal.valueOf(180)) > 0) {
                    errors.put("longitude", "Kinh độ không hợp lệ.");
                }
            } catch (NumberFormatException e) {
                errors.put("longitude", "Kinh độ không hợp lệ.");
            }
        }
        if (errors.containsKey("latitude")) latitude = null;
        if (errors.containsKey("longitude")) longitude = null;

        boolean isPayOS = "PAYOS".equals(paymentMethod);
        if (!"COD".equals(paymentMethod) && !isPayOS) {
            errors.put("paymentMethod", "Phương thức thanh toán không hợp lệ.");
        } else if (isPayOS && !PayOSPaymentService.isConfigured()) {
            errors.put("paymentMethod", "PayOS chưa được cấu hình, vui lòng dùng COD.");
        }

        if (!errors.isEmpty()) {
            forwardCheckoutPageWithErrors(req, resp, session, items, errors,
                    recipientName, recipientPhone, addressLabel, provinceCity, district, ward,
                    houseNumberStreet, note, latitudeRaw, longitudeRaw);
            return;
        }

        // ---- Tính tiền lại hoàn toàn từ DB bằng BigDecimal — không tin số nào từ client ----
        BigDecimal totalAmount = sumTotal(items);
        BigDecimal shippingFee = BigDecimal.ZERO; // chưa có rule phí ship
        BigDecimal discount = BigDecimal.ZERO;    // chưa có coupon ở luồng COD prompt này
        BigDecimal finalAmount = totalAmount.add(shippingFee).subtract(discount);
        if (finalAmount.signum() < 0) finalAmount = BigDecimal.ZERO;

        String shippingAddress = String.join(", ", houseNumberStreet, ward, district, provinceCity);

        Order order = new Order();
        order.setUserId(userId);
        order.setCustomerName(recipientName);
        order.setPhoneNumber(recipientPhone);
        order.setShippingAddress(shippingAddress);
        order.setOrderNote(note);
        order.setTotalAmount(totalAmount);
        order.setShippingFee(shippingFee);
        order.setFinalAmount(finalAmount);
        order.setPaymentMethod(paymentMethod);
        order.setRecipientName(recipientName);
        order.setRecipientPhone(recipientPhone);
        order.setShippingLatitude(latitude);
        order.setShippingLongitude(longitude);

        if (isPayOS) {
            handlePlaceOrderPayOS(req, resp, session, userId, order, items,
                    recipientName, recipientPhone, addressLabel, provinceCity, district, ward,
                    houseNumberStreet, note, latitudeRaw, longitudeRaw);
            return;
        }

        int orderId;
        try {
            // Transaction thật (Order + OrderDetails + xóa đúng CartItems đã chọn) — xem OrderDaoImpl.placeOrder.
            orderId = orderDao.placeOrder(order, items);
        } catch (Exception e) {
            // Rollback đã xảy ra bên trong placeOrder(); giỏ hàng không mất, không có đơn dở dang.
            // Cấp lại token để user có thể thử lại mà không cần quay lại /cart chọn lại sản phẩm.
            session.setAttribute("checkoutToken", CsrfFilter.generateToken());
            System.err.println("[CheckoutController] placeOrder thất bại: " + e.getMessage());
            forwardCheckoutPageWithErrors(req, resp, session, items,
                    Map.of("_general", "Không thể tạo đơn hàng lúc này. Vui lòng thử lại sau."),
                    recipientName, recipientPhone, addressLabel, provinceCity, district, ward,
                    houseNumberStreet, note, latitudeRaw, longitudeRaw);
            return;
        }

        // ---- Thành công: dọn session, cập nhật badge, PRG sang trang success ----
        session.removeAttribute("checkoutSelection");
        session.setAttribute("lastOrderId", orderId);
        int cartCount = cartItemDao.countQuantityByUserId(userId);
        session.setAttribute("cartCount", cartCount);

        resp.sendRedirect(req.getContextPath() + "/checkout/success?orderId=" + orderId);
    }

    // =========================================================================================
    // POST /checkout/place-order — nhánh PayOS: tạo Order (PaymentStatus=PENDING, KHÔNG xóa
    // CartItems) rồi gọi PayOS tạo payment link và redirect user sang checkoutUrl. PAID chỉ
    // được xác nhận qua webhook đã verify chữ ký (xem PaymentController).
    // =========================================================================================

    private void handlePlaceOrderPayOS(HttpServletRequest req, HttpServletResponse resp, HttpSession session,
            int userId, Order order, List<CartItem> items,
            String recipientName, String recipientPhone, String addressLabel, String provinceCity,
            String district, String ward, String houseNumberStreet, String note,
            String latitudeRaw, String longitudeRaw) throws ServletException, IOException {

        int orderId;
        try {
            orderId = orderDao.placeOrderPayOS(order, items);
        } catch (Exception e) {
            session.setAttribute("checkoutToken", CsrfFilter.generateToken());
            System.err.println("[CheckoutController] placeOrderPayOS thất bại: " + e.getMessage());
            forwardCheckoutPageWithErrors(req, resp, session, items,
                    Map.of("_general", "Không thể tạo đơn hàng lúc này. Vui lòng thử lại sau."),
                    recipientName, recipientPhone, addressLabel, provinceCity, district, ward,
                    houseNumberStreet, note, latitudeRaw, longitudeRaw);
            return;
        }

        String returnUrl = com.nhietdoixanh.config.PayOSConfig.getReturnUrl();
        if (returnUrl == null) returnUrl = buildAbsoluteUrl(req, "/payment/payos/return");
        String cancelUrl = com.nhietdoixanh.config.PayOSConfig.getCancelUrl();
        if (cancelUrl == null) cancelUrl = buildAbsoluteUrl(req, "/payment/payos/cancel");

        PayOSPaymentService.CreatePaymentLinkRequest linkReq = new PayOSPaymentService.CreatePaymentLinkRequest(
                order.getPayOSOrderCode(),
                order.getFinalAmount().setScale(0, java.math.RoundingMode.HALF_UP).longValueExact(),
                "Thanh toan DH" + orderId,
                returnUrl, cancelUrl, recipientName, recipientPhone);

        try {
            PayOSPaymentService.CreatePaymentLinkResult result = PayOSPaymentService.createPaymentLink(linkReq);
            orderDao.attachPayOSPaymentLink(orderId, result.paymentLinkId, result.checkoutUrl);

            // ---- Thành công: dọn selection (đơn đã tạo), CartItems vẫn còn cho tới khi PAID ----
            session.removeAttribute("checkoutSelection");
            session.setAttribute("lastOrderId", orderId);
            int cartCount = cartItemDao.countQuantityByUserId(userId);
            session.setAttribute("cartCount", cartCount);

            resp.sendRedirect(result.checkoutUrl);
        } catch (PayOSPaymentService.PayOSApiException e) {
            try {
                orderDao.markPayOSLinkFailed(orderId);
            } catch (Exception ex) {
                System.err.println("[CheckoutController] markPayOSLinkFailed thất bại: " + ex.getMessage());
            }
            System.err.println("[CheckoutController] Tạo payment link PayOS thất bại (OrderID=" + orderId + "): " + e.getMessage());
            session.setAttribute("checkoutToken", CsrfFilter.generateToken());
            forwardCheckoutPageWithErrors(req, resp, session, items,
                    Map.of("_general", "Không thể tạo yêu cầu thanh toán PayOS lúc này. Vui lòng thử lại hoặc chọn Tiền mặt khi nhận hàng (COD)."),
                    recipientName, recipientPhone, addressLabel, provinceCity, district, ward,
                    houseNumberStreet, note, latitudeRaw, longitudeRaw);
        } catch (Exception e) {
            System.err.println("[CheckoutController] Lưu payment link PayOS thất bại (OrderID=" + orderId + "): " + e.getMessage());
            session.setAttribute("checkoutToken", CsrfFilter.generateToken());
            forwardCheckoutPageWithErrors(req, resp, session, items,
                    Map.of("_general", "Không thể lưu thông tin thanh toán lúc này. Vui lòng thử lại hoặc chọn Tiền mặt khi nhận hàng (COD)."),
                    recipientName, recipientPhone, addressLabel, provinceCity, district, ward,
                    houseNumberStreet, note, latitudeRaw, longitudeRaw);
        }
    }

    private String buildAbsoluteUrl(HttpServletRequest req, String path) {
        String scheme = req.getScheme();
        int port = req.getServerPort();
        StringBuilder sb = new StringBuilder(scheme).append("://").append(req.getServerName());
        boolean isDefaultPort = ("http".equals(scheme) && port == 80) || ("https".equals(scheme) && port == 443);
        if (!isDefaultPort) sb.append(':').append(port);
        sb.append(req.getContextPath()).append(path);
        return sb.toString();
    }

    private void forwardCheckoutPageWithErrors(HttpServletRequest req, HttpServletResponse resp, HttpSession session,
            List<CartItem> items, Map<String, String> errors,
            String recipientName, String recipientPhone, String addressLabel, String provinceCity,
            String district, String ward, String houseNumberStreet, String note,
            String latitudeRaw, String longitudeRaw) throws ServletException, IOException {

        // Token cũ đã bị tiêu thụ ở đầu request — cấp token mới để form vẫn submit được.
        String newToken = CsrfFilter.generateToken();
        session.setAttribute("checkoutToken", newToken);

        req.setAttribute("checkoutItems", items);
        req.setAttribute("subtotal", sumTotal(items));
        req.setAttribute("checkoutToken", newToken);
        req.setAttribute("payosConfigured", PayOSPaymentService.isConfigured());
        req.setAttribute("oldPaymentMethod", trimOrNull(req.getParameter("paymentMethod")));
        req.setAttribute("formErrors", errors);
        req.setAttribute("oldRecipientName", recipientName);
        req.setAttribute("oldRecipientPhone", recipientPhone);
        req.setAttribute("oldAddressLabel", addressLabel);
        req.setAttribute("oldProvinceCity", provinceCity);
        req.setAttribute("oldDistrict", district);
        req.setAttribute("oldWard", ward);
        req.setAttribute("oldHouseNumberStreet", houseNumberStreet);
        req.setAttribute("oldNote", note);
        req.setAttribute("oldLatitude", latitudeRaw);
        req.setAttribute("oldLongitude", longitudeRaw);
        req.setAttribute("currentPage", "cart");
        req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
    }

    // =========================================================================================
    // GET /checkout/success?orderId=...
    // =========================================================================================

    private void handleSuccessPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        int userId = user.getUserId();

        Integer orderId = parsePositiveInt(req.getParameter("orderId"));
        if (orderId == null) {
            resp.sendRedirect(req.getContextPath() + "/san-pham");
            return;
        }

        // Ownership kiểm tra ngay trong SQL (WHERE OrderID = ? AND UserID = ?) — không cho xem đơn người khác.
        Order order = orderDao.findByIdAndUserId(orderId, userId).orElse(null);
        if (order == null) {
            resp.sendRedirect(req.getContextPath() + "/san-pham");
            return;
        }

        List<OrderDetail> orderItems = orderDao.findDetailsByOrderIdAndUserId(orderId, userId);

        req.setAttribute("order", order);
        req.setAttribute("orderItems", orderItems);
        req.setAttribute("orderStatusLabel", com.nhietdoixanh.util.OrderStatuses.getLabel(order.getOrderStatus()));
        req.setAttribute("paymentStatusLabel", com.nhietdoixanh.util.PaymentStatuses.getLabel(order.getPaymentStatus()));
        req.getRequestDispatcher("/WEB-INF/views/checkout-success.jsp").forward(req, resp);
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    /** Trả về message lỗi tiếng Việt cho item đầu tiên không hợp lệ, hoặc null nếu tất cả hợp lệ. */
    private String findFirstInvalidItemMessage(List<CartItem> items) {
        for (CartItem item : items) {
            if (!item.isVariantActive()) {
                return "Sản phẩm \"" + item.getProductName() + "\" hiện không còn kinh doanh. Vui lòng bỏ chọn để tiếp tục.";
            }
            if (item.getQuantity() < 1 || item.getQuantity() > 99) {
                return "Số lượng sản phẩm \"" + item.getProductName() + "\" không hợp lệ. Vui lòng cập nhật lại giỏ hàng.";
            }
            if (item.getPrice() == null || item.getPrice().signum() <= 0) {
                return "Giá sản phẩm \"" + item.getProductName() + "\" không hợp lệ. Vui lòng thử lại sau.";
            }
        }
        return null;
    }

    private BigDecimal sumTotal(List<CartItem> items) {
        return items.stream().map(CartItem::getTotalPrice).reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private void redirectToCartWithError(HttpSession session, HttpServletRequest req, HttpServletResponse resp,
            String message) throws IOException {
        if (session != null) session.setAttribute("cartFlashError", message);
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private String trimOrNull(String raw) {
        if (raw == null) return null;
        String trimmed = raw.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private Integer parsePositiveInt(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            int v = Integer.parseInt(raw.trim());
            return v > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void writeError(HttpServletResponse resp, int status, String message) throws IOException {
        JsonObject json = new JsonObject();
        json.addProperty("success", false);
        json.addProperty("message", message);
        writeJson(resp, status, json);
    }

    private void writeJson(HttpServletResponse resp, int status, JsonObject json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(GSON.toJson(json));
    }
}
