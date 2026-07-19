<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sở Thích Của Tôi — Nhiệt Đới Xanh</title>
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
                <div class="account-page-title">Sở Thích Của Tôi</div>
                <div class="account-page-subtitle">Cho chúng tôi biết bạn thích gì để phục vụ tốt hơn</div>
            </div>

            <div class="account-shell">
                <%@ include file="/WEB-INF/views/common/account-sidebar.jsp" %>

                <div class="account-card">
                    <form method="post" action="${pageContext.request.contextPath}/account/preferences">
                        <input type="hidden" name="_csrf" value="${sessionScope._csrf}">

                        <div class="account-field">
                            <label for="plantInterests">Loại cây/sản phẩm yêu thích</label>
                            <input type="text" id="plantInterests" name="plantInterests" maxlength="300"
                                   placeholder="Ví dụ: Nước ép cam, mix trái cây theo mùa..."
                                   value="${fn:escapeXml(prefs.plantInterests)}">
                        </div>

                        <div class="account-field">
                            <label for="decorStyles">Phong cách decor</label>
                            <input type="text" id="decorStyles" name="decorStyles" maxlength="300"
                                   placeholder="Ví dụ: Tối giản, nhiệt đới, mộc mạc..."
                                   value="${fn:escapeXml(prefs.decorStyles)}">
                        </div>

                        <div class="account-field">
                            <label>Không gian sử dụng</label>
                            <c:set var="spaceOptions" value="Phòng ngủ,Bàn làm việc,Ban công,Văn phòng,Quán cafe,Khác"/>
                            <div class="account-option-grid">
                                <c:forEach var="opt" items="${fn:split(spaceOptions, ',')}">
                                    <label class="account-option-card">
                                        <input type="radio" name="spaceType" value="${opt}" ${prefs.spaceType == opt ? 'checked' : ''}>
                                        <c:out value="${opt}"/>
                                    </label>
                                </c:forEach>
                            </div>
                        </div>

                        <div class="account-field">
                            <label>Mức độ chăm sóc</label>
                            <c:set var="careOptions" value="Dễ chăm,Trung bình,Cần chăm kỹ"/>
                            <div class="account-option-grid">
                                <c:forEach var="opt" items="${fn:split(careOptions, ',')}">
                                    <label class="account-option-card">
                                        <input type="radio" name="careLevel" value="${opt}" ${prefs.careLevel == opt ? 'checked' : ''}>
                                        <c:out value="${opt}"/>
                                    </label>
                                </c:forEach>
                            </div>
                        </div>

                        <div class="account-field account-field-full">
                            <label for="notes">Ghi chú cá nhân</label>
                            <textarea id="notes" name="notes" maxlength="1000" placeholder="Ghi chú thêm về sở thích của bạn..."><c:out value="${prefs.notes}"/></textarea>
                        </div>

                        <button type="submit" class="btn-shop btn-shop-primary"><i class="fa-solid fa-floppy-disk"></i> Lưu sở thích</button>
                    </form>
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
