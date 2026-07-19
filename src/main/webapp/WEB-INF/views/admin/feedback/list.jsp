<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
.fb-flash{padding:14px 18px;border-radius:12px;margin-bottom:20px;font-weight:600;font-size:14px}
.fb-flash.success{background:rgba(42,92,56,.1);color:var(--admin-primary)}
.fb-flash.error{background:rgba(217,83,79,.1);color:var(--admin-red)}

/* NEW dùng chung .badge-NEW đã khai báo global (header.jsp) — chỉ bổ sung SEEN/RESOLVED tại đây. */
.badge-SEEN{background:rgba(57,101,255,.12);color:var(--status-confirmed)}
.badge-RESOLVED{background:rgba(42,92,56,.12);color:var(--status-done)}

.fb-search-row{display:flex;gap:10px;align-items:center;margin-bottom:18px}
.fb-search-input{flex:1;padding:11px 14px;border:1px solid var(--admin-border);border-radius:10px;
    font-size:14px;font-family:var(--fb);color:var(--admin-text);background:var(--admin-bg)}
.fb-search-input:focus{border-color:var(--admin-primary);outline:none;background:#fff}

.fb-count{color:var(--admin-text-light);font-size:13px;font-weight:600;margin-bottom:14px}

.fb-sender-cell b{display:block;font-size:14px;font-weight:700;color:var(--admin-text)}
.fb-sender-cell span{display:block;font-size:12px;color:var(--admin-text-light);font-weight:500;margin-top:1px}
.fb-registered{color:var(--status-done) !important;font-weight:600 !important}
.fb-registered i{margin-right:3px}

.fb-stars{white-space:nowrap;font-size:13px}
.fb-stars i{color:#D8D2C4;margin-right:1px}
.fb-stars i.filled{color:#F4A261}
.fb-no-rating{font-size:12.5px;color:var(--admin-text-light)}

.fb-msg-cell{max-width:320px}
.fb-msg{font-size:13px;color:var(--admin-text);line-height:1.4;
    display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden;margin-bottom:4px}
.fb-msg-empty{color:var(--admin-text-light);font-size:12.5px}
.fb-view-more{background:none;border:none;padding:0;font-size:12.5px;font-weight:700;
    color:var(--admin-primary);cursor:pointer;text-decoration:underline}

.fb-date{color:var(--admin-text-light);font-size:13px;white-space:nowrap}

.fb-actions{display:flex;flex-wrap:wrap;gap:8px}
.btn-sm{padding:8px 14px;font-size:12.5px;border-radius:9px}

.fb-empty{text-align:center;padding:60px 20px;color:var(--admin-text-light)}
.fb-empty i{font-size:40px;opacity:.3;margin-bottom:14px;display:block}

.fb-pager{display:flex;justify-content:center;align-items:center;gap:8px;margin-top:22px}
.fb-pager a,.fb-pager span{min-width:38px;height:38px;display:flex;align-items:center;justify-content:center;border-radius:10px;font-weight:700;font-size:13.5px;color:var(--admin-text)}
.fb-pager a{background:var(--admin-bg)}
.fb-pager a:hover{background:#EAF0E7}
.fb-pager span.current{background:var(--admin-primary);color:#fff}

.fb-row-removing{opacity:0;transition:opacity .35s ease}

/* -------- Modal xem đầy đủ phản hồi -------- */
.fb-overlay{position:fixed;inset:0;background:rgba(26,46,26,.45);backdrop-filter:blur(2px);
    display:none;align-items:center;justify-content:center;z-index:400;padding:20px;
    opacity:0;transition:opacity .2s ease}
.fb-overlay.show{display:flex;opacity:1}
.fb-modal{background:#fff;border-radius:18px;padding:24px;width:100%;max-width:520px;
    box-shadow:0 30px 60px -20px rgba(0,0,0,.4);transform:translateY(12px);transition:transform .2s ease;
    max-height:86vh;overflow-y:auto}
.fb-overlay.show .fb-modal{transform:none}
.fb-modal h3{font-family:var(--fd);font-size:18px;margin-bottom:16px}
.fb-view-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px 20px;margin-bottom:16px}
.fb-view-label{display:block;font-size:11.5px;font-weight:700;text-transform:uppercase;letter-spacing:.03em;
    color:var(--admin-text-light);margin-bottom:3px}
.fb-view-grid > div > span:last-child{font-size:14px;color:var(--admin-text);font-weight:600;word-break:break-word}
.fb-view-message-label{font-size:11.5px;font-weight:700;text-transform:uppercase;letter-spacing:.03em;
    color:var(--admin-text-light);margin-bottom:6px}
.fb-view-message{font-size:14px;color:var(--admin-text);line-height:1.55;white-space:pre-wrap;word-break:break-word;
    background:var(--admin-bg);border-radius:12px;padding:14px 16px;max-height:260px;overflow-y:auto}
.fb-modal-actions{display:flex;gap:10px;margin-top:18px;justify-content:flex-end}

.fb-toast{position:fixed;bottom:26px;left:50%;transform:translate(-50%,20px);z-index:500;
    background:var(--admin-red);color:#fff;padding:13px 22px;border-radius:12px;font-weight:600;font-size:14px;
    box-shadow:0 16px 34px -16px rgba(217,83,79,.8);opacity:0;pointer-events:none;transition:opacity .25s,transform .25s}
.fb-toast.show{opacity:1;transform:translate(-50%,0)}
.fb-toast.ok{background:var(--admin-primary);box-shadow:0 16px 34px -16px rgba(42,92,56,.8)}
</style>

<c:if test="${not empty flashSuccess}"><div class="fb-flash success"><c:out value="${flashSuccess}"/></div></c:if>
<c:if test="${not empty flashError}"><div class="fb-flash error"><c:out value="${flashError}"/></div></c:if>

<!-- Ngữ cảnh lọc hiện tại — JS đọc qua dataset thay vì nhúng thẳng vào chuỗi JS để tránh
     mọi rủi ro reflected-XSS nếu tham số q/status bị chỉnh sửa trên URL. -->
<div id="fbPageContext" data-status="<c:out value="${status}"/>" data-q="<c:out value="${q}"/>" data-page="${currentPage}" hidden></div>

<div class="card">
    <nav class="admin-tabs" aria-label="Lọc theo trạng thái phản hồi">
        <c:url value="/admin/phan-hoi" var="tabAllUrl"><c:param name="q" value="${q}"/></c:url>
        <a href="${tabAllUrl}" class="admin-tab ${activeTab == 'ALL' ? 'active' : ''}">Tất cả <span class="admin-tab-count">${countAll}</span></a>

        <c:url value="/admin/phan-hoi" var="tabNewUrl"><c:param name="q" value="${q}"/><c:param name="status" value="NEW"/></c:url>
        <a href="${tabNewUrl}" class="admin-tab ${activeTab == 'NEW' ? 'active' : ''}">Chờ duyệt <span class="admin-tab-count" id="tabCountNEW">${countNew}</span></a>

        <c:url value="/admin/phan-hoi" var="tabSeenUrl"><c:param name="q" value="${q}"/><c:param name="status" value="SEEN"/></c:url>
        <a href="${tabSeenUrl}" class="admin-tab ${activeTab == 'SEEN' ? 'active' : ''}">Đã xem <span class="admin-tab-count" id="tabCountSEEN">${countSeen}</span></a>

        <c:url value="/admin/phan-hoi" var="tabResolvedUrl"><c:param name="q" value="${q}"/><c:param name="status" value="RESOLVED"/></c:url>
        <a href="${tabResolvedUrl}" class="admin-tab ${activeTab == 'RESOLVED' ? 'active' : ''}">Đã duyệt, hiện công khai <span class="admin-tab-count" id="tabCountRESOLVED">${countResolved}</span></a>
    </nav>

    <form class="fb-search-row" method="get" action="${ctx}/admin/phan-hoi">
        <c:if test="${not empty status}"><input type="hidden" name="status" value="${status}"></c:if>
        <input type="text" class="fb-search-input" name="q" placeholder="Tìm theo tên, SĐT, email hoặc nội dung..." value="${fn:escapeXml(q)}">
        <button type="submit" class="btn btn-primary btn-sm"><i class="fa-solid fa-magnifying-glass"></i> Lọc</button>
        <c:if test="${not empty q}">
            <c:url value="/admin/phan-hoi" var="clearUrl"><c:param name="status" value="${status}"/></c:url>
            <a href="${clearUrl}" class="btn btn-outline btn-sm">Xóa lọc</a>
        </c:if>
    </form>

    <div class="fb-count" id="fbCount">Tìm thấy <b id="fbTotalCount"><c:out value="${totalFeedback}"/></b> phản hồi</div>

    <c:choose>
        <c:when test="${not empty feedbackList}">
            <div id="fbListSection">
            <div class="table-responsive">
                <table class="admin-table" id="feedbackTable">
                    <thead>
                        <tr>
                            <th>Người gửi</th>
                            <th>Đánh giá</th>
                            <th>Nội dung</th>
                            <th>Trạng thái</th>
                            <th>Ngày gửi</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody id="feedbackTbody">
                        <c:forEach var="f" items="${feedbackList}">
                            <tr data-feedback-id="${f.feedbackId}" data-status="${f.status}">
                                <td class="fb-sender-cell">
                                    <b><c:out value="${f.name}"/></b>
                                    <span><c:out value="${f.phone}"/><c:if test="${not empty f.email}"> · <c:out value="${f.email}"/></c:if></span>
                                    <c:if test="${not empty f.userId}">
                                        <span class="fb-registered"><i class="fa-solid fa-circle-check"></i> Khách đã đăng ký</span>
                                    </c:if>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty f.rating}">
                                            <span class="fb-stars" aria-label="${f.rating}/5 sao">
                                                <c:forEach begin="1" end="5" var="i">
                                                    <c:choose>
                                                        <c:when test="${i <= f.rating}"><i class="fa-solid fa-star filled"></i></c:when>
                                                        <c:otherwise><i class="fa-regular fa-star"></i></c:otherwise>
                                                    </c:choose>
                                                </c:forEach>
                                            </span>
                                        </c:when>
                                        <c:otherwise><span class="fb-no-rating">Không đánh giá</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="fb-msg-cell">
                                    <c:choose>
                                        <c:when test="${not empty f.message}">
                                            <div class="fb-msg"><c:out value="${f.message}"/></div>
                                            <button type="button" class="fb-view-more js-view-full"
                                                    data-name="<c:out value="${f.name}"/>"
                                                    data-phone="<c:out value="${f.phone}"/>"
                                                    data-email="<c:out value="${f.email}"/>"
                                                    data-rating="${not empty f.rating ? f.rating : 0}"
                                                    data-date="<fmt:formatDate value="${f.createdAt}" pattern="HH:mm dd/MM/yyyy"/>"
                                                    data-message="<c:out value="${f.message}"/>">Xem đầy đủ</button>
                                        </c:when>
                                        <c:otherwise><span class="fb-msg-empty">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="js-status-cell">
                                    <c:choose>
                                        <c:when test="${f.status == 'NEW'}"><span class="badge badge-NEW">Chờ duyệt</span></c:when>
                                        <c:when test="${f.status == 'SEEN'}"><span class="badge badge-SEEN">Đã xem</span></c:when>
                                        <c:when test="${f.status == 'RESOLVED'}"><span class="badge badge-RESOLVED">Đã duyệt, hiện công khai</span></c:when>
                                        <c:otherwise><span class="badge"><c:out value="${f.status}"/></span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="fb-date"><fmt:formatDate value="${f.createdAt}" pattern="HH:mm dd/MM/yyyy"/></td>
                                <td class="js-actions-cell">
                                    <div class="fb-actions">
                                        <c:choose>
                                            <c:when test="${f.status == 'NEW'}">
                                                <button type="button" class="btn btn-outline btn-sm js-status-btn" data-id="${f.feedbackId}" data-status="SEEN">Đánh dấu đã xem</button>
                                                <button type="button" class="btn btn-primary btn-sm js-status-btn" data-id="${f.feedbackId}" data-status="RESOLVED">Duyệt hiển thị</button>
                                            </c:when>
                                            <c:when test="${f.status == 'SEEN'}">
                                                <button type="button" class="btn btn-primary btn-sm js-status-btn" data-id="${f.feedbackId}" data-status="RESOLVED">Duyệt hiển thị</button>
                                            </c:when>
                                            <c:otherwise>
                                                <button type="button" class="btn btn-outline btn-sm js-status-btn" data-id="${f.feedbackId}" data-status="SEEN">Gỡ khỏi trang chủ</button>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${totalPages > 1}">
                <div class="fb-pager">
                    <c:if test="${currentPage > 1}">
                        <c:url value="/admin/phan-hoi" var="prevUrl">
                            <c:param name="q" value="${q}"/><c:param name="status" value="${status}"/>
                            <c:param name="page" value="${currentPage - 1}"/>
                        </c:url>
                        <a href="${prevUrl}"><i class="fa-solid fa-chevron-left"></i></a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <c:choose>
                            <c:when test="${p == currentPage}"><span class="current">${p}</span></c:when>
                            <c:otherwise>
                                <c:url value="/admin/phan-hoi" var="pageUrl">
                                    <c:param name="q" value="${q}"/><c:param name="status" value="${status}"/>
                                    <c:param name="page" value="${p}"/>
                                </c:url>
                                <a href="${pageUrl}">${p}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <c:url value="/admin/phan-hoi" var="nextUrl">
                            <c:param name="q" value="${q}"/><c:param name="status" value="${status}"/>
                            <c:param name="page" value="${currentPage + 1}"/>
                        </c:url>
                        <a href="${nextUrl}"><i class="fa-solid fa-chevron-right"></i></a>
                    </c:if>
                </div>
            </c:if>
            </div>
        </c:when>
        <c:otherwise>
            <div class="fb-empty">
                <i class="fa-regular fa-folder-open"></i>
                <p>Không tìm thấy phản hồi nào khớp bộ lọc.</p>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- Hiện khi JS xóa hết dòng cuối cùng khỏi tab hiện tại sau khi đổi trạng thái — cùng
         markup/CSS với nhánh rỗng ở trên, chỉ khác là bắt đầu ẩn (server render đủ dữ liệu). -->
    <div class="fb-empty" id="fbEmptyDynamic" hidden>
        <i class="fa-regular fa-folder-open"></i>
        <p>Không còn phản hồi nào khớp bộ lọc hiện tại.</p>
    </div>
</div>

<!-- Modal xem đầy đủ nội dung phản hồi -->
<div class="fb-overlay" id="fbViewOverlay" hidden>
    <div class="fb-modal" role="dialog" aria-modal="true" aria-labelledby="fbViewTitle">
        <h3 id="fbViewTitle">Chi tiết phản hồi</h3>
        <div class="fb-view-grid">
            <div><span class="fb-view-label">Người gửi</span><span id="fbViewName"></span></div>
            <div><span class="fb-view-label">Điện thoại</span><span id="fbViewPhone"></span></div>
            <div><span class="fb-view-label">Email</span><span id="fbViewEmail"></span></div>
            <div><span class="fb-view-label">Đánh giá</span><span id="fbViewRating"></span></div>
            <div><span class="fb-view-label">Ngày gửi</span><span id="fbViewDate"></span></div>
        </div>
        <p class="fb-view-message-label">Nội dung</p>
        <div class="fb-view-message" id="fbViewMessage"></div>
        <div class="fb-modal-actions">
            <button type="button" class="btn btn-outline" id="fbViewDismiss">Đóng</button>
        </div>
    </div>
</div>

<div class="fb-toast" id="fbToast" role="status" aria-live="polite" hidden></div>

<script>
(function () {
    var ctx = '${ctx}';
    var csrf = '${sessionScope._csrf}';
    var ENDPOINT = ctx + '/admin/phan-hoi/cap-nhat-trang-thai';

    var pageCtx = document.getElementById('fbPageContext');
    var curStatus = pageCtx.dataset.status || '';
    var curQ = pageCtx.dataset.q || '';
    var curPage = pageCtx.dataset.page || '';

    var toast = document.getElementById('fbToast');
    var table = document.getElementById('feedbackTable');

    var STATUS_LABEL = { NEW: 'Chờ duyệt', SEEN: 'Đã xem', RESOLVED: 'Đã duyệt, hiện công khai' };

    function showToast(msg, ok) {
        toast.textContent = msg;
        toast.className = 'fb-toast show' + (ok ? ' ok' : '');
        toast.hidden = false;
        clearTimeout(toast._t);
        toast._t = setTimeout(function () { toast.className = 'fb-toast'; }, 3200);
    }

    function openOverlay(el) {
        el.hidden = false;
        requestAnimationFrame(function () { el.classList.add('show'); });
    }
    function closeOverlay(el) {
        el.classList.remove('show');
        setTimeout(function () { el.hidden = true; }, 200);
    }

    // ==================== Modal xem đầy đủ ====================
    var viewOverlay = document.getElementById('fbViewOverlay');

    document.querySelectorAll('.js-view-full').forEach(function (btn) {
        btn.addEventListener('click', function () {
            // Luôn dùng textContent (không innerHTML) — Name/Phone/Email/Message do khách vãng lai
            // tự nhập, phải coi là dữ liệu không đáng tin dù đã được c:out escape khi render ra data-*.
            document.getElementById('fbViewName').textContent = btn.dataset.name || '';
            document.getElementById('fbViewPhone').textContent = btn.dataset.phone || '';
            document.getElementById('fbViewEmail').textContent = btn.dataset.email || '—';
            var rating = parseInt(btn.dataset.rating, 10) || 0;
            document.getElementById('fbViewRating').textContent = rating > 0 ? (rating + '/5 sao') : 'Không đánh giá';
            document.getElementById('fbViewDate').textContent = btn.dataset.date || '';
            document.getElementById('fbViewMessage').textContent = btn.dataset.message || '';
            openOverlay(viewOverlay);
        });
    });
    document.getElementById('fbViewDismiss').addEventListener('click', function () { closeOverlay(viewOverlay); });
    viewOverlay.addEventListener('click', function (e) { if (e.target === viewOverlay) closeOverlay(viewOverlay); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !viewOverlay.hidden) closeOverlay(viewOverlay); });

    // ==================== Đổi trạng thái (AJAX, không reload trang) ====================

    // Số đếm trên tab + tổng số phải theo kịp thao tác AJAX — nếu không, tab "Chờ duyệt" vẫn
    // hiện số cũ và dòng vừa xử lý đứng "lạc" trong tab không còn khớp trạng thái của nó nữa.
    function adjustTabCount(status, delta) {
        var el = document.getElementById('tabCount' + status);
        if (!el) return;
        el.textContent = Math.max(0, (parseInt(el.textContent, 10) || 0) + delta);
    }
    function adjustTotalCount(delta) {
        var el = document.getElementById('fbTotalCount');
        if (!el) return;
        el.textContent = Math.max(0, (parseInt(el.textContent, 10) || 0) + delta);
    }
    function showEmptyStateIfNeeded() {
        var tbody = document.getElementById('feedbackTbody');
        if (tbody && tbody.children.length === 0) {
            var section = document.getElementById('fbListSection');
            var empty = document.getElementById('fbEmptyDynamic');
            if (section) section.hidden = true;
            if (empty) empty.hidden = false;
        }
    }
    // Đang xem tab lọc theo trạng thái (curStatus khác rỗng) và dòng vừa đổi SANG trạng thái
    // khác trạng thái đang lọc -> dòng đó không còn thuộc tab này -> mờ dần rồi gỡ khỏi bảng.
    function removeRow(row) {
        row.classList.add('fb-row-removing');
        var done = false;
        function finish() {
            if (done) return;
            done = true;
            row.remove();
            adjustTotalCount(-1);
            showEmptyStateIfNeeded();
        }
        row.addEventListener('transitionend', finish, { once: true });
        setTimeout(finish, 450); // fallback nếu transitionend không kích hoạt
    }

    function actionsHtmlFor(id, status) {
        if (status === 'NEW') {
            return '<button type="button" class="btn btn-outline btn-sm js-status-btn" data-id="' + id + '" data-status="SEEN">Đánh dấu đã xem</button>'
                + '<button type="button" class="btn btn-primary btn-sm js-status-btn" data-id="' + id + '" data-status="RESOLVED">Duyệt hiển thị</button>';
        }
        if (status === 'SEEN') {
            return '<button type="button" class="btn btn-primary btn-sm js-status-btn" data-id="' + id + '" data-status="RESOLVED">Duyệt hiển thị</button>';
        }
        return '<button type="button" class="btn btn-outline btn-sm js-status-btn" data-id="' + id + '" data-status="SEEN">Gỡ khỏi trang chủ</button>';
    }

    function submitStatus(feedbackId, newStatus) {
        var body = new URLSearchParams();
        body.set('_csrf', csrf);
        body.set('feedbackId', feedbackId);
        body.set('newStatus', newStatus);
        if (curStatus) body.set('status', curStatus);
        if (curQ) body.set('q', curQ);
        if (curPage) body.set('page', curPage);
        return fetch(ENDPOINT, {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body.toString()
        }).then(function (r) { return r.json().then(function (j) { return { ok: r.ok, data: j }; }); });
    }

    // #feedbackTable chỉ tồn tại khi danh sách không rỗng (xem c:choose ở trên).
    if (table) {
        table.addEventListener('click', function (e) {
            var btn = e.target.closest('.js-status-btn');
            if (!btn) return;
            var idNum = parseInt(btn.dataset.id, 10);
            var newStatus = btn.dataset.status;
            if (!idNum || !STATUS_LABEL[newStatus]) return;

            var row = table.querySelector('tr[data-feedback-id="' + idNum + '"]');
            var oldStatus = row ? row.dataset.status : null;
            var actionBtns = row ? row.querySelectorAll('.js-status-btn') : [];
            actionBtns.forEach(function (b) { b.disabled = true; });

            submitStatus(idNum, newStatus).then(function (res) {
                if (res.ok && res.data.success) {
                    if (row) {
                        row.dataset.status = newStatus;
                        if (oldStatus) adjustTabCount(oldStatus, -1);
                        adjustTabCount(newStatus, 1);

                        // Đang lọc theo 1 tab cụ thể và dòng vừa rời khỏi trạng thái đó -> gỡ khỏi
                        // bảng (không còn khớp bộ lọc). Tab "Tất cả" (curStatus rỗng) luôn khớp mọi
                        // trạng thái nên chỉ cập nhật badge/nút tại chỗ, không bao giờ gỡ dòng.
                        if (curStatus && newStatus !== curStatus) {
                            removeRow(row);
                        } else {
                            actionBtns.forEach(function (b) { b.disabled = false; });
                            row.querySelector('.js-status-cell').innerHTML =
                                '<span class="badge badge-' + newStatus + '">' + STATUS_LABEL[newStatus] + '</span>';
                            row.querySelector('.js-actions-cell .fb-actions').innerHTML = actionsHtmlFor(idNum, newStatus);
                        }
                    }
                    showToast(res.data.message, true);
                } else {
                    actionBtns.forEach(function (b) { b.disabled = false; });
                    showToast(res.data.message || 'Không thể cập nhật.', false);
                }
            }).catch(function () {
                actionBtns.forEach(function (b) { b.disabled = false; });
                showToast('Lỗi kết nối, vui lòng thử lại.', false);
            });
        });
    }
})();
</script>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
