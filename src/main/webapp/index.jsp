<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhiệt Đới Xanh — Trọn Vị Thanh Mát | Nước Ép & Thức Uống Tươi</title>
    <meta name="description"
        content="Nhiệt Đới Xanh - Nước ép trái cây tươi, cà phê, sinh tố nguyên chất. Giao hỏa tốc 15-20 phút trong khuôn viên trường.">

    <!-- Google Fonts: Be Vietnam Pro -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">

    <!-- FontAwesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Stylesheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>

<body>

    <!-- ================================================================
     NAVBAR — Glassmorphism
     ================================================================ -->
    <nav class="navbar" id="navbar">
        <div class="container">
            <a href="#hero" class="navbar-brand">
                <div class="navbar-logo">
                    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path d="M17 8C8 10 5.9 16.17 3.82 21.34l1.89.66.95-2.3c.48.17.98.3 1.34.3C19 20 22 3 22 3c-1 2-8 2.25-13 3.25S2 11.5 2 13.5s1.75 3.75 1.75 3.75C7 8 17 8 17 8z"/>
                    </svg>
                </div>
                <div class="navbar-name">Nhiệt Đới <span>Xanh</span></div>
            </a>

            <div class="nav-links" id="navLinks">
                <a href="#story">Câu Chuyện</a>
                <a href="#values">Giá Trị</a>
                <a href="#menu">Menu</a>
                <a href="#team">Đội Ngũ</a>
                <a href="#checkout" class="nav-cta">Đặt Hàng</a>
            </div>

            <button class="nav-toggle" id="navToggle" aria-label="Menu">
                <span></span>
                <span></span>
                <span></span>
            </button>
        </div>
    </nav>

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
                    <a href="#checkout" class="btn btn-primary">
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
     MENU — Magazine + Category Style
     ================================================================ -->
    <section class="menu section" id="menu">
        <div class="container">
            <div class="menu-header reveal">
                <span class="section-label">Thực Đơn</span>
                <h2 class="section-title">Menu Thanh Mát</h2>
                <p class="section-subtitle">
                    Những ly thức uống tươi nguyên chất, vừa ngon vừa bổ dưỡng cho sức khỏe mỗi ngày.
                </p>
            </div>

            <!-- ── TOP 3 BEST-SELLERS (Zig-Zag with Cream Sweeps) ── -->
            <div class="bestseller-zone">
                <div class="bestseller-label reveal">⭐ Best-Sellers</div>

                <!-- Nước Ép Cam -->
                <div class="zigzag-block reveal">
                    <div class="zigzag-image">
                        <img src="${pageContext.request.contextPath}/images/cam.png" alt="Nước Ép Cam" class="zigzag-img">
                    </div>
                    <div class="zigzag-content">
                        <h3 class="zigzag-name">Nước Ép Cam</h3>
                        <p class="zigzag-desc">Cam tươi Bến Tre, vị ngọt tự nhiên — giàu vitamin C, tăng sức đề kháng mỗi ngày.</p>
                        <div class="zigzag-prices">
                            <span class="zigzag-price">Size M — <strong>20K</strong></span>
                            <span class="zigzag-divider">|</span>
                            <span class="zigzag-price">Size L — <strong>25K</strong></span>
                        </div>
                    </div>
                </div>

                <!-- Nước Ép Thơm -->
                <div class="zigzag-block zigzag-reverse reveal">
                    <div class="zigzag-image">
                        <img src="${pageContext.request.contextPath}/images/thom.png" alt="Nước Ép Thơm" class="zigzag-img">
                    </div>
                    <div class="zigzag-content">
                        <h3 class="zigzag-name">Nước Ép Thơm</h3>
                        <p class="zigzag-desc">Dứa thơm lừng, hỗ trợ tiêu hóa tốt — hương vị nhiệt đới đậm đà, sảng khoái.</p>
                        <div class="zigzag-prices">
                            <span class="zigzag-price">Size M — <strong>20K</strong></span>
                            <span class="zigzag-divider">|</span>
                            <span class="zigzag-price">Size L — <strong>25K</strong></span>
                        </div>
                    </div>
                </div>

                <!-- Nước Ép Dưa Hấu -->
                <div class="zigzag-block reveal">
                    <div class="zigzag-image">
                        <img src="${pageContext.request.contextPath}/images/duahau.png" alt="Nước Ép Dưa Hấu" class="zigzag-img">
                    </div>
                    <div class="zigzag-content">
                        <h3 class="zigzag-name">Nước Ép Dưa Hấu</h3>
                        <p class="zigzag-desc">Ngọt mát giải nhiệt mùa hè — bổ sung nước tự nhiên, thanh lọc cơ thể.</p>
                        <div class="zigzag-prices">
                            <span class="zigzag-price">Size M — <strong>20K</strong></span>
                            <span class="zigzag-divider">|</span>
                            <span class="zigzag-price">Size L — <strong>25K</strong></span>
                        </div>
                    </div>
                </div>
            </div>

           

            <!-- ── Classic List + Mix ── -->
            <div class="classic-menu-zone reveal">
                <div class="classic-menu-header">
                    <h3 class="classic-menu-title">Các Món Khác</h3>
                    <div class="classic-menu-size-legend">
                        <span>Size M</span><span>/</span><span>Size L</span>
                    </div>
                </div>

                <ul class="classic-menu-list">
                    <li class="classic-menu-item reveal reveal-delay-1">
                        <div class="classic-item-left">
                            <span class="classic-item-name">Nước Ép Bưởi</span>
                            <span class="classic-item-note">Bưởi da xanh Đồng Nai, thanh mát detox</span>
                        </div>
                        <span class="classic-item-dots"></span>
                        <div class="classic-item-price">20K / 25K</div>
                    </li>
                    <li class="classic-menu-item reveal reveal-delay-2">
                        <div class="classic-item-left">
                            <span class="classic-item-name">Nước Ép Ổi</span>
                            <span class="classic-item-note">Giàu vitamin C, giữ dáng đẹp da</span>
                        </div>
                        <span class="classic-item-dots"></span>
                        <div class="classic-item-price">20K / 25K</div>
                    </li>
                    <li class="classic-menu-item reveal reveal-delay-3">
                        <div class="classic-item-left">
                            <span class="classic-item-name">Nước Ép Cà Rốt</span>
                            <span class="classic-item-note">Sáng mắt, tốt cho sức khỏe</span>
                        </div>
                        <span class="classic-item-dots"></span>
                        <div class="classic-item-price">20K / 25K</div>
                    </li>
                </ul>

                <div class="classic-menu-mix reveal">
                    <div class="classic-mix-badge">🧃 Mix</div>
                    <div class="classic-mix-content">
                        <div class="classic-mix-left">
                            <span class="classic-item-name">Mix Theo Yêu Cầu</span>
                            <span class="classic-item-note">Ghi chú loại trái cây. Đồ uống có sử dụng đường, vui lòng báo nếu muốn giảm/không đường.</span>
                        </div>
                        <span class="classic-item-dots"></span>
                        <div class="classic-item-price">27K / 30K</div>
                    </div>
                </div>
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
                    <img src="https://randomuser.me/api/portraits/women/12.jpg" alt="Oanh" class="team-avatar avatar-oanh">
                    <div class="team-name">Oanh</div>
                    <div class="team-role">Founder / Quản lý</div>
                </div>

                <div class="team-card reveal reveal-delay-2">
                    <img src="https://randomuser.me/api/portraits/women/44.jpg" alt="Tiên" class="team-avatar avatar-tien">
                    <div class="team-name">Tiên</div>
                    <div class="team-role">Marketing</div>
                </div>

                <div class="team-card reveal reveal-delay-3">
                    <img src="https://randomuser.me/api/portraits/men/32.jpg" alt="Kỳ" class="team-avatar avatar-ky">
                    <div class="team-name">Kỳ</div>
                    <div class="team-role">Vận hành</div>
                </div>

                <div class="team-card reveal reveal-delay-4">
                    <img src="https://randomuser.me/api/portraits/women/68.jpg" alt="Thư" class="team-avatar avatar-thu">
                    <div class="team-name">Thư</div>
                    <div class="team-role">Chăm sóc khách hàng</div>
                </div>

                <div class="team-card reveal reveal-delay-5">
                    <img src="https://randomuser.me/api/portraits/women/90.jpg" alt="Trúc" class="team-avatar avatar-truc">
                    <div class="team-name">Trúc</div>
                    <div class="team-role">Tài chính</div>
                </div>
            </div>
        </div>
    </section>

    <!-- ================================================================
     CHECKOUT — Dark Section, Floating Labels
     ================================================================ -->
    <section class="checkout section" id="checkout">
        <div class="container">
            <div class="checkout-info reveal">
                <span class="section-label">Đặt Hàng</span>
                <h2 class="section-title">Đặt Hàng Ngay</h2>
                <p class="section-subtitle">
                    Điền thông tin bên dưới để đặt thức uống tươi.
                    Chúng tôi sẽ giao hàng trong 20-30 phút!
                </p>

                <div class="checkout-features">
                    <div class="checkout-feature">
                        <div class="checkout-feature-icon">🚀</div>
                        <div class="checkout-feature-text">
                            <h4>Giao siêu tốc</h4>
                            <p>20-30 phút đến tay bạn</p>
                        </div>
                    </div>
                    <div class="checkout-feature">
                        <div class="checkout-feature-icon">💳</div>
                        <div class="checkout-feature-text">
                            <h4>Thanh toán khi nhận</h4>
                            <p>COD — không cần trả trước</p>
                        </div>
                    </div>
                    <div class="checkout-feature">
                        <div class="checkout-feature-icon">🎁</div>
                        <div class="checkout-feature-text">
                            <h4>Miễn phí ship</h4>
                            <p>Cho đơn hàng trong khu vực trường</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="order-form-wrapper reveal reveal-delay-2">
                <div class="order-form-title">
                    📝 Thông Tin Đặt Hàng
                </div>

                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-error" id="alertError">
                        ⚠️ ${errorMessage}
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/order" method="POST" id="orderForm" novalidate>

                    <div class="form-group">
                        <input type="text" class="form-control" id="customerName" name="customerName"
                            placeholder="Họ và tên" value="${prevName}" required>
                        <label for="customerName">
                            Họ và Tên <span class="required">*</span>
                        </label>
                    </div>

                    <div class="form-group">
                        <input type="tel" class="form-control" id="phoneNumber" name="phoneNumber"
                            placeholder="Số điện thoại" value="${prevPhone}" required>
                        <label for="phoneNumber">
                            Số Điện Thoại <span class="required">*</span>
                        </label>
                    </div>

                    <div class="form-group">
                        <input type="text" class="form-control" id="shippingAddress" name="shippingAddress"
                            placeholder="Địa chỉ giao hàng" value="${prevAddress}" required>
                        <label for="shippingAddress">
                            Địa Chỉ Giao Hàng <span class="required">*</span>
                        </label>
                    </div>

                    <div class="form-group">
                        <textarea class="form-control" id="orderNote" name="orderNote"
                            placeholder="Ghi chú">${prevNote}</textarea>
                        <label for="orderNote">
                            Ghi Chú Đơn Hàng
                        </label>
                    </div>

                    <button type="submit" class="btn-submit" id="btnSubmit">
                        Xác Nhận Đặt Hàng
                    </button>
                    <div class="freeship-notice">✨ Miễn phí vận chuyển khu vực ở trường ✨</div>
                </form>
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
