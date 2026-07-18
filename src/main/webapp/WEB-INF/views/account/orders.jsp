<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn Hàng Của Tôi — Nhiệt Đới Xanh</title>
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

            <c:if test="${not empty flashSuccess}"><div class="account-flash success"><c:out value="${flashSuccess}"/></div></c:if>
            <c:if test="${not empty flashError}"><div class="account-flash error"><c:out value="${flashError}"/></div></c:if>

            <div class="account-page-header">
                <div class="account-page-title">Đơn Hàng Của Tôi</div>
                <div class="account-page-subtitle">Theo dõi và quản lý các đơn hàng bạn đã đặt</div>
            </div>

            <div class="account-shell">
                <%@ include file="/WEB-INF/views/common/account-sidebar.jsp" %>

                <div>
                    <div class="account-card">
                        <form class="account-filter-bar" method="get" action="${pageContext.request.contextPath}/account/orders">
                            <div class="f-group f-search">
                                <label>Tìm theo mã đơn</label>
                                <input type="text" name="q" placeholder="Ví dụ: 5 hoặc #5" value="${fn:escapeXml(q)}">
                            </div>
                            <div class="f-group">
                                <label>Trạng thái</label>
                                <select name="status">
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
                                <button type="submit" class="btn-shop btn-shop-primary"><i class="fa-solid fa-magnifying-glass"></i> Lọc</button>
                            </div>
                            <c:if test="${not empty q or not empty orderStatus}">
                                <div class="f-group">
                                    <a href="${pageContext.request.contextPath}/account/orders" class="btn-shop btn-shop-outline">Xóa lọc</a>
                                </div>
                            </c:if>
                        </form>

                        <c:choose>
                            <c:when test="${not empty orders}">
                                <div class="account-order-list">
                                    <c:forEach var="o" items="${orders}">
                                        <div class="account-order-card">
                                            <div class="account-order-card-top">
                                                <div>
                                                    <div class="account-order-id">Đơn #${o.orderId}</div>
                                                    <div class="account-order-date"><fmt:formatDate value="${o.createdAt}" pattern="HH:mm dd/MM/yyyy"/></div>
                                                </div>
                                                <div class="account-order-badges">
                                                    <span class="acc-badge acc-badge-${o.orderStatus}"><c:out value="${o.orderStatusLabel}"/></span>
                                                    <span class="acc-badge acc-badge-${o.paymentStatus}"><c:out value="${o.paymentStatusLabel}"/></span>
                                                </div>
                                            </div>
                                            <div class="account-order-products">
                                                <c:out value="${not empty o.productSummary ? o.productSummary : 'Đơn hàng'}"/>
                                            </div>
                                            <div class="account-order-card-bottom">
                                                <div class="account-order-total">
                                                    <fmt:formatNumber value="${o.finalAmount}" type="number" groupingUsed="true"/>đ
                                                    <small>${o.paymentMethod == 'COD' ? 'Tiền mặt khi nhận hàng' : 'PayOS'}</small>
                                                </div>
                                                <div class="account-order-actions">
                                                    <a href="${pageContext.request.contextPath}/account/orders/detail?id=${o.orderId}" class="btn-shop btn-shop-outline">
                                                        <i class="fa-solid fa-eye"></i> Xem chi tiết
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>

                                <c:if test="${totalPages > 1}">
                                    <div class="account-pager">
                                        <c:if test="${currentPageNum > 1}">
                                            <c:url value="/account/orders" var="prevUrl">
                                                <c:param name="q" value="${q}"/><c:param name="status" value="${orderStatus}"/>
                                                <c:param name="page" value="${currentPageNum - 1}"/>
                                            </c:url>
                                            <a href="${prevUrl}"><i class="fa-solid fa-chevron-left"></i></a>
                                        </c:if>
                                        <c:forEach begin="1" end="${totalPages}" var="p">
                                            <c:choose>
                                                <c:when test="${p == currentPageNum}"><span class="current">${p}</span></c:when>
                                                <c:otherwise>
                                                    <c:url value="/account/orders" var="pageUrl">
                                                        <c:param name="q" value="${q}"/><c:param name="status" value="${orderStatus}"/>
                                                        <c:param name="page" value="${p}"/>
                                                    </c:url>
                                                    <a href="${pageUrl}">${p}</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                        <c:if test="${currentPageNum < totalPages}">
                                            <c:url value="/account/orders" var="nextUrl">
                                                <c:param name="q" value="${q}"/><c:param name="status" value="${orderStatus}"/>
                                                <c:param name="page" value="${currentPageNum + 1}"/>
                                            </c:url>
                                            <a href="${nextUrl}"><i class="fa-solid fa-chevron-right"></i></a>
                                        </c:if>
                                    </div>
                                </c:if>
                            </c:when>
                            <c:otherwise>
                                <div class="shop-empty">
                                    <i class="fa-solid fa-basket-shopping"></i>
                                    <h3>Không có đơn hàng nào</h3>
                                    <p>
                                        <c:choose>
                                            <c:when test="${not empty q or not empty orderStatus}">Không tìm thấy đơn khớp bộ lọc hiện tại.</c:when>
                                            <c:otherwise>Bạn chưa đặt đơn hàng nào tại Nhiệt Đới Xanh.</c:otherwise>
                                        </c:choose>
                                    </p>
                                    <a href="${pageContext.request.contextPath}/san-pham" class="btn-shop btn-shop-primary" style="margin-top:16px;display:inline-flex;">
                                        Mua sắm ngay
                                    </a>
                                </div>
                            </c:otherwise>
                        </c:choose>
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
    </script>
</body>
</html>
