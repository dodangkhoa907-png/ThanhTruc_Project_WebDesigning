<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhiệt Đới Xanh - Đặt Hàng Thành Công</title>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            background-color: var(--background);
            font-family: 'Be Vietnam Pro', sans-serif;
            margin: 0;
        }
        .thankyou-container {
            text-align: center;
            background: #ffffff;
            padding: 50px 40px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            max-width: 500px;
            width: 90%;
        }
        .thankyou-container h1 {
            color: var(--primary);
            margin-bottom: 20px;
        }
        .thankyou-container p {
            color: var(--text);
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .success-icon {
            font-size: 60px;
            color: var(--primary);
            margin-bottom: 20px;
        }
        .btn-home {
            display: inline-block;
            background: var(--primary);
            color: white;
            padding: 12px 30px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
        }
        .btn-home:hover {
            background: var(--secondary);
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="thankyou-container">
        <div class="success-icon">✔️</div>
        <h1>Đặt Hàng Thành Công!</h1>
        <p>Cảm ơn bạn đã lựa chọn <strong>Nhiệt Đới Xanh</strong>. Đơn hàng của bạn đã được ghi nhận và đang được chuẩn bị. Chúng tôi sẽ giao hỏa tốc đến bạn trong thời gian sớm nhất!</p>
        <a href="${pageContext.request.contextPath}/" class="btn-home">Quay lại trang chủ</a>
    </div>
</body>
</html>
