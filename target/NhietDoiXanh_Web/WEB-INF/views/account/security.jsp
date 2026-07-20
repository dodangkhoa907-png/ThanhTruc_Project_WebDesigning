<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảo Mật — Nhiệt Đới Xanh</title>
    <meta name="csrf-token" content="${sessionScope._csrf}">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/account.css?v=${initParam.assetVer}">
</head>

<body class="shop-page-body">

    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>

    <section class="section" style="padding-top:130px;">
        <div class="container">

            <c:if test="${not empty flashSuccess}"><div class="account-flash success"><c:out value="${flashSuccess}"/></div></c:if>
            <c:if test="${not empty flashError}"><div class="account-flash error"><c:out value="${flashError}"/></div></c:if>

            <div class="account-page-header">
                <div class="account-page-title">Bảo Mật</div>
                <div class="account-page-subtitle">Đổi mật khẩu có xác minh OTP qua email để bảo vệ tài khoản</div>
            </div>

            <div class="account-shell">
                <%@ include file="/WEB-INF/views/common/account-sidebar.jsp" %>

                <div class="account-card" style="max-width:480px;">
                    <c:choose>
                        <%-- ================= BƯỚC 2: NHẬP OTP ================= --%>
                        <c:when test="${otpStep}">
                            <div class="account-card-title"><span><i class="fa-solid fa-envelope-circle-check"></i> Xác minh OTP</span></div>

                            <p class="account-otp-lead">
                                Chúng tôi đã gửi mã OTP gồm 6 chữ số đến email
                                <strong><c:out value="${otpEmailMasked}"/></strong>.
                                Mã có hiệu lực trong 5 phút.
                            </p>

                            <form method="post" action="${pageContext.request.contextPath}/account/password/change" id="otpForm">
                                <input type="hidden" name="_csrf" value="${sessionScope._csrf}">

                                <div class="account-field">
                                    <label for="otp">Mã xác minh (OTP) <span class="required">*</span></label>
                                    <input type="text" id="otp" name="otp" inputmode="numeric" pattern="[0-9]*"
                                           maxlength="6" required autocomplete="one-time-code"
                                           placeholder="Nhập 6 chữ số"
                                           style="letter-spacing:8px;font-size:1.3rem;text-align:center;font-weight:700;">
                                </div>

                                <div class="account-otp-timer" id="otpTimer" data-remaining="${otpRemainingMs}"></div>

                                <button type="submit" class="btn-shop btn-shop-primary">
                                    <i class="fa-solid fa-shield-halved"></i> Xác nhận và đổi mật khẩu
                                </button>
                            </form>

                            <form method="post" action="${pageContext.request.contextPath}/account/password/resend-otp" style="margin-top:14px;">
                                <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                                <button type="submit" class="btn-shop btn-shop-outline" id="resendBtn" style="width:100%;">
                                    <i class="fa-solid fa-rotate-right"></i> Gửi lại mã
                                </button>
                            </form>
                        </c:when>

                        <%-- ================= BƯỚC 1: NHẬP MẬT KHẨU ================= --%>
                        <c:otherwise>
                            <div class="account-card-title"><span><i class="fa-solid fa-key"></i> Đổi mật khẩu</span></div>

                            <form method="post" action="${pageContext.request.contextPath}/account/password/request-otp" id="passwordForm">
                                <input type="hidden" name="_csrf" value="${sessionScope._csrf}">

                                <div class="account-field">
                                    <label for="currentPassword">Mật khẩu hiện tại <span class="required">*</span></label>
                                    <div class="account-password-wrap">
                                        <input type="password" id="currentPassword" name="currentPassword" required autocomplete="current-password">
                                        <button type="button" class="account-password-toggle" data-target="currentPassword" aria-label="Hiện/ẩn mật khẩu"><i class="fa-solid fa-eye"></i></button>
                                    </div>
                                </div>
                                <div class="account-field">
                                    <label for="newPassword">Mật khẩu mới <span class="required">*</span></label>
                                    <div class="account-password-wrap">
                                        <input type="password" id="newPassword" name="newPassword" required autocomplete="new-password">
                                        <button type="button" class="account-password-toggle" data-target="newPassword" aria-label="Hiện/ẩn mật khẩu"><i class="fa-solid fa-eye"></i></button>
                                    </div>
                                    <div class="account-strength" id="pwStrength" hidden>
                                        <div class="account-strength-bar"><span id="pwStrengthFill"></span></div>
                                        <div class="account-strength-label" id="pwStrengthLabel"></div>
                                    </div>
                                    <div class="account-field-hint">Tối thiểu 6 ký tự, gồm chữ hoa, chữ thường và số.</div>
                                </div>
                                <div class="account-field">
                                    <label for="confirmPassword">Xác nhận mật khẩu mới <span class="required">*</span></label>
                                    <div class="account-password-wrap">
                                        <input type="password" id="confirmPassword" name="confirmPassword" required autocomplete="new-password">
                                        <button type="button" class="account-password-toggle" data-target="confirmPassword" aria-label="Hiện/ẩn mật khẩu"><i class="fa-solid fa-eye"></i></button>
                                    </div>
                                    <div class="account-field-error" id="confirmError" style="display:none;">Xác nhận mật khẩu không khớp.</div>
                                </div>

                                <button type="submit" class="btn-shop btn-shop-primary">
                                    <i class="fa-solid fa-paper-plane"></i> Gửi mã xác minh
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </section>

    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 50));
        navbar.classList.add('scrolled');
        const navToggle = document.getElementById('navToggle');
        const navLinks = document.getElementById('navLinks');
        navToggle.addEventListener('click', () => navLinks.classList.toggle('active'));

        // Show/hide password
        document.querySelectorAll('.account-password-toggle').forEach((btn) => {
            btn.addEventListener('click', () => {
                const input = document.getElementById(btn.dataset.target);
                if (!input) return;
                const show = input.type === 'password';
                input.type = show ? 'text' : 'password';
                btn.querySelector('i').className = show ? 'fa-solid fa-eye-slash' : 'fa-solid fa-eye';
            });
        });

        // Password strength hint
        const newPassword = document.getElementById('newPassword');
        if (newPassword) {
            const wrap = document.getElementById('pwStrength');
            const fill = document.getElementById('pwStrengthFill');
            const label = document.getElementById('pwStrengthLabel');
            newPassword.addEventListener('input', () => {
                const v = newPassword.value;
                if (!v) { wrap.hidden = true; return; }
                wrap.hidden = false;
                let score = 0;
                if (v.length >= 6) score++;
                if (/[a-z]/.test(v) && /[A-Z]/.test(v)) score++;
                if (/\d/.test(v)) score++;
                if (v.length >= 10 && /[^A-Za-z0-9]/.test(v)) score++;
                const levels = ['Yếu', 'Trung bình', 'Khá', 'Mạnh'];
                const colors = ['#D9534F', '#F4A261', '#3A7D4A', '#2A5C38'];
                const idx = Math.max(0, Math.min(3, score - 1));
                fill.style.width = (score * 25) + '%';
                fill.style.background = colors[idx];
                label.textContent = v ? levels[idx] : '';
                label.style.color = colors[idx];
            });
        }

        // Confirm match
        const form = document.getElementById('passwordForm');
        if (form) {
            const confirmPassword = document.getElementById('confirmPassword');
            const confirmError = document.getElementById('confirmError');
            form.addEventListener('submit', (e) => {
                if (newPassword.value !== confirmPassword.value) {
                    e.preventDefault();
                    confirmError.style.display = 'block';
                    confirmPassword.focus();
                }
            });
        }

        // OTP resend cooldown + expiry countdown
        const timer = document.getElementById('otpTimer');
        const resendBtn = document.getElementById('resendBtn');
        if (timer) {
            let remaining = Math.floor((parseInt(timer.dataset.remaining, 10) || 0) / 1000);
            function tick() {
                if (remaining <= 0) {
                    timer.textContent = 'Mã OTP đã hết hạn. Vui lòng gửi lại mã.';
                    timer.style.color = '#D9534F';
                    return;
                }
                const m = Math.floor(remaining / 60);
                const s = remaining % 60;
                timer.textContent = 'Mã hết hạn sau ' + m + ':' + (s < 10 ? '0' : '') + s;
                remaining--;
                setTimeout(tick, 1000);
            }
            tick();
        }
        if (resendBtn) {
            let cooldown = 60;
            const origHtml = resendBtn.innerHTML;
            resendBtn.disabled = true;
            function cd() {
                if (cooldown <= 0) {
                    resendBtn.disabled = false;
                    resendBtn.innerHTML = origHtml;
                    return;
                }
                resendBtn.innerHTML = '<i class="fa-solid fa-clock"></i> Gửi lại mã (' + cooldown + 's)';
                cooldown--;
                setTimeout(cd, 1000);
            }
            cd();
        }
    </script>
</body>
</html>
