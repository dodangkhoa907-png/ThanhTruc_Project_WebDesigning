<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tài Khoản Của Tôi — Nhiệt Đới Xanh</title>
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
                <div class="account-page-title">Tài Khoản Của Tôi</div>
                <div class="account-page-subtitle">Tổng quan hoạt động mua sắm của bạn tại Nhiệt Đới Xanh</div>
            </div>

            <div class="account-shell">
                <%@ include file="/WEB-INF/views/common/account-sidebar.jsp" %>

                <div>
                    <div class="account-profile-card">
                        <c:choose>
                            <c:when test="${not empty user.profileImage}">
                                <img class="account-avatar" src="${pageContext.request.contextPath}${user.profileImage}" alt="Ảnh đại diện">
                            </c:when>
                            <c:otherwise>
                                <div class="account-avatar account-avatar-fallback" aria-hidden="true"><c:out value="${not empty user.fullName ? fn:substring(user.fullName, 0, 1) : 'N'}"/></div>
                            </c:otherwise>
                        </c:choose>
                        <div class="account-profile-info">
                            <div class="account-profile-name"><c:out value="${user.fullName}"/></div>
                            <c:if test="${not empty user.nickname}">
                                <div class="account-profile-nickname">@<c:out value="${user.nickname}"/></div>
                            </c:if>
                            <div class="account-tier-badge"><i class="fa-solid fa-seedling"></i> <c:out value="${tier.label}"/></div>

                            <div class="account-profile-meta">
                                <span><i class="fa-solid fa-envelope"></i> <c:out value="${user.email}"/></span>
                                <c:if test="${not empty user.phone}">
                                    <span><i class="fa-solid fa-phone"></i> <c:out value="${user.phone}"/></span>
                                </c:if>
                                <span><i class="fa-solid fa-calendar"></i> Tham gia <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy"/></span>
                            </div>

                            <c:if test="${not empty nextTier}">
                                <div class="account-tier-progress">
                                    <div class="account-tier-progress-track">
                                        <div class="account-tier-progress-fill" style="width:${tierProgressPercent}%"></div>
                                    </div>
                                    <div class="account-tier-progress-text">
                                        Chi thêm <fmt:formatNumber value="${amountToNext}" type="number" groupingUsed="true"/>đ để lên hạng
                                        <c:out value="${nextTier.label}"/>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <div class="account-stats">
                        <div class="account-stat-card">
                            <div class="account-stat-icon"><i class="fa-solid fa-box"></i></div>
                            <div>
                                <div class="account-stat-value">${totalOrders}</div>
                                <div class="account-stat-label">Tổng đơn hàng</div>
                            </div>
                        </div>
                        <div class="account-stat-card">
                            <div class="account-stat-icon"><i class="fa-solid fa-circle-check"></i></div>
                            <div>
                                <div class="account-stat-value">${doneOrders}</div>
                                <div class="account-stat-label">Đơn hoàn thành</div>
                            </div>
                        </div>
                        <div class="account-stat-card">
                            <div class="account-stat-icon gold"><i class="fa-solid fa-truck"></i></div>
                            <div>
                                <div class="account-stat-value">${processingOrders}</div>
                                <div class="account-stat-label">Đang xử lý</div>
                            </div>
                        </div>
                        <div class="account-stat-card">
                            <div class="account-stat-icon"><i class="fa-solid fa-wallet"></i></div>
                            <div>
                                <div class="account-stat-value"><fmt:formatNumber value="${totalSpent}" type="number" groupingUsed="true"/>đ</div>
                                <div class="account-stat-label">Tổng chi tiêu (đơn hoàn thành)</div>
                            </div>
                        </div>
                    </div>

                    <div class="account-card">
                        <div class="account-card-title">
                            <span><i class="fa-solid fa-clock-rotate-left"></i> Đơn hàng gần đây</span>
                            <a href="${pageContext.request.contextPath}/account/orders">Xem tất cả →</a>
                        </div>
                        <c:choose>
                            <c:when test="${totalOrders > 0}">
                                <p style="font-size:0.86rem;color:var(--text-muted)">
                                    Bạn có <c:out value="${totalOrders}"/> đơn hàng. Xem chi tiết ở mục "Đơn hàng".
                                </p>
                            </c:when>
                            <c:otherwise>
                                <div class="shop-empty" style="padding:40px 20px">
                                    <i class="fa-solid fa-basket-shopping"></i>
                                    <h3>Bạn chưa có đơn hàng nào</h3>
                                    <p>Khám phá thực đơn và đặt ly nước ép đầu tiên của bạn.</p>
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
