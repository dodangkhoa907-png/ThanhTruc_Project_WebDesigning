<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Cá Nhân — Nhiệt Đới Xanh</title>
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
            <c:if test="${not empty formErrors['avatar']}"><div class="account-flash error"><c:out value="${formErrors['avatar']}"/></div></c:if>

            <div class="account-page-header">
                <div class="account-page-title">Hồ Sơ Cá Nhân</div>
                <div class="account-page-subtitle">Cập nhật thông tin liên hệ và ảnh đại diện của bạn</div>
            </div>

            <div class="account-shell">
                <%@ include file="/WEB-INF/views/common/account-sidebar.jsp" %>

                <div class="account-card">
                    <form method="post" action="${pageContext.request.contextPath}/account/profile" enctype="multipart/form-data">
                        <input type="hidden" name="_csrf" value="${sessionScope._csrf}">

                        <div class="account-avatar-upload">
                            <c:choose>
                                <c:when test="${not empty profileUser.profileImage}">
                                    <img class="account-avatar-preview" id="avatarPreview" src="${pageContext.request.contextPath}${profileUser.profileImage}" alt="Ảnh đại diện">
                                </c:when>
                                <c:otherwise>
                                    <div class="account-avatar-preview account-avatar-fallback" id="avatarPreviewFallback" aria-hidden="true">
                                        <c:out value="${not empty profileUser.fullName ? fn:substring(profileUser.fullName, 0, 1) : 'N'}"/>
                                    </div>
                                    <img class="account-avatar-preview" id="avatarPreview" src="#" alt="Ảnh đại diện" hidden>
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <label for="avatarInput" class="btn-shop btn-shop-outline" style="cursor:pointer;">
                                    <i class="fa-solid fa-camera"></i> Đổi ảnh đại diện
                                </label>
                                <input type="file" id="avatarInput" name="avatar" accept="image/jpeg,image/png,image/webp" style="display:none;">
                                <div class="account-avatar-upload-hint">JPG, PNG hoặc WEBP, tối đa 1MB. Bạn có thể cắt và căn chỉnh trước khi lưu.</div>
                                <div class="account-field-error" id="avatarCropError" hidden></div>
                            </div>
                        </div>

                        <%-- Modal cắt/căn chỉnh ảnh đại diện (canvas thuần, không thư viện ngoài) --%>
                        <div class="avatar-crop-modal" id="avatarCropModal" role="dialog" aria-modal="true" aria-label="Cắt ảnh đại diện">
                            <div class="avatar-crop-dialog">
                                <div class="avatar-crop-header">
                                    <i class="fa-solid fa-crop-simple"></i> Cắt &amp; căn chỉnh ảnh
                                </div>
                                <div class="avatar-crop-stage">
                                    <canvas id="avatarCropCanvas" width="320" height="320"></canvas>
                                    <div class="avatar-crop-overlay" aria-hidden="true"></div>
                                </div>
                                <div class="avatar-crop-controls">
                                    <i class="fa-solid fa-magnifying-glass-minus"></i>
                                    <input type="range" id="avatarCropZoom" min="1" max="3" step="0.01" value="1" aria-label="Phóng to">
                                    <i class="fa-solid fa-magnifying-glass-plus"></i>
                                </div>
                                <div class="avatar-crop-hint">Kéo để di chuyển, dùng thanh trượt để phóng to/thu nhỏ.</div>
                                <div class="avatar-crop-actions">
                                    <button type="button" class="btn-shop btn-shop-outline" id="avatarCropCancel">Hủy</button>
                                    <button type="button" class="btn-shop btn-shop-primary" id="avatarCropSave">
                                        <i class="fa-solid fa-check"></i> Lưu ảnh đại diện
                                    </button>
                                </div>
                            </div>
                        </div>

                        <div class="account-field-grid">
                            <div class="account-field ${not empty formErrors.fullName ? 'has-error' : ''}">
                                <label for="fullName">Họ và tên <span class="required">*</span></label>
                                <input type="text" id="fullName" name="fullName" maxlength="100" required
                                       value="${fn:escapeXml(not empty oldFullName ? oldFullName : profileUser.fullName)}">
                                <c:if test="${not empty formErrors.fullName}"><div class="account-field-error"><c:out value="${formErrors.fullName}"/></div></c:if>
                            </div>
                            <div class="account-field ${not empty formErrors.nickname ? 'has-error' : ''}">
                                <label for="nickname">Nickname</label>
                                <input type="text" id="nickname" name="nickname" maxlength="100"
                                       value="${fn:escapeXml(not empty oldNickname ? oldNickname : profileUser.nickname)}">
                                <c:if test="${not empty formErrors.nickname}"><div class="account-field-error"><c:out value="${formErrors.nickname}"/></div></c:if>
                            </div>
                            <div class="account-field ${not empty formErrors.phone ? 'has-error' : ''}">
                                <label for="phone">Số điện thoại</label>
                                <input type="tel" id="phone" name="phone" maxlength="15"
                                       value="${fn:escapeXml(not empty oldPhone ? oldPhone : profileUser.phone)}">
                                <c:if test="${not empty formErrors.phone}"><div class="account-field-error"><c:out value="${formErrors.phone}"/></div></c:if>
                            </div>
                            <div class="account-field ${not empty formErrors.email ? 'has-error' : ''}">
                                <label for="email">Email <span class="required">*</span></label>
                                <input type="email" id="email" name="email" maxlength="150" required
                                       value="${fn:escapeXml(not empty oldEmail ? oldEmail : profileUser.email)}">
                                <c:if test="${not empty formErrors.email}"><div class="account-field-error"><c:out value="${formErrors.email}"/></div></c:if>
                            </div>
                        </div>

                        <button type="submit" class="btn-shop btn-shop-primary">
                            <i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi
                        </button>
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
    <script src="${pageContext.request.contextPath}/js/avatar-crop.js?v=${initParam.assetVer}"></script>
</body>
</html>
