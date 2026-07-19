<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
.pr-filters{display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end;margin-bottom:20px}
.pr-filters .f-group{display:flex;flex-direction:column;gap:6px}
.pr-filters .f-group label{font-size:12px;font-weight:700;color:var(--admin-text-light)}
.pr-filters input,.pr-filters select{padding:10px 13px;border:1.5px solid var(--admin-border);border-radius:10px;font-size:14px;font-family:var(--fb);color:var(--admin-text)}
.pr-filters input:focus,.pr-filters select:focus{border-color:var(--admin-primary);outline:none}
.pr-filters .f-search{flex:1;min-width:220px}
.pr-flash{padding:14px 18px;border-radius:12px;margin-bottom:20px;font-weight:600;font-size:14px}
.pr-flash.success{background:rgba(42,92,56,.1);color:var(--admin-primary)}
.pr-flash.error{background:rgba(217,83,79,.1);color:var(--admin-red)}
.pr-empty{text-align:center;padding:60px 20px;color:var(--admin-text-light)}
.pr-empty i{font-size:40px;opacity:.3;margin-bottom:14px;display:block}
.pr-count{color:var(--admin-text-light);font-size:13px;font-weight:600;margin-bottom:14px;display:flex;justify-content:space-between;align-items:center}
.pr-thumb{width:50px;height:50px;border-radius:10px;object-fit:cover;background:var(--admin-bg);flex:none}
.pr-name-cell{display:flex;align-items:center;gap:12px}
.pr-name-cell .n{font-weight:700}
.pr-name-cell .cat{font-size:12.5px;color:var(--admin-text-light)}
.pr-variants{display:flex;flex-wrap:wrap;gap:6px}
.pr-variants span{background:var(--admin-bg);border-radius:8px;padding:3px 9px;font-size:12.5px;font-weight:700;color:var(--admin-text)}
.pr-actions{display:flex;gap:8px}
.badge-ACTIVE{background:rgba(42,92,56,.12);color:var(--status-done)}
.badge-INACTIVE{background:rgba(138,154,138,.15);color:var(--admin-text-light)}
</style>

<c:if test="${not empty flashSuccess}"><div class="pr-flash success"><c:out value="${flashSuccess}"/></div></c:if>
<c:if test="${not empty flashError}"><div class="pr-flash error"><c:out value="${flashError}"/></div></c:if>

<div class="card">
    <form class="pr-filters" method="get" action="${ctx}/admin/san-pham">
        <div class="f-group f-search">
            <label>Tìm kiếm</label>
            <input type="text" name="q" placeholder="Tên sản phẩm..." value="${fn:escapeXml(q)}">
        </div>
        <div class="f-group">
            <label>Danh mục</label>
            <select name="categoryId">
                <option value="">Tất cả</option>
                <c:forEach var="c" items="${categories}">
                    <option value="${c.categoryId}" ${categoryId == c.categoryId ? 'selected' : ''}><c:out value="${c.name}"/></option>
                </c:forEach>
            </select>
        </div>
        <div class="f-group">
            <label>Trạng thái</label>
            <select name="status">
                <option value="">Tất cả</option>
                <option value="active" ${status == 'active' ? 'selected' : ''}>Đang bán</option>
                <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Đã ẩn</option>
            </select>
        </div>
        <div class="f-group">
            <button type="submit" class="btn btn-primary"><i class="fa-solid fa-magnifying-glass"></i> Lọc</button>
        </div>
        <c:if test="${not empty q or not empty categoryId or not empty status}">
            <div class="f-group">
                <a href="${ctx}/admin/san-pham" class="btn btn-outline">Xóa lọc</a>
            </div>
        </c:if>
    </form>

    <div class="pr-count">
        <span>Tìm thấy <b><c:out value="${totalProducts}"/></b> sản phẩm</span>
        <a href="${ctx}/admin/san-pham/them" class="btn btn-primary"><i class="fa-solid fa-plus"></i> Thêm sản phẩm</a>
    </div>

    <c:choose>
        <c:when test="${not empty products}">
            <div class="table-responsive">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Sản phẩm</th>
                            <th>Size / Giá</th>
                            <th>Trạng thái</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${products}">
                            <tr>
                                <td>
                                    <div class="pr-name-cell">
                                        <c:choose>
                                            <c:when test="${not empty p.imageUrl}">
                                                <img class="pr-thumb" src="${ctx}${p.imageUrl}" alt="">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="pr-thumb"></div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div>
                                            <div class="n"><c:out value="${p.name}"/></div>
                                            <div class="cat"><c:out value="${p.categoryName}"/></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="pr-variants">
                                        <c:forEach var="v" items="${p.variants}">
                                            <span><c:out value="${v.sizeLabel}"/>: <fmt:formatNumber value="${v.price}" type="number" groupingUsed="true"/>đ</span>
                                        </c:forEach>
                                        <c:if test="${empty p.variants}"><span>Chưa có biến thể</span></c:if>
                                    </div>
                                </td>
                                <td><span class="badge badge-${p.active ? 'ACTIVE' : 'INACTIVE'}">${p.active ? 'Đang bán' : 'Đã ẩn'}</span></td>
                                <td>
                                    <div class="pr-actions">
                                        <a href="${ctx}/admin/san-pham/sua?id=${p.productId}" class="btn btn-outline">Sửa</a>
                                        <form method="post" action="${ctx}/admin/san-pham/an-hien"
                                              onsubmit="return confirm('${p.active ? 'Ẩn' : 'Hiện lại'} sản phẩm này?');">
                                            <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                                            <input type="hidden" name="id" value="${p.productId}">
                                            <input type="hidden" name="active" value="${p.active}">
                                            <button type="submit" class="btn ${p.active ? 'btn-danger' : 'btn-primary'}">${p.active ? 'Ẩn' : 'Hiện'}</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <div class="pr-empty">
                <i class="fa-regular fa-folder-open"></i>
                <p>Không tìm thấy sản phẩm nào khớp bộ lọc.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
