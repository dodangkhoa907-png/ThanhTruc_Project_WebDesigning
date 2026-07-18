<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Sidebar tài khoản dùng chung cho mọi trang /account/*.
     Cần request attribute "accountTab" ("overview" | "orders" | "profile" | "addresses"
     | "preferences" | "security") để tô active. --%>
<aside class="account-sidebar">
    <nav class="account-nav">
        <a href="${pageContext.request.contextPath}/account" class="${accountTab == 'overview' ? 'active' : ''}">
            <i class="fa-solid fa-gauge"></i> Tổng quan
        </a>
        <a href="${pageContext.request.contextPath}/account/orders" class="${accountTab == 'orders' ? 'active' : ''}">
            <i class="fa-solid fa-box"></i> Đơn hàng
        </a>
        <div class="account-nav-divider"></div>
        <a href="${pageContext.request.contextPath}/account/profile" class="${accountTab == 'profile' ? 'active' : ''}">
            <i class="fa-solid fa-user"></i> Hồ sơ cá nhân
        </a>
        <a href="${pageContext.request.contextPath}/account/addresses" class="${accountTab == 'addresses' ? 'active' : ''}">
            <i class="fa-solid fa-location-dot"></i> Sổ địa chỉ
        </a>
        <a href="${pageContext.request.contextPath}/account/preferences" class="${accountTab == 'preferences' ? 'active' : ''}">
            <i class="fa-solid fa-heart"></i> Sở thích
        </a>
        <a href="${pageContext.request.contextPath}/account/security" class="${accountTab == 'security' ? 'active' : ''}">
            <i class="fa-solid fa-shield-halved"></i> Bảo mật
        </a>
        <div class="account-nav-divider"></div>
        <form method="post" action="${pageContext.request.contextPath}/logout">
            <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
            <button type="submit"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</button>
        </form>
    </nav>
</aside>
