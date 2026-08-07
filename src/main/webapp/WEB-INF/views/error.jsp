<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Oops! Có Lỗi Xảy Ra — Nhiệt Đới Xanh</title>


                    <link rel="icon" href="${pageContext.request.contextPath}/favicon.ico" sizes="any">
                    <link rel="apple-touch-icon" href="${pageContext.request.contextPath}/apple-touch-icon.png">
                    <link rel="stylesheet"
                        href="${pageContext.request.contextPath}/css/fonts.css?v=${initParam.assetVer}">
                    <link rel="stylesheet"
                        href="${pageContext.request.contextPath}/css/icons.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${initParam.assetVer}">
</head>
<body>

<div class="error-page">
    <div class="error-card">
        <div class="error-code">
            <%= response.getStatus() %>
        </div>
        <%-- Mỗi mã lỗi có nguyên nhân và cách xử lý khác hẳn nhau. Trước đây mọi mã đều
             hiện chung một câu "trang không tồn tại", nên khách gặp 403 (thường chỉ là
             hết phiên đăng nhập) lại tưởng web hỏng và bỏ đi. --%>
        <% int sc = response.getStatus(); %>
        <% if (sc == 403) { %>
            <h1>Phiên làm việc đã hết hạn ⏱️</h1>
            <p>
                Bạn để trang mở quá lâu nên hệ thống đã đóng phiên cũ để giữ an toàn cho tài khoản.
                Đây không phải lỗi của bạn — chỉ cần mở lại và thao tác lại là được nhé!
            </p>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
                <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18"><path d="M10 17l5-5-5-5v3H3v4h7v3zm9-14H5a2 2 0 0 0-2 2v4h2V5h14v14H5v-4H3v4a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2z"/></svg>
                Đăng Nhập Lại
            </a>
        <% } else if (sc == 429) { %>
            <h1>Bạn thao tác hơi nhanh 🚦</h1>
            <p>
                Hệ thống tạm khoá thao tác này khoảng 15 phút để chống dò mật khẩu tự động.
                Bạn nghỉ một chút rồi thử lại giúp nhé!
            </p>
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
                Quay Về Trang Chủ
            </a>
        <% } else { %>
            <h1>Oops! Có Lỗi Xảy Ra 😅</h1>
            <p>
                Trang bạn tìm kiếm không tồn tại hoặc đã xảy ra sự cố.
                Hãy quay về trang chủ và thử lại nhé!
            </p>
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                <svg viewBox="0 0 24 24" fill="currentColor" width="18" height="18"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
                Quay Về Trang Chủ
            </a>
        <% } %>
    </div>
</div>

</body>
</html>
