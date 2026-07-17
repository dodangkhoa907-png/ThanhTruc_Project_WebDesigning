<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thực Đơn — Nhiệt Đới Xanh | Nước Ép & Thức Uống Tươi</title>
    <meta name="description"
        content="Thực đơn đầy đủ Nhiệt Đới Xanh — nước ép trái cây tươi ép mỗi ngày, giao hỏa tốc trong khuôn viên trường.">
    <meta name="csrf-token" content="${sessionScope._csrf}">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&family=Baloo+2:wght@600;700;800&display=swap"
        rel="stylesheet">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/menu.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css">
</head>

<body class="menu-page-body">

    <!-- ================================================================
     NAVBAR
     ================================================================ -->
    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>

    <!-- ================================================================
     MENU HERO
     ================================================================ -->
    <section class="menu-hero">
        <div class="container">
            <div class="menu-hero-content">
                <div class="menu-hero-eyebrow">
                    <i class="fa-solid fa-leaf"></i> 100% trái cây tươi ép mỗi ngày
                </div>
                <h1 class="menu-hero-title">Trọn vị<br>thanh mát,<br><em>đủ cho mọi gu.</em></h1>
                <p class="menu-hero-desc">
                    Từ nước ép nguyên chất đến ly mix theo yêu cầu — chọn size, chọn vị,
                    giao tận tay chỉ trong 20–30 phút quanh khuôn viên trường.
                </p>
                <div class="menu-hero-chips">
                    <a href="${pageContext.request.contextPath}/thuc-don"
                       class="menu-hero-chip ${empty activeCategoryId ? 'active' : ''}">Tất cả</a>
                    <c:forEach var="c" items="${categories}">
                        <a href="${pageContext.request.contextPath}/thuc-don?danhmuc=${c.categoryId}"
                           class="menu-hero-chip ${activeCategoryId == c.categoryId ? 'active' : ''}">
                            <c:out value="${c.name}"/>
                        </a>
                    </c:forEach>
                </div>
            </div>
            <div class="menu-hero-visual">
                <div class="menu-hero-bowl">
                    🍊
                    <span>🍋</span>
                    <span>🍓</span>
                    <span>🥝</span>
                    <span>🍍</span>
                </div>
            </div>
        </div>
        <div class="menu-hero-torn"></div>
    </section>

    <!-- ================================================================
     HIGHLIGHTS
     ================================================================ -->
    <section class="menu-highlights">
        <div class="container">
            <div class="menu-highlights-grid">
                <div class="menu-highlight-card c-peach reveal">
                    <span class="menu-highlight-icon">🍊</span>
                    <h4>Trái cây tươi mỗi ngày</h4>
                    <p>Nhập mới và ép trực tiếp, không để tồn qua đêm.</p>
                </div>
                <div class="menu-highlight-card c-mint reveal reveal-delay-1">
                    <span class="menu-highlight-icon">⚡</span>
                    <h4>Giao hỏa tốc 20–30 phút</h4>
                    <p>Quanh khuôn viên trường, tươi ngon khi đến tay bạn.</p>
                </div>
                <div class="menu-highlight-card c-gold reveal reveal-delay-2">
                    <span class="menu-highlight-icon">🚫</span>
                    <h4>Không chất bảo quản</h4>
                    <p>Không hương liệu hóa học, vị nguyên bản tự nhiên.</p>
                </div>
                <div class="menu-highlight-card c-white reveal reveal-delay-3">
                    <span class="menu-highlight-icon">🧃</span>
                    <h4>Mix theo yêu cầu</h4>
                    <p>Tự chọn loại trái cây, báo mức đường bạn thích.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ================================================================
     DANH MỤC
     ================================================================ -->
    <c:if test="${not empty categories}">
    <section class="menu-categories">
        <div class="container">
            <div class="menu-header reveal" style="margin-bottom:40px">
                <span class="section-label">Danh Mục</span>
                <h2 class="section-title">Chọn Theo Sở Thích</h2>
            </div>
            <div class="menu-cat-grid">
                <c:forEach var="c" items="${categories}" varStatus="st">
                    <a href="${pageContext.request.contextPath}/thuc-don?danhmuc=${c.categoryId}"
                       class="menu-cat-card cat-${(st.index % 3) + 1} reveal reveal-delay-${st.index + 1}">
                        <div class="menu-cat-icon">
                            <c:choose>
                                <c:when test="${st.index % 3 == 0}"><i class="fa-solid fa-glass-water-droplet"></i></c:when>
                                <c:when test="${st.index % 3 == 1}"><i class="fa-solid fa-blender"></i></c:when>
                                <c:otherwise><i class="fa-solid fa-leaf"></i></c:otherwise>
                            </c:choose>
                        </div>
                        <h3><c:out value="${c.name}"/></h3>
                        <p>Khám phá các thức uống thuộc danh mục này.</p>
                        <span class="menu-cat-btn ${activeCategoryId == c.categoryId ? 'active' : ''}">
                            Xem thực đơn <i class="fa-solid fa-arrow-right"></i>
                        </span>
                    </a>
                </c:forEach>
            </div>
        </div>
    </section>
    </c:if>

    <!-- ================================================================
     SẢN PHẨM
     ================================================================ -->
    <section class="menu-products">
        <div class="container">
            <div class="menu-products-header reveal">
                <div>
                    <span class="section-label">Thực Đơn</span>
                    <h2 class="section-title" style="margin-bottom:0">
                        <c:choose>
                            <c:when test="${not empty activeCategoryId}">
                                <c:forEach var="c" items="${categories}">
                                    <c:if test="${c.categoryId == activeCategoryId}"><c:out value="${c.name}"/></c:if>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>Tất Cả Món</c:otherwise>
                        </c:choose>
                    </h2>
                </div>
                <span style="color:var(--text-muted);font-size:0.9rem">${fn:length(products)} món</span>
            </div>

            <c:choose>
            <c:when test="${not empty products}">
            <div class="menu-products-grid">
                <c:forEach var="p" items="${products}" varStatus="st">
                    <div class="product-card reveal reveal-delay-${(st.index % 5) + 1}">
                        <div class="product-card-media">
                            <c:choose>
                                <c:when test="${not empty p.imageUrl}">
                                    <img src="${pageContext.request.contextPath}${p.imageUrl}" alt="${p.name}">
                                </c:when>
                                <c:otherwise>
                                    <span class="ph-icon">🥤</span>
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${not empty p.categoryName}">
                                <span class="product-card-cat"><c:out value="${p.categoryName}"/></span>
                            </c:if>
                        </div>
                        <div class="product-card-body">
                            <div class="product-card-name"><c:out value="${p.name}"/></div>
                            <div class="product-card-desc">
                                <c:out value="${not empty p.description ? p.description : 'Thức uống tươi ép nguyên chất, vị thanh mát tự nhiên.'}"/>
                            </div>
                            <c:if test="${not empty p.variants}">
                                <div class="product-card-sizes">
                                    <c:forEach var="v" items="${p.variants}">
                                        <span class="product-size-pill">${v.sizeLabel}<strong>${v.formattedPrice}đ</strong></span>
                                    </c:forEach>
                                </div>
                            </c:if>
                            <div class="product-card-footer">
                                <div class="product-card-price">
                                    <small>Từ</small>
                                    <fmt:formatNumber value="${p.fromPrice}" type="number" groupingUsed="true"/>đ
                                </div>
                                <a href="${pageContext.request.contextPath}/#checkout" class="btn-add-cart">
                                    <i class="fa-solid fa-cart-plus"></i> Đặt ngay
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            </c:when>
            <c:otherwise>
                <div class="menu-empty">
                    <p>Chưa có món nào trong danh mục này.</p>
                </div>
            </c:otherwise>
            </c:choose>
        </div>
    </section>

    <!-- ================================================================
     CTA
     ================================================================ -->
    <section class="menu-cta">
        <div class="menu-cta-torn-top"></div>
        <div class="container">
            <div>
                <h2>Thèm rồi đúng không?</h2>
                <p>Đặt ngay để nhận ly nước ép tươi mát trong 20–30 phút.</p>
            </div>
            <a href="${pageContext.request.contextPath}/#checkout" class="btn-cta-white">
                <i class="fa-solid fa-bolt"></i> Đặt Hàng Ngay
            </a>
        </div>
    </section>

    <!-- ================================================================
     FOOTER
     ================================================================ -->
    <footer class="footer-nhiet-doi">
        <div class="cursor-glow" id="cursorGlow"></div>
        <div class="footer-content">
            <h2 class="brand-title">Nhiệt Đới Xanh</h2>
            <p class="brand-slogan">Trọn Vị Thanh Mát — Trái Cây Tươi Mới Mỗi Ngày</p>

            <div class="social-links">
                <a href="https://www.facebook.com/share/1EMX9PdG2D/" target="_blank" class="social-btn" aria-label="Facebook"><i class="fa-brands fa-facebook-f"></i></a>
                <a href="https://www.instagram.com/nhietdoixanh_05?igsh=dTR0dmgzcWg3aWV3" target="_blank" class="social-btn" aria-label="Instagram"><i class="fa-brands fa-instagram"></i></a>
                <a href="https://tiktok.com/@nuocepnhietdoixanh_05" target="_blank" class="social-btn" aria-label="TikTok"><i class="fa-brands fa-tiktok"></i></a>
            </div>

            <div class="copyright">
                &copy; 2026 Nhiệt Đới Xanh. All rights reserved. | Designed by IT Team.
            </div>
        </div>
    </footer>

    <div class="toast-stack" id="toastStack" aria-live="polite"></div>
    <script src="${pageContext.request.contextPath}/js/cart.js"></script>
    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => {
            navbar.classList.toggle('scrolled', window.scrollY > 50);
        });
        navbar.classList.add('scrolled');

        const navToggle = document.getElementById('navToggle');
        const navLinks = document.getElementById('navLinks');
        navToggle.addEventListener('click', () => navLinks.classList.toggle('active'));
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => navLinks.classList.remove('active'));
        });

        const revealObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                    revealObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.1, rootMargin: '0px 0px -30px 0px' });
        document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));

        document.addEventListener("DOMContentLoaded", () => {
            const footer = document.querySelector('.footer-nhiet-doi');
            const cursorGlow = document.getElementById('cursorGlow');
            if (footer && cursorGlow) {
                footer.addEventListener('mousemove', (e) => {
                    const rect = footer.getBoundingClientRect();
                    cursorGlow.style.left = (e.clientX - rect.left) + 'px';
                    cursorGlow.style.top = (e.clientY - rect.top) + 'px';
                });
                footer.addEventListener('mouseenter', () => cursorGlow.style.opacity = '1');
                footer.addEventListener('mouseleave', () => cursorGlow.style.opacity = '0');
            }
        });
    </script>
</body>
</html>
