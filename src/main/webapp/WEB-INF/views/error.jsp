<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oops! Có Lỗi Xảy Ra — Nhiệt Đới Xanh</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700;800&family=EB+Garamond:wght@400;500;600&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${initParam.assetVer}">
</head>
<body>

<div class="error-page">
    <div class="error-card">
        <div class="error-code">
            <%= response.getStatus() %>
        </div>
        <h1>Oops! Có Lỗi Xảy Ra 😅</h1>
        <p>
            Trang bạn tìm kiếm không tồn tại hoặc đã xảy ra sự cố.
            Hãy quay về trang chủ và thử lại nhé!
        </p>
        <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
            <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
            Quay Về Trang Chủ
        </a>
    </div>
</div>

</body>
</html>
