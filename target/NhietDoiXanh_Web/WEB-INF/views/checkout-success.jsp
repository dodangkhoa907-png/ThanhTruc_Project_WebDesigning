<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt Hàng Thành Công — Nhiệt Đới Xanh</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=${initParam.assetVer}">
</head>

<body class="shop-page-body">

    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>

    <section class="section" style="padding-top:130px;">
        <div class="container">
            <div class="success-page-wrap">
                <div class="success-icon"><i class="fa-solid fa-check"></i></div>
                <div class="success-title">Đặt Hàng Thành Công!</div>
                <div class="success-subtitle">
                    Cảm ơn bạn đã mua sắm tại Nhiệt Đới Xanh. Chúng tôi sẽ liên hệ để xác nhận đơn hàng sớm nhất.
                </div>

                <div class="success-card">
                    <div class="success-row">
                        <span class="success-row-label">Mã đơn hàng</span>
                        <span class="success-row-value">#<c:out value="${order.orderId}"/></span>
                    </div>
                    <div class="success-row">
                        <span class="success-row-label">Người nhận</span>
                        <span class="success-row-value"><c:out value="${order.recipientName}"/></span>
                    </div>
                    <div class="success-row">
                        <span class="success-row-label">Số điện thoại</span>
                        <span class="success-row-value"><c:out value="${order.recipientPhone}"/></span>
                    </div>
                    <div class="success-row">
                        <span class="success-row-label">Địa chỉ giao hàng</span>
                        <span class="success-row-value"><c:out value="${order.shippingAddress}"/></span>
                    </div>
                    <c:if test="${not empty order.orderNote}">
                        <div class="success-row">
                            <span class="success-row-label">Ghi chú</span>
                            <span class="success-row-value"><c:out value="${order.orderNote}"/></span>
                        </div>
                    </c:if>
                    <div class="success-row">
                        <span class="success-row-label">Phương thức thanh toán</span>
                        <span class="success-row-value">Tiền mặt khi nhận hàng (COD)</span>
                    </div>
                    <div class="success-row">
                        <span class="success-row-label">Trạng thái đơn hàng</span>
                        <span class="success-row-value"><span class="success-status-badge"><c:out value="${orderStatusLabel}"/></span></span>
                    </div>
                    <div class="success-row">
                        <span class="success-row-label">Trạng thái thanh toán</span>
                        <span class="success-row-value"><span class="success-status-badge is-unpaid"><c:out value="${paymentStatusLabel}"/></span></span>
                    </div>
                    <div class="success-row">
                        <span class="success-row-label">Tổng thanh toán</span>
                        <span class="success-row-value is-total"><fmt:formatNumber value="${order.finalAmount}" type="number" groupingUsed="true"/>đ</span>
                    </div>
                </div>

                <c:if test="${not empty orderItems}">
                    <div class="success-card">
                        <c:forEach var="item" items="${orderItems}" varStatus="st">
                            <div class="success-row">
                                <span class="success-row-label">
                                    <c:out value="${item.productName}"/>
                                    <c:if test="${not empty item.size}"> (<c:out value="${item.size}"/>)</c:if>
                                    × ${item.quantity}
                                </span>
                                <span class="success-row-value"><fmt:formatNumber value="${item.subTotal}" type="number" groupingUsed="true"/>đ</span>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>

                <div class="success-actions">
                    <a href="${pageContext.request.contextPath}/checkout/success?orderId=${order.orderId}" class="btn-shop btn-shop-outline">
                        <i class="fa-solid fa-receipt"></i> Xem Đơn Hàng
                    </a>
                    <a href="${pageContext.request.contextPath}/san-pham" class="btn-shop btn-shop-primary">
                        <i class="fa-solid fa-basket-shopping"></i> Tiếp Tục Mua Sắm
                    </a>
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
    </script>
</body>
</html>
