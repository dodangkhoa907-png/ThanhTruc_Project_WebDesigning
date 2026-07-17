<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${not empty product ? product.name : 'Sản phẩm không tồn tại'}"/> — Nhiệt Đới Xanh</title>
    <meta name="csrf-token" content="${sessionScope._csrf}">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css">
</head>

<body class="shop-page-body">

    <c:set var="cartCount" value="${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}" />

    <!-- ================================================================
     NAVBAR
     ================================================================ -->
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
                <a href="${pageContext.request.contextPath}/">Trang Chủ</a>
                <a href="${pageContext.request.contextPath}/san-pham" style="color:var(--green);font-weight:700">Sản Phẩm</a>
                <a href="${pageContext.request.contextPath}/cart" class="nav-cart-link">
                    <i class="fa-solid fa-basket-shopping"></i>
                    <span class="nav-cart-badge" id="navCartBadge" ${cartCount == 0 ? 'hidden' : ''}>${cartCount}</span>
                </a>
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/">
                            <c:out value="${sessionScope.user.fullName}"/>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login">Đăng Nhập</a>
                        <a href="${pageContext.request.contextPath}/register" class="nav-cta">Đăng Ký</a>
                    </c:otherwise>
                </c:choose>
            </div>

            <button class="nav-toggle" id="navToggle" aria-label="Menu">
                <span></span><span></span><span></span>
            </button>
        </div>
    </nav>

    <section class="section" style="padding-top:130px;">
        <div class="container">
            <a href="${pageContext.request.contextPath}/san-pham" class="detail-back">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách sản phẩm
            </a>

            <c:choose>
            <c:when test="${empty product}">
                <div class="shop-empty">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <h3><c:out value="${not empty errorMessage ? errorMessage : 'Sản phẩm không tồn tại.'}"/></h3>
                    <a href="${pageContext.request.contextPath}/san-pham" class="btn-shop btn-shop-primary" style="margin-top:20px;display:inline-flex;">
                        Xem sản phẩm khác
                    </a>
                </div>
            </c:when>
            <c:otherwise>
            <div class="detail-grid">
                <div class="detail-media">
                    <c:choose>
                        <c:when test="${not empty product.imageUrl}">
                            <img src="${pageContext.request.contextPath}${product.imageUrl}" alt="${fn:escapeXml(product.name)}">
                        </c:when>
                        <c:otherwise>
                            <span class="ph-icon">🌿</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="detail-info">
                    <c:if test="${not empty product.categoryName}">
                        <span class="detail-cat"><c:out value="${product.categoryName}"/></span>
                    </c:if>
                    <h1 class="detail-title"><c:out value="${product.name}"/></h1>
                    <p class="detail-desc">
                        <c:out value="${not empty product.description ? product.description : 'Sản phẩm chất lượng, phù hợp không gian sống xanh mát.'}"/>
                    </p>

                    <c:choose>
                    <c:when test="${not empty product.variants}">
                        <div class="detail-section-label">Chọn biến thể</div>
                        <div class="detail-variants" id="variantOptions">
                            <c:forEach var="v" items="${product.variants}" varStatus="vs">
                                <div class="detail-variant-option">
                                    <input type="radio" name="variantId" id="variant-${v.variantId}"
                                           value="${v.variantId}" data-price="${v.price}"
                                           ${vs.first ? 'checked' : ''}>
                                    <label for="variant-${v.variantId}">
                                        <span><c:out value="${v.sizeLabel}"/></span>
                                        <span><fmt:formatNumber value="${v.price}" type="number" groupingUsed="true"/>đ</span>
                                    </label>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="detail-section-label">Số lượng</div>
                        <div class="detail-qty-row">
                            <div class="detail-qty-stepper">
                                <button type="button" id="qtyMinus" aria-label="Giảm số lượng">−</button>
                                <input type="text" id="qtyInput" value="1" inputmode="numeric" aria-label="Số lượng">
                                <button type="button" id="qtyPlus" aria-label="Tăng số lượng">+</button>
                            </div>
                            <div class="detail-price-now" id="detailPriceNow">
                                <fmt:formatNumber value="${product.variants[0].price}" type="number" groupingUsed="true"/>đ
                            </div>
                        </div>

                        <div class="detail-actions">
                            <button type="button" class="btn-shop btn-shop-primary" id="btnAddToCart">
                                <i class="fa-solid fa-cart-plus"></i> Thêm vào giỏ
                            </button>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="detail-unavailable">
                            <i class="fa-solid fa-circle-exclamation"></i>
                            Sản phẩm hiện tạm hết hàng / chưa có biến thể để đặt mua.
                        </div>
                    </c:otherwise>
                    </c:choose>
                </div>
            </div>
            </c:otherwise>
            </c:choose>
        </div>
    </section>

    <div class="toast-stack" id="toastStack" aria-live="polite"></div>

    <script src="${pageContext.request.contextPath}/js/cart.js"></script>
    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 50));
        navbar.classList.add('scrolled');

        const navToggle = document.getElementById('navToggle');
        const navLinks = document.getElementById('navLinks');
        navToggle.addEventListener('click', () => navLinks.classList.toggle('active'));

        const qtyInput = document.getElementById('qtyInput');
        const qtyMinus = document.getElementById('qtyMinus');
        const qtyPlus = document.getElementById('qtyPlus');
        const priceNow = document.getElementById('detailPriceNow');
        const addBtn = document.getElementById('btnAddToCart');

        function clampQty(v) {
            v = parseInt(v, 10);
            if (isNaN(v)) v = 1;
            return Math.min(99, Math.max(1, v));
        }

        function formatVnd(n) {
            return new Intl.NumberFormat('vi-VN').format(n) + 'đ';
        }

        function currentVariantPrice() {
            const checked = document.querySelector('input[name="variantId"]:checked');
            return checked ? parseFloat(checked.dataset.price) : 0;
        }

        function updatePriceNow() {
            if (!priceNow) return;
            const qty = clampQty(qtyInput.value);
            priceNow.textContent = formatVnd(currentVariantPrice() * qty);
        }

        if (qtyInput) {
            qtyMinus.addEventListener('click', () => { qtyInput.value = clampQty(qtyInput.value) - 1 < 1 ? 1 : clampQty(qtyInput.value) - 1; updatePriceNow(); });
            qtyPlus.addEventListener('click', () => { qtyInput.value = clampQty(qtyInput.value) + 1 > 99 ? 99 : clampQty(qtyInput.value) + 1; updatePriceNow(); });
            qtyInput.addEventListener('change', () => { qtyInput.value = clampQty(qtyInput.value); updatePriceNow(); });
            document.querySelectorAll('input[name="variantId"]').forEach(r => r.addEventListener('change', updatePriceNow));
        }

        if (addBtn) {
            addBtn.addEventListener('click', () => {
                const checked = document.querySelector('input[name="variantId"]:checked');
                if (!checked) return;
                const qty = clampQty(qtyInput.value);
                NhietDoiXanhCart.addToCart(checked.value, qty, addBtn);
            });
        }
    </script>
</body>
</html>
