package com.nhietdoixanh.controller.admin;

import com.nhietdoixanh.dao.CategoryDao;
import com.nhietdoixanh.dao.ProductDao;
import com.nhietdoixanh.dao.ProductVariantDao;
import com.nhietdoixanh.dao.impl.CategoryDaoImpl;
import com.nhietdoixanh.dao.impl.ProductDaoImpl;
import com.nhietdoixanh.dao.impl.ProductVariantDaoImpl;
import com.nhietdoixanh.model.Product;
import com.nhietdoixanh.model.ProductVariant;
import com.nhietdoixanh.model.Staff;
import com.nhietdoixanh.util.AuditLogger;
import com.nhietdoixanh.util.ProductImageUpload;
import com.nhietdoixanh.util.Validators;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * Admin quản lý sản phẩm — danh sách/tìm kiếm, thêm/sửa (kèm biến thể size M/L), ẩn/hiện.
 *
 * Quyền hạn: nằm dưới urlPattern "/admin/*" nên đã được {@link com.nhietdoixanh.filter.AuthFilter}
 * chặn — chỉ Staff đã đăng nhập (session "adminUser") mới tới được. Mọi POST đã được
 * {@link com.nhietdoixanh.filter.CsrfFilter} kiểm tra token "_csrf" trước khi vào servlet này.
 *
 * Biến thể (size/giá) không có servlet riêng — được sửa trực tiếp trong form sản phẩm dưới dạng
 * các hàng lặp (variantId[]/variantSize[]/variantPrice[]/variantRemove[]). Xóa biến thể luôn là
 * ẩn (IsActive=0), không xóa cứng, vì OrderDetails tham chiếu VariantID của các đơn cũ.
 */
@WebServlet(name = "AdminProductController", urlPatterns = {
        "/admin/san-pham",
        "/admin/san-pham/them",
        "/admin/san-pham/sua",
        "/admin/san-pham/an-hien"
})
@MultipartConfig(
        maxFileSize = 3 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024,
        fileSizeThreshold = 1024 * 1024
)
public class AdminProductController extends HttpServlet {

    private static final Set<String> VALID_SIZES = Set.of("M", "L");

    private ProductDao productDao;
    private ProductVariantDao variantDao;
    private CategoryDao categoryDao;

    @Override
    public void init() {
        productDao = new ProductDaoImpl();
        variantDao = new ProductVariantDaoImpl();
        categoryDao = new CategoryDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/admin/san-pham" -> handleList(req, resp);
            case "/admin/san-pham/them" -> handleNewForm(req, resp);
            case "/admin/san-pham/sua" -> handleEditForm(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        switch (path) {
            case "/admin/san-pham/them", "/admin/san-pham/sua" -> handleSave(req, resp);
            case "/admin/san-pham/an-hien" -> handleToggleActive(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================================================
    // GET /admin/san-pham — danh sách + tìm kiếm/lọc (danh mục sản phẩm thường nhỏ, lọc in-memory)
    // =========================================================================================

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String keyword = trimOrNull(req.getParameter("q"));
        Integer categoryId = parsePositiveInt(req.getParameter("categoryId"));
        String status = trimOrNull(req.getParameter("status")); // active | inactive | null=tất cả

        List<Product> all = productDao.findAllForAdmin();
        List<Product> filtered = new ArrayList<>();
        for (Product p : all) {
            if (keyword != null && !containsIgnoreCase(p.getName(), keyword)) continue;
            if (categoryId != null && p.getCategoryId() != categoryId) continue;
            if ("active".equals(status) && !p.isActive()) continue;
            if ("inactive".equals(status) && p.isActive()) continue;
            filtered.add(p);
        }

        req.setAttribute("products", filtered);
        req.setAttribute("totalProducts", filtered.size());
        req.setAttribute("categories", categoryDao.findAll());
        req.setAttribute("q", keyword);
        req.setAttribute("categoryId", categoryId);
        req.setAttribute("status", status);
        req.setAttribute("pageTitle", "Sản phẩm");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/admin/products/list.jsp").forward(req, resp);
    }

    // =========================================================================================
    // GET /admin/san-pham/them — form thêm mới
    // =========================================================================================

    private void handleNewForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("categories", categoryDao.findAll());
        req.setAttribute("pageTitle", "Thêm sản phẩm");
        req.getRequestDispatcher("/WEB-INF/views/admin/products/form.jsp").forward(req, resp);
    }

    // =========================================================================================
    // GET /admin/san-pham/sua?id=... — form sửa
    // =========================================================================================

    private void handleEditForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Integer id = parsePositiveInt(req.getParameter("id"));
        Optional<Product> pOpt = id != null ? productDao.findById(id) : Optional.empty();
        if (pOpt.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/san-pham");
            return;
        }

        req.setAttribute("product", pOpt.get());
        req.setAttribute("categories", categoryDao.findAll());
        req.setAttribute("pageTitle", "Sửa sản phẩm");
        req.getRequestDispatcher("/WEB-INF/views/admin/products/form.jsp").forward(req, resp);
    }

    // =========================================================================================
    // POST /admin/san-pham/them | /admin/san-pham/sua — lưu sản phẩm + biến thể
    // =========================================================================================

    private void handleSave(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        Staff admin = currentAdmin(req);
        boolean isEdit = "/admin/san-pham/sua".equals(req.getServletPath());
        Integer productId = parsePositiveInt(req.getParameter("productId"));

        if (isEdit && productId == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/san-pham");
            return;
        }

        String name = trimOrNull(req.getParameter("name"));
        Integer categoryId = parsePositiveInt(req.getParameter("categoryId"));
        String description = req.getParameter("description");
        String returnTo = isEdit
                ? req.getContextPath() + "/admin/san-pham/sua?id=" + productId
                : req.getContextPath() + "/admin/san-pham/them";

        if (Validators.isBlank(name) || categoryId == null) {
            flashError(req, "Vui lòng nhập tên và chọn danh mục sản phẩm.");
            resp.sendRedirect(returnTo);
            return;
        }

        if (productDao.existsByName(name, isEdit ? productId : null)) {
            flashError(req, "Tên sản phẩm \"" + name + "\" đã tồn tại.");
            resp.sendRedirect(returnTo);
            return;
        }

        List<VariantRow> variantRows;
        try {
            variantRows = parseVariantRows(req);
        } catch (IllegalArgumentException e) {
            flashError(req, e.getMessage());
            resp.sendRedirect(returnTo);
            return;
        }
        if (variantRows.stream().noneMatch(r -> !r.remove)) {
            flashError(req, "Sản phẩm cần ít nhất một biến thể (size + giá) đang hoạt động.");
            resp.sendRedirect(returnTo);
            return;
        }

        String imageUrl;
        try {
            imageUrl = ProductImageUpload.store(req.getPart("imageFile"), getServletContext());
        } catch (IllegalArgumentException e) {
            flashError(req, e.getMessage());
            resp.sendRedirect(returnTo);
            return;
        }

        if (!isEdit && imageUrl == null) {
            flashError(req, "Vui lòng chọn ảnh sản phẩm.");
            resp.sendRedirect(returnTo);
            return;
        }

        Product p = new Product();
        p.setName(name);
        p.setCategoryId(categoryId);
        p.setDescription(description);
        p.setActive(true);

        String oldImageUrl = null;
        if (isEdit) {
            p.setProductId(productId);
            Optional<Product> existing = productDao.findById(productId);
            if (existing.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/san-pham");
                return;
            }
            oldImageUrl = existing.get().getImageUrl();
            p.setActive(existing.get().isActive());
            p.setImageUrl(imageUrl != null ? imageUrl : oldImageUrl);
            productDao.update(p);
            saveVariants(productId, variantRows);
            if (imageUrl != null && oldImageUrl != null) {
                ProductImageUpload.deleteQuietly(oldImageUrl, getServletContext());
            }
            AuditLogger.log(req, admin.getStaffId(), "UPDATE_PRODUCT", "Product#" + productId,
                    "Cập nhật sản phẩm \"" + name + "\"");
            flashSuccess(req, "Đã cập nhật sản phẩm \"" + name + "\".");
        } else {
            p.setImageUrl(imageUrl);
            int newId = productDao.insert(p);
            saveVariants(newId, variantRows);
            AuditLogger.log(req, admin.getStaffId(), "CREATE_PRODUCT", "Product#" + newId,
                    "Thêm sản phẩm mới \"" + name + "\"");
            flashSuccess(req, "Đã thêm sản phẩm \"" + name + "\".");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/san-pham");
    }

    // =========================================================================================
    // POST /admin/san-pham/an-hien — ẩn/hiện sản phẩm (soft delete = IsActive)
    // =========================================================================================

    private void handleToggleActive(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Staff admin = currentAdmin(req);
        Integer id = parsePositiveInt(req.getParameter("id"));
        boolean currentlyActive = Boolean.parseBoolean(req.getParameter("active"));

        if (id == null) {
            flashError(req, "Yêu cầu không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/admin/san-pham");
            return;
        }

        boolean newActive = !currentlyActive;
        if (productDao.setActive(id, newActive)) {
            AuditLogger.log(req, admin.getStaffId(), newActive ? "SHOW_PRODUCT" : "HIDE_PRODUCT",
                    "Product#" + id, (newActive ? "Hiện lại" : "Ẩn") + " sản phẩm #" + id);
            flashSuccess(req, newActive ? "Đã hiện lại sản phẩm." : "Đã ẩn sản phẩm.");
        } else {
            flashError(req, "Không thể cập nhật — sản phẩm không tồn tại.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/san-pham");
    }

    // =========================================================================================
    // Biến thể (size/giá)
    // =========================================================================================

    private record VariantRow(int variantId, String size, BigDecimal price, boolean remove) {}

    /** Đọc các hàng biến thể lặp từ form; ném lỗi rõ ràng nếu size/giá không hợp lệ. */
    private List<VariantRow> parseVariantRows(HttpServletRequest req) {
        String[] ids = req.getParameterValues("variantId");
        String[] sizes = req.getParameterValues("variantSize");
        String[] prices = req.getParameterValues("variantPrice");
        String[] removes = req.getParameterValues("variantRemove"); // "row-index" của các hàng bị đánh dấu xóa

        List<VariantRow> rows = new ArrayList<>();
        if (sizes == null) return rows;

        Set<String> removedIndexes = removes != null ? Set.of(removes) : Set.of();

        for (int i = 0; i < sizes.length; i++) {
            boolean removed = removedIndexes.contains(String.valueOf(i));
            int variantId = (ids != null && i < ids.length) ? parseIntOrZero(ids[i]) : 0;

            if (removed) {
                rows.add(new VariantRow(variantId, null, null, true));
                continue;
            }

            String size = sizes[i] == null ? "" : sizes[i].trim().toUpperCase();
            if (!VALID_SIZES.contains(size)) {
                throw new IllegalArgumentException("Size biến thể không hợp lệ (chỉ nhận M hoặc L).");
            }

            String priceRaw = (prices != null && i < prices.length) ? prices[i] : null;
            BigDecimal price;
            try {
                price = new BigDecimal(priceRaw.trim().replace(",", ""));
                if (price.signum() <= 0) throw new NumberFormatException();
            } catch (Exception e) {
                throw new IllegalArgumentException("Giá biến thể phải là số dương.");
            }

            rows.add(new VariantRow(variantId, size, price, false));
        }
        return rows;
    }

    private void saveVariants(int productId, List<VariantRow> rows) {
        for (VariantRow row : rows) {
            if (row.remove) {
                if (row.variantId > 0) variantDao.setActive(row.variantId, false);
                continue;
            }
            if (row.variantId > 0) {
                ProductVariant v = new ProductVariant();
                v.setVariantId(row.variantId);
                v.setSize(row.size);
                v.setPrice(row.price);
                variantDao.update(v);
            } else {
                ProductVariant v = new ProductVariant();
                v.setProductId(productId);
                v.setSize(row.size);
                v.setPrice(row.price);
                v.setActive(true);
                variantDao.insert(v);
            }
        }
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    /** Luôn lấy admin thao tác từ session — KHÔNG BAO GIỜ nhận staffId từ client. */
    private Staff currentAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (Staff) session.getAttribute("adminUser") : null;
    }

    private boolean containsIgnoreCase(String haystack, String needle) {
        return haystack != null && haystack.toLowerCase().contains(needle.toLowerCase());
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

    private int parseIntOrZero(String raw) {
        try {
            return Integer.parseInt(raw.trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private void flashSuccess(HttpServletRequest req, String message) {
        HttpSession session = req.getSession(false);
        if (session != null) session.setAttribute("adminFlashSuccess", message);
    }

    private void flashError(HttpServletRequest req, String message) {
        HttpSession session = req.getSession(false);
        if (session != null) session.setAttribute("adminFlashError", message);
    }

    private void consumeFlash(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return;
        Object success = session.getAttribute("adminFlashSuccess");
        Object error = session.getAttribute("adminFlashError");
        if (success != null) {
            req.setAttribute("flashSuccess", success);
            session.removeAttribute("adminFlashSuccess");
        }
        if (error != null) {
            req.setAttribute("flashError", error);
            session.removeAttribute("adminFlashError");
        }
    }
}
