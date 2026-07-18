<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
.ord-filters{display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end;margin-bottom:20px}
.ord-filters .f-group{display:flex;flex-direction:column;gap:6px}
.ord-filters .f-group label{font-size:12px;font-weight:700;color:var(--admin-text-light)}
.ord-filters input,.ord-filters select{padding:10px 13px;border:1.5px solid var(--admin-border);border-radius:10px;font-size:14px;font-family:var(--fb);color:var(--admin-text)}
.ord-filters input:focus,.ord-filters select:focus{border-color:var(--admin-primary);outline:none}
.ord-filters .f-search{flex:1;min-width:220px}
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
.ord-pager span.ellipsis{color:var(--admin-text-light);font-weight:400}
.ord-count{color:var(--admin-text-light);font-size:13px;font-weight:600;margin-bottom:14px}
</style>

<c:if test="${not empty flashSuccess}"><div class="ord-flash success"><c:out value="${flashSuccess}"/></div></c:if>
<c:if test="${not empty flashError}"><div class="ord-flash error"><c:out value="${flashError}"/></div></c:if>

<div class="card">
    <form class="ord-filters" method="get" action="${ctx}/admin/don-hang">
        <div class="f-group f-search">
            <label>Tìm kiếm</label>
            <input type="text" name="q" placeholder="Mã đơn, tên người nhận, SĐT, email..." value="${fn:escapeXml(q)}">
        </div>
        <div class="f-group">
            <label>Trạng thái đơn</label>
            <select name="orderStatus">
                <option value="">Tất cả</option>
                <option value="PENDING" ${orderStatus == 'PENDING' ? 'selected' : ''}>Chờ xác nhận</option>
                <option value="CONFIRMED" ${orderStatus == 'CONFIRMED' ? 'selected' : ''}>Đang xử lý</option>
                <option value="SHIPPING" ${orderStatus == 'SHIPPING' ? 'selected' : ''}>Đang giao</option>
                <option value="DONE" ${orderStatus == 'DONE' ? 'selected' : ''}>Hoàn thành</option>
                <option value="PENDING_CANCEL" ${orderStatus == 'PENDING_CANCEL' ? 'selected' : ''}>Chờ duyệt hủy</option>
                <option value="CANCELLED" ${orderStatus == 'CANCELLED' ? 'selected' : ''}>Đã hủy</option>
            </select>
        </div>
        <div class="f-group">
            <label>Thanh toán</label>
            <select name="paymentStatus">
                <option value="">Tất cả</option>
                <option value="UNPAID" ${paymentStatus == 'UNPAID' ? 'selected' : ''}>Chưa thanh toán</option>
                <option value="PENDING" ${paymentStatus == 'PENDING' ? 'selected' : ''}>Chờ thanh toán</option>
                <option value="PAID" ${paymentStatus == 'PAID' ? 'selected' : ''}>Đã thanh toán</option>
                <option value="FAILED" ${paymentStatus == 'FAILED' ? 'selected' : ''}>Thất bại</option>
                <option value="CANCELLED" ${paymentStatus == 'CANCELLED' ? 'selected' : ''}>Đã hủy TT</option>
                <option value="REFUND_PENDING" ${paymentStatus == 'REFUND_PENDING' ? 'selected' : ''}>Chờ hoàn tiền</option>
            </select>
        </div>
        <div class="f-group">
            <label>Phương thức</label>
            <select name="paymentMethod">
                <option value="">Tất cả</option>
                <option value="COD" ${paymentMethod == 'COD' ? 'selected' : ''}>COD</option>
                <option value="PAYOS" ${paymentMethod == 'PAYOS' ? 'selected' : ''}>PayOS</option>
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
        <div class="f-group">
            <button type="submit" class="btn btn-primary"><i class="fa-solid fa-magnifying-glass"></i> Lọc</button>
        </div>
        <c:if test="${not empty q or not empty orderStatus or not empty paymentStatus or not empty paymentMethod or not empty fromDate or not empty toDate}">
            <div class="f-group">
                <a href="${ctx}/admin/don-hang" class="btn btn-outline">Xóa lọc</a>
            </div>
        </c:if>
    </form>

    <div class="ord-count">Tìm thấy <b><c:out value="${totalOrders}"/></b> đơn hàng</div>

    <c:choose>
        <c:when test="${not empty orders}">
            <div class="table-responsive">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Người nhận</th>
                            <th>SĐT</th>
                            <th>Tổng tiền</th>
                            <th>Thanh toán</th>
                            <th>TT Thanh toán</th>
                            <th>TT Đơn hàng</th>
                            <th>Ngày đặt</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="o" items="${orders}">
                            <tr>
                                <td>#${o.orderId}</td>
                                <td><c:out value="${not empty o.recipientName ? o.recipientName : o.customerName}"/></td>
                                <td><c:out value="${not empty o.recipientPhone ? o.recipientPhone : o.phoneNumber}"/></td>
                                <td><fmt:formatNumber value="${o.finalAmount}" type="number" groupingUsed="true"/> đ</td>
                                <td>${o.paymentMethod == 'COD' ? 'COD' : 'PayOS'}</td>
                                <td><span class="badge badge-${o.paymentStatus}"><c:out value="${o.paymentStatusLabel}"/></span></td>
                                <td><span class="badge badge-${o.orderStatus}"><c:out value="${o.orderStatusLabel}"/></span></td>
                                <td><fmt:formatDate value="${o.createdAt}" pattern="HH:mm dd/MM/yyyy"/></td>
                                <td><a href="${ctx}/admin/don-hang/chi-tiet?id=${o.orderId}" class="btn btn-outline">Xem chi tiết</a></td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <c:if test="${totalPages > 1}">
                <div class="ord-pager">
                    <c:if test="${currentPage > 1}">
                        <c:url value="/admin/don-hang" var="prevUrl">
                            <c:param name="q" value="${q}"/><c:param name="orderStatus" value="${orderStatus}"/>
                            <c:param name="paymentStatus" value="${paymentStatus}"/><c:param name="paymentMethod" value="${paymentMethod}"/>
                            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
                            <c:param name="page" value="${currentPage - 1}"/>
                        </c:url>
                        <a href="${prevUrl}"><i class="fa-solid fa-chevron-left"></i></a>
                    </c:if>
                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <c:choose>
                            <c:when test="${p == currentPage}"><span class="current">${p}</span></c:when>
                            <c:otherwise>
                                <c:url value="/admin/don-hang" var="pageUrl">
                                    <c:param name="q" value="${q}"/><c:param name="orderStatus" value="${orderStatus}"/>
                                    <c:param name="paymentStatus" value="${paymentStatus}"/><c:param name="paymentMethod" value="${paymentMethod}"/>
                                    <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
                                    <c:param name="page" value="${p}"/>
                                </c:url>
                                <a href="${pageUrl}">${p}</a>
                            </c:otherwise>
                        </c:choose>
                    </c:forEach>
                    <c:if test="${currentPage < totalPages}">
                        <c:url value="/admin/don-hang" var="nextUrl">
                            <c:param name="q" value="${q}"/><c:param name="orderStatus" value="${orderStatus}"/>
                            <c:param name="paymentStatus" value="${paymentStatus}"/><c:param name="paymentMethod" value="${paymentMethod}"/>
                            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
                            <c:param name="page" value="${currentPage + 1}"/>
                        </c:url>
                        <a href="${nextUrl}"><i class="fa-solid fa-chevron-right"></i></a>
                    </c:if>
                </div>
            </c:if>
        </c:when>
        <c:otherwise>
            <div class="ord-empty">
                <i class="fa-regular fa-folder-open"></i>
                <p>Không tìm thấy đơn hàng nào khớp bộ lọc.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
