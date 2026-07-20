package com.nhietdoixanh.controller.admin;

import com.nhietdoixanh.dao.AuditLogDao;
import com.nhietdoixanh.dao.StaffDao;
import com.nhietdoixanh.dao.impl.AuditLogDaoImpl;
import com.nhietdoixanh.dao.impl.StaffDaoImpl;
import com.nhietdoixanh.model.AuditLogFilter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

/**
 * Admin xem nhật ký hành động (audit log) — tìm kiếm/lọc/phân trang, CHỈ ĐỌC theo thiết kế
 * (tính toàn vẹn của bằng chứng kiểm toán). Không có thao tác sửa/xóa nào ở đây; nguồn ghi
 * duy nhất là {@link com.nhietdoixanh.util.AuditLogger} gọi rải rác khắp codebase — controller
 * này không đụng tới đường ghi đó.
 *
 * Quyền hạn: nằm dưới urlPattern "/admin/*" nên đã được {@link com.nhietdoixanh.filter.AuthFilter}
 * chặn — chỉ Staff đã đăng nhập (cookie {@link com.nhietdoixanh.util.AdminAuth}) mới tới được. Chỉ nhận GET nên
 * {@link com.nhietdoixanh.filter.CsrfFilter} (chỉ kiểm tra POST/PUT/DELETE) không áp dụng ở đây.
 */
@WebServlet(name = "AdminAuditController", urlPatterns = {"/admin/nhat-ky"})
public class AdminAuditController extends HttpServlet {

    /** Nhật ký có thể rất nhiều nhưng mỗi dòng nhẹ — trang lớn hơn bảng đơn hàng (10). */
    private static final int PAGE_SIZE = 30;

    private AuditLogDao auditLogDao;
    private StaffDao staffDao;

    @Override
    public void init() {
        auditLogDao = new AuditLogDaoImpl();
        staffDao = new StaffDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleList(req, resp);
    }

    // Trang chỉ đọc — không có route ghi nào, không cần override doPost (mặc định 405 của HttpServlet).

    private void handleList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String keyword = trimOrNull(req.getParameter("q"));
        String staffIdRaw = trimOrNull(req.getParameter("staffId"));
        String fromDateRaw = trimOrNull(req.getParameter("fromDate"));
        String toDateRaw = trimOrNull(req.getParameter("toDate"));

        Integer staffId = parsePositiveInt(staffIdRaw);

        AuditLogFilter filter = new AuditLogFilter();
        filter.setKeyword(keyword);
        filter.setStaffId(staffId);
        filter.setFromDate(parseDate(fromDateRaw));
        filter.setToDate(parseDate(toDateRaw));

        int page = parsePositiveIntOrDefault(req.getParameter("page"), 1);
        int totalLogs = auditLogDao.countSearch(filter);
        int totalPages = Math.max(1, (int) Math.ceil(totalLogs / (double) PAGE_SIZE));
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * PAGE_SIZE;

        var logs = auditLogDao.searchPaged(filter, offset, PAGE_SIZE);

        req.setAttribute("logs", logs);
        req.setAttribute("totalLogs", totalLogs);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("currentPage", page);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("q", keyword);
        req.setAttribute("staffId", staffId);
        req.setAttribute("fromDate", fromDateRaw);
        req.setAttribute("toDate", toDateRaw);
        req.setAttribute("staffList", staffDao.findAll());

        req.setAttribute("pageTitle", "Nhật ký");
        req.getRequestDispatcher("/WEB-INF/views/admin/audit/list.jsp").forward(req, resp);
    }

    // =========================================================================================
    // Helpers
    // =========================================================================================

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

    private int parsePositiveIntOrDefault(String raw, int fallback) {
        Integer v = parsePositiveInt(raw);
        return v != null ? v : fallback;
    }

    private LocalDate parseDate(String raw) {
        if (raw == null) return null;
        try {
            return LocalDate.parse(raw);
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
