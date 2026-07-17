<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Sidebar tài khoản dùng chung cho /account, /account/orders, /account/orders/detail.
     Cần request attribute "accountTab" ("overview" | "orders") để tô active. --%>
<aside class="account-sidebar">
    <nav class="account-nav">
        <a href="${pageContext.request.contextPath}/account" class="${accountTab == 'overview' ? 'active' : ''}">
            <i class="fa-solid fa-gauge"></i> Tổng quan
        </a>
        <a href="${pageContext.request.contextPath}/account/orders" class="${accountTab == 'orders' ? 'active' : ''}">
            <i class="fa-solid fa-box"></i> Đơn hàng
        </a>
        <div class="account-nav-divider"></div>
        <a class="is-disabled">
            <i class="fa-solid fa-user"></i> Thông tin cá nhân
            <span class="account-nav-soon">Sắp có</span>
        </a>
        <a class="is-disabled">
            <i class="fa-solid fa-location-dot"></i> Sổ địa chỉ
            <span class="account-nav-soon">Sắp có</span>
        </a>
        <a class="is-disabled">
            <i class="fa-solid fa-heart"></i> Sở thích
            <span class="account-nav-soon">Sắp có</span>
        </a>
        <a class="is-disabled">
            <i class="fa-solid fa-shield-halved"></i> Bảo mật
            <span class="account-nav-soon">Sắp có</span>
        </a>
        <div class="account-nav-divider"></div>
        <a href="${pageContext.request.contextPath}/logout">
            <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
        </a>
    </nav>
</aside>
