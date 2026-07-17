package com.nhietdoixanh.util;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Cấp bậc thành viên — tính từ tổng tiền các đơn đã DONE (đơn hủy không tính).
 * Ngưỡng đặt tập trung ở đây — sửa số tiền là đủ, không rải rác nơi khác.
 */
public final class MemberTierService {

    public enum Tier {
        MAM_XANH("Mầm Xanh", BigDecimal.ZERO),
        LA_XANH("Lá Xanh", new BigDecimal("300000")),
        VUON_NHIET_DOI("Vườn Nhiệt Đới", new BigDecimal("1000000")),
        DAI_SU_XANH("Đại Sứ Xanh", new BigDecimal("3000000"));

        private final String label;
        private final BigDecimal minSpend;

        Tier(String label, BigDecimal minSpend) {
            this.label = label;
            this.minSpend = minSpend;
        }

        public String getLabel() { return label; }
        public BigDecimal getMinSpend() { return minSpend; }
    }

    /** Thứ tự từ cao xuống thấp để duyệt tìm ngưỡng đầu tiên thỏa mãn. */
    private static final Tier[] DESCENDING = { Tier.DAI_SU_XANH, Tier.VUON_NHIET_DOI, Tier.LA_XANH, Tier.MAM_XANH };

    private MemberTierService() {}

    public static Tier resolve(BigDecimal totalDoneAmount) {
        BigDecimal amount = totalDoneAmount != null ? totalDoneAmount : BigDecimal.ZERO;
        for (Tier tier : DESCENDING) {
            if (amount.compareTo(tier.getMinSpend()) >= 0) return tier;
        }
        return Tier.MAM_XANH;
    }

    /** Ngưỡng tiền cần chi thêm để lên hạng kế tiếp, null nếu đã ở hạng cao nhất. */
    public static BigDecimal amountToNextTier(BigDecimal totalDoneAmount) {
        BigDecimal amount = totalDoneAmount != null ? totalDoneAmount : BigDecimal.ZERO;
        Tier current = resolve(amount);
        Tier next = switch (current) {
            case MAM_XANH -> Tier.LA_XANH;
            case LA_XANH -> Tier.VUON_NHIET_DOI;
            case VUON_NHIET_DOI -> Tier.DAI_SU_XANH;
            case DAI_SU_XANH -> null;
        };
        return next != null ? next.getMinSpend().subtract(amount) : null;
    }

    public static Tier nextTier(BigDecimal totalDoneAmount) {
        Tier current = resolve(totalDoneAmount != null ? totalDoneAmount : BigDecimal.ZERO);
        return switch (current) {
            case MAM_XANH -> Tier.LA_XANH;
            case LA_XANH -> Tier.VUON_NHIET_DOI;
            case VUON_NHIET_DOI -> Tier.DAI_SU_XANH;
            case DAI_SU_XANH -> null;
        };
    }

    /** Map nhãn -> ngưỡng, dùng nếu cần hiển thị toàn bộ thang cấp bậc ở UI. */
    public static Map<String, BigDecimal> allTiersAscending() {
        Map<String, BigDecimal> map = new LinkedHashMap<>();
        map.put(Tier.MAM_XANH.getLabel(), Tier.MAM_XANH.getMinSpend());
        map.put(Tier.LA_XANH.getLabel(), Tier.LA_XANH.getMinSpend());
        map.put(Tier.VUON_NHIET_DOI.getLabel(), Tier.VUON_NHIET_DOI.getMinSpend());
        map.put(Tier.DAI_SU_XANH.getLabel(), Tier.DAI_SU_XANH.getMinSpend());
        return map;
    }
}
