package com.nhietdoixanh.controller.admin;

import com.nhietdoixanh.dao.FeedbackDao;
import com.nhietdoixanh.dao.OrderDAO;
import com.nhietdoixanh.dao.ProductDao;
import com.nhietdoixanh.dao.impl.FeedbackDaoImpl;
import com.nhietdoixanh.dao.impl.OrderDaoImpl;
import com.nhietdoixanh.dao.impl.ProductDaoImpl;
import com.nhietdoixanh.model.Order;
import com.nhietdoixanh.model.ProductRevenueRow;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@WebServlet(name = "AdminDashboardController", urlPatterns = {"/admin", "/admin/dashboard"})
public class AdminDashboardController extends HttpServlet {

    private static final Set<String> PROCESSING_STATUSES =
            Set.of("PENDING", "CONFIRMED", "SHIPPING", "PENDING_CANCEL");
    private static final String[] DAY_LABELS = {"T2", "T3", "T4", "T5", "T6", "T7", "CN"};
    private static final DayOfWeek[] DAY_ORDER = {
            DayOfWeek.MONDAY, DayOfWeek.TUESDAY, DayOfWeek.WEDNESDAY, DayOfWeek.THURSDAY,
            DayOfWeek.FRIDAY, DayOfWeek.SATURDAY, DayOfWeek.SUNDAY
    };

    private ProductDao productDao;
    private OrderDAO orderDao;
    private FeedbackDao feedbackDao;

    @Override
    public void init() {
        productDao = new ProductDaoImpl();
        orderDao = new OrderDaoImpl();
        feedbackDao = new FeedbackDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Order> allOrders = orderDao.findAllOrders();
        List<Order> recentOrders = allOrders.stream().limit(6).collect(Collectors.toList());

        ZoneId zone = ZoneId.systemDefault();
        LocalDate today = LocalDate.now(zone);
        LocalDate weekStart = today.with(DayOfWeek.MONDAY);
        LocalDate weekEnd = weekStart.plusDays(7);       // exclusive
        LocalDate lastWeekStart = weekStart.minusDays(7);

        BigDecimal revenueThisWeek = BigDecimal.ZERO;
        BigDecimal revenueLastWeek = BigDecimal.ZERO;
        int newOrdersThisWeek = 0, newOrdersLastWeek = 0;
        int processingThisWeek = 0, processingLastWeek = 0;
        int processingNow = 0;
        long doneCount = 0, cancelledCount = 0;
        Map<DayOfWeek, BigDecimal> revenueByDow = new LinkedHashMap<>();

        for (Order o : allOrders) {
            boolean cancelled = "CANCELLED".equals(o.getOrderStatus());
            boolean processing = PROCESSING_STATUSES.contains(o.getOrderStatus());
            if ("DONE".equals(o.getOrderStatus())) doneCount++;
            if (cancelled) cancelledCount++;
            if (processing) processingNow++;

            if (o.getCreatedAt() == null) continue;
            LocalDate d = o.getCreatedAt().toInstant().atZone(zone).toLocalDate();

            if (!d.isBefore(weekStart) && d.isBefore(weekEnd)) {
                newOrdersThisWeek++;
                if (processing) processingThisWeek++;
                if (!cancelled) {
                    revenueThisWeek = revenueThisWeek.add(o.getFinalAmount());
                    revenueByDow.merge(d.getDayOfWeek(), o.getFinalAmount(), BigDecimal::add);
                }
            } else if (!d.isBefore(lastWeekStart) && d.isBefore(weekStart)) {
                newOrdersLastWeek++;
                if (processing) processingLastWeek++;
                if (!cancelled) revenueLastWeek = revenueLastWeek.add(o.getFinalAmount());
            }
        }

        double successRate = (doneCount + cancelledCount) == 0
                ? 0.0
                : (doneCount * 100.0 / (doneCount + cancelledCount));

        LinkedHashMap<String, BigDecimal> revenueByDay = new LinkedHashMap<>();
        BigDecimal maxDayRevenue = BigDecimal.ZERO;
        String todayLabel = DAY_LABELS[today.getDayOfWeek().getValue() - 1];
        for (int i = 0; i < DAY_ORDER.length; i++) {
            BigDecimal v = revenueByDow.getOrDefault(DAY_ORDER[i], BigDecimal.ZERO);
            revenueByDay.put(DAY_LABELS[i], v);
            if (v.compareTo(maxDayRevenue) > 0) maxDayRevenue = v;
        }

        List<ProductRevenueRow> revenueRows = orderDao.findProductRevenueRowsForAdmin();

        // Cơ cấu doanh thu theo danh mục
        Map<String, BigDecimal> byCategory = new LinkedHashMap<>();
        BigDecimal totalCategoryRevenue = BigDecimal.ZERO;
        for (ProductRevenueRow r : revenueRows) {
            String cat = r.getCategoryName() != null ? r.getCategoryName() : "Khác";
            byCategory.merge(cat, r.getSubTotal(), BigDecimal::add);
            totalCategoryRevenue = totalCategoryRevenue.add(r.getSubTotal());
        }
        final BigDecimal totalCatRev = totalCategoryRevenue;
        List<CategorySlice> categorySlices = byCategory.entrySet().stream()
                .map(e -> new CategorySlice(e.getKey(), e.getValue(),
                        totalCatRev.signum() == 0 ? 0.0
                                : e.getValue().multiply(BigDecimal.valueOf(100))
                                    .divide(totalCatRev, 1, RoundingMode.HALF_UP).doubleValue()))
                .sorted(Comparator.comparing(CategorySlice::getAmount).reversed())
                .collect(Collectors.toList());

        // Top sản phẩm bán chạy theo số lượng
        Map<String, Integer> byProduct = new LinkedHashMap<>();
        for (ProductRevenueRow r : revenueRows) {
            byProduct.merge(r.getProductName(), r.getQuantity(), Integer::sum);
        }
        List<TopProductRow> topProducts = byProduct.entrySet().stream()
                .map(e -> new TopProductRow(e.getKey(), e.getValue()))
                .sorted(Comparator.comparingInt(TopProductRow::getQuantity).reversed())
                .limit(5)
                .collect(Collectors.toList());

        req.setAttribute("totalProducts", productDao.findAllForAdmin().size());
        req.setAttribute("totalOrders", allOrders.size());
        req.setAttribute("pendingOrders", processingNow);
        req.setAttribute("doneOrders", doneCount);
        req.setAttribute("newFeedback", feedbackDao.countByStatus("NEW"));
        req.setAttribute("recentOrders", recentOrders);

        req.setAttribute("revenueThisWeek", revenueThisWeek);
        req.setAttribute("revenueChangePct", pctChange(revenueThisWeek, revenueLastWeek));
        req.setAttribute("newOrdersThisWeek", newOrdersThisWeek);
        req.setAttribute("newOrdersChangePct", pctChange(
                BigDecimal.valueOf(newOrdersThisWeek), BigDecimal.valueOf(newOrdersLastWeek)));
        req.setAttribute("processingNow", processingNow);
        req.setAttribute("processingChangePct", pctChange(
                BigDecimal.valueOf(processingThisWeek), BigDecimal.valueOf(processingLastWeek)));
        req.setAttribute("successRate", Math.round(successRate));

        req.setAttribute("revenueByDay", revenueByDay);
        req.setAttribute("maxDayRevenue", maxDayRevenue);
        req.setAttribute("todayLabel", todayLabel);
        req.setAttribute("categorySlices", categorySlices);
        req.setAttribute("topProducts", topProducts);

        req.setAttribute("pageTitle", "Dashboard");
        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }

    /** % thay đổi so với kỳ trước; null nếu kỳ trước = 0 (không có mốc để so sánh — hiển thị "Mới"). */
    private Double pctChange(BigDecimal current, BigDecimal previous) {
        if (previous.signum() == 0) {
            return null;
        }
        return current.subtract(previous)
                .multiply(BigDecimal.valueOf(100))
                .divide(previous, 1, RoundingMode.HALF_UP)
                .doubleValue();
    }

    public static class CategorySlice {
        private final String name;
        private final BigDecimal amount;
        private final double percent;

        CategorySlice(String name, BigDecimal amount, double percent) {
            this.name = name;
            this.amount = amount;
            this.percent = percent;
        }

        public String getName() { return name; }
        public BigDecimal getAmount() { return amount; }
        public double getPercent() { return percent; }
    }

    public static class TopProductRow {
        private final String name;
        private final int quantity;

        TopProductRow(String name, int quantity) {
            this.name = name;
            this.quantity = quantity;
        }

        public String getName() { return name; }
        public int getQuantity() { return quantity; }
    }
}
