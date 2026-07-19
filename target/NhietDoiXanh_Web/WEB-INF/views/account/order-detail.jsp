<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Hàng #${order.orderId} — Nhiệt Đới Xanh</title>
    <meta name="csrf-token" content="${sessionScope._csrf}">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/account.css?v=${initParam.assetVer}">
</head>

<body class="shop-page-body">

    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>

    <section class="section" style="padding-top:130px;">
        <div class="container">

            <a href="${pageContext.request.contextPath}/account/orders" class="cart-continue-link" style="margin-bottom:16px;display:inline-flex;">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách đơn hàng
            </a>

            <c:if test="${not empty flashSuccess}"><div class="account-flash success"><c:out value="${flashSuccess}"/></div></c:if>
            <c:if test="${not empty flashError}"><div class="account-flash error"><c:out value="${flashError}"/></div></c:if>

            <div class="account-page-header">
                <div class="account-page-title">Đơn Hàng #${order.orderId}</div>
                <div class="account-page-subtitle">Chi tiết và trạng thái đơn hàng của bạn</div>
            </div>

            <div class="account-shell">
                <%@ include file="/WEB-INF/views/common/account-sidebar.jsp" %>

                <div class="account-detail-grid">
                    <div>
                        <div class="account-card">
                            <div class="account-card-title">
                                <span><i class="fa-solid fa-receipt"></i> Thông tin đơn hàng</span>
                                <span class="acc-badge acc-badge-${order.orderStatus}" id="orderStatusBadge"><c:out value="${order.orderStatusLabel}"/></span>
                            </div>

                            <c:if test="${not empty order.cancelReason}">
                                <div class="account-cancel-note">
                                    <strong>Lý do hủy:</strong> <c:out value="${order.cancelReason}"/>
                                    <c:if test="${not empty order.cancelledAt}"> — <fmt:formatDate value="${order.cancelledAt}" pattern="HH:mm dd/MM/yyyy"/></c:if>
                                </div>
                            </c:if>

                            <dl class="account-kv">
                                <dt>Người nhận</dt>
                                <dd><c:out value="${not empty order.recipientName ? order.recipientName : order.customerName}"/></dd>
                                <dt>Số điện thoại</dt>
                                <dd><c:out value="${not empty order.recipientPhone ? order.recipientPhone : order.phoneNumber}"/></dd>
                                <dt>Địa chỉ giao hàng</dt>
                                <dd><c:out value="${order.shippingAddress}"/></dd>
                                <c:if test="${not empty order.orderNote}">
                                    <dt>Ghi chú</dt>
                                    <dd><c:out value="${order.orderNote}"/></dd>
                                </c:if>
                                <dt>Phương thức TT</dt>
                                <dd>${order.paymentMethod == 'COD' ? 'Tiền mặt khi nhận hàng (COD)' : 'PayOS'}</dd>
                                <dt>Trạng thái TT</dt>
                                <dd><span class="acc-badge acc-badge-${order.paymentStatus}" id="paymentStatusBadge"><c:out value="${order.paymentStatusLabel}"/></span></dd>
                                <dt>Ngày đặt</dt>
                                <dd><fmt:formatDate value="${order.createdAt}" pattern="HH:mm dd/MM/yyyy"/></dd>
                            </dl>
                        </div>

                        <div class="account-card">
                            <div class="account-card-title"><span><i class="fa-solid fa-basket-shopping"></i> Sản phẩm</span></div>
                            <c:forEach var="item" items="${orderItems}">
                                <div class="account-detail-item">
                                    <div>
                                        <div class="name"><c:out value="${item.productName}"/></div>
                                        <div class="meta">Size <c:out value="${item.size}"/> · SL: ${item.quantity} × <fmt:formatNumber value="${item.unitPrice}" type="number" groupingUsed="true"/>đ</div>
                                    </div>
                                    <div><fmt:formatNumber value="${item.subTotal}" type="number" groupingUsed="true"/>đ</div>
                                </div>
                            </c:forEach>
                            <div class="account-detail-total">
                                <span>Tổng thanh toán</span>
                                <span><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/>đ</span>
                            </div>
                        </div>

                        <div class="account-card">
                            <div class="account-card-title"><span><i class="fa-solid fa-timeline"></i> Timeline trạng thái</span></div>
                            <ul class="account-timeline">
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
                                            <span><fmt:formatDate value="${log.createdAt}" pattern="HH:mm dd/MM/yyyy"/></span>
                                        </div>
                                    </li>
                                </c:forEach>
                            </ul>
                        </div>
                    </div>

                    <div>
                        <div class="account-card">
                            <div class="account-card-title"><span><i class="fa-solid fa-gear"></i> Thao tác</span></div>
                            <c:choose>
                                <c:when test="${canCancel}">
                                    <form class="account-cancel-form" method="post" action="${pageContext.request.contextPath}/account/order/cancel"
                                          onsubmit="return confirm('Xác nhận hủy đơn #${order.orderId}?');">
                                        <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                                        <input type="hidden" name="orderId" value="${order.orderId}">
                                        <input type="hidden" name="returnTo" value="detail">
                                        <textarea name="cancelReason" maxlength="500" placeholder="Lý do hủy đơn (bắt buộc)" required></textarea>
                                        <button type="submit" class="btn-shop btn-shop-outline" style="border-color:#b44242;color:#b44242;">
                                            <i class="fa-solid fa-ban"></i> Hủy đơn hàng
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <p style="color:var(--text-muted);font-size:0.86rem">
                                        Đơn hàng ở trạng thái hiện tại không thể tự hủy. Liên hệ với chúng tôi nếu bạn cần hỗ trợ.
                                    </p>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 50));
        navbar.classList.add('scrolled');
        const navToggle = document.getElementById('navToggle');
        const navLinks = document.getElementById('navLinks');
        navToggle.addEventListener('click', () => navLinks.classList.toggle('active'));

        // Cập nhật trạng thái gần-realtime bằng cách polling nhẹ mỗi 20s — không cần WebSocket.
        (function pollOrderStatus() {
            const orderId = ${order.orderId};
            const ctx = '${pageContext.request.contextPath}';
            const statusBadge = document.getElementById('orderStatusBadge');
            const paymentBadge = document.getElementById('paymentStatusBadge');
            if (!statusBadge || !paymentBadge) return;

            setInterval(() => {
                fetch(ctx + '/account/orders/status?id=' + orderId, { headers: { 'Accept': 'application/json' } })
                    .then(r => r.ok ? r.json() : null)
                    .then(data => {
                        if (!data || !data.success) return;
                        if (statusBadge.textContent !== data.orderStatusLabel) {
                            statusBadge.textContent = data.orderStatusLabel;
                            statusBadge.className = 'acc-badge acc-badge-' + data.orderStatus;
                        }
                        if (paymentBadge.textContent !== data.paymentStatusLabel) {
                            paymentBadge.textContent = data.paymentStatusLabel;
                            paymentBadge.className = 'acc-badge acc-badge-' + data.paymentStatus;
                        }
                    })
                    .catch(() => {});
            }, 20000);
        })();
    </script>
</body>
</html>
