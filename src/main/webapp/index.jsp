<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhiệt Đới Xanh — Trọn Vị Thanh Mát | Nước Ép Trái Cây Tươi</title>
    <meta name="description" content="Nhiệt Đới Xanh - Nước ép trái cây tươi nguyên chất. Cam, Bưởi, Táo, Ép Mix. Giao hỏa tốc 20-30 phút. Ly giấy thân thiện môi trường.">
    <meta name="keywords" content="nước ép trái cây, nước ép tươi, nhiệt đới xanh, nước ép cam, nước ép bưởi">

    <!-- Google Fonts: Be Vietnam Pro + EB Garamond -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800&family=EB+Garamond:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500&display=swap" rel="stylesheet">

    <!-- Stylesheet -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<!-- ================================================================
     NAVIGATION BAR
     ================================================================ -->
<nav class="navbar" id="navbar">
    <div class="container">
        <a href="#hero" class="navbar-brand">
            <div class="navbar-logo">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
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

<!-- ================================================================
     SECTION 1: HERO BANNER
     ================================================================ -->
<section class="hero section" id="hero">
    <div class="container">
        <div class="hero-content">
            <div class="hero-badge">
                <svg viewBox="0 0 24 24"><path d="M12 2L9.19 8.63 2 9.24l5.46 4.73L5.82 21 12 17.27 18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2z"/></svg>
                100% Trái Cây Tươi Nguyên Chất
            </div>

            <h1>
                Nhiệt Đới<br>
                <span class="highlight">Xanh</span>
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
            <div class="hero-illustration">
                <span class="hero-emoji">🍹</span>
                <span class="floating-fruit fruit-1">🍊</span>
                <span class="floating-fruit fruit-2">🍋</span>
                <span class="floating-fruit fruit-3">🍎</span>
                <span class="floating-fruit fruit-4">🥝</span>
            </div>
        </div>
    </div>
</section>

<!-- ================================================================
     SECTION 2: BRAND STORY
     ================================================================ -->
<section class="story section" id="story">
    <div class="container">
        <div class="story-visual reveal">
            <div class="story-image-wrapper">
                <span class="story-emoji-large">🌿🍊🥤</span>
            </div>
            <div class="story-stat">
                <div class="story-stat-number">100%</div>
                <div class="story-stat-label">Nguyên Chất</div>
            </div>
        </div>

        <div class="story-content reveal reveal-delay-2">
            <span class="section-label">Câu Chuyện Của Chúng Tôi</span>
            <h2 class="section-title">Từ Vườn Cây<br>Đến Ly Nước</h2>

            <p>
                Nhiệt Đới Xanh ra đời từ mong muốn mang đến một lựa chọn thức uống
                tươi mát, lành mạnh cho giới trẻ — thay thế cho những lon nước ngọt có gas
                đầy đường hóa học. Chúng tôi tin rằng thiên nhiên đã ban tặng cho Việt Nam
                những loại trái cây nhiệt đới tuyệt vời nhất.
            </p>
            <p>
                Mỗi ly nước ép tại Nhiệt Đới Xanh đều được pha chế từ trái cây tươi nguyên chất,
                không đường, không chất bảo quản, không phẩm màu. Từ những quả cam mọng nước
                Bến Tre, bưởi da xanh Đồng Nai, đến những quả táo giòn tan — tất cả đều được
                tuyển chọn kỹ lưỡng mỗi sáng.
            </p>

            <div class="story-highlights">
                <div class="story-highlight-item">
                    <div class="story-highlight-icon">🌱</div>
                    <div class="story-highlight-text">Nguyên liệu<br>100% tự nhiên</div>
                </div>
                <div class="story-highlight-item">
                    <div class="story-highlight-icon">🚫</div>
                    <div class="story-highlight-text">Không đường<br>Không chất bảo quản</div>
                </div>
                <div class="story-highlight-item">
                    <div class="story-highlight-icon">❤️</div>
                    <div class="story-highlight-text">Tươi mỗi ngày<br>Ép tại chỗ</div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ================================================================
     SECTION 3: CORE VALUES
     ================================================================ -->
<section class="values section" id="values">
    <div class="container">
        <div class="values-header reveal">
            <span class="section-label">Giá Trị Cốt Lõi</span>
            <h2 class="section-title">Vì Sao Chọn Nhiệt Đới Xanh?</h2>
            <p class="section-subtitle">
                Ba cam kết vàng mà chúng tôi đặt lên hàng đầu trong mỗi ly nước gửi đến bạn.
            </p>
        </div>

        <div class="values-grid">
            <!-- Card 1: Sạch Minh Bạch -->
            <div class="value-card reveal reveal-delay-1">
                <div class="value-icon">🔍</div>
                <h3>Sạch & Minh Bạch</h3>
                <p>
                    Nguồn nguyên liệu rõ ràng, quy trình chế biến minh bạch.
                    Bạn hoàn toàn có thể theo dõi từ vườn cây đến ly nước trên tay.
                </p>
            </div>

            <!-- Card 2: Ly Giấy Thân Thiện -->
            <div class="value-card reveal reveal-delay-2">
                <div class="value-icon">🌍</div>
                <h3>Ly Giấy Thân Thiện</h3>
                <p>
                    Chúng tôi sử dụng 100% ly giấy có thể phân hủy sinh học,
                    góp phần giảm rác thải nhựa và bảo vệ môi trường xanh.
                </p>
            </div>

            <!-- Card 3: Giao Hỏa Tốc -->
            <div class="value-card reveal reveal-delay-3">
                <div class="value-icon">⚡</div>
                <h3>Giao Hỏa Tốc</h3>
                <p>
                    Đặt hàng và nhận nước ép tươi trong vòng 20-30 phút.
                    Ly nước vẫn giữ nguyên độ tươi mát khi đến tay bạn.
                </p>
            </div>
        </div>
    </div>
</section>

<!-- ================================================================
     SECTION 4: MENU THANH MÁT
     ================================================================ -->
<section class="menu section" id="menu">
    <div class="container">
        <div class="menu-header reveal">
            <span class="section-label">Thực Đơn</span>
            <h2 class="section-title">Menu Thanh Mát</h2>
            <p class="section-subtitle">
                Những ly nước ép tươi nguyên chất, vừa ngon vừa bổ dưỡng cho sức khỏe mỗi ngày.
            </p>
        </div>

        <!-- Category: Phổ Thông -->
        <div class="menu-category reveal">
            <div class="menu-category-title">🍊 Nước Ép Phổ Thông</div>
            <div class="menu-grid">
                <!-- Cam -->
                <div class="menu-card reveal reveal-delay-1">
                    <div class="menu-card-top">
                        <div class="menu-card-emoji">🍊</div>
                        <div class="menu-card-info">
                            <h4>Nước Ép Cam</h4>
                            <p class="menu-card-desc">Cam tươi Bến Tre, vị ngọt tự nhiên</p>
                        </div>
                    </div>
                    <div class="menu-card-prices">
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size M</div>
                            <div class="menu-price-value">20<sup>K</sup></div>
                        </div>
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size L</div>
                            <div class="menu-price-value">25<sup>K</sup></div>
                        </div>
                    </div>
                </div>

                <!-- Bưởi -->
                <div class="menu-card reveal reveal-delay-2">
                    <div class="menu-card-top">
                        <div class="menu-card-emoji">🍈</div>
                        <div class="menu-card-info">
                            <h4>Nước Ép Bưởi</h4>
                            <p class="menu-card-desc">Bưởi da xanh Đồng Nai, thanh mát detox</p>
                        </div>
                    </div>
                    <div class="menu-card-prices">
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size M</div>
                            <div class="menu-price-value">20<sup>K</sup></div>
                        </div>
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size L</div>
                            <div class="menu-price-value">25<sup>K</sup></div>
                        </div>
                    </div>
                </div>

                <!-- Táo -->
                <div class="menu-card reveal reveal-delay-3">
                    <div class="menu-card-top">
                        <div class="menu-card-emoji">🍎</div>
                        <div class="menu-card-info">
                            <h4>Nước Ép Táo</h4>
                            <p class="menu-card-desc">Táo tươi giòn ngọt, giàu vitamin C</p>
                        </div>
                    </div>
                    <div class="menu-card-prices">
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size M</div>
                            <div class="menu-price-value">20<sup>K</sup></div>
                        </div>
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size L</div>
                            <div class="menu-price-value">25<sup>K</sup></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Category: Ép Mix -->
        <div class="menu-category reveal">
            <div class="menu-category-title">🧃 Nước Ép Mix</div>
            <div class="menu-grid">
                <!-- Cam + Bưởi -->
                <div class="menu-card reveal reveal-delay-1">
                    <div class="menu-card-top">
                        <div class="menu-card-emoji">🍊🍈</div>
                        <div class="menu-card-info">
                            <h4>Mix Cam – Bưởi</h4>
                            <p class="menu-card-desc">Sự kết hợp thanh mát, tăng cường sức đề kháng</p>
                        </div>
                    </div>
                    <div class="menu-card-prices">
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size M</div>
                            <div class="menu-price-value">27<sup>K</sup></div>
                        </div>
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size L</div>
                            <div class="menu-price-value">30<sup>K</sup></div>
                        </div>
                    </div>
                </div>

                <!-- Táo + Cam -->
                <div class="menu-card reveal reveal-delay-2">
                    <div class="menu-card-top">
                        <div class="menu-card-emoji">🍎🍊</div>
                        <div class="menu-card-info">
                            <h4>Mix Táo – Cam</h4>
                            <p class="menu-card-desc">Ngọt dịu, giàu chất xơ & vitamin</p>
                        </div>
                    </div>
                    <div class="menu-card-prices">
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size M</div>
                            <div class="menu-price-value">27<sup>K</sup></div>
                        </div>
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size L</div>
                            <div class="menu-price-value">30<sup>K</sup></div>
                        </div>
                    </div>
                </div>

                <!-- 3 Vị Mix -->
                <div class="menu-card reveal reveal-delay-3">
                    <div class="menu-card-top">
                        <div class="menu-card-emoji">🌈</div>
                        <div class="menu-card-info">
                            <h4>Mix 3 Vị Đặc Biệt</h4>
                            <p class="menu-card-desc">Cam + Bưởi + Táo, hương vị trọn vẹn nhất</p>
                        </div>
                    </div>
                    <div class="menu-card-prices">
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size M</div>
                            <div class="menu-price-value">27<sup>K</sup></div>
                        </div>
                        <div class="menu-price-tag">
                            <div class="menu-price-size">Size L</div>
                            <div class="menu-price-value">30<sup>K</sup></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ================================================================
     SECTION 5: ĐỘI NGŨ QUẢN TRỊ
     ================================================================ -->
<section class="team section" id="team">
    <div class="container">
        <div class="team-header reveal">
            <span class="section-label">Đội Ngũ</span>
            <h2 class="section-title">Đội Ngũ Quản Trị</h2>
            <p class="section-subtitle">
                Những con người tận tâm đứng sau mỗi ly nước ép tươi mát gửi đến bạn.
            </p>
        </div>

        <div class="team-grid">
            <!-- Oanh -->
            <div class="team-card reveal reveal-delay-1">
                <div class="team-avatar avatar-oanh">👩‍💼</div>
                <div class="team-name">Oanh</div>
                <div class="team-role">Giám Đốc Điều Hành</div>
            </div>

            <!-- Tiên -->
            <div class="team-card reveal reveal-delay-2">
                <div class="team-avatar avatar-tien">👩‍🔬</div>
                <div class="team-name">Tiên</div>
                <div class="team-role">Quản Lý Chất Lượng</div>
            </div>

            <!-- Kỳ -->
            <div class="team-card reveal reveal-delay-3">
                <div class="team-avatar avatar-ky">👨‍🍳</div>
                <div class="team-name">Kỳ</div>
                <div class="team-role">Trưởng Bộ Phận Pha Chế</div>
            </div>

            <!-- Thư -->
            <div class="team-card reveal reveal-delay-4">
                <div class="team-avatar avatar-thu">👩‍💻</div>
                <div class="team-name">Thư</div>
                <div class="team-role">Marketing & Truyền Thông</div>
            </div>

            <!-- Trúc -->
            <div class="team-card reveal reveal-delay-5">
                <div class="team-avatar avatar-truc">👩‍🚀</div>
                <div class="team-name">Trúc</div>
                <div class="team-role">Quản Lý Vận Hành</div>
            </div>
        </div>
    </div>
</section>

<!-- ================================================================
     SECTION 6: CHECKOUT FORM
     ================================================================ -->
<section class="checkout section" id="checkout">
    <div class="container">
        <div class="checkout-info reveal">
            <span class="section-label">Đặt Hàng</span>
            <h2 class="section-title">Đặt Ngay, Giao Liền!</h2>
            <p class="section-subtitle">
                Điền thông tin bên dưới để đặt nước ép tươi.
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
                        <p>Cho đơn hàng từ 50K</p>
                    </div>
                </div>
            </div>
        </div>

        <div class="order-form-wrapper reveal reveal-delay-2">
            <div class="order-form-title">
                📝 Thông Tin Đặt Hàng
            </div>

            <!-- Error Message from Server -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-error" id="alertError">
                    ⚠️ ${errorMessage}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/order" method="POST" id="orderForm" novalidate>

                <div class="form-group">
                    <label for="customerName">
                        Họ và Tên <span class="required">*</span>
                    </label>
                    <input type="text"
                           class="form-control"
                           id="customerName"
                           name="customerName"
                           placeholder="Nguyễn Văn A"
                           value="${prevName}"
                           required>
                </div>

                <div class="form-group">
                    <label for="phoneNumber">
                        Số Điện Thoại <span class="required">*</span>
                    </label>
                    <input type="tel"
                           class="form-control"
                           id="phoneNumber"
                           name="phoneNumber"
                           placeholder="0901234567"
                           value="${prevPhone}"
                           required>
                </div>

                <div class="form-group">
                    <label for="shippingAddress">
                        Địa Chỉ Giao Hàng <span class="required">*</span>
                    </label>
                    <input type="text"
                           class="form-control"
                           id="shippingAddress"
                           name="shippingAddress"
                           placeholder="123 Đường ABC, Quận XYZ, TP. HCM"
                           value="${prevAddress}"
                           required>
                </div>

                <div class="form-group">
                    <label for="orderNote">
                        Ghi Chú Đơn Hàng
                    </label>
                    <textarea class="form-control"
                              id="orderNote"
                              name="orderNote"
                              placeholder="Ít đá, thêm đường, giao giờ hành chính...">${prevNote}</textarea>
                </div>

                <button type="submit" class="btn-submit" id="btnSubmit">
                    🛒 Gửi Đơn Đặt Hàng
                </button>

            </form>
        </div>
    </div>
</section>

<!-- ================================================================
     FOOTER
     ================================================================ -->
<footer class="footer">
    <div class="container">
        <p class="footer-text">
            © 2025 <span>Nhiệt Đới Xanh</span>. Trọn Vị Thanh Mát — Made with 💚 in Vietnam.
        </p>
    </div>
</footer>

<!-- ================================================================
     JAVASCRIPT
     ================================================================ -->
<script>
    // ===== Navbar Scroll Effect =====
    const navbar = document.getElementById('navbar');
    window.addEventListener('scroll', () => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    });

    // ===== Mobile Nav Toggle =====
    const navToggle = document.getElementById('navToggle');
    const navLinks = document.getElementById('navLinks');

    navToggle.addEventListener('click', () => {
        navLinks.classList.toggle('active');
    });

    // Close nav when clicking a link
    navLinks.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('active');
        });
    });

    // ===== Scroll Reveal Animation (Intersection Observer) =====
    const revealElements = document.querySelectorAll('.reveal');

    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                revealObserver.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.15,
        rootMargin: '0px 0px -50px 0px'
    });

    revealElements.forEach(el => revealObserver.observe(el));

    // ===== Client-side Form Validation =====
    const orderForm = document.getElementById('orderForm');
    if (orderForm) {
        orderForm.addEventListener('submit', function(e) {
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

    // ===== Smooth scroll for anchor links =====
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                const offset = 80; // navbar height
                const y = target.getBoundingClientRect().top + window.pageYOffset - offset;
                window.scrollTo({ top: y, behavior: 'smooth' });
            }
        });
    });
</script>

</body>
</html>
