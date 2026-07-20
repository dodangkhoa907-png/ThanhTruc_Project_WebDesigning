<%@ page pageEncoding="UTF-8" %>
<%-- Shared customer navbar. Included via <%@ include %> so it shares the
     caller's pageContext/taglibs. Requires request attribute "currentPage"
     to be set by the caller's servlet for active-state highlighting
     ("products" | "cart" | "account"); Home sets nothing and highlights nothing.
     "menu" vẫn được chấp nhận cho tương thích ngược (route /thuc-don cũ đã redirect
     sang /san-pham nên currentPage="menu" không còn servlet nào set nữa). --%>
<nav class="navbar" id="navbar">
    <div class="container">
        <a href="${pageContext.request.contextPath}/" class="navbar-brand">
            <div class="navbar-logo">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M17 8C8 10 5.9 16.17 3.82 21.34l1.89.66.95-2.3c.48.17.98.3 1.34.3C19 20 22 3 22 3c-1 2-8 2.25-13 3.25S2 11.5 2 13.5s1.75 3.75 1.75 3.75C7 8 17 8 17 8z"/>
                </svg>
            </div>
            <div class="navbar-name">Nhiệt Đới <span>Xanh</span></div>
        </a>

        <div class="nav-links" id="navLinks">
            <a href="${pageContext.request.contextPath}/#story">Câu Chuyện</a>
            <a href="${pageContext.request.contextPath}/#values">Giá Trị</a>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <%-- Đã đăng nhập: "Sản Phẩm" mở thẳng trang danh sách/chi tiết sản phẩm thật. --%>
                    <a href="${pageContext.request.contextPath}/san-pham"
                       class="${(currentPage == 'products' || currentPage == 'menu') ? 'active' : ''}">Sản Phẩm</a>
                </c:when>
                <c:otherwise>
                    <%-- Chưa đăng nhập: cuộn mượt tới khu menu ngay trên trang chủ, chưa cần vào trang riêng. --%>
                    <a href="${pageContext.request.contextPath}/#menu">Sản Phẩm</a>
                </c:otherwise>
            </c:choose>
            <a href="${pageContext.request.contextPath}/#team">Đội Ngũ</a>
            <c:if test="${not empty sessionScope.user}">
                <a href="${pageContext.request.contextPath}/cart"
                   class="nav-cart-link ${currentPage == 'cart' ? 'active' : ''}" aria-label="Giỏ hàng">
                    <i class="fa-solid fa-basket-shopping"></i>
                    <span class="nav-cart-badge" id="navCartBadge"
                          ${empty sessionScope.cartCount || sessionScope.cartCount == 0 ? 'hidden' : ''}>
                        ${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}
                    </span>
                </a>
            </c:if>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <div class="nav-user-wrap" id="navUserWrap">
                        <button type="button" class="nav-user-trigger ${currentPage == 'account' ? 'active' : ''}" id="navUserTrigger" aria-haspopup="true" aria-expanded="false">
                            <i class="fa-solid fa-user"></i> Tài Khoản
                            <i class="fa-solid fa-chevron-down nav-user-caret"></i>
                        </button>
                        <div class="nav-user-menu" id="navUserMenu" role="menu">
                            <a href="${pageContext.request.contextPath}/account" role="menuitem"><i class="fa-solid fa-gauge"></i> Tổng quan tài khoản</a>
                            <a href="${pageContext.request.contextPath}/account/orders" role="menuitem"><i class="fa-solid fa-box"></i> Đơn hàng của tôi</a>
                            <a href="${pageContext.request.contextPath}/account/profile" role="menuitem"><i class="fa-solid fa-user"></i> Hồ sơ cá nhân</a>
                            <a href="${pageContext.request.contextPath}/account/addresses" role="menuitem"><i class="fa-solid fa-location-dot"></i> Sổ địa chỉ</a>
                            <a href="${pageContext.request.contextPath}/account/preferences" role="menuitem"><i class="fa-solid fa-heart"></i> Sở thích của tôi</a>
                            <a href="${pageContext.request.contextPath}/account/security" role="menuitem"><i class="fa-solid fa-shield-halved"></i> Bảo mật</a>
                            <div class="nav-user-menu-divider"></div>
                            <form method="post" action="${pageContext.request.contextPath}/logout" class="nav-user-logout-form">
                                <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                                <button type="submit" role="menuitem"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</button>
                            </form>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="nav-login-link">
                        <i class="fa-solid fa-right-to-bracket"></i> Đăng Nhập
                    </a>
                </c:otherwise>
            </c:choose>
            <c:if test="${empty sessionScope.user}">
                <a href="${pageContext.request.contextPath}/san-pham" class="nav-cta">Đặt Hàng</a>
            </c:if>
        </div>

        <button class="nav-toggle" id="navToggle" aria-label="Menu">
            <span></span>
            <span></span>
            <span></span>
        </button>
    </div>
</nav>

<c:if test="${not empty sessionScope.user}">
<script>
    (function () {
        var wrap = document.getElementById('navUserWrap');
        var trigger = document.getElementById('navUserTrigger');
        if (!wrap || !trigger) return;

        function closeMenu() {
            wrap.classList.remove('open');
            trigger.setAttribute('aria-expanded', 'false');
        }

        trigger.addEventListener('click', function (e) {
            e.stopPropagation();
            var isOpen = wrap.classList.toggle('open');
            trigger.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        });

        document.addEventListener('click', function (e) {
            if (!wrap.contains(e.target)) closeMenu();
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeMenu();
        });
    })();
</script>
</c:if>
