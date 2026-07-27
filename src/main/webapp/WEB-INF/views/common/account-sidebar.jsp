<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Sidebar tài khoản dùng chung cho mọi trang /account/*.
     Cần request attribute "accountTab" ("overview" | "orders" | "profile" | "addresses"
     | "preferences" | "security") để tô active. --%>
<aside class="account-sidebar">
    <nav class="account-nav">
        <a href="${pageContext.request.contextPath}/account" class="${accountTab == 'overview' ? 'active' : ''}">
            <i class="fa-solid fa-gauge"></i> Tổng quan
        </a>
        <a href="${pageContext.request.contextPath}/account/orders" class="${accountTab == 'orders' ? 'active' : ''}">
            <i class="fa-solid fa-box"></i> Đơn hàng
        </a>
        <div class="account-nav-divider"></div>
        <a href="${pageContext.request.contextPath}/account/profile" class="${accountTab == 'profile' ? 'active' : ''}">
            <i class="fa-solid fa-user"></i> Hồ sơ cá nhân
        </a>
        <a href="${pageContext.request.contextPath}/account/addresses" class="${accountTab == 'addresses' ? 'active' : ''}">
            <i class="fa-solid fa-location-dot"></i> Sổ địa chỉ
        </a>
        <a href="${pageContext.request.contextPath}/account/preferences" class="${accountTab == 'preferences' ? 'active' : ''}">
            <i class="fa-solid fa-heart"></i> Sở thích
        </a>
        <a href="${pageContext.request.contextPath}/account/security" class="${accountTab == 'security' ? 'active' : ''}">
            <i class="fa-solid fa-shield-halved"></i> Bảo mật
        </a>
        <div class="account-nav-divider"></div>
        <form method="post" action="${pageContext.request.contextPath}/logout">
            <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
            <button type="submit"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</button>
        </form>
    </nav>
</aside>
<script>
    // Mobile: thanh tab cuộn ngang — tự đưa tab đang active vào giữa tầm nhìn (vd đang ở
    // "Bảo mật" thì tab nằm khuất bên phải). Đặt scrollLeft trực tiếp trên .account-nav
    // (không dùng scrollIntoView vì nó cuộn cả trang và kém ổn định với container lồng nhau).
    (function () {
        // Trả về true nếu đã căn xong (hoặc không cần), false nếu chưa đủ điều kiện để thử lại.
        function centerActiveTab() {
            var nav = document.querySelector('.account-nav');
            var active = nav && nav.querySelector('a.active');
            if (!nav || !active) return true;                 // không có gì để làm
            if (nav.scrollWidth <= nav.clientWidth) return false; // layout ngang/FA font chưa xong → thử lại
            var target = active.offsetLeft - (nav.clientWidth - active.offsetWidth) / 2;
            if (target <= 0) return true;                     // tab đã nằm đầu, khỏi cuộn
            // Gán scrollLeft trực tiếp (tức thời): scrollTo({behavior:'smooth'}) là no-op trên
            // một số trình duyệt với container cuộn lồng nhau. Căn vị trí lúc tải nên tức thời.
            nav.scrollLeft = target;
            return true;
        }
        // Poll tự dừng: FontAwesome tải qua CDN có thể xong sau window.load nên bề rộng tab đổi
        // muộn; cứ thử tới khi căn được (hoặc hết ~3s) thay vì đoán đúng một mốc thời gian.
        var tries = 0;
        var iv = setInterval(function () {
            if (centerActiveTab() || ++tries > 20) clearInterval(iv);
        }, 150);
    })();
</script>
