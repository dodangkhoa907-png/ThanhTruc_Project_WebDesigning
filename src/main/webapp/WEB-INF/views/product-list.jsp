<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sản Phẩm — Nhiệt Đới Xanh | Cây Cảnh &amp; Decor Nhiệt Đới</title>
    <meta name="description"
        content="Khu sản phẩm Nhiệt Đới Xanh — cây cảnh, chậu decor phong cách nhiệt đới, chọn size và số lượng, giao tận nơi.">
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

    <!-- ================================================================
     SHOP HERO
     ================================================================ -->
    <section class="shop-hero">
        <div class="container">
            <div class="shop-hero-eyebrow">
                <i class="fa-solid fa-seedling"></i> Cây cảnh &amp; decor phong cách nhiệt đới
            </div>
            <h1 class="shop-hero-title">Mang không gian<br>xanh mát về nhà bạn.</h1>
            <p class="shop-hero-desc">
                Chọn cây, chọn chậu, chọn kích thước phù hợp với góc nhà của bạn —
                giao tận nơi, chăm sóc dễ dàng.
            </p>
        </div>
    </section>

    <!-- ================================================================
     TOOLBAR — search / sort / filter
     ================================================================ -->
    <section class="shop-toolbar">
        <div class="container">
            <form id="shopFilterForm" method="GET" action="${pageContext.request.contextPath}/san-pham"
                  style="display:flex;flex-wrap:wrap;gap:14px;flex:1;align-items:center;">
                <div class="shop-search">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" name="q" id="shopSearchInput" placeholder="Tìm kiếm sản phẩm..."
                           value="${fn:escapeXml(keyword)}" maxlength="100" autocomplete="off">
                </div>
                <c:if test="${not empty activeCategoryId}">
                    <input type="hidden" name="danhmuc" value="${activeCategoryId}">
                </c:if>
                <div class="shop-sort">
                    <select name="sort" id="shopSortSelect">
                        <option value="moi-nhat" ${activeSort == 'moi-nhat' ? 'selected' : ''}>Mới nhất</option>
                        <option value="gia-tang" ${activeSort == 'gia-tang' ? 'selected' : ''}>Giá thấp đến cao</option>
                        <option value="gia-giam" ${activeSort == 'gia-giam' ? 'selected' : ''}>Giá cao đến thấp</option>
                        <option value="ten-az" ${activeSort == 'ten-az' ? 'selected' : ''}>Tên A-Z</option>
                    </select>
                </div>
            </form>

            <c:if test="${not empty categories}">
            <div class="shop-cat-chips">
                <a href="${pageContext.request.contextPath}/san-pham?x=1${keepQuerySuffix}"
                   class="shop-cat-chip ${empty activeCategoryId ? 'active' : ''}">Tất cả</a>
                <c:forEach var="c" items="${categories}">
                    <a href="${pageContext.request.contextPath}/san-pham?danhmuc=${c.categoryId}${keepQuerySuffix}"
                       class="shop-cat-chip ${activeCategoryId == c.categoryId ? 'active' : ''}">
                        <c:out value="${c.name}"/>
                    </a>
                </c:forEach>
            </div>
            </c:if>
        </div>
    </section>

    <!-- ================================================================
     RESULTS + GRID
     ================================================================ -->
    <section class="section" style="padding-top:0;">
        <div class="container">
            <div class="shop-results-header">
                <span class="shop-results-count">
                    <strong>${fn:length(products)}</strong> sản phẩm
                    <c:if test="${not empty keyword}"> cho "<c:out value="${keyword}"/>"</c:if>
                </span>
            </div>

            <c:choose>
            <c:when test="${not empty products}">
            <div class="shop-grid">
                <c:forEach var="p" items="${products}">
                    <div class="shop-card">
                        <div class="shop-card-media">
                            <c:choose>
                                <c:when test="${not empty p.imageUrl}">
                                    <img src="${pageContext.request.contextPath}${p.imageUrl}" alt="${fn:escapeXml(p.name)}" loading="lazy">
                                </c:when>
                                <c:otherwise>
                                    <span class="ph-icon">🌿</span>
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${not empty p.categoryName}">
                                <span class="shop-card-cat"><c:out value="${p.categoryName}"/></span>
                            </c:if>
                        </div>
                        <div class="shop-card-body">
                            <div class="shop-card-name">
                                <a href="${pageContext.request.contextPath}/san-pham/chi-tiet?id=${p.productId}">
                                    <c:out value="${p.name}"/>
                                </a>
                            </div>
                            <div class="shop-card-desc">
                                <c:out value="${not empty p.description ? p.description : 'Sản phẩm chất lượng, phù hợp không gian sống xanh mát.'}"/>
                            </div>
                            <c:if test="${not empty p.variants}">
                                <div class="shop-card-variants">
                                    <c:forEach var="v" items="${p.variants}" varStatus="vs" begin="0" end="2">
                                        <span class="shop-variant-pill"><c:out value="${v.sizeLabel}"/></span>
                                    </c:forEach>
                                </div>
                            </c:if>
                            <div class="shop-card-footer">
                                <div class="shop-card-price">
                                    <small>Từ</small>
                                    <fmt:formatNumber value="${p.fromPrice}" type="number" groupingUsed="true"/>đ
                                </div>
                                <c:choose>
                                    <c:when test="${fn:length(p.variants) == 1}">
                                        <button type="button" class="btn-shop btn-shop-primary btn-quick-add"
                                                data-variant-id="${p.variants[0].variantId}">
                                            <i class="fa-solid fa-cart-plus"></i> Thêm
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/san-pham/chi-tiet?id=${p.productId}"
                                           class="btn-shop btn-shop-outline">
                                            Xem chi tiết
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            </c:when>
            <c:otherwise>
                <div class="shop-empty">
                    <i class="fa-solid fa-seedling"></i>
                    <h3>Chưa tìm thấy sản phẩm phù hợp</h3>
                    <p>Thử đổi từ khóa tìm kiếm hoặc chọn danh mục khác.</p>
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

        // Sort/category auto-submit khi đổi giá trị (giữ nguyên search text hiện tại)
        document.getElementById('shopSortSelect').addEventListener('change', () => {
            document.getElementById('shopFilterForm').submit();
        });

        document.querySelectorAll('.btn-quick-add').forEach(btn => {
            btn.addEventListener('click', () => {
                NhietDoiXanhCart.addToCart(btn.dataset.variantId, 1, btn);
            });
        });
    </script>
</body>
</html>
