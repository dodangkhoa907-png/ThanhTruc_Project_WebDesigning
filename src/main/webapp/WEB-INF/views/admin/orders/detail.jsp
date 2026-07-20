<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<!-- Dùng cdnjs (đã whitelist sẵn trong CSP của SecurityHeadersFilter — xem checkout.jsp) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>

<style>
.od-map{width:100%;height:240px;border-radius:14px;border:1.5px solid var(--admin-border);overflow:hidden;margin-top:14px}
.od-back{display:inline-flex;align-items:center;gap:8px;color:var(--admin-text-light);font-weight:700;font-size:13.5px;margin-bottom:16px}
.od-back:hover{color:var(--admin-primary)}
.od-grid{display:grid;grid-template-columns:2fr 1fr;gap:22px;align-items:start}
@media(max-width:1100px){.od-grid{grid-template-columns:1fr}}
.od-flash{padding:14px 18px;border-radius:12px;margin-bottom:20px;font-weight:600;font-size:14px}
.od-flash.success{background:rgba(42,92,56,.1);color:var(--admin-primary)}
.od-flash.error{background:rgba(217,83,79,.1);color:var(--admin-red)}
.od-section-title{font-family:var(--fd);font-size:16px;margin-bottom:16px}
.od-kv{display:grid;grid-template-columns:150px 1fr;gap:10px 14px;font-size:14.5px}
.od-kv dt{color:var(--admin-text-light);font-weight:600}
.od-kv dd{font-weight:600}
.od-badges{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:18px}
.od-item{display:flex;justify-content:space-between;align-items:center;padding:12px 0;border-bottom:1px solid var(--admin-border)}
.od-item:last-child{border-bottom:none}
.od-item .name{font-weight:700}
.od-item .meta{color:var(--admin-text-light);font-size:13px}
.od-total{display:flex;justify-content:space-between;font-weight:800;font-size:16px;padding-top:14px}
.od-actions{display:flex;flex-direction:column;gap:10px}
.od-actions form{display:flex;flex-direction:column;gap:8px}
.od-actions textarea{width:100%;padding:10px 12px;border:1.5px solid var(--admin-border);border-radius:10px;font-family:var(--fb);font-size:14px;resize:vertical;min-height:64px}
.od-actions select{width:100%;padding:10px 12px;border:1.5px solid var(--admin-border);border-radius:10px;font-family:var(--fb);font-size:14px;color:var(--admin-text);background:var(--admin-bg)}
.od-actions select:focus{border-color:var(--admin-primary);outline:none;background:#fff}
.od-timeline{list-style:none;display:flex;flex-direction:column;gap:16px}
.od-timeline li{display:flex;gap:12px}
.od-timeline .dot{width:10px;height:10px;border-radius:50%;background:var(--admin-primary);margin-top:6px;flex:none}
.od-timeline .tl-body b{display:block;font-size:14px}
.od-timeline .tl-body span{font-size:12.5px;color:var(--admin-text-light)}
.od-cancel-note{background:rgba(217,83,79,.08);border-radius:12px;padding:14px 16px;font-size:13.5px;color:var(--admin-red);margin-bottom:18px}
</style>

<a class="od-back" href="${ctx}/admin/don-hang"><i class="fa-solid fa-arrow-left"></i> Quay lại danh sách đơn hàng</a>

<c:if test="${not empty flashSuccess}"><div class="od-flash success"><c:out value="${flashSuccess}"/></div></c:if>
<c:if test="${not empty flashError}"><div class="od-flash error"><c:out value="${flashError}"/></div></c:if>

<div class="od-grid">
    <div>
        <div class="card">
            <h3 class="od-section-title">Đơn hàng #${order.orderId}</h3>
            <div class="od-badges">
                <span class="badge badge-${order.orderStatus}"><c:out value="${order.orderStatusLabel}"/></span>
                <span class="badge badge-${order.paymentStatus}"><c:out value="${order.paymentStatusLabel}"/></span>
            </div>

            <c:if test="${not empty order.cancelReason}">
                <div class="od-cancel-note">
                    <strong>Lý do hủy:</strong> <c:out value="${order.cancelReason}"/>
                    <c:if test="${not empty order.cancelledAt}"> — <fmt:formatDate value="${order.cancelledAt}" pattern="HH:mm dd/MM/yyyy"/></c:if>
                </div>
            </c:if>

            <dl class="od-kv">
                <dt>Khách đặt hàng</dt>
                <dd>
                    <c:choose>
                        <c:when test="${not empty order.userId}">
                            <c:out value="${order.customerName}"/>
                            <c:if test="${not empty order.userEmail}"> (<c:out value="${order.userEmail}"/>)</c:if>
                        </c:when>
                        <c:otherwise>Khách vãng lai — <c:out value="${order.customerName}"/></c:otherwise>
                    </c:choose>
                </dd>
                <dt>Người nhận</dt>
                <dd><c:out value="${not empty order.recipientName ? order.recipientName : order.customerName}"/></dd>
                <dt>Số điện thoại</dt>
                <dd><c:out value="${not empty order.recipientPhone ? order.recipientPhone : order.phoneNumber}"/></dd>
                <dt>Địa chỉ giao hàng</dt>
                <dd><c:out value="${order.shippingAddress}"/></dd>
                <c:if test="${not empty order.shippingLatitude and not empty order.shippingLongitude}">
                    <dt>Tọa độ GPS</dt>
                    <dd>
                        <a href="https://www.google.com/maps?q=${order.shippingLatitude},${order.shippingLongitude}" target="_blank" rel="noopener">
                            <c:out value="${order.shippingLatitude}"/>, <c:out value="${order.shippingLongitude}"/>
                        </a>
                    </dd>
                </c:if>
                <c:if test="${not empty order.orderNote}">
                    <dt>Ghi chú</dt>
                    <dd><c:out value="${order.orderNote}"/></dd>
                </c:if>
                <dt>Phương thức TT</dt>
                <dd>${order.paymentMethod == 'COD' ? 'Tiền mặt khi nhận hàng (COD)' : 'PayOS'}</dd>
                <dt>Nhân viên xử lý</dt>
                <dd><c:out value="${not empty order.handledByName ? order.handledByName : 'Chưa phân công'}"/></dd>
                <dt>Ngày tạo</dt>
                <dd><fmt:formatDate value="${order.createdAt}" pattern="HH:mm dd/MM/yyyy"/></dd>
                <c:if test="${not empty order.statusUpdatedAt}">
                    <dt>Cập nhật lần cuối</dt>
                    <dd><fmt:formatDate value="${order.statusUpdatedAt}" pattern="HH:mm dd/MM/yyyy"/></dd>
                </c:if>
            </dl>

            <c:if test="${not empty order.shippingLatitude and not empty order.shippingLongitude}">
                <div class="od-map" id="odMap"
                     data-lat="${order.shippingLatitude}" data-lng="${order.shippingLongitude}"
                     data-addr="${fn:escapeXml(order.shippingAddress)}"></div>
            </c:if>
        </div>

        <div class="card">
            <h3 class="od-section-title">Sản phẩm trong đơn</h3>
            <c:forEach var="item" items="${order.items}">
                <div class="od-item">
                    <div>
                        <div class="name"><c:out value="${item.productName}"/></div>
                        <div class="meta">Size <c:out value="${item.size}"/> · SL: ${item.quantity} × <fmt:formatNumber value="${item.unitPrice}" type="number" groupingUsed="true"/>đ</div>
                    </div>
                    <div><fmt:formatNumber value="${item.subTotal}" type="number" groupingUsed="true"/>đ</div>
                </div>
            </c:forEach>
            <div class="od-total">
                <span>Tổng thanh toán</span>
                <span><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/>đ</span>
            </div>
        </div>

        <div class="card">
            <h3 class="od-section-title">Timeline trạng thái</h3>
            <ul class="od-timeline">
                <li>
                    <span class="dot"></span>
                    <div class="tl-body">
                        <b>Đơn hàng được tạo</b>
                        <span><fmt:formatDate value="${order.createdAt}" pattern="HH:mm dd/MM/yyyy"/></span>
                    </div>
                </li>
                <c:forEach var="log" items="${auditTrail}">
                    <li>
                        <span class="dot"></span>
                        <div class="tl-body">
                            <b><c:out value="${log.detail}"/></b>
                            <span>
                                <fmt:formatDate value="${log.createdAt}" pattern="HH:mm dd/MM/yyyy"/>
                                — <c:out value="${not empty log.staffName ? log.staffName : 'Hệ thống'}"/>
                            </span>
                        </div>
                    </li>
                </c:forEach>
            </ul>
        </div>
    </div>

    <div>
        <div class="card od-actions">
            <h3 class="od-section-title">Thao tác</h3>

            <c:if test="${canConfirm}">
                <form method="post" action="${ctx}/admin/don-hang/cap-nhat-trang-thai">
                    <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                    <input type="hidden" name="orderId" value="${order.orderId}">
                    <input type="hidden" name="newStatus" value="CONFIRMED">
                    <input type="hidden" name="returnTo" value="detail">
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-check"></i> Xác nhận đơn</button>
                </form>
            </c:if>

            <c:if test="${canShip}">
                <c:choose>
                    <c:when test="${not empty activeShippers}">
                        <form method="post" action="${ctx}/admin/don-hang/giao-van-chuyen" class="od-ship-form">
                            <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                            <input type="hidden" name="orderId" value="${order.orderId}">
                            <input type="hidden" name="returnTo" value="detail">
                            <select name="handlerId" required>
                                <option value="">-- Người giao --</option>
                                <c:forEach var="s" items="${activeShippers}">
                                    <option value="${s.staffId}"><c:out value="${s.fullName}"/></option>
                                </c:forEach>
                            </select>
                            <button type="submit" class="btn btn-primary"><i class="fa-solid fa-truck"></i> Chuyển đang giao</button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <a href="${ctx}/admin/nhan-vien?formOpen=them&amp;role=DELIVERY" class="od-back">Chưa có ai trong đội giao hàng — Thêm nhân viên</a>
                    </c:otherwise>
                </c:choose>
            </c:if>

            <c:if test="${canDone}">
                <form method="post" action="${ctx}/admin/don-hang/cap-nhat-trang-thai"
                      onsubmit="return confirm('Xác nhận đơn #${order.orderId} đã giao thành công tới khách hàng?\n\nThao tác này sẽ chuyển đơn sang trạng thái Hoàn thành, không thể quay lại Đang giao.');">
                    <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                    <input type="hidden" name="orderId" value="${order.orderId}">
                    <input type="hidden" name="newStatus" value="DONE">
                    <input type="hidden" name="returnTo" value="detail">
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-circle-check"></i> Hoàn thành đơn</button>
                </form>
            </c:if>

            <c:if test="${canReviewCancelRequest}">
                <form method="post" action="${ctx}/admin/don-hang/duyet-huy">
                    <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                    <input type="hidden" name="orderId" value="${order.orderId}">
                    <input type="hidden" name="returnTo" value="detail">
                    <button type="submit" class="btn btn-danger"><i class="fa-solid fa-check-double"></i> Duyệt yêu cầu hủy</button>
                </form>
                <form method="post" action="${ctx}/admin/don-hang/tu-choi-huy">
                    <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                    <input type="hidden" name="orderId" value="${order.orderId}">
                    <input type="hidden" name="returnTo" value="detail">
                    <button type="submit" class="btn btn-outline"><i class="fa-solid fa-xmark"></i> Từ chối yêu cầu hủy</button>
                </form>
            </c:if>

            <c:if test="${canCancelDirect}">
                <form method="post" action="${ctx}/admin/don-hang/cap-nhat-trang-thai" onsubmit="return confirm('Xác nhận hủy đơn #${order.orderId}?');">
                    <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                    <input type="hidden" name="orderId" value="${order.orderId}">
                    <input type="hidden" name="newStatus" value="CANCELLED">
                    <input type="hidden" name="returnTo" value="detail">
                    <textarea name="reason" placeholder="Lý do hủy đơn (bắt buộc)" required></textarea>
                    <button type="submit" class="btn btn-danger"><i class="fa-solid fa-ban"></i> Hủy đơn</button>
                </form>
            </c:if>

            <c:if test="${!canConfirm and !canShip and !canDone and !canCancelDirect and !canReviewCancelRequest}">
                <p style="color:var(--admin-text-light);font-size:13.5px">Đơn hàng đã ở trạng thái cuối, không còn thao tác nào khả dụng.</p>
            </c:if>
        </div>
    </div>
</div>

<script>
(function () {
    var el = document.getElementById('odMap');
    if (!el || typeof L === 'undefined') return;
    var lat = parseFloat(el.dataset.lat);
    var lng = parseFloat(el.dataset.lng);
    if (isNaN(lat) || isNaN(lng)) return;

    var pin = L.divIcon({
        className: '',
        html: '<div style="position:relative;width:26px;height:39px;filter:drop-shadow(0 3px 4px rgba(0,0,0,.35))">' +
              '<svg width="26" height="39" viewBox="0 0 30 45" xmlns="http://www.w3.org/2000/svg">' +
              '<path d="M15 0C6.7 0 0 6.7 0 15c0 11.25 15 30 15 30s15-18.75 15-30C30 6.7 23.3 0 15 0z" fill="#2A5C38"/>' +
              '<circle cx="15" cy="14" r="6" fill="#fff"/></svg></div>',
        iconSize: [26, 39],
        iconAnchor: [13, 39],
        popupAnchor: [0, -35]
    });

    var map = L.map('odMap', { scrollWheelZoom: false }).setView([lat, lng], 16);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '&copy; OpenStreetMap'
    }).addTo(map);
    // Chỉ xem, không kéo-thả — sửa vị trí giao hàng phải qua checkout/sổ địa chỉ của khách.
    L.marker([lat, lng], { icon: pin, draggable: false })
        .addTo(map)
        .bindPopup('<b>Địa chỉ giao hàng</b><br><small>' + (el.dataset.addr || '') + '</small>');
})();
</script>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
