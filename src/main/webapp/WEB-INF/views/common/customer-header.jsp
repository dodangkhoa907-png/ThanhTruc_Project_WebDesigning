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
                <img src="${pageContext.request.contextPath}/images/logo.png" alt="Nhiệt Đới Xanh Logo" class="brand-logo-img">
            </div>
            <div class="navbar-name">Nhiệt Đới <span>Xanh</span></div>
        </a>

        <div class="nav-links" id="navLinks">
            <button type="button" class="nav-close-btn mobile-only" id="navClose" aria-label="Đóng menu">
                <i class="fa-solid fa-xmark"></i>
            </button>
            <a href="${pageContext.request.contextPath}/#story">Câu Chuyện</a>
            <a href="${pageContext.request.contextPath}/#values">Giá Trị</a>
            <a href="${pageContext.request.contextPath}/san-pham"
               class="${(currentPage == 'products' || currentPage == 'menu') ? 'active' : ''}">Sản Phẩm</a>
            <a href="${pageContext.request.contextPath}/#team">Đội Ngũ</a>
            <c:if test="${not empty sessionScope.user}">
                <a href="${pageContext.request.contextPath}/cart"
                   class="nav-cart-link desktop-only ${currentPage == 'cart' ? 'active' : ''}" aria-label="Giỏ hàng">
                    <i class="fa-solid fa-basket-shopping"></i>
                    <span class="nav-cart-badge" id="navCartBadge"
                          ${empty sessionScope.cartCount || sessionScope.cartCount == 0 ? 'hidden' : ''}>
                        ${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}
                    </span>
                </a>
            </c:if>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <!-- Desktop: nút + dropdown hover/click -->
                    <div class="nav-user-wrap desktop-only" id="navUserWrap">
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
                    <!-- Mobile: bấm "Tài Khoản" vào thẳng trang tài khoản, đăng xuất ngay bên dưới — không cần dropdown -->
                    <a href="${pageContext.request.contextPath}/account" class="mobile-only ${currentPage == 'account' ? 'active' : ''}">
                        <i class="fa-solid fa-user" style="margin-right:10px"></i>Tài Khoản
                    </a>
                    <form method="post" action="${pageContext.request.contextPath}/logout" class="nav-logout-form-mobile mobile-only-flex">
                        <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                        <button type="submit" class="nav-logout-btn-mobile"><i class="fa-solid fa-right-from-bracket" style="margin-right:10px"></i>Đăng xuất</button>
                    </form>
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

        <!-- Mobile: giỏ hàng nằm ngoài drawer, ngay cạnh nút mở menu -->
        <div class="nav-mobile-actions mobile-only-flex">
            <c:if test="${not empty sessionScope.user}">
            <a href="${pageContext.request.contextPath}/cart"
               class="nav-cart-link nav-cart-link--icon ${currentPage == 'cart' ? 'active' : ''}" aria-label="Giỏ hàng">
                <i class="fa-solid fa-basket-shopping"></i>
                <span class="nav-cart-badge" id="navCartBadgeMobile"
                      ${empty sessionScope.cartCount || sessionScope.cartCount == 0 ? 'hidden' : ''}>
                    ${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}
                </span>
            </a>
            </c:if>
            <button class="nav-toggle" id="navToggle" aria-label="Menu">
                <span></span>
                <span></span>
                <span></span>
            </button>
        </div>
    </div>
</nav>

<div class="nav-backdrop" id="navBackdrop"></div>

<script>
    (function () {
        var navLinks = document.getElementById('navLinks');
        var navToggle = document.getElementById('navToggle');
        var navClose = document.getElementById('navClose');
        var navBackdrop = document.getElementById('navBackdrop');

        function openDrawer() {
            if (navLinks) navLinks.classList.add('active');
            if (navBackdrop) navBackdrop.classList.add('active');
            document.body.style.overflow = 'hidden';
        }

        function closeDrawer() {
            if (navLinks) navLinks.classList.remove('active');
            if (navBackdrop) navBackdrop.classList.remove('active');
            document.body.style.overflow = '';
        }

        function toggleDrawer(e) {
            if (e) e.stopPropagation();
            if (navLinks && navLinks.classList.contains('active')) {
                closeDrawer();
            } else {
                openDrawer();
            }
        }

        window.NhietDoiXanhToggleNav = toggleDrawer;

        if (navToggle) navToggle.onclick = toggleDrawer;
        if (navClose) navClose.onclick = closeDrawer;
        if (navBackdrop) navBackdrop.onclick = closeDrawer;

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeDrawer();
        });

        var wrap = document.getElementById('navUserWrap');
        var trigger = document.getElementById('navUserTrigger');
        if (wrap && trigger) {
            trigger.onclick = function (e) {
                e.stopPropagation();
                var isOpen = wrap.classList.toggle('open');
                trigger.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
            };
            document.addEventListener('click', function (e) {
                if (!wrap.contains(e.target)) {
                    wrap.classList.remove('open');
                    trigger.setAttribute('aria-expanded', 'false');
                }
            });
        }
    })();
</script>



