<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ Hàng — Nhiệt Đới Xanh</title>
    <meta name="csrf-token" content="${sessionScope._csrf}">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=2">
</head>

<body class="shop-page-body">

    <c:set var="cartCount" value="${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}" />

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
                <a href="${pageContext.request.contextPath}/san-pham">Sản Phẩm</a>
                <a href="${pageContext.request.contextPath}/cart" class="nav-cart-link" style="color:var(--green);font-weight:700">
                    <i class="fa-solid fa-basket-shopping"></i>
                    <span class="nav-cart-badge" id="navCartBadge" ${cartCount == 0 ? 'hidden' : ''}>${cartCount}</span>
                </a>
                <a href="${pageContext.request.contextPath}/">
                    <c:out value="${sessionScope.user.fullName}"/>
                </a>
            </div>
            <button class="nav-toggle" id="navToggle" aria-label="Menu">
                <span></span><span></span><span></span>
            </button>
        </div>
    </nav>

    <section class="section" style="padding-top:130px;">
        <div class="container">

            <c:choose>
            <c:when test="${not empty cartItems}">

                <div class="cart-page-header">
                    <div>
                        <div class="cart-page-title">Giỏ Hàng Của Tôi</div>
                        <div class="cart-page-subtitle">${fn:length(cartItems)} sản phẩm trong giỏ hàng</div>
                    </div>
                    <a href="${pageContext.request.contextPath}/san-pham" class="cart-continue-link">
                        <i class="fa-solid fa-arrow-left"></i> Tiếp tục mua sắm
                    </a>
                </div>

                <div class="cart-layout">
                    <!-- ===== DANH SÁCH SẢN PHẨM ===== -->
                    <div>
                        <div class="cart-select-all-bar">
                            <label class="cart-select-all-left">
                                <input type="checkbox" class="cart-checkbox" id="selectAllCheckbox">
                                Chọn tất cả
                            </label>
                            <span class="cart-select-all-count" id="selectAllCount">Đã chọn 0/${fn:length(cartItems)} sản phẩm</span>
                            <button type="button" class="cart-remove-selected-btn" id="removeSelectedBtn" disabled>
                                <i class="fa-solid fa-trash-can"></i> Xóa đã chọn
                            </button>
                        </div>

                        <div class="cart-items-list" id="cartItemsList">
                            <c:forEach var="item" items="${cartItems}">
                                <div class="cart-item-card ${item.unavailable ? 'is-unavailable' : ''}"
                                     data-cart-item-id="${item.cartItemId}"
                                     data-unit-price="${item.unitPrice}"
                                     data-unavailable="${item.unavailable}">

                                    <input type="checkbox" class="cart-checkbox cart-item-checkbox"
                                           value="${item.cartItemId}"
                                           ${item.unavailable ? 'disabled' : ''}
                                           aria-label="Chọn sản phẩm">

                                    <div class="cart-item-media">
                                        <c:choose>
                                            <c:when test="${not empty item.imageUrl}">
                                                <img src="${pageContext.request.contextPath}${item.imageUrl}" alt="${fn:escapeXml(item.productName)}">
                                            </c:when>
                                            <c:otherwise><i class="fa-solid fa-leaf ph-icon"></i></c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="cart-item-info">
                                        <div class="cart-item-name"><c:out value="${item.productName}"/></div>
                                        <div class="cart-item-meta">
                                            <c:if test="${not empty item.categoryName}">
                                                <span><c:out value="${item.categoryName}"/></span>
                                            </c:if>
                                            <span class="${not empty item.categoryName ? 'dot' : ''}"><c:out value="${item.sizeLabel}"/></span>
                                        </div>
                                        <div class="cart-item-unit-price">${item.formattedUnitPrice}đ / sản phẩm</div>
                                        <c:if test="${item.unavailable}">
                                            <span class="cart-item-unavailable-badge">Ngừng kinh doanh</span>
                                        </c:if>
                                    </div>

                                    <div class="cart-item-qty">
                                        <div class="detail-qty-stepper">
                                            <button type="button" class="cart-qty-minus" aria-label="Giảm số lượng" ${item.unavailable ? 'disabled' : ''}>−</button>
                                            <input type="text" class="cart-qty-input" value="${item.quantity}"
                                                   inputmode="numeric" aria-label="Số lượng" ${item.unavailable ? 'disabled' : ''}>
                                            <button type="button" class="cart-qty-plus" aria-label="Tăng số lượng" ${item.unavailable ? 'disabled' : ''}>+</button>
                                        </div>
                                    </div>

                                    <div class="cart-item-subtotal">
                                        <span class="cart-item-subtotal-value">${item.formattedSubtotal}</span>đ
                                    </div>

                                    <button type="button" class="cart-item-remove-btn">
                                        <i class="fa-solid fa-trash-can"></i> Xóa
                                    </button>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- ===== ORDER SUMMARY ===== -->
                    <aside class="cart-summary">
                        <div class="cart-summary-title">Tóm Tắt Đơn Hàng</div>
                        <div class="cart-summary-row">
                            <span>Sản phẩm đã chọn</span>
                            <strong id="summarySelectedCount">0</strong>
                        </div>
                        <div class="cart-summary-row">
                            <span>Tạm tính</span>
                            <strong id="summarySubtotal">0đ</strong>
                        </div>
                        <div class="cart-summary-row">
                            <span>Phí giao hàng</span>
                            <span>Tính ở bước thanh toán</span>
                        </div>
                        <div class="cart-summary-divider"></div>
                        <div class="cart-summary-total-row">
                            <span class="cart-summary-total-label">Tổng dự kiến</span>
                            <span class="cart-summary-total-value" id="summaryTotal">0đ</span>
                        </div>
                        <button type="button" class="btn-shop btn-shop-primary" id="checkoutBtn" disabled>
                            <i class="fa-solid fa-lock"></i> Tiến hành thanh toán
                        </button>
                        <p class="cart-summary-hint" id="checkoutHint">
                            Vui lòng chọn ít nhất 1 sản phẩm.
                        </p>
                        <p class="cart-summary-note">
                            Giá cuối cùng và phí giao hàng sẽ được xác nhận lại ở bước thanh toán.
                        </p>
                    </aside>
                </div>

                <div class="cart-mobile-bar">
                    <div class="cart-mobile-bar-total">
                        <span class="cart-mobile-bar-total-label" id="mobileSelectedCount">0 sản phẩm</span>
                        <span class="cart-mobile-bar-total-value" id="mobileTotal">0đ</span>
                    </div>
                    <button type="button" class="btn-shop btn-shop-primary" id="checkoutBtnMobile" disabled>
                        Thanh toán
                    </button>
                </div>

            </c:when>
            <c:otherwise>
                <div class="shop-empty">
                    <i class="fa-solid fa-basket-shopping"></i>
                    <h3>Giỏ hàng của bạn đang trống</h3>
                    <p>Hãy khám phá các sản phẩm của Nhiệt Đới Xanh.</p>
                    <a href="${pageContext.request.contextPath}/san-pham" class="btn-shop btn-shop-primary" style="margin-top:20px;display:inline-flex;">
                        Tiếp tục mua sắm
                    </a>
                </div>
            </c:otherwise>
            </c:choose>
        </div>
    </section>

    <div class="toast-stack" id="toastStack" aria-live="polite"></div>
    <script src="${pageContext.request.contextPath}/js/cart.js?v=2"></script>
    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 50));
        navbar.classList.add('scrolled');
        const navToggle = document.getElementById('navToggle');
        const navLinks = document.getElementById('navLinks');
        navToggle.addEventListener('click', () => navLinks.classList.toggle('active'));

        if (window.NhietDoiXanhCart && typeof window.NhietDoiXanhCart.initCartPage === 'function') {
            window.NhietDoiXanhCart.initCartPage();
        }
    </script>
</body>
</html>
