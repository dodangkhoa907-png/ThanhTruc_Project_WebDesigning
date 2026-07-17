package com.nhietdoixanh.controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.nhietdoixanh.dao.CartItemDao;
import com.nhietdoixanh.dao.impl.CartItemDaoImpl;
import com.nhietdoixanh.model.CartItem;
import com.nhietdoixanh.model.CheckoutSelection;
import com.nhietdoixanh.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * POST /checkout/prepare — xác thực lại các CartItem khách đã chọn trên trang /cart
 * và lưu một {@link CheckoutSelection} vào session để bước /checkout (prompt sau) dùng.
 *
 * KHÔNG tạo Order/OrderDetails, KHÔNG xóa giỏ hàng, KHÔNG nhận tổng tiền từ client —
 * chỉ chuẩn bị + validate selection. Nguồn sự thật về giá/tồn kho luôn là DB, đọc lại
 * tại đây và sẽ được đọc lại LẦN NỮA khi /checkout thật sự tạo đơn ở prompt sau.
 */
@WebServlet(name = "CheckoutController", urlPatterns = {"/checkout/prepare"})
public class CheckoutController extends HttpServlet {

    private static final Gson GSON = new Gson();

    private CartItemDao cartItemDao;

    @Override
    public void init() {
        cartItemDao = new CartItemDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Chuẩn bị checkout là một hành động ghi (tạo session state) — không cho phép GET.
        resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

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

        // Đọc lại từ DB bằng danh sách ID + ownership — không tin bất kỳ dữ liệu nào khác từ client.
        List<CartItem> items = cartItemDao.findSelectedByIdsAndUserId(requestedIds, userId);

        if (items.size() != requestedIds.size()) {
            writeError(resp, HttpServletResponse.SC_CONFLICT,
                    "Một số sản phẩm đã chọn không còn trong giỏ hàng của bạn. Vui lòng tải lại trang.");
            return;
        }

        for (CartItem item : items) {
            if (!item.isVariantActive()) {
                writeError(resp, HttpServletResponse.SC_CONFLICT,
                        "Sản phẩm \"" + item.getProductName() + "\" hiện không còn kinh doanh. Vui lòng bỏ chọn để tiếp tục.");
                return;
            }
            if (item.getQuantity() < 1 || item.getQuantity() > 99) {
                writeError(resp, HttpServletResponse.SC_CONFLICT,
                        "Số lượng sản phẩm \"" + item.getProductName() + "\" không hợp lệ. Vui lòng cập nhật lại giỏ hàng.");
                return;
            }
            if (item.getPrice() == null || item.getPrice().signum() <= 0) {
                writeError(resp, HttpServletResponse.SC_CONFLICT,
                        "Giá sản phẩm \"" + item.getProductName() + "\" không hợp lệ. Vui lòng thử lại sau.");
                return;
            }
        }

        // Preview subtotal — CHỈ để hiển thị, không phải nguồn sự thật cho bước tạo đơn.
        BigDecimal previewSubtotal = items.stream()
                .map(CartItem::getTotalPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

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
