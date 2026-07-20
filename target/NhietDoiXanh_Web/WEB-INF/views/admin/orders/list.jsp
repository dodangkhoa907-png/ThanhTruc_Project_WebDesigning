<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
/* ============================ HÀNG ĐỢI KHẨN CẤP ============================ */
/* Vùng "nóng" ấm màu hổ phách, tương phản với shell xanh rừng — báo hiệu việc cần làm ngay. */
.uq-zone{
    position:relative;background:linear-gradient(135deg,#FFFBF3 0%,#FEF4E4 100%);
    border:1px solid #F6E3C4;border-left:6px solid transparent;border-radius:16px;
    padding:22px 24px 8px;margin-bottom:24px;overflow:hidden;
    box-shadow:0 10px 30px -20px rgba(226,112,58,.5);
}
/* Thanh ray trái gradient gold→ember (dùng ::before để giữ được bo góc cạnh trái) */
.uq-zone::before{content:"";position:absolute;left:0;top:0;bottom:0;width:6px;
    background:linear-gradient(180deg,#F4A261 0%,#E2703A 100%)}
.uq-head{display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;margin-bottom:18px}
.uq-head-left{display:flex;align-items:center;gap:12px}
.uq-live{position:relative;width:11px;height:11px;flex:none;border-radius:50%;background:#E2703A}
.uq-live::after{content:"";position:absolute;inset:0;border-radius:50%;background:#E2703A;
    animation:uqpulse 1.8s ease-out infinite}
@keyframes uqpulse{0%{transform:scale(1);opacity:.7}100%{transform:scale(3.2);opacity:0}}
.uq-title{font-family:var(--fd);font-size:19px;font-weight:800;color:#B5541F;line-height:1.15}
.uq-title small{display:block;font-family:var(--fb);font-size:12.5px;font-weight:600;color:#C08A4E;margin-top:1px}
.uq-sum{text-align:right;font-size:12.5px;color:#B0895A;font-weight:600}
.uq-sum b{display:block;font-family:var(--fd);font-size:18px;color:#B5541F;font-variant-numeric:tabular-nums}

.uq-rail{display:flex;gap:14px;flex-wrap:wrap;padding-bottom:14px}

/* -------- Thẻ phiếu order -------- */
.uq-ticket{
    position:relative;background:#fff;border:1px solid #F1E6D4;border-radius:14px;
    padding:15px 16px 14px;width:255px;flex:0 0 auto;display:flex;flex-direction:column;gap:11px;
    box-shadow:0 6px 16px -12px rgba(120,80,30,.4);
    transition:opacity .45s ease,transform .45s cubic-bezier(.4,0,.2,1),
               margin .45s ease,width .45s ease,padding .45s ease,box-shadow .2s ease;
}
.uq-ticket:hover{box-shadow:0 12px 26px -14px rgba(120,80,30,.55);transform:translateY(-2px)}
/* Vạch trạng thái nhiệt bên trái thẻ — leo màu theo độ chờ */
.uq-ticket::before{content:"";position:absolute;left:0;top:14px;bottom:14px;width:3px;border-radius:3px;background:var(--status-done)}
.uq-ticket.is-warm::before{background:#E08A00}
.uq-ticket.is-hot::before{background:var(--admin-red)}

.uq-ticket-top{display:flex;align-items:center;justify-content:space-between;gap:8px}
.uq-code{font-family:var(--fd);font-size:19px;font-weight:800;color:var(--admin-text);
    font-variant-numeric:tabular-nums;letter-spacing:.01em}
.uq-wait{display:inline-flex;align-items:center;gap:5px;font-size:12px;font-weight:700;
    padding:4px 9px;border-radius:20px;white-space:nowrap;font-variant-numeric:tabular-nums;
    background:rgba(42,92,56,.1);color:var(--status-done)}
.uq-ticket.is-warm .uq-wait{background:rgba(224,138,0,.13);color:#B06A00}
.uq-ticket.is-hot .uq-wait{background:rgba(217,83,79,.13);color:var(--admin-red)}

.uq-body{display:flex;flex-direction:column;gap:4px}
.uq-cust{font-weight:700;font-size:14.5px;color:var(--admin-text);display:flex;align-items:center;gap:7px}
.uq-cust i{color:var(--admin-text-light);font-size:12px;width:13px;text-align:center}
.uq-phone{font-size:13px;color:var(--admin-text-light);font-weight:600;display:flex;align-items:center;gap:7px}
.uq-phone i{font-size:11px;width:13px;text-align:center}
.uq-items{font-size:12.5px;color:var(--admin-text-light);line-height:1.35;
    display:-webkit-box;-webkit-line-clamp:1;-webkit-box-orient:vertical;overflow:hidden}
.uq-total{margin-top:2px;font-family:var(--fd);font-size:18px;font-weight:800;color:var(--admin-primary);
    font-variant-numeric:tabular-nums}

.uq-actions{display:flex;gap:8px;margin-top:2px}
.uq-btn{flex:1;padding:10px 12px;border-radius:10px;font-weight:700;font-size:13.5px;font-family:var(--fb);
    cursor:pointer;border:none;display:inline-flex;align-items:center;justify-content:center;gap:6px;transition:.18s}
.uq-btn:disabled{opacity:.6;cursor:progress}
.uq-btn-approve{background:#10B981;color:#fff;box-shadow:0 8px 16px -10px rgba(16,185,129,.9)}
.uq-btn-approve:hover:not(:disabled){background:#0EA372;transform:translateY(-1px)}
.uq-btn-cancel{flex:0 0 auto;width:78px;background:#F1F0EC;color:#5B5B54}
.uq-btn-cancel:hover:not(:disabled){background:#E6E4DD}

/* Thẻ đang được xử lý xong: mờ + co lại rồi biến mất */
.uq-ticket.removing{opacity:0;transform:scale(.9);width:0 !important;padding-left:0;padding-right:0;
    margin-left:-14px;pointer-events:none;box-shadow:none}

.uq-more{width:100%;font-size:12.5px;color:#B0895A;font-weight:600;padding:2px 2px 12px}
.uq-more a{color:#B5541F;font-weight:700;text-decoration:underline}

/* Trạng thái rỗng — mọi đơn mới đã xử lý xong */
.uq-empty{display:flex;align-items:center;gap:12px;padding:18px 20px 26px;color:var(--admin-primary);font-weight:700;font-size:15px}
.uq-empty .ic{width:40px;height:40px;border-radius:50%;background:rgba(42,92,56,.12);
    display:flex;align-items:center;justify-content:center;font-size:18px;flex:none}
.uq-empty small{display:block;font-weight:500;font-size:13px;color:var(--admin-text-light);margin-top:2px}
/* Rule tác giả (.uq-empty{display:flex}) đè mất display:none mặc định của [hidden] vì cùng độ ưu
   tiên nhưng CSS tác giả luôn thắng CSS trình duyệt — phải khai báo lại tường minh. */
.uq-empty[hidden]{display:none}

/* Mã đơn giờ là link trỏ sang trang chi tiết/xác nhận đầy đủ — giữ y hệt hình thức cũ, chỉ thêm gạch chân khi hover. */
a.uq-code{color:inherit;text-decoration:none;border-bottom:2px solid transparent;transition:border-color .15s}
a.uq-code:hover{border-color:var(--admin-gold)}
.uq-detail-link{font-size:11.5px;font-weight:700;color:var(--admin-text-light);display:inline-flex;
    align-items:center;gap:4px;text-decoration:none;transition:color .15s}
.uq-detail-link:hover{color:#B5541F}
.uq-detail-link i{font-size:9px}

/* ============================ BẢNG LỊCH SỬ ============================ */

/* -------- Bảng: cột khách hàng gộp, chỉ báo thanh toán nhẹ, hành động gọn -------- */
.ord-cust-cell b{display:block;font-size:14px;font-weight:700;color:var(--admin-text)}
.ord-cust-cell span{display:block;font-size:12px;color:var(--admin-text-light);font-weight:500;margin-top:1px}
.ord-amount{font-weight:700;font-variant-numeric:tabular-nums;white-space:nowrap}
.ord-date{color:var(--admin-text-light);font-size:13px;white-space:nowrap}

.pay-ind{display:inline-flex;align-items:center;gap:7px;font-size:12.5px;font-weight:600;color:var(--admin-text-light);white-space:nowrap}
.pay-dot{width:7px;height:7px;border-radius:50%;background:#C7CFC9;flex-shrink:0}
.pay-ind.is-paid{color:var(--status-done)}
.pay-ind.is-paid .pay-dot{background:var(--status-done)}
.pay-ind.is-flag{color:var(--admin-red)}
.pay-ind.is-flag .pay-dot{background:var(--admin-red)}

.ord-row-actions{display:flex;flex-wrap:wrap;gap:10px;align-items:center}
.ord-inline-form{display:inline}
.ord-ship-form{display:inline-flex;gap:6px;align-items:center}
.ord-ship-select{padding:7px 9px;border:1px solid var(--admin-border);border-radius:8px;
    font-size:12.5px;font-family:var(--fb);background:var(--admin-bg);color:var(--admin-text);max-width:130px}
.ord-ship-select:focus{border-color:var(--admin-primary);outline:none;background:#fff}
.btn-sm{padding:8px 14px;font-size:12.5px;border-radius:9px}
.ord-link-action{font-size:12.5px;font-weight:700;color:var(--admin-text-light);text-decoration:none;
    padding:6px 2px;transition:color .15s}
.ord-link-action:hover{color:var(--admin-primary);text-decoration:underline}

/* -------- Chuyển tab/trang/lọc bằng AJAX — không reload cả trang -------- */
#historySection{transition:opacity .12s ease}
#historySection.is-loading{opacity:.45;pointer-events:none}

.ord-filters{margin-bottom:18px}
.ord-filters .f-group{display:flex;flex-direction:column;gap:6px}
.ord-filters .f-group label{font-size:12px;font-weight:700;color:var(--admin-text-light)}
.ord-filters input,.ord-filters select{padding:9px 12px;border:1px solid var(--admin-border);border-radius:9px;font-size:13.5px;font-family:var(--fb);color:var(--admin-text);background:var(--admin-bg)}
.ord-filters input:focus,.ord-filters select:focus{border-color:var(--admin-primary);outline:none;background:#fff}

/* -------- Thanh tìm kiếm chính (luôn hiện) -------- */
.ord-search-row{display:flex;gap:10px;align-items:center;margin-bottom:6px}
.ord-search-input{flex:1;padding:11px 14px;border:1px solid var(--admin-border);border-radius:10px;
    font-size:14px;font-family:var(--fb);color:var(--admin-text);background:var(--admin-bg)}
.ord-search-input:focus{border-color:var(--admin-primary);outline:none;background:#fff}

/* -------- Bộ lọc nâng cao (ẩn mặc định, giảm rối mắt) -------- */
.ord-adv summary{cursor:pointer;font-size:12.5px;font-weight:700;color:var(--admin-text-light);
    list-style:none;padding:6px 0;user-select:none;transition:color .15s}
.ord-adv summary::-webkit-details-marker{display:none}
.ord-adv summary::before{content:"▸";display:inline-block;margin-right:6px;transition:transform .15s;font-size:10px}
.ord-adv[open] summary::before{transform:rotate(90deg)}
.ord-adv summary:hover{color:var(--admin-text)}
.ord-adv-hint{font-weight:500;color:var(--admin-text-light);opacity:.75}
.ord-adv-grid{display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end;padding:12px 2px 4px}
.ord-adv-apply{justify-content:flex-end}
.ord-flash{padding:14px 18px;border-radius:12px;margin-bottom:20px;font-weight:600;font-size:14px}
.ord-flash.success{background:rgba(42,92,56,.1);color:var(--admin-primary)}
.ord-flash.error{background:rgba(217,83,79,.1);color:var(--admin-red)}
.ord-empty{text-align:center;padding:60px 20px;color:var(--admin-text-light)}
.ord-empty i{font-size:40px;opacity:.3;margin-bottom:14px;display:block}
.ord-pager{display:flex;justify-content:center;align-items:center;gap:8px;margin-top:22px}
.ord-pager a,.ord-pager span{min-width:38px;height:38px;display:flex;align-items:center;justify-content:center;border-radius:10px;font-weight:700;font-size:13.5px;color:var(--admin-text)}
.ord-pager a{background:var(--admin-bg)}
.ord-pager a:hover{background:#EAF0E7}
.ord-pager span.current{background:var(--admin-primary);color:#fff}
.ord-count{color:var(--admin-text-light);font-size:13px;font-weight:600;margin-bottom:14px}
.ord-section-head{font-family:var(--fd);font-size:16px;font-weight:800;margin-bottom:16px;color:var(--admin-text);display:flex;align-items:center;gap:9px}
.ord-section-head i{color:var(--admin-text-light);font-size:14px}

/* -------- Modal lý do hủy -------- */
.uq-overlay{position:fixed;inset:0;background:rgba(26,46,26,.45);backdrop-filter:blur(2px);
    display:none;align-items:center;justify-content:center;z-index:400;padding:20px;
    opacity:0;transition:opacity .2s ease}
.uq-overlay.show{display:flex;opacity:1}
.uq-modal{background:#fff;border-radius:18px;padding:24px;width:100%;max-width:440px;
    box-shadow:0 30px 60px -20px rgba(0,0,0,.4);transform:translateY(12px);transition:transform .2s ease}
.uq-overlay.show .uq-modal{transform:none}
.uq-modal h3{font-family:var(--fd);font-size:18px;margin-bottom:6px}
.uq-modal p{font-size:13.5px;color:var(--admin-text-light);margin-bottom:14px}
.uq-modal textarea{width:100%;padding:12px 14px;border:1.5px solid var(--admin-border);border-radius:11px;
    font-family:var(--fb);font-size:14px;resize:vertical;min-height:84px;color:var(--admin-text)}
.uq-modal textarea:focus{border-color:var(--admin-red);outline:none;box-shadow:0 0 0 4px rgba(217,83,79,.1)}
.uq-modal-actions{display:flex;gap:10px;margin-top:16px;justify-content:flex-end}

/* -------- Toast lỗi -------- */
.uq-toast{position:fixed;bottom:26px;left:50%;transform:translate(-50%,20px);z-index:500;
    background:var(--admin-red);color:#fff;padding:13px 22px;border-radius:12px;font-weight:600;font-size:14px;
    box-shadow:0 16px 34px -16px rgba(217,83,79,.8);opacity:0;pointer-events:none;transition:opacity .25s,transform .25s}
.uq-toast.show{opacity:1;transform:translate(-50%,0)}
.uq-toast.ok{background:var(--admin-primary);box-shadow:0 16px 34px -16px rgba(42,92,56,.8)}

@media(max-width:560px){.uq-ticket{width:100%}}
@media(prefers-reduced-motion:reduce){
    .uq-live::after{animation:none}
    .uq-ticket,.uq-overlay,.uq-modal,.uq-toast{transition:none}
}
</style>

<c:if test="${not empty flashSuccess}"><div class="ord-flash success"><c:out value="${flashSuccess}"/></div></c:if>
<c:if test="${not empty flashError}"><div class="ord-flash error"><c:out value="${flashError}"/></div></c:if>

<!-- ======================= PHÂN VÙNG 1 · HÀNG ĐỢI KHẨN CẤP ======================= -->
<section class="uq-zone" aria-label="Đơn hàng cần xử lý ngay">
    <div class="uq-head">
        <div class="uq-head-left">
            <span class="uq-live" aria-hidden="true"></span>
            <div class="uq-title">🔥 Cần xử lý ngay
                <small>Đơn mới đang chờ bạn xác nhận · <span id="uqCount">${pendingTotal}</span> đơn</small>
            </div>
        </div>
        <div class="uq-sum">Tổng giá trị đang chờ
            <b id="uqTotal">0đ</b>
        </div>
    </div>

    <div class="uq-rail" id="uqRail">
        <c:forEach var="o" items="${pendingQueue}">
            <article class="uq-ticket"
                     data-order-id="${o.orderId}"
                     data-created="${o.createdAt.time}"
                     data-amount="${o.finalAmount}">
                <div class="uq-ticket-top">
                    <a class="uq-code" href="${ctx}/admin/don-hang/chi-tiet?id=${o.orderId}" title="Xem chi tiết đơn #${o.orderId}">#${o.orderId}</a>
                    <span class="uq-wait"><i class="fa-regular fa-clock"></i> <span class="wait-text">—</span></span>
                </div>
                <div class="uq-body">
                    <div class="uq-cust"><i class="fa-solid fa-user"></i>
                        <c:out value="${not empty o.recipientName ? o.recipientName : o.customerName}"/></div>
                    <div class="uq-phone"><i class="fa-solid fa-phone"></i>
                        <c:out value="${not empty o.recipientPhone ? o.recipientPhone : o.phoneNumber}"/></div>
                    <c:if test="${not empty o.productSummary}">
                        <div class="uq-items"><c:out value="${o.productSummary}"/></div>
                    </c:if>
                    <div class="uq-total"><fmt:formatNumber value="${o.finalAmount}" type="number" groupingUsed="true"/>đ</div>
                </div>
                <div class="uq-actions">
                    <button type="button" class="uq-btn uq-btn-approve" data-action="approve">
                        <i class="fa-solid fa-check"></i> Duyệt đơn</button>
                    <button type="button" class="uq-btn uq-btn-cancel" data-action="cancel">Hủy</button>
                </div>
                <a class="uq-detail-link" href="${ctx}/admin/don-hang/chi-tiet?id=${o.orderId}">
                    Xem đầy đủ &amp; xác nhận tại trang chi tiết <i class="fa-solid fa-arrow-right"></i></a>
            </article>
        </c:forEach>

        <c:if test="${pendingTotal > queueLimit}">
            <div class="uq-more">Đang hiển thị ${queueLimit} đơn chờ mới nhất trên tổng ${pendingTotal}.
                <a href="${ctx}/admin/don-hang?orderStatus=PENDING">Xem tất cả đơn chờ →</a></div>
        </c:if>
    </div>

    <div class="uq-empty" id="uqEmpty" ${pendingTotal > 0 ? 'hidden' : ''}>
        <span class="ic">✅</span>
        <div>Tuyệt vời! Tất cả đơn hàng mới đã được xử lý xong.
            <small>Đơn "Chờ xác nhận" mới sẽ tự xuất hiện ở đây khi bạn tải lại trang.</small></div>
    </div>
</section>

<!-- ======================= PHÂN VÙNG 2 · BẢNG LỊCH SỬ ĐƠN HÀNG ======================= -->
<div id="historySection">
    <jsp:include page="_history-section.jsp"/>
</div>

<!-- Modal lý do hủy -->
<div class="uq-overlay" id="cancelOverlay" hidden>
    <div class="uq-modal" role="dialog" aria-modal="true" aria-labelledby="cancelTitle">
        <h3 id="cancelTitle">Hủy đơn #<span id="cancelOrderNo"></span></h3>
        <p>Nhập lý do hủy — thao tác này không thể hoàn tác.</p>
        <textarea id="cancelReason" placeholder="VD: Khách yêu cầu hủy, hết hàng, sai thông tin..."></textarea>
        <div class="uq-modal-actions">
            <button type="button" class="btn btn-outline" id="cancelDismiss">Quay lại</button>
            <button type="button" class="btn btn-danger" id="cancelConfirm">Xác nhận hủy</button>
        </div>
    </div>
</div>

<div class="uq-toast" id="uqToast" role="status" aria-live="polite" hidden></div>

<script>
(function () {
    var ctx = '${ctx}';
    var csrf = '${sessionScope._csrf}';
    var ENDPOINT = ctx + '/admin/don-hang/cap-nhat-trang-thai';
    var rail = document.getElementById('uqRail');
    var emptyBox = document.getElementById('uqEmpty');
    var countEl = document.getElementById('uqCount');
    var totalEl = document.getElementById('uqTotal');
    var toast = document.getElementById('uqToast');

    var STATUS_LABEL = { CONFIRMED: 'Đang xử lý', CANCELLED: 'Đã hủy' };

    function formatVND(n) { return (Math.round(n) || 0).toLocaleString('vi-VN') + 'đ'; }

    function relativeWait(createdMs) {
        var mins = Math.floor((Date.now() - createdMs) / 60000);
        if (isNaN(mins) || mins < 0) mins = 0;
        if (mins < 1) return { text: 'vừa xong', heat: '' };
        if (mins < 60) return { text: mins + ' phút trước', heat: mins >= 15 ? 'hot' : (mins >= 5 ? 'warm' : '') };
        var hrs = Math.floor(mins / 60);
        if (hrs < 24) return { text: hrs + ' giờ trước', heat: 'hot' };
        return { text: Math.floor(hrs / 24) + ' ngày trước', heat: 'hot' };
    }

    // Cập nhật thời gian chờ + màu nhiệt cho mọi thẻ (chạy khi tải và mỗi 30s)
    function refreshWaits() {
        rail.querySelectorAll('.uq-ticket').forEach(function (card) {
            var created = parseInt(card.dataset.created, 10);
            var w = relativeWait(created);
            var t = card.querySelector('.wait-text');
            if (t) t.textContent = w.text;
            card.classList.remove('is-warm', 'is-hot');
            if (w.heat) card.classList.add('is-' + w.heat);
        });
    }

    function recomputeSummary() {
        var cards = rail.querySelectorAll('.uq-ticket:not(.removing)');
        countEl.textContent = cards.length;
        var sum = 0;
        cards.forEach(function (c) { sum += parseFloat(c.dataset.amount) || 0; });
        totalEl.textContent = formatVND(sum);
        if (cards.length === 0) emptyBox.hidden = false;
    }

    function showToast(msg, ok) {
        toast.textContent = msg;
        toast.className = 'uq-toast show' + (ok ? ' ok' : '');
        toast.hidden = false;
        clearTimeout(toast._t);
        toast._t = setTimeout(function () { toast.className = 'uq-toast'; }, 3200);
    }

    // Đồng bộ badge trạng thái ở bảng lịch sử (nếu đơn đang hiển thị trên trang hiện tại)
    function syncTableRow(orderId, newStatus) {
        var row = document.querySelector('#historyTable tr[data-order-id="' + orderId + '"]');
        if (!row) return;
        var cell = row.querySelector('.js-status-cell');
        if (cell) cell.innerHTML = '<span class="badge badge-' + newStatus + '">'
            + (STATUS_LABEL[newStatus] || newStatus) + '</span>';
    }

    function removeCard(card) {
        card.classList.add('removing');
        var done = false;
        function finish() { if (done) return; done = true; card.remove(); recomputeSummary(); }
        card.addEventListener('transitionend', finish, { once: true });
        setTimeout(finish, 550); // fallback nếu transitionend không kích hoạt
    }

    // Gọi API cập nhật trạng thái; trả về Promise
    function submitStatus(orderId, newStatus, reason) {
        var body = new URLSearchParams();
        body.set('_csrf', csrf);
        body.set('orderId', orderId);
        body.set('newStatus', newStatus);
        if (reason != null) body.set('reason', reason);
        return fetch(ENDPOINT, {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body.toString()
        }).then(function (r) { return r.json().then(function (j) { return { ok: r.ok, data: j }; }); });
    }

    function setBusy(card, busy) {
        card.querySelectorAll('.uq-btn').forEach(function (b) { b.disabled = busy; });
    }

    function approve(card) {
        var id = card.dataset.orderId;
        setBusy(card, true);
        submitStatus(id, 'CONFIRMED', null).then(function (res) {
            if (res.ok && res.data.success) {
                syncTableRow(id, 'CONFIRMED');
                showToast('Đã duyệt đơn #' + id, true);
                removeCard(card);
            } else {
                setBusy(card, false);
                showToast(res.data.message || 'Không thể duyệt đơn.', false);
            }
        }).catch(function () {
            setBusy(card, false);
            showToast('Lỗi kết nối, vui lòng thử lại.', false);
        });
    }

    // ---- Modal hủy ----
    var overlay = document.getElementById('cancelOverlay');
    var reasonInput = document.getElementById('cancelReason');
    var orderNoEl = document.getElementById('cancelOrderNo');
    var pendingCancelCard = null;

    function openCancel(card) {
        pendingCancelCard = card;
        orderNoEl.textContent = card.dataset.orderId;
        reasonInput.value = '';
        overlay.hidden = false;
        requestAnimationFrame(function () { overlay.classList.add('show'); });
        setTimeout(function () { reasonInput.focus(); }, 60);
    }
    function closeCancel() {
        overlay.classList.remove('show');
        setTimeout(function () { overlay.hidden = true; }, 200);
        pendingCancelCard = null;
    }

    document.getElementById('cancelDismiss').addEventListener('click', closeCancel);
    overlay.addEventListener('click', function (e) { if (e.target === overlay) closeCancel(); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !overlay.hidden) closeCancel(); });

    document.getElementById('cancelConfirm').addEventListener('click', function () {
        var reason = reasonInput.value.trim();
        if (!reason) { reasonInput.focus(); showToast('Vui lòng nhập lý do hủy.', false); return; }
        var card = pendingCancelCard;
        if (!card) return;
        var id = card.dataset.orderId;
        this.disabled = true;
        var btn = this;
        submitStatus(id, 'CANCELLED', reason).then(function (res) {
            btn.disabled = false;
            if (res.ok && res.data.success) {
                syncTableRow(id, 'CANCELLED');
                closeCancel();
                showToast('Đã hủy đơn #' + id, true);
                removeCard(card);
            } else {
                showToast(res.data.message || 'Không thể hủy đơn.', false);
            }
        }).catch(function () { btn.disabled = false; showToast('Lỗi kết nối, vui lòng thử lại.', false); });
    });

    // Uỷ quyền sự kiện cho toàn hàng đợi
    rail.addEventListener('click', function (e) {
        var btn = e.target.closest('.uq-btn');
        if (!btn) return;
        var card = btn.closest('.uq-ticket');
        if (!card || card.classList.contains('removing')) return;
        if (btn.dataset.action === 'approve') approve(card);
        else if (btn.dataset.action === 'cancel') openCancel(card);
    });

    refreshWaits();
    recomputeSummary();
    setInterval(refreshWaits, 30000);

    // ---- Điều hướng AJAX cho khu "Lịch sử đơn hàng" (tab/phân trang/lọc) ----
    // Thay vì để trình duyệt load lại CẢ TRANG (header/sidebar/hàng đợi khẩn cấp render lại
    // từ đầu -> cảm giác "khựng"), chỉ fetch riêng fragment bảng và thay innerHTML.
    var historySection = document.getElementById('historySection');
    var historyBase = ctx + '/admin/don-hang';

    function loadHistory(url, push) {
        historySection.classList.add('is-loading');
        fetch(url, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function (r) {
                if (!r.ok) throw new Error('bad status');
                return r.text();
            })
            .then(function (html) {
                historySection.innerHTML = html;
                historySection.classList.remove('is-loading');
                if (push) history.pushState({ historyAjax: true }, '', url);
            })
            .catch(function () {
                // AJAX lỗi (mất mạng, server down...) -> fallback điều hướng thật, không để kẹt trang.
                window.location.href = url;
            });
    }

    historySection.addEventListener('click', function (e) {
        // Ctrl/Cmd/Shift+click, click giữa (mở tab mới), hoặc chuột phải -> để trình duyệt xử lý
        // như bình thường (mở tab mới...), KHÔNG cướp bằng preventDefault(). Trước đây thiếu check
        // này nên Ctrl+click vào tab lịch sử bị chặn mất, không mở tab mới được như trình duyệt vẫn làm.
        if (e.defaultPrevented || e.button !== 0 || e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;
        var a = e.target.closest('a[href]');
        if (!a || !historySection.contains(a)) return;
        var href = a.getAttribute('href');
        // Chỉ chặn link quay lại ĐÚNG trang danh sách này (tab/phân trang/xóa lọc);
        // để nguyên "Xem chi tiết" (/admin/don-hang/chi-tiet) đi bình thường sang trang khác.
        if (href !== historyBase && href.indexOf(historyBase + '?') !== 0) return;
        e.preventDefault();
        loadHistory(a.href, true);
    });

    historySection.addEventListener('submit', function (e) {
        var form = e.target;
        // Chỉ chặn form lọc (GET) — các form hành động (POST: Giao cho vận chuyển/Chốt hoàn thành)
        // vẫn submit thật để redirect + flash message như bình thường.
        if (!form.classList.contains('ord-filters')) return;
        e.preventDefault();
        var params = new URLSearchParams(new FormData(form));
        loadHistory(form.action + '?' + params.toString(), true);
    });

    window.addEventListener('popstate', function () {
        if (location.href.indexOf(historyBase) === 0) loadHistory(location.href, false);
    });
})();
</script>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
