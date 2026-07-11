<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt Hàng Thành Công — Nhiệt Đới Xanh</title>
    <meta name="description" content="Cảm ơn bạn đã đặt hàng tại Nhiệt Đới Xanh. Đơn hàng sẽ được giao trong 20-30 phút.">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=EB+Garamond:wght@400;500;600&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

<div class="thankyou-page">
    <div class="thankyou-card">
        <!-- Animated Checkmark -->
        <div class="thankyou-check">
            <svg viewBox="0 0 24 24">
                <polyline points="5 12 10 17 19 7"/>
            </svg>
        </div>

        <h1>Đặt Hàng Thành Công! 🎉</h1>
        <p>
            Cảm ơn bạn đã tin tưởng <strong>Nhiệt Đới Xanh</strong>!<br>
            Đơn hàng của bạn đang được chuẩn bị và sẽ được giao trong
            <strong>20-30 phút</strong>.<br>
            Hãy ngồi thư giãn và chờ ly nước ép tươi mát nhé! 🍹
        </p>

        <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
            <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
            Quay Về Trang Chủ
        </a>
    </div>
</div>

</body>
</html>
