<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảo Mật — Nhiệt Đới Xanh</title>
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
                <div class="account-page-title">Bảo Mật</div>
                <div class="account-page-subtitle">Đổi mật khẩu để bảo vệ tài khoản của bạn</div>
            </div>

            <div class="account-shell">
                <%@ include file="/WEB-INF/views/common/account-sidebar.jsp" %>

                <div class="account-card" style="max-width:480px;">
                    <div class="account-card-title"><span><i class="fa-solid fa-key"></i> Đổi mật khẩu</span></div>

                    <form method="post" action="${pageContext.request.contextPath}/account/password" id="passwordForm">
                        <input type="hidden" name="_csrf" value="${sessionScope._csrf}">

                        <div class="account-field">
                            <label for="currentPassword">Mật khẩu hiện tại <span class="required">*</span></label>
                            <input type="password" id="currentPassword" name="currentPassword" required autocomplete="current-password">
                        </div>
                        <div class="account-field">
                            <label for="newPassword">Mật khẩu mới <span class="required">*</span></label>
                            <input type="password" id="newPassword" name="newPassword" required autocomplete="new-password">
                            <div class="account-field-hint">Tối thiểu 6 ký tự, gồm chữ hoa, chữ thường và số.</div>
                        </div>
                        <div class="account-field">
                            <label for="confirmPassword">Xác nhận mật khẩu mới <span class="required">*</span></label>
                            <input type="password" id="confirmPassword" name="confirmPassword" required autocomplete="new-password">
                            <div class="account-field-error" id="confirmError" style="display:none;">Xác nhận mật khẩu không khớp.</div>
                        </div>

                        <button type="submit" class="btn-shop btn-shop-primary"><i class="fa-solid fa-shield-halved"></i> Đổi mật khẩu</button>
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

        const form = document.getElementById('passwordForm');
        const newPassword = document.getElementById('newPassword');
        const confirmPassword = document.getElementById('confirmPassword');
        const confirmError = document.getElementById('confirmError');
        form.addEventListener('submit', (e) => {
            if (newPassword.value !== confirmPassword.value) {
                e.preventDefault();
                confirmError.style.display = 'block';
                confirmPassword.focus();
            }
        });
    </script>
</body>
</html>
