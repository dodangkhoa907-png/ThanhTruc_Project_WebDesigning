package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.UserAddressDao;
import com.nhietdoixanh.dao.impl.UserAddressDaoImpl;
import com.nhietdoixanh.model.User;
import com.nhietdoixanh.model.UserAddress;
import com.nhietdoixanh.util.Validators;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * /account/addresses — sổ địa chỉ giao hàng: thêm/sửa/xóa/đặt mặc định.
 * Mọi thao tác ghi đều kiểm tra AddressID + UserID trong SQL (ownership) — không cho sửa/xóa
 * địa chỉ của user khác (IDOR).
 */
@WebServlet(name = "AccountAddressController", urlPatterns = {
        "/account/addresses",
        "/account/address/create",
        "/account/address/update",
        "/account/address/delete",
        "/account/address/default"
})
public class AccountAddressController extends HttpServlet {

    private UserAddressDao addressDao;

    @Override
    public void init() {
        addressDao = new UserAddressDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if (!"/account/addresses".equals(path)) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }

        int userId = currentUserId(req);
        List<UserAddress> addresses = addressDao.findByUserId(userId);

        req.setAttribute("addresses", addresses);
        req.setAttribute("currentPage", "account");
        req.setAttribute("accountTab", "addresses");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/account/addresses.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        switch (path) {
            case "/account/address/create" -> handleCreate(req, resp);
            case "/account/address/update" -> handleUpdate(req, resp);
            case "/account/address/delete" -> handleDelete(req, resp);
            case "/account/address/default" -> handleSetDefault(req, resp);
            default -> resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }

    // =========================================================================================
    // POST /account/address/create
    // =========================================================================================

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int userId = currentUserId(req);
        UserAddress form = readForm(req, userId);
        Map<String, String> errors = validate(form);

        if (!errors.isEmpty()) {
            forwardWithErrors(req, resp, userId, errors, form);
            return;
        }

        // Địa chỉ đầu tiên của user tự động là mặc định — không cần thao tác thêm.
        boolean isFirstAddress = addressDao.findByUserId(userId).isEmpty();
        boolean requestedDefault = "on".equals(req.getParameter("isDefault"));
        form.setDefault(isFirstAddress);

        int newId = addressDao.create(form);
        if (newId <= 0) {
            flashError(req, "Không thể thêm địa chỉ, vui lòng thử lại.");
        } else {
            if (!isFirstAddress && requestedDefault) {
                addressDao.setDefaultAddress(newId, userId);
            }
            flashSuccess(req, "Đã thêm địa chỉ mới.");
        }
        resp.sendRedirect(req.getContextPath() + "/account/addresses");
    }

    // =========================================================================================
    // POST /account/address/update
    // =========================================================================================

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int userId = currentUserId(req);
        Integer addressId = parsePositiveInt(req.getParameter("addressId"));

        if (addressId == null || addressDao.findByIdAndUserId(addressId, userId).isEmpty()) {
            flashError(req, "Địa chỉ không tồn tại hoặc không thuộc về bạn.");
            resp.sendRedirect(req.getContextPath() + "/account/addresses");
            return;
        }

        UserAddress form = readForm(req, userId);
        form.setAddressId(addressId);
        Map<String, String> errors = validate(form);

        if (!errors.isEmpty()) {
            forwardWithErrors(req, resp, userId, errors, form);
            return;
        }

        boolean updated = addressDao.update(form);
        if (updated) {
            flashSuccess(req, "Đã cập nhật địa chỉ.");
        } else {
            flashError(req, "Không thể cập nhật địa chỉ, vui lòng thử lại.");
        }
        resp.sendRedirect(req.getContextPath() + "/account/addresses");
    }

    // =========================================================================================
    // POST /account/address/delete
    // =========================================================================================

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = currentUserId(req);
        Integer addressId = parsePositiveInt(req.getParameter("addressId"));

        if (addressId != null && addressDao.deleteByIdAndUserId(addressId, userId)) {
            flashSuccess(req, "Đã xóa địa chỉ.");
        } else {
            flashError(req, "Không thể xóa địa chỉ — địa chỉ không tồn tại hoặc không thuộc về bạn.");
        }
        resp.sendRedirect(req.getContextPath() + "/account/addresses");
    }

    // =========================================================================================
    // POST /account/address/default
    // =========================================================================================

    private void handleSetDefault(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int userId = currentUserId(req);
        Integer addressId = parsePositiveInt(req.getParameter("addressId"));

        if (addressId != null && addressDao.setDefaultAddress(addressId, userId)) {
            flashSuccess(req, "Đã đặt làm địa chỉ mặc định.");
        } else {
            flashError(req, "Không thể đặt mặc định — địa chỉ không tồn tại hoặc không thuộc về bạn.");
        }
        resp.sendRedirect(req.getContextPath() + "/account/addresses");
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

    private UserAddress readForm(HttpServletRequest req, int userId) {
        UserAddress a = new UserAddress();
        a.setUserId(userId);
        a.setLabel(trimOrNull(req.getParameter("label")));
        a.setRecipientName(trimOrNull(req.getParameter("recipientName")));
        a.setPhone(trimOrNull(req.getParameter("phone")));
        a.setProvinceCity(trimOrNull(req.getParameter("provinceCity")));
        a.setDistrict(trimOrNull(req.getParameter("district")));
        a.setWard(trimOrNull(req.getParameter("ward")));
        a.setHouseNumberStreet(trimOrNull(req.getParameter("houseNumberStreet")));
        // "Street" giữ bản rút gọn để tương thích trang /checkout đang fallback đọc field này.
        if (a.getHouseNumberStreet() != null) {
            a.setStreet(String.join(", ", nonNull(a.getHouseNumberStreet()), nonNull(a.getWard()),
                    nonNull(a.getDistrict()), nonNull(a.getProvinceCity())));
        }
        a.setLatitude(parseBigDecimal(req.getParameter("latitude")));
        a.setLongitude(parseBigDecimal(req.getParameter("longitude")));
        return a;
    }

    private Map<String, String> validate(UserAddress a) {
        Map<String, String> errors = new LinkedHashMap<>();
        if (a.getLabel() == null || (!a.getLabel().equals("HOME") && !a.getLabel().equals("OFFICE") && !a.getLabel().equals("OTHER"))) {
            errors.put("label", "Nhãn địa chỉ không hợp lệ.");
        }
        if (a.getRecipientName() == null || a.getRecipientName().length() < 2 || a.getRecipientName().length() > 100) {
            errors.put("recipientName", "Người nhận phải từ 2 đến 100 ký tự.");
        }
        if (a.getPhone() == null || !Validators.isValidPhone(a.getPhone())) {
            errors.put("phone", "Số điện thoại không hợp lệ.");
        }
        if (a.getProvinceCity() == null || a.getProvinceCity().length() > 100) {
            errors.put("provinceCity", "Vui lòng nhập Tỉnh/Thành phố (tối đa 100 ký tự).");
        }
        if (a.getDistrict() == null || a.getDistrict().length() > 100) {
            errors.put("district", "Vui lòng nhập Quận/Huyện (tối đa 100 ký tự).");
        }
        if (a.getWard() == null || a.getWard().length() > 100) {
            errors.put("ward", "Vui lòng nhập Phường/Xã (tối đa 100 ký tự).");
        }
        if (a.getHouseNumberStreet() == null || a.getHouseNumberStreet().length() > 300) {
            errors.put("houseNumberStreet", "Vui lòng nhập số nhà/tên đường (tối đa 300 ký tự).");
        }
        return errors;
    }

    private void forwardWithErrors(HttpServletRequest req, HttpServletResponse resp, int userId,
            Map<String, String> errors, UserAddress form) throws ServletException, IOException {
        req.setAttribute("addresses", addressDao.findByUserId(userId));
        req.setAttribute("formErrors", errors);
        req.setAttribute("formAddress", form);
        req.setAttribute("currentPage", "account");
        req.setAttribute("accountTab", "addresses");
        req.getRequestDispatcher("/WEB-INF/views/account/addresses.jsp").forward(req, resp);
    }

    private int currentUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        return user.getUserId();
    }

    private void flashSuccess(HttpServletRequest req, String message) {
        req.getSession(false).setAttribute("accountFlashSuccess", message);
    }

    private void flashError(HttpServletRequest req, String message) {
        req.getSession(false).setAttribute("accountFlashError", message);
    }

    private void consumeFlash(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return;
        Object success = session.getAttribute("accountFlashSuccess");
        Object error = session.getAttribute("accountFlashError");
        if (success != null) {
            req.setAttribute("flashSuccess", success);
            session.removeAttribute("accountFlashSuccess");
        }
        if (error != null) {
            req.setAttribute("flashError", error);
            session.removeAttribute("accountFlashError");
        }
    }

    private String trimOrNull(String raw) {
        if (raw == null) return null;
        String trimmed = raw.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private String nonNull(String s) { return s != null ? s : ""; }

    private Integer parsePositiveInt(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            int v = Integer.parseInt(raw.trim());
            return v > 0 ? v : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String raw) {
        if (raw == null || raw.isBlank()) return null;
        try {
            return new BigDecimal(raw.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
