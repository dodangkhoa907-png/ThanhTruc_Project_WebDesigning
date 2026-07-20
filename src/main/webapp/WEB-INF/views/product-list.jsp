    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sản Phẩm — Nhiệt Đới Xanh | Nước Ép &amp; Sinh Tố Trái Cây Tươi</title>
    <meta name="description"
        content="Khu sản phẩm Nhiệt Đới Xanh — nước ép, sinh tố trái cây nguyên chất, chọn size và số lượng, giao tận nơi.">
    <meta name="csrf-token" content="${sessionScope._csrf}">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=${initParam.assetVer}">
</head>

<body class="shop-page-body">

    <c:set var="cartCount" value="${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}" />

    <!-- ================================================================
     NAVBAR
     ================================================================ -->
    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>

    <!-- ================================================================
     SHOP HERO
     ================================================================ -->
    <section class="shop-hero">
        <div class="shop-hero-banner" style="background-image:url('${pageContext.request.contextPath}/images/category/Standee.png')" aria-hidden="true"></div>
        <div class="shop-hero-scrim" aria-hidden="true"></div>
        <div class="container">
            <div class="shop-hero-eyebrow">
                <i class="fa-solid fa-glass-water-droplet"></i> Nước ép &amp; sinh tố trái cây nguyên chất
            </div>
            <h1 class="shop-hero-title">Mang vị tươi mát<br>nhiệt đới về với bạn.</h1>
            <p class="shop-hero-desc">
                Chọn loại trái cây, chọn size ly phù hợp với khẩu vị của bạn —
                ép tươi mỗi ngày, giao tận nơi.
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
                                    <span class="ph-icon">🍹</span>
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
                                <c:out value="${not empty p.description ? p.description : 'Nước ép nguyên chất, tươi ngon mỗi ngày.'}"/>
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
                    <i class="fa-solid fa-glass-water-droplet"></i>
                    <h3>Chưa tìm thấy sản phẩm phù hợp</h3>
                    <p>Thử đổi từ khóa tìm kiếm hoặc chọn danh mục khác.</p>
                </div>
            </c:otherwise>
            </c:choose>
        </div>
    </section>

    <div class="toast-stack" id="toastStack" aria-live="polite"></div>

    <script src="${pageContext.request.contextPath}/js/cart.js?v=${initParam.assetVer}"></script>
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

        // Bấm vào ảnh/tên/mô tả sản phẩm là vào luôn trang chi tiết — cố tình KHÔNG gộp
        // vùng footer (giá + nút "Thêm"/"Xem chi tiết") vào đây để tránh chạm nhầm trên di động.
        document.querySelectorAll('.shop-card-media, .shop-card-desc').forEach(zone => {
            zone.addEventListener('click', () => {
                const link = zone.closest('.shop-card').querySelector('.shop-card-name a');
                if (link) window.location.href = link.href;
            });
        });
    </script>
</body>
</html>
