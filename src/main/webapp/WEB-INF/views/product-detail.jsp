<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <fmt:setLocale value="vi_VN" />
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>
                        <c:out value="${not empty product ? product.name : 'Sản phẩm không tồn tại'}" /> — Nhiệt Đới
                        Xanh
                    </title>
                    <meta name="csrf-token" content="${sessionScope._csrf}">



                    <link rel="icon" href="${pageContext.request.contextPath}/favicon.ico" sizes="any">
                    <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/apple-touch-icon.png">
                    <link rel="stylesheet"
                        href="${pageContext.request.contextPath}/css/fonts.css?v=${initParam.assetVer}">
                    <link rel="stylesheet"
                        href="${pageContext.request.contextPath}/css/icons.css?v=${initParam.assetVer}">
                    <link rel="stylesheet"
                        href="${pageContext.request.contextPath}/css/style.css?v=${initParam.assetVer}">
                    <link rel="stylesheet"
                        href="${pageContext.request.contextPath}/css/product.css?v=${initParam.assetVer}">
                </head>

                <body class="shop-page-body">

                    <c:set var="cartCount" value="${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}" />

                    <!-- ================================================================
     NAVBAR
     ================================================================ -->
                    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>

                        <section class="section" style="padding-top:130px;">
                            <div class="container">
                                <a href="${pageContext.request.contextPath}/san-pham" class="detail-back">
                                    <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách sản phẩm
                                </a>

                                <c:choose>
                                    <c:when test="${empty product}">
                                        <div class="shop-empty">
                                            <i class="fa-solid fa-triangle-exclamation"></i>
                                            <h3>
                                                <c:out
                                                    value="${not empty errorMessage ? errorMessage : 'Sản phẩm không tồn tại.'}" />
                                            </h3>
                                            <a href="${pageContext.request.contextPath}/san-pham"
                                                class="btn-shop btn-shop-primary"
                                                style="margin-top:20px;display:inline-flex;">
                                                Xem sản phẩm khác
                                            </a>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="detail-grid">
                                            <div class="detail-media">
                                                <c:choose>
                                                    <c:when test="${not empty product.imageUrl}">
                                                        <img src="${pageContext.request.contextPath}${product.imageUrl}"
                                                            alt="${fn:escapeXml(product.name)}">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="ph-icon">🌿</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="detail-info">
                                                <c:if test="${not empty product.categoryName}">
                                                    <span class="detail-cat">
                                                        <c:out value="${product.categoryName}" />
                                                    </span>
                                                </c:if>
                                                <h1 class="detail-title">
                                                    <c:out value="${product.name}" />
                                                </h1>
                                                <p class="detail-desc">
                                                    <c:out
                                                        value="${not empty product.description ? product.description : 'Sản phẩm chất lượng, phù hợp không gian sống xanh mát.'}" />
                                                </p>

                                                <c:choose>
                                                    <c:when test="${not empty product.variants}">
                                                        <div class="detail-section-label">Chọn biến thể</div>
                                                        <div class="detail-variants" id="variantOptions">
                                                            <c:forEach var="v" items="${product.variants}"
                                                                varStatus="vs">
                                                                <div class="detail-variant-option">
                                                                    <input type="radio" name="variantId"
                                                                        id="variant-${v.variantId}"
                                                                        value="${v.variantId}" data-price="${v.price}"
                                                                        ${vs.first ? 'checked' : '' }>
                                                                    <label for="variant-${v.variantId}">
                                                                        <span>
                                                                            <c:out value="${v.sizeLabel}" />
                                                                        </span>
                                                                        <span>
                                                                            <fmt:formatNumber value="${v.price}"
                                                                                type="number" groupingUsed="true" />đ
                                                                        </span>
                                                                    </label>
                                                                </div>
                                                            </c:forEach>
                                                        </div>

                                                        <div class="detail-section-label">Số lượng</div>
                                                        <div class="detail-qty-row">
                                                            <div class="detail-qty-stepper">
                                                                <button type="button" id="qtyMinus"
                                                                    aria-label="Giảm số lượng">−</button>
                                                                <input type="text" id="qtyInput" value="1"
                                                                    inputmode="numeric" aria-label="Số lượng">
                                                                <button type="button" id="qtyPlus"
                                                                    aria-label="Tăng số lượng">+</button>
                                                            </div>
                                                            <div class="detail-price-now" id="detailPriceNow">
                                                                <fmt:formatNumber value="${product.variants[0].price}"
                                                                    type="number" groupingUsed="true" />đ
                                                            </div>
                                                        </div>

                                                        <div class="detail-actions">
                                                            <button type="button" class="btn-shop btn-shop-primary"
                                                                id="btnAddToCart">
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

                                        <c:if test="${not empty otherProducts}">
                                            <div class="detail-related">
                                                <div class="shop-results-header">
                                                    <span class="shop-results-count"><strong>Sản Phẩm
                                                            Khác</strong></span>
                                                </div>
                                                <div class="shop-grid">
                                                    <c:forEach var="p" items="${otherProducts}">
                                                        <div class="shop-card">
                                                            <div class="shop-card-media">
                                                                <c:choose>
                                                                    <c:when test="${not empty p.imageUrl}">
                                                                        <img src="${pageContext.request.contextPath}${p.imageUrl}"
                                                                            alt="${fn:escapeXml(p.name)}"
                                                                            loading="lazy">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="ph-icon">🍹</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                                <c:if test="${not empty p.categoryName}">
                                                                    <span class="shop-card-cat">
                                                                        <c:out value="${p.categoryName}" />
                                                                    </span>
                                                                </c:if>
                                                            </div>
                                                            <div class="shop-card-body">
                                                                <div class="shop-card-name">
                                                                    <a
                                                                        href="${pageContext.request.contextPath}/san-pham/chi-tiet?id=${p.productId}">
                                                                        <c:out value="${p.name}" />
                                                                    </a>
                                                                </div>
                                                                <div class="shop-card-desc">
                                                                    <c:out
                                                                        value="${not empty p.description ? p.description : 'Nước ép nguyên chất, tươi ngon mỗi ngày.'}" />
                                                                </div>
                                                                <c:if test="${not empty p.variants}">
                                                                    <div class="shop-card-variants">
                                                                        <c:forEach var="v" items="${p.variants}"
                                                                            varStatus="vs" begin="0" end="2">
                                                                            <span class="shop-variant-pill">
                                                                                <c:out value="${v.sizeLabel}" />
                                                                            </span>
                                                                        </c:forEach>
                                                                    </div>
                                                                </c:if>
                                                                <div class="shop-card-footer">
                                                                    <div class="shop-card-price">
                                                                        <small>Từ</small>
                                                                        <fmt:formatNumber value="${p.fromPrice}"
                                                                            type="number" groupingUsed="true" />đ
                                                                    </div>
                                                                    <c:choose>
                                                                        <c:when test="${fn:length(p.variants) == 1}">
                                                                            <button type="button"
                                                                                class="btn-shop btn-shop-primary btn-quick-add"
                                                                                data-variant-id="${p.variants[0].variantId}">
                                                                                <i class="fa-solid fa-cart-plus"></i>
                                                                                Thêm
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
                                            </div>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </section>

                        <c:if test="${not empty product && not empty product.variants}">
                            <div class="mobile-sticky-bottom-bar mobile-only">
                                <div style="flex:1;">
                                    <div style="font-size:0.72rem;color:var(--text-muted);font-weight:500;">Giá tổng
                                    </div>
                                    <div style="font-size:1.15rem;font-weight:900;color:var(--green-dark);"
                                        id="mobileDetailPriceNow">
                                        <fmt:formatNumber value="${product.variants[0].price}" type="number"
                                            groupingUsed="true" />đ
                                    </div>
                                </div>
                                <button type="button" class="btn-shop btn-shop-primary" id="btnMobileAddToCart"
                                    style="padding:12px 22px;">
                                    <i class="fa-solid fa-cart-plus"></i> Thêm vào giỏ
                                </button>
                            </div>
                        </c:if>

                        <div class="toast-stack" id="toastStack" aria-live="polite"></div>

                        <script src="${pageContext.request.contextPath}/js/cart.js?v=${initParam.assetVer}"></script>
                        <script>
                            const navbar = document.getElementById('navbar');
                            window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 50));
                            navbar.classList.add('scrolled');


                            const qtyInput = document.getElementById('qtyInput');
                            const qtyMinus = document.getElementById('qtyMinus');
                            const qtyPlus = document.getElementById('qtyPlus');
                            const priceNow = document.getElementById('detailPriceNow');
                            const mobilePriceNow = document.getElementById('mobileDetailPriceNow');
                            const addBtn = document.getElementById('btnAddToCart');
                            const mobileAddBtn = document.getElementById('btnMobileAddToCart');

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
                                const qty = clampQty(qtyInput ? qtyInput.value : 1);
                                const totalStr = formatVnd(currentVariantPrice() * qty);
                                if (priceNow) priceNow.textContent = totalStr;
                                if (mobilePriceNow) mobilePriceNow.textContent = totalStr;
                            }

                            if (qtyInput) {
                                qtyMinus.addEventListener('click', () => { qtyInput.value = clampQty(qtyInput.value) - 1 < 1 ? 1 : clampQty(qtyInput.value) - 1; updatePriceNow(); });
                                qtyPlus.addEventListener('click', () => { qtyInput.value = clampQty(qtyInput.value) + 1 > 99 ? 99 : clampQty(qtyInput.value) + 1; updatePriceNow(); });
                                qtyInput.addEventListener('change', () => { qtyInput.value = clampQty(qtyInput.value); updatePriceNow(); });
                                document.querySelectorAll('input[name="variantId"]').forEach(r => r.addEventListener('change', updatePriceNow));
                            }

                            function handleAddToCart(btn) {
                                const checked = document.querySelector('input[name="variantId"]:checked');
                                if (!checked) return;
                                const qty = clampQty(qtyInput ? qtyInput.value : 1);
                                NhietDoiXanhCart.addToCart(checked.value, qty, btn);
                            }

                            if (addBtn) addBtn.addEventListener('click', () => handleAddToCart(addBtn));
                            if (mobileAddBtn) mobileAddBtn.addEventListener('click', () => handleAddToCart(mobileAddBtn));

                            document.querySelectorAll('.btn-quick-add').forEach(btn => {
                                btn.addEventListener('click', () => {
                                    NhietDoiXanhCart.addToCart(btn.dataset.variantId, 1, btn);
                                });
                            });

                            document.querySelectorAll('.shop-card-media, .shop-card-desc').forEach(zone => {
                                zone.addEventListener('click', () => {
                                    const link = zone.closest('.shop-card').querySelector('.shop-card-name a');
                                    if (link) window.location.href = link.href;
                                });
                            });
                        </script>
                        <%@ include file="/WEB-INF/views/common/customer-footer.jsp" %>
                </body>

                </html>