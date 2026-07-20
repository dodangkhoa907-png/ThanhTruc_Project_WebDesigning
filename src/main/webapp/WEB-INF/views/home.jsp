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
    <title>Nhiệt Đới Xanh — Trọn Vị Thanh Mát | Nước Ép & Thức Uống Tươi</title>
    <meta name="description"
        content="Nhiệt Đới Xanh - Nước ép trái cây tươi, cà phê, sinh tố nguyên chất. Giao hỏa tốc 15-20 phút trong khuôn viên trường.">
    <meta name="csrf-token" content="${sessionScope._csrf}">

    <!-- Google Fonts: Be Vietnam Pro -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">

    <!-- FontAwesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Stylesheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=${initParam.assetVer}">
</head>

<body>

    <!-- ================================================================
     NAVBAR — Glassmorphism
     ================================================================ -->
    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>

    <!-- Parallax Leaves (decorative) -->
    <div class="parallax-leaf" style="top:20%;left:3%;" data-speed="0.3">🍃</div>
    <div class="parallax-leaf" style="top:45%;right:2%;" data-speed="0.5">🌿</div>
    <div class="parallax-leaf" style="top:70%;left:5%;" data-speed="0.2">🍂</div>
    <div class="parallax-leaf" style="top:85%;right:4%;" data-speed="0.4">🌱</div>

    <!-- ================================================================
     HERO BANNER — 3D Floating
     ================================================================ -->
    <section class="hero section" id="hero">
        <div class="container">
            <div class="hero-content">
                <div class="hero-badge">
                    <svg viewBox="0 0 24 24"><path d="M12 2L9.19 8.63 2 9.24l5.46 4.73L5.82 21 12 17.27 18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2z"/></svg>
                    100% Trái Cây Tươi Nguyên Chất
                </div>

                <h1>
                    Trái Cây<br>
                    Tươi Mới<br>
                    <span class="highlight">Mỗi Ngày</span>
                </h1>

                <p class="hero-slogan">"Trọn Vị Thanh Mát — Tươi Mát Từ Thiên Nhiên"</p>

                <div class="hero-actions">
                    <%-- Chưa đăng nhập: mời đăng nhập/đăng ký trước để đặt hàng. Đã đăng nhập: vào thẳng khu sản phẩm. --%>
                    <a href="${pageContext.request.contextPath}${empty sessionScope.user ? '/login' : '/san-pham'}" class="btn btn-primary">
                        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49A1.003 1.003 0 0020 4H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/></svg>
                        Đặt Hàng Ngay
                    </a>
                    <a href="#menu" class="btn btn-secondary">Xem Menu</a>
                </div>
            </div>

            <div class="hero-visual">
                <div class="hero-3d-container">
                    <div class="hero-3d-bg"></div>
                    <img src="${pageContext.request.contextPath}/images/cam.png" alt="Nước Ép Cam Tươi" class="hero-product-img">
                    <span class="floating-fruit fruit-1">🍊</span>
                    <span class="floating-fruit fruit-2">🍋</span>
                    <span class="floating-fruit fruit-3">🍎</span>
                    <span class="floating-fruit fruit-4">🥝</span>
                </div>
            </div>
        </div>
    </section>

    <!-- ================================================================
     BRAND STORY
     ================================================================ -->
    <section class="story section" id="story">
        <div class="container">
            <div class="story-visual reveal">
                <div class="story-ambient-glow"></div>
                <div class="story-image-wrapper">
                    <div class="story-glow-container">
                        <div class="story-glow-blob blob-1"></div>
                        <div class="story-glow-blob blob-2"></div>
                        <div class="story-glow-blob blob-3"></div>
                    </div>
                    <img src="${pageContext.request.contextPath}/images/story.png" alt="Câu chuyện Nhiệt Đới Xanh" class="story-img">
                </div>
                <div class="story-stat">
                    <div class="story-stat-number">100%</div>
                    <div class="story-stat-label">Nguyên Chất</div>
                </div>
            </div>

            <div class="story-content reveal reveal-delay-2">
                <span class="section-label">Câu Chuyện Của Chúng Tôi</span>
                <h2 class="section-title">Câu Chuyện Của Nhiệt Đới Xanh</h2>

                <p>
                    Nhiệt Đới Xanh được lập ra bởi một nhóm sinh viên với mong muốn đơn giản:
                    mang đến cho bạn bè trong trường một ly nước ép tươi ngon, giá vừa túi tiền,
                    thay cho những lon nước ngọt có gas đầy đường hóa học.
                </p>
                <p>
                    Trái cây được chúng tôi nhập mới và ép trực tiếp mỗi ngày.
                    Đồ uống có sử dụng đường để cân bằng vị — bạn hoàn toàn có thể yêu cầu
                    giảm đường hoặc không đường khi đặt hàng.
                </p>

                <div class="story-highlights">
                    <div class="story-highlight-item">
                        <div class="story-highlight-icon">🌱</div>
                        <div class="story-highlight-text">Trái cây nhập<br>mới mỗi ngày</div>
                    </div>
                    <div class="story-highlight-item">
                        <div class="story-highlight-icon">🚫</div>
                        <div class="story-highlight-text">Không bảo quản<br>Không hương liệu</div>
                    </div>
                    <div class="story-highlight-item">
                        <div class="story-highlight-icon">🥤</div>
                        <div class="story-highlight-text">Ly ép màng kín<br>Tiện mang đi</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- ── Stats Counter Bar ── -->
    <div class="stats-bar">
        <div class="container">
            <div class="stats-grid">
                <div class="stat-item reveal reveal-delay-1">
                    <div class="stat-number" data-target="500">500+</div>
                    <div class="stat-label">Ly bán mỗi tuần</div>
                </div>
                <div class="stat-item reveal reveal-delay-2">
                    <div class="stat-number">100%</div>
                    <div class="stat-label">Nguyên chất tự nhiên</div>
                </div>
                <div class="stat-item reveal reveal-delay-3">
                    <div class="stat-number">20 phút</div>
                    <div class="stat-label">Giao hàng nhanh nhất</div>
                </div>
                <div class="stat-item reveal reveal-delay-4">
                    <div class="stat-number">15+</div>
                    <div class="stat-label">Loại thức uống</div>
                </div>
            </div>
        </div>
    </div>

    <!-- ================================================================
     CORE VALUES
     ================================================================ -->
    <section class="values section" id="values">
        <div class="container">
            <div class="values-header reveal">
                <span class="section-label">Giá Trị Cốt Lõi</span>
                <h2 class="section-title">Cam Kết Của Chúng Tôi</h2>
                <p class="section-subtitle">
                    Ba cam kết vàng trong mỗi ly nước gửi đến bạn.
                </p>
            </div>

            <div class="values-grid">
                <div class="value-card reveal reveal-delay-1">
                    <div class="value-icon">🍊</div>
                    <h3>Trái Cây Mới Mỗi Ngày</h3>
                    <p>Trái cây được chúng tôi nhập mới và ép trực tiếp mỗi ngày. Cam kết không sử dụng chất bảo quản hay hương liệu hóa học.</p>
                </div>

                <div class="value-card reveal reveal-delay-2">
                    <div class="value-icon">🥤</div>
                    <h3>Đóng Gói Chắc Chắn</h3>
                    <p>Sử dụng ly nhựa nắp ép màng kín 100%, an toàn và tiện lợi mang đi học, đi làm mà không lo tràn đổ.</p>
                </div>

                <div class="value-card reveal reveal-delay-3">
                    <div class="value-icon">⚡</div>
                    <h3>Giao Hỏa Tốc</h3>
                    <p>Đặt hàng và nhận nước ép tươi mát ngay trong khuôn viên trường chỉ từ 15-20 phút.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ================================================================
     SẢN PHẨM NỔI BẬT — đọc thật từ DB (ProductDao.findAllActive), mỗi card
     trỏ đúng /san-pham/chi-tiet?id=<ProductID> theo sản phẩm được click.
     3 sản phẩm đầu trình bày dạng "zigzag" nổi bật (Best-Sellers), phần còn
     lại gọn trong "Các Món Khác" — tái dùng CSS .zigzag-*/.bestseller-* đã có
     sẵn trong style.css (từng thiết kế cho mục này nhưng chưa nối HTML).
     Ảnh: ưu tiên p.imageUrl thật (admin upload qua /admin/san-pham); nếu sản
     phẩm chưa có ảnh riêng thì đoán theo tên khớp ảnh trái cây có sẵn trong
     /images (cam/thơm/dưa hấu), cuối cùng mới rơi về icon chung.
     ================================================================ -->
    <section class="menu section" id="menu">
        <div class="container">
            <div class="menu-header reveal">
                <span class="section-label">Sản Phẩm</span>
                <h2 class="section-title">Sản Phẩm Nổi Bật</h2>
                <p class="section-subtitle">
                    Những ly nước ép trái cây tươi nguyên chất, chọn size phù hợp với nhu cầu của bạn.
                </p>
            </div>

            <c:choose>
            <c:when test="${not empty featuredProducts}">

            <div class="bestseller-zone">
                <div class="bestseller-label reveal">⭐ Best-Sellers</div>

                <c:forEach var="p" items="${featuredProducts}" begin="0" end="2" varStatus="loop">
                    <c:set var="zigzagFruitClass" value="${(fn:containsIgnoreCase(p.name, 'dưa hấu') or fn:containsIgnoreCase(p.name, 'dua hau')) ? 'zigzag-watermelon' : ((fn:containsIgnoreCase(p.name, 'thơm') or fn:containsIgnoreCase(p.name, 'dứa') or fn:containsIgnoreCase(p.name, 'thom')) ? 'zigzag-pineapple' : '')}"/>
                    <div class="zigzag-block reveal ${loop.index % 2 == 1 ? 'zigzag-reverse' : ''} ${zigzagFruitClass}">
                        <a href="${pageContext.request.contextPath}/san-pham/chi-tiet?id=${p.productId}"
                           class="zigzag-image" aria-label="Xem chi tiết ${fn:escapeXml(p.name)}">
                            <c:choose>
                                <c:when test="${not empty p.imageUrl}">
                                    <img src="${pageContext.request.contextPath}${p.imageUrl}" alt="${fn:escapeXml(p.name)}" class="zigzag-img" loading="lazy">
                                </c:when>
                                <c:when test="${fn:containsIgnoreCase(p.name, 'cam')}">
                                    <img src="${pageContext.request.contextPath}/images/cam.png" alt="${fn:escapeXml(p.name)}" class="zigzag-img" loading="lazy">
                                </c:when>
                                <c:when test="${fn:containsIgnoreCase(p.name, 'dưa hấu') or fn:containsIgnoreCase(p.name, 'dua hau')}">
                                    <img src="${pageContext.request.contextPath}/images/duahau.png" alt="${fn:escapeXml(p.name)}" class="zigzag-img" loading="lazy">
                                </c:when>
                                <c:when test="${fn:containsIgnoreCase(p.name, 'thơm') or fn:containsIgnoreCase(p.name, 'dứa') or fn:containsIgnoreCase(p.name, 'thom')}">
                                    <img src="${pageContext.request.contextPath}/images/thom.png" alt="${fn:escapeXml(p.name)}" class="zigzag-img" loading="lazy">
                                </c:when>
                                <c:otherwise>
                                    <span class="ph-icon">🍹</span>
                                </c:otherwise>
                            </c:choose>
                        </a>
                        <div class="zigzag-content">
                            <h3 class="zigzag-name">
                                <a href="${pageContext.request.contextPath}/san-pham/chi-tiet?id=${p.productId}"><c:out value="${p.name}"/></a>
                            </h3>
                            <p class="zigzag-desc">
                                <c:out value="${not empty p.description ? p.description : 'Thức uống tươi mát, nguyên chất, ép trực tiếp mỗi ngày.'}"/>
                            </p>
                            <div class="zigzag-prices">
                                <c:forEach var="v" items="${p.variants}" varStatus="vloop">
                                    <c:if test="${not vloop.first}"><span class="zigzag-divider">|</span></c:if>
                                    <span class="zigzag-price"><c:out value="${v.sizeLabel}"/> —
                                        <strong><fmt:formatNumber value="${v.price}" type="number" groupingUsed="true"/>đ</strong></span>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <c:if test="${fn:length(featuredProducts) > 3}">
                <div class="classic-menu-zone reveal">
                    <div class="classic-menu-header">
                        <h3 class="classic-menu-title">Các Món Khác</h3>
                        <div class="classic-menu-size-legend"><span>Size M</span><span>/</span><span>Size L</span></div>
                    </div>
                    <c:forEach var="p" items="${featuredProducts}" begin="3">
                        <a href="${pageContext.request.contextPath}/san-pham/chi-tiet?id=${p.productId}" class="classic-menu-item">
                            <div class="classic-item-left">
                                <span class="classic-item-name"><c:out value="${p.name}"/></span>
                                <c:if test="${not empty p.description}">
                                    <span class="classic-item-note"><c:out value="${p.description}"/></span>
                                </c:if>
                            </div>
                            <div class="classic-item-dots"></div>
                            <div class="classic-item-price">
                                <c:forEach var="v" items="${p.variants}" varStatus="vloop">
                                    <c:if test="${not vloop.first}"> / </c:if>
                                    <fmt:formatNumber value="${v.price}" type="number" groupingUsed="true"/>đ
                                </c:forEach>
                            </div>
                        </a>
                    </c:forEach>
                </div>
            </c:if>

            </c:when>
            <c:otherwise>
                <div class="shop-empty">
                    <i class="fa-solid fa-seedling"></i>
                    <h3>Chưa có sản phẩm nào</h3>
                    <p>Sản phẩm mới sẽ sớm được cập nhật tại đây.</p>
                </div>
            </c:otherwise>
            </c:choose>

            <div class="menu-view-all reveal" style="text-align:center;margin-top:32px;">
                <a href="${pageContext.request.contextPath}/san-pham" class="btn btn-secondary">
                    Xem Tất Cả Sản Phẩm
                </a>
            </div>
        </div>
    </section>

    <!-- ================================================================
     TEAM
     ================================================================ -->
    <section class="team section" id="team">
        <div class="container">
            <div class="team-header reveal">
                <span class="section-label">Đội Ngũ</span>
                <h2 class="section-title">Người Đứng Sau Nhiệt Đới Xanh</h2>
                <p class="section-subtitle">
                    Những con người tận tâm đứng sau mỗi ly thức uống tươi mát gửi đến bạn.
                </p>
            </div>

            <div class="team-grid">
                <div class="team-card reveal reveal-delay-1">
                    <img src="${pageContext.request.contextPath}/images/oanh.png" alt="Oanh" class="team-avatar avatar-oanh">
                    <div class="team-name">Oanh</div>
                    <div class="team-role">Founder / Quản lý</div>
                </div>

                <div class="team-card reveal reveal-delay-2">
                    <img src="${pageContext.request.contextPath}/images/tien.png" alt="Tiên" class="team-avatar avatar-tien">
                    <div class="team-name">Tiên</div>
                    <div class="team-role">Marketing</div>
                </div>

                <div class="team-card reveal reveal-delay-3">
                    <img src="${pageContext.request.contextPath}/images/ky.png" alt="Kỳ" class="team-avatar avatar-ky">
                    <div class="team-name">Kỳ</div>
                    <div class="team-role">Vận hành</div>
                </div>

                <div class="team-card reveal reveal-delay-4">
                    <img src="${pageContext.request.contextPath}/images/thu.png" alt="Thư" class="team-avatar avatar-thu">
                    <div class="team-name">Thư</div>
                    <div class="team-role">Chăm sóc khách hàng</div>
                </div>

                <div class="team-card reveal reveal-delay-5">
                    <img src="${pageContext.request.contextPath}/images/truc.png" alt="Trúc" class="team-avatar avatar-truc">
                    <div class="team-name">Trúc</div>
                    <div class="team-role">Tài chính</div>
                </div>
            </div>
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

    <!-- ================================================================
     JAVASCRIPT
     ================================================================ -->
    <div class="toast-stack" id="toastStack" aria-live="polite"></div>
    <script src="${pageContext.request.contextPath}/js/cart.js?v=${initParam.assetVer}"></script>
    <script>
        // ===== Navbar Scroll Effect =====
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => {
            navbar.classList.toggle('scrolled', window.scrollY > 50);
        });

        // ===== Mobile Nav Toggle =====
        const navToggle = document.getElementById('navToggle');
        const navLinks = document.getElementById('navLinks');
        navToggle.addEventListener('click', () => navLinks.classList.toggle('active'));
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => navLinks.classList.remove('active'));
        });

        // ===== Scroll Reveal (Intersection Observer) =====
        const revealObserver = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                    revealObserver.unobserve(entry.target);
                }
            });
        }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });

        document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));

        // ===== Parallax Leaves =====
        window.addEventListener('scroll', () => {
            const scrollY = window.scrollY;
            document.querySelectorAll('.parallax-leaf').forEach(leaf => {
                const speed = parseFloat(leaf.dataset.speed) || 0.3;
                leaf.style.transform = 'translateY(' + (scrollY * speed * -0.5) + 'px)';
            });
        });

        // ===== Client-side Form Validation =====
        const orderForm = document.getElementById('orderForm');
        if (orderForm) {
            orderForm.addEventListener('submit', function (e) {
                const name = document.getElementById('customerName').value.trim();
                const phone = document.getElementById('phoneNumber').value.trim();
                const address = document.getElementById('shippingAddress').value.trim();
                let errorMsg = '';

                if (!name) errorMsg += 'Vui lòng nhập Họ và Tên.\n';
                if (!phone) {
                    errorMsg += 'Vui lòng nhập Số Điện Thoại.\n';
                } else if (!/^(0|\+84)[0-9]{9,10}$/.test(phone)) {
                    errorMsg += 'Số điện thoại không hợp lệ.\n';
                }
                if (!address) errorMsg += 'Vui lòng nhập Địa Chỉ Giao Hàng.\n';

                if (errorMsg) {
                    e.preventDefault();
                    alert(errorMsg);
                }
            });
        }

        // ===== Smooth Scroll =====
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    const y = target.getBoundingClientRect().top + window.pageYOffset - 80;
                    window.scrollTo({ top: y, behavior: 'smooth' });
                }
            });
        });

        // ===== Footer Cursor Glow =====
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
