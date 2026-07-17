package com.nhietdoixanh.controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.nhietdoixanh.dao.CartItemDao;
import com.nhietdoixanh.dao.ProductDao;
import com.nhietdoixanh.dao.ProductVariantDao;
import com.nhietdoixanh.dao.impl.CartItemDaoImpl;
import com.nhietdoixanh.dao.impl.ProductDaoImpl;
import com.nhietdoixanh.dao.impl.ProductVariantDaoImpl;
import com.nhietdoixanh.model.CartItem;
import com.nhietdoixanh.model.CartLineItemDto;
import com.nhietdoixanh.model.Product;
import com.nhietdoixanh.model.ProductVariant;
import com.nhietdoixanh.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * Giỏ hàng:
 * - GET  /cart                  — trang xem giỏ hàng đầy đủ (checkbox, sửa số lượng, xóa).
 * - POST /cart/add               — thêm sản phẩm vào giỏ.
 * - POST /cart/update            — cập nhật số lượng 1 dòng.
 * - POST /cart/remove            — xóa 1 dòng.
 * - POST /cart/remove-selected   — xóa nhiều dòng đã chọn.
 * - GET  /cart/count             — đếm tổng số lượng cho badge navbar.
 *
 * Badge navbar tính theo TỔNG SỐ LƯỢNG (SUM Quantity), không phải số dòng —
 * xem CartItemDao.countItemsByUserId/countQuantityByUserId.
 *
 * /cart, /cart/add, /cart/update, /cart/remove, /cart/remove-selected nằm dưới
 * AuthFilter (urlPatterns "/cart", "/cart/*") nên chỉ user đã đăng nhập tới được;
 * /cart/count được AuthFilter cho qua không cần đăng nhập (trả cartCount=0).
 */
@WebServlet(name = "CartController", urlPatterns = {
        "/cart", "/cart/add", "/cart/update", "/cart/remove", "/cart/remove-selected", "/cart/count"
})
public class CartController extends HttpServlet {

    private static final Gson GSON = new Gson();
    private static final int MAX_QUANTITY = 99;

    private CartItemDao cartItemDao;
    private ProductVariantDao productVariantDao;
    private ProductDao productDao;

    @Override
    public void init() {
        cartItemDao = new CartItemDaoImpl();
        productVariantDao = new ProductVariantDaoImpl();
        productDao = new ProductDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/cart/count".equals(path)) {
            handleCount(req, resp);
        } else if ("/cart".equals(path)) {
            handleViewCart(req, resp);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();

        // Mọi thao tác ghi dữ liệu đều cần user đăng nhập — không nhận userId từ client,
        // luôn đọc từ session do AuthFilter/AuthController thiết lập.
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            writeError(resp, HttpServletResponse.SC_UNAUTHORIZED, "Vui lòng đăng nhập để tiếp tục.");
            return;
        }
        int userId = user.getUserId();

        switch (path) {
            case "/cart/add" -> handleAdd(req, resp, session, userId);
            case "/cart/update" -> handleUpdate(req, resp, session, userId);
            case "/cart/remove" -> handleRemove(req, resp, session, userId);
            case "/cart/remove-selected" -> handleRemoveSelected(req, resp, session, userId);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // ===== GET /cart/count =====

    private void handleCount(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        int cartCount = (user != null) ? cartItemDao.countQuantityByUserId(user.getUserId()) : 0;

        JsonObject json = new JsonObject();
        json.addProperty("success", true);
        json.addProperty("cartCount", cartCount);
        writeJson(resp, HttpServletResponse.SC_OK, json);
    }

    // ===== GET /cart =====

    private void handleViewCart(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<CartLineItemDto> cartItems = cartItemDao.findLineItemsByUserId(user.getUserId());
        req.setAttribute("cartItems", cartItems);
        req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
    }

    // ===== POST /cart/add =====

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, HttpSession session, int userId)
            throws IOException {
        Integer variantId = parsePositiveInt(req.getParameter("variantId"));
        if (variantId == null) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Sản phẩm không hợp lệ.");
            return;
        }

        Integer quantity = parsePositiveInt(req.getParameter("quantity"));
        if (quantity == null || quantity < 1 || quantity > MAX_QUANTITY) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Số lượng phải từ 1 đến 99.");
            return;
        }

        // Đọc lại variant thật từ DB — không tin bất kỳ giá/trạng thái nào từ client.
        Optional<ProductVariant> variantOpt = productVariantDao.findById(variantId);
        if (variantOpt.isEmpty()) {
            writeError(resp, HttpServletResponse.SC_NOT_FOUND, "Sản phẩm không tồn tại.");
            return;
        }
        ProductVariant variant = variantOpt.get();
        if (!variant.isActive()) {
            writeError(resp, HttpServletResponse.SC_CONFLICT, "Sản phẩm này hiện không còn kinh doanh.");
            return;
        }

        cartItemDao.addOrIncrease(userId, variantId, quantity);
        int cartCount = cartItemDao.countQuantityByUserId(userId);
        session.setAttribute("cartCount", cartCount);

        JsonObject json = new JsonObject();
        json.addProperty("success", true);
        json.addProperty("message", "Đã thêm vào giỏ hàng.");
        json.addProperty("cartCount", cartCount);
        writeJson(resp, HttpServletResponse.SC_OK, json);
    }

    // ===== POST /cart/update =====

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, HttpSession session, int userId)
            throws IOException {
        Integer cartItemId = parsePositiveInt(req.getParameter("cartItemId"));
        if (cartItemId == null) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Sản phẩm trong giỏ không hợp lệ.");
            return;
        }

        Integer quantity = parsePositiveInt(req.getParameter("quantity"));
        if (quantity == null || quantity < 1 || quantity > MAX_QUANTITY) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Số lượng phải từ 1 đến 99.");
            return;
        }

        Optional<CartItem> itemOpt = cartItemDao.findByIdAndUserId(cartItemId, userId);
        if (itemOpt.isEmpty()) {
            writeError(resp, HttpServletResponse.SC_NOT_FOUND, "Sản phẩm không tồn tại trong giỏ hàng của bạn.");
            return;
        }
        CartItem item = itemOpt.get();

        Optional<ProductVariant> variantOpt = productVariantDao.findById(item.getVariantId());
        if (variantOpt.isEmpty() || !variantOpt.get().isActive()) {
            writeError(resp, HttpServletResponse.SC_CONFLICT, "Sản phẩm này hiện không còn kinh doanh.");
            return;
        }
        Optional<Product> productOpt = productDao.findById(variantOpt.get().getProductId());
        if (productOpt.isEmpty() || !productOpt.get().isActive()) {
            writeError(resp, HttpServletResponse.SC_CONFLICT, "Sản phẩm này hiện không còn kinh doanh.");
            return;
        }

        boolean updated = cartItemDao.updateQuantityChecked(cartItemId, userId, quantity);
        if (!updated) {
            writeError(resp, HttpServletResponse.SC_NOT_FOUND, "Sản phẩm không tồn tại trong giỏ hàng của bạn.");
            return;
        }

        java.math.BigDecimal itemSubtotal = variantOpt.get().getPrice().multiply(java.math.BigDecimal.valueOf(quantity));
        int cartCount = cartItemDao.countQuantityByUserId(userId);
        session.setAttribute("cartCount", cartCount);

        JsonObject json = new JsonObject();
        json.addProperty("success", true);
        json.addProperty("message", "Đã cập nhật số lượng.");
        json.addProperty("cartCount", cartCount);
        json.addProperty("itemSubtotal", itemSubtotal);
        writeJson(resp, HttpServletResponse.SC_OK, json);
    }

    // ===== POST /cart/remove =====

    private void handleRemove(HttpServletRequest req, HttpServletResponse resp, HttpSession session, int userId)
            throws IOException {
        Integer cartItemId = parsePositiveInt(req.getParameter("cartItemId"));
        if (cartItemId == null) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Sản phẩm trong giỏ không hợp lệ.");
            return;
        }

        boolean deleted = cartItemDao.deleteByIdAndUserId(cartItemId, userId);
        if (!deleted) {
            writeError(resp, HttpServletResponse.SC_NOT_FOUND, "Sản phẩm không tồn tại trong giỏ hàng của bạn.");
            return;
        }

        int cartCount = cartItemDao.countQuantityByUserId(userId);
        session.setAttribute("cartCount", cartCount);

        JsonObject json = new JsonObject();
        json.addProperty("success", true);
        json.addProperty("message", "Đã xóa sản phẩm khỏi giỏ hàng.");
        json.addProperty("cartCount", cartCount);
        writeJson(resp, HttpServletResponse.SC_OK, json);
    }

    // ===== POST /cart/remove-selected =====

    private void handleRemoveSelected(HttpServletRequest req, HttpServletResponse resp, HttpSession session, int userId)
            throws IOException {
        List<Integer> cartItemIds = parseIdList(req.getParameterValues("cartItemIds"));
        if (cartItemIds.isEmpty()) {
            writeError(resp, HttpServletResponse.SC_BAD_REQUEST, "Vui lòng chọn ít nhất một sản phẩm để xóa.");
            return;
        }

        // deleteSelectedByUserIdCounted tự lọc theo UserID trong SQL — ID không thuộc user
        // sẽ không bị ảnh hưởng, chỉ đơn giản không nằm trong số dòng bị xóa.
        int deletedCount = cartItemDao.deleteSelectedByUserIdCounted(cartItemIds, userId);

        int cartCount = cartItemDao.countQuantityByUserId(userId);
        session.setAttribute("cartCount", cartCount);

        JsonObject json = new JsonObject();
        json.addProperty("success", true);
        json.addProperty("message", "Đã xóa " + deletedCount + " sản phẩm khỏi giỏ hàng.");
        json.addProperty("deletedCount", deletedCount);
        json.addProperty("cartCount", cartCount);
        writeJson(resp, HttpServletResponse.SC_OK, json);
    }

    // ===== Helpers =====

    private Integer parsePositiveInt(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            int v = Integer.parseInt(raw.trim());
            return v > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Parse an toàn danh sách ID từ request — bỏ qua giá trị không phải số nguyên dương, loại trùng. */
    static List<Integer> parseIdList(String[] raw) {
        if (raw == null) return new ArrayList<>();
        Set<Integer> ids = new LinkedHashSet<>();
        for (String s : raw) {
            if (s == null) continue;
            for (String part : s.split(",")) {
                if (part == null || part.isBlank()) continue;
                try {
                    int v = Integer.parseInt(part.trim());
                    if (v > 0) ids.add(v);
                } catch (NumberFormatException ignored) {
                    // bỏ qua giá trị rác, không ném lỗi để 1 ID hỏng không chặn toàn bộ request
                }
            }
        }
        return new ArrayList<>(ids);
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
