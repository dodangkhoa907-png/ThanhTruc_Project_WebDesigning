<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
/* ============================ NHẬT KÝ HÀNH ĐỘNG (chỉ đọc) ============================ */
.al-readonly-note{display:flex;align-items:center;gap:9px;padding:11px 16px;margin-bottom:18px;
    background:rgba(138,154,138,.12);color:var(--admin-text-light);border-radius:12px;
    font-size:13px;font-weight:600}
.al-readonly-note i{color:var(--admin-text-light);font-size:13px}

.al-section-head{font-family:var(--fd);font-size:16px;font-weight:800;margin-bottom:16px;
    color:var(--admin-text);display:flex;align-items:center;gap:9px}
.al-section-head i{color:var(--admin-text-light);font-size:14px}

/* -------- Thanh tìm kiếm chính (luôn hiện) -------- */
.al-search-row{display:flex;gap:10px;align-items:center;margin-bottom:6px}
.al-search-input{flex:1;padding:11px 14px;border:1px solid var(--admin-border);border-radius:10px;
    font-size:14px;font-family:var(--fb);color:var(--admin-text);background:var(--admin-bg)}
.al-search-input:focus{border-color:var(--admin-primary);outline:none;background:#fff}

/* -------- Bộ lọc nâng cao (ẩn mặc định) -------- */
.al-adv summary{cursor:pointer;font-size:12.5px;font-weight:700;color:var(--admin-text-light);
    list-style:none;padding:6px 0;user-select:none;transition:color .15s}
.al-adv summary::-webkit-details-marker{display:none}
.al-adv summary::before{content:"▸";display:inline-block;margin-right:6px;transition:transform .15s;font-size:10px}
.al-adv[open] summary::before{transform:rotate(90deg)}
.al-adv summary:hover{color:var(--admin-text)}
.al-adv-hint{font-weight:500;color:var(--admin-text-light);opacity:.75}
.al-adv-grid{display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end;padding:12px 2px 4px}
.al-adv-grid .f-group{display:flex;flex-direction:column;gap:6px}
.al-adv-grid .f-group label{font-size:12px;font-weight:700;color:var(--admin-text-light)}
.al-adv-grid input,.al-adv-grid select{padding:9px 12px;border:1px solid var(--admin-border);
    border-radius:9px;font-size:13.5px;font-family:var(--fb);color:var(--admin-text);background:var(--admin-bg)}
.al-adv-grid input:focus,.al-adv-grid select:focus{border-color:var(--admin-primary);outline:none;background:#fff}
.al-adv-apply{justify-content:flex-end}

.al-count{color:var(--admin-text-light);font-size:13px;font-weight:600;margin-bottom:14px}

/* -------- Bảng -------- */
.al-action-chip{display:inline-block;font-family:'Courier New',monospace;font-size:11.5px;
    font-weight:700;letter-spacing:.01em;padding:5px 10px;border-radius:7px;
    background:rgba(42,92,56,.08);color:var(--admin-primary);white-space:nowrap}
.al-target{font-size:13px;font-weight:600;color:var(--admin-text);white-space:nowrap}
.al-detail{font-size:13.5px;color:var(--admin-text);max-width:360px}
.al-staff{font-size:13.5px;font-weight:600;color:var(--admin-text)}
.al-staff.is-system{color:var(--admin-text-light);font-weight:500;font-style:italic}
.al-ip{font-size:12px;color:var(--admin-text-light);font-variant-numeric:tabular-nums;white-space:nowrap}
.al-date{color:var(--admin-text-light);font-size:13px;white-space:nowrap}

.al-empty{text-align:center;padding:60px 20px;color:var(--admin-text-light)}
.al-empty i{font-size:40px;opacity:.3;margin-bottom:14px;display:block}

.al-pager{display:flex;justify-content:center;align-items:center;gap:8px;margin-top:22px}
.al-pager a,.al-pager span{min-width:38px;height:38px;display:flex;align-items:center;justify-content:center;
    border-radius:10px;font-weight:700;font-size:13.5px;color:var(--admin-text)}
.al-pager a{background:var(--admin-bg)}
.al-pager a:hover{background:#EAF0E7}
.al-pager span.current{background:var(--admin-primary);color:#fff}
.btn-sm{padding:8px 14px;font-size:12.5px;border-radius:9px}
</style>

<div class="al-readonly-note">
    <i class="fa-solid fa-lock"></i>
    Nhật ký chỉ đọc — không thể chỉnh sửa hoặc xóa, phục vụ tra soát và kiểm toán.
</div>

<div class="card">
    <div class="al-section-head"><i class="fa-solid fa-clock-rotate-left"></i> Nhật ký hành động</div>

    <form class="al-filters" method="get" action="${ctx}/admin/nhat-ky">
        <div class="al-search-row">
            <input type="text" class="al-search-input" name="q"
                   placeholder="Tìm theo hành động, đối tượng, nội dung chi tiết..." value="${fn:escapeXml(q)}">
            <button type="submit" class="btn btn-primary btn-sm"><i class="fa-solid fa-magnifying-glass"></i> Lọc</button>
            <c:if test="${not empty q or not empty staffId or not empty fromDate or not empty toDate}">
                <a href="${ctx}/admin/nhat-ky" class="btn btn-outline btn-sm">Xóa lọc</a>
            </c:if>
        </div>

        <details class="al-adv" ${not empty staffId or not empty fromDate or not empty toDate ? 'open' : ''}>
            <summary>Bộ lọc nâng cao <span class="al-adv-hint">(nhân viên, khoảng ngày...)</span></summary>
            <div class="al-adv-grid">
                <div class="f-group">
                    <label>Nhân viên</label>
                    <select name="staffId">
                        <option value="">Tất cả (kể cả khách/hệ thống)</option>
                        <c:forEach var="s" items="${staffList}">
                            <option value="${s.staffId}" ${staffId == s.staffId ? 'selected' : ''}><c:out value="${s.fullName}"/></option>
                        </c:forEach>
                    </select>
                </div>
                <div class="f-group">
                    <label>Từ ngày</label>
                    <input type="date" name="fromDate" value="${fromDate}">
                </div>
                <div class="f-group">
                    <label>Đến ngày</label>
                    <input type="date" name="toDate" value="${toDate}">
                </div>
                <div class="f-group al-adv-apply">
                    <button type="submit" class="btn btn-outline btn-sm">Áp dụng</button>
                </div>
            </div>
        </details>
    </form>

    <div class="al-count">Tìm thấy <b><c:out value="${totalLogs}"/></b> nhật ký</div>

    <c:choose>
        <c:when test="${not empty logs}">
            <div class="table-responsive">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Thời gian</th>
                            <th>Người thực hiện</th>
                            <th>Hành động</th>
                            <th>Đối tượng</th>
                            <th>Chi tiết</th>
                            <th>Địa chỉ IP</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="log" items="${logs}">
                            <tr>
                                <td class="al-date"><fmt:formatDate value="${log.createdAt}" pattern="HH:mm dd/MM/yyyy"/></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty log.staffName}">
                                            <span class="al-staff"><c:out value="${log.staffName}"/></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="al-staff is-system">Khách hàng / Hệ thống</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td><span class="al-action-chip"><c:out value="${log.action}"/></span></td>
                                <td class="al-target"><c:out value="${log.target}"/></td>
                                <td class="al-detail"><c:out value="${log.detail}"/></td>
                                <td class="al-ip"><c:out value="${log.ipAddress}"/></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${totalPages > 1}">
                <div class="al-pager">
                    <c:if test="${currentPage > 1}">
                        <c:url value="/admin/nhat-ky" var="prevUrl">
                            <c:param name="q" value="${q}"/><c:param name="staffId" value="${staffId}"/>
                            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
                            <c:param name="page" value="${currentPage - 1}"/>
                        </c:url>
                        <a href="${prevUrl}"><i class="fa-solid fa-chevron-left"></i></a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <c:choose>
                            <c:when test="${p == currentPage}"><span class="current">${p}</span></c:when>
                            <c:otherwise>
                                <c:url value="/admin/nhat-ky" var="pageUrl">
                                    <c:param name="q" value="${q}"/><c:param name="staffId" value="${staffId}"/>
                                    <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
                                    <c:param name="page" value="${p}"/>
                                </c:url>
                                <a href="${pageUrl}">${p}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <c:url value="/admin/nhat-ky" var="nextUrl">
                            <c:param name="q" value="${q}"/><c:param name="staffId" value="${staffId}"/>
                            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
                            <c:param name="page" value="${currentPage + 1}"/>
                        </c:url>
                        <a href="${nextUrl}"><i class="fa-solid fa-chevron-right"></i></a>
                    </c:if>
                </div>
            </c:if>
        </c:when>
        <c:otherwise>
            <div class="al-empty">
                <i class="fa-regular fa-folder-open"></i>
                <p>Không tìm thấy nhật ký nào khớp bộ lọc.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
