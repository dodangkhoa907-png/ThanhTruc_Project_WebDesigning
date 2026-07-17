<%-- Shared customer navbar. Included via <%@ include %> so it shares the
     caller's pageContext/taglibs. Requires request attribute "currentPage"
     to be set by the caller's servlet for active-state highlighting
     ("menu" | "products" | "cart"); Home sets nothing and highlights nothing. --%>
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
            <a href="${pageContext.request.contextPath}/thuc-don"
               class="${currentPage == 'menu' ? 'active' : ''}">Thực Đơn</a>
            <a href="${pageContext.request.contextPath}/san-pham"
               class="${currentPage == 'products' ? 'active' : ''}">Sản Phẩm</a>
            <a href="${pageContext.request.contextPath}/#team">Đội Ngũ</a>
            <a href="${pageContext.request.contextPath}/cart"
               class="nav-cart-link ${currentPage == 'cart' ? 'active' : ''}" aria-label="Giỏ hàng">
                <i class="fa-solid fa-basket-shopping"></i>
                <span class="nav-cart-badge" id="navCartBadge"
                      ${empty sessionScope.cartCount || sessionScope.cartCount == 0 ? 'hidden' : ''}>
                    ${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}
                </span>
            </a>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/">
                        <c:out value="${sessionScope.user.fullName}"/>
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login">Đăng Nhập</a>
                </c:otherwise>
            </c:choose>
            <a href="${pageContext.request.contextPath}/#checkout" class="nav-cta">Đặt Hàng</a>
        </div>

        <button class="nav-toggle" id="navToggle" aria-label="Menu">
            <span></span>
            <span></span>
            <span></span>
        </button>
    </div>
</nav>
