<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%--
  Fragment độc lập — render nội dung "Lịch sử đơn hàng" (tabs + filter + bảng + phân trang).
  Dùng chung cho:
   1) list.jsp include lúc tải trang đầy đủ lần đầu.
   2) AdminOrderController trả thẳng fragment này (không header/sidebar) khi request có
      header X-Requested-With — cho phép JS thay innerHTML #historySection mà KHÔNG reload
      cả trang, tránh giật/khựng khi đổi tab, phân trang, hoặc lọc.
  KHÔNG đặt <style>/<script> trong file này — chúng chỉ nằm trong list.jsp (nạp 1 lần khi
  tải trang), tránh lặp lại/tràn DOM mỗi lần AJAX thay nội dung.
--%>
<div class="card">
    <div class="ord-section-head"><i class="fa-solid fa-clock-rotate-left"></i> Lịch sử đơn hàng</div>

    <nav class="admin-tabs" aria-label="Lọc nhanh theo trạng thái vòng đời đơn hàng">
        <c:url value="/admin/don-hang" var="tabAllUrl">
            <c:param name="q" value="${q}"/><c:param name="paymentStatus" value="${paymentStatus}"/>
            <c:param name="paymentMethod" value="${paymentMethod}"/>
            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
        </c:url>
        <a href="${tabAllUrl}" class="admin-tab ${activeTab == 'ALL' ? 'active' : ''}">Tất cả <span class="admin-tab-count">${tabCounts.all}</span></a>

        <c:url value="/admin/don-hang" var="tabPendingUrl">
            <c:param name="q" value="${q}"/><c:param name="paymentStatus" value="${paymentStatus}"/>
            <c:param name="paymentMethod" value="${paymentMethod}"/>
            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
            <c:param name="orderStatus" value="PENDING"/>
        </c:url>
        <a href="${tabPendingUrl}" class="admin-tab ${activeTab == 'PENDING' ? 'active' : ''}">Chờ duyệt <span class="admin-tab-count">${tabCounts.pending}</span></a>

        <c:url value="/admin/don-hang" var="tabConfirmedUrl">
            <c:param name="q" value="${q}"/><c:param name="paymentStatus" value="${paymentStatus}"/>
            <c:param name="paymentMethod" value="${paymentMethod}"/>
            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
            <c:param name="orderStatus" value="CONFIRMED"/>
        </c:url>
        <a href="${tabConfirmedUrl}" class="admin-tab ${activeTab == 'CONFIRMED' ? 'active' : ''}">Đã duyệt <span class="admin-tab-count">${tabCounts.confirmed}</span></a>

        <c:url value="/admin/don-hang" var="tabShippingUrl">
            <c:param name="q" value="${q}"/><c:param name="paymentStatus" value="${paymentStatus}"/>
            <c:param name="paymentMethod" value="${paymentMethod}"/>
            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
            <c:param name="orderStatus" value="SHIPPING"/>
        </c:url>
        <a href="${tabShippingUrl}" class="admin-tab ${activeTab == 'SHIPPING' ? 'active' : ''}">Đang vận chuyển <span class="admin-tab-count">${tabCounts.shipping}</span></a>

        <c:url value="/admin/don-hang" var="tabAwaitingUrl">
            <c:param name="q" value="${q}"/><c:param name="paymentStatus" value="${paymentStatus}"/>
            <c:param name="paymentMethod" value="${paymentMethod}"/>
            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
            <c:param name="orderStatus" value="DONE"/><c:param name="confirmState" value="PENDING"/>
        </c:url>
        <a href="${tabAwaitingUrl}" class="admin-tab ${activeTab == 'AWAITING_CONFIRM' ? 'active' : ''}">Chờ xác nhận <span class="admin-tab-count">${tabCounts.awaitingConfirm}</span></a>

        <c:url value="/admin/don-hang" var="tabCompletedUrl">
            <c:param name="q" value="${q}"/><c:param name="paymentStatus" value="${paymentStatus}"/>
            <c:param name="paymentMethod" value="${paymentMethod}"/>
            <c:param name="fromDate" value="${fromDate}"/><c:param name="toDate" value="${toDate}"/>
            <c:param name="orderStatus" value="DONE"/><c:param name="confirmState" value="CONFIRMED"/>
        </c:url>
        <a href="${tabCompletedUrl}" class="admin-tab ${activeTab == 'COMPLETED' ? 'active' : ''}">Thành công <span class="admin-tab-count">${tabCounts.completed}</span></a>
    </nav>

    <form class="ord-filters" method="get" action="${ctx}/admin/don-hang">
        <div class="ord-search-row">
            <input type="text" class="ord-search-input" name="q" placeholder="Tìm theo mã đơn, tên người nhận, SĐT, email..." value="${fn:escapeXml(q)}">
            <button type="submit" class="btn btn-primary btn-sm"><i class="fa-solid fa-magnifying-glass"></i> Lọc</button>
            <c:if test="${not empty q or not empty paymentStatus or not empty paymentMethod or not empty fromDate or not empty toDate or activeTab == 'OTHER'}">
                <a href="${ctx}/admin/don-hang" class="btn btn-outline btn-sm">Xóa lọc</a>
            </c:if>
        </div>

        <details class="ord-adv" ${not empty paymentStatus or not empty paymentMethod or not empty fromDate or not empty toDate or activeTab == 'OTHER' ? 'open' : ''}>
            <summary>Bộ lọc nâng cao <span class="ord-adv-hint">(trạng thái khác, thanh toán, ngày...)</span></summary>
            <div class="ord-adv-grid">
                <div class="f-group">
                    <label>Trạng thái đơn</label>
                    <select name="orderStatus">
                        <option value="">Tất cả (theo tab ở trên)</option>
                        <option value="PENDING" ${orderStatus == 'PENDING' ? 'selected' : ''}>Chờ duyệt</option>
                        <option value="CONFIRMED" ${orderStatus == 'CONFIRMED' ? 'selected' : ''}>Đã duyệt</option>
                        <option value="SHIPPING" ${orderStatus == 'SHIPPING' ? 'selected' : ''}>Đang vận chuyển</option>
                        <option value="DONE" ${orderStatus == 'DONE' ? 'selected' : ''}>Hoàn thành (cả 2 loại)</option>
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
                <div class="f-group ord-adv-apply">
                    <button type="submit" class="btn btn-outline btn-sm">Áp dụng</button>
                </div>
            </div>
        </details>
    </form>

    <div class="ord-count">Tìm thấy <b><c:out value="${totalOrders}"/></b> đơn hàng</div>

    <c:choose>
        <c:when test="${not empty orders}">
            <div class="table-responsive">
                <table class="admin-table" id="historyTable">
                    <thead>
                        <tr>
                            <th>Mã đơn</th>
                            <th>Khách hàng</th>
                            <th>Tổng tiền</th>
                            <th>Thanh toán</th>
                            <th>Trạng thái</th>
                            <th>Ngày đặt</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="o" items="${orders}">
                            <tr data-order-id="${o.orderId}">
                                <td>#${o.orderId}</td>
                                <td class="ord-cust-cell">
                                    <b><c:out value="${not empty o.recipientName ? o.recipientName : o.customerName}"/></b>
                                    <span><c:out value="${not empty o.recipientPhone ? o.recipientPhone : o.phoneNumber}"/></span>
                                </td>
                                <td class="ord-amount"><fmt:formatNumber value="${o.finalAmount}" type="number" groupingUsed="true"/> đ</td>
                                <td>
                                    <span class="pay-ind ${o.paymentStatus == 'PAID' ? 'is-paid' : (o.paymentStatus == 'FAILED' or o.paymentStatus == 'REFUND_PENDING' ? 'is-flag' : '')}">
                                        <span class="pay-dot"></span><c:out value="${o.paymentMethod == 'COD' ? 'COD' : 'PayOS'}"/> · <c:out value="${o.paymentStatusLabel}"/>
                                    </span>
                                </td>
                                <td class="js-status-cell">
                                    <c:choose>
                                        <c:when test="${o.orderStatus == 'DONE' && empty o.receivedConfirmedAt}">
                                            <span class="badge badge-AWAITING_CONFIRM">Chờ xác nhận</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-${o.orderStatus}"><c:out value="${o.orderStatusLabel}"/></span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="ord-date"><fmt:formatDate value="${o.createdAt}" pattern="HH:mm dd/MM/yyyy"/></td>
                                <td>
                                    <div class="ord-row-actions">
                                        <c:if test="${o.orderStatus == 'CONFIRMED'}">
                                            <c:choose>
                                                <c:when test="${not empty activeShippers}">
                                                    <form method="post" action="${ctx}/admin/don-hang/giao-van-chuyen" class="ord-ship-form js-row-action-form">
                                                        <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                                                        <input type="hidden" name="orderId" value="${o.orderId}">
                                                        <select name="handlerId" class="ord-ship-select" required>
                                                            <option value="">-- Người giao --</option>
                                                            <c:forEach var="s" items="${activeShippers}">
                                                                <option value="${s.staffId}"><c:out value="${s.fullName}"/></option>
                                                            </c:forEach>
                                                        </select>
                                                        <button type="submit" class="btn btn-primary btn-sm"><i class="fa-solid fa-truck"></i> Giao vận chuyển</button>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${ctx}/admin/nhan-vien?formOpen=them&amp;role=DELIVERY" class="ord-link-action">Chưa có ai trong đội giao hàng — Thêm nhân viên</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                        <c:if test="${o.orderStatus == 'DONE' && empty o.receivedConfirmedAt}">
                                            <form method="post" action="${ctx}/admin/don-hang/chot-hoan-thanh" class="ord-inline-form js-row-action-form">
                                                <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                                                <input type="hidden" name="orderId" value="${o.orderId}">
                                                <button type="submit" class="btn btn-primary btn-sm"><i class="fa-solid fa-flag-checkered"></i> Chốt hoàn thành</button>
                                            </form>
                                        </c:if>
                                        <a href="${ctx}/admin/don-hang/chi-tiet?id=${o.orderId}" class="ord-link-action">Chi tiết</a>
                                    </div>
                                </td>
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
                            <c:param name="confirmState" value="${param.confirmState}"/>
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
                                    <c:param name="confirmState" value="${param.confirmState}"/>
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
                            <c:param name="confirmState" value="${param.confirmState}"/>
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
