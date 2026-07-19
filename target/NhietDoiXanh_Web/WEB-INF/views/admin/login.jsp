<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Đăng nhập Quản trị — Nhiệt Đới Xanh</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;700;800&family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
:root{--green:#2A5C38;--green-dark:#1E3F27;--gold:#F4A261;--gold-light:#F9C784;--cream:#FDFBF7;--paper:#FFFFFF;--ink:#1A2E1A;--ink-soft:#7A8D7A;--line:#E8E0D0;--fd:'Baloo 2',sans-serif;--fb:'Be Vietnam Pro',sans-serif}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:var(--fb);background:var(--cream);color:var(--ink);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:28px}
a{text-decoration:none;color:inherit}button{font:inherit;cursor:pointer;border:none}
.blob{position:fixed;border-radius:50%;filter:blur(60px);opacity:.3;pointer-events:none;z-index:0;animation:drift 14s ease-in-out infinite}
.blob.b1{width:380px;height:380px;background:var(--gold-light);top:-120px;left:-100px}
.blob.b2{width:320px;height:320px;background:var(--green);opacity:.15;bottom:-100px;right:-80px;animation-delay:-6s}
@keyframes drift{0%,100%{transform:translate(0,0)}50%{transform:translate(26px,-30px)}}
.back{position:fixed;top:22px;left:24px;z-index:20;display:inline-flex;align-items:center;gap:8px;background:var(--paper);border:1px solid var(--line);padding:10px 20px;border-radius:99px;font-weight:600;font-size:13.5px;color:var(--ink-soft);box-shadow:0 10px 26px -14px rgba(20,30,20,.3)}
.back:hover{color:var(--green)}
@keyframes cardIn{from{opacity:0;transform:translateY(36px) scale(.97)}to{opacity:1;transform:none}}
.auth{position:relative;z-index:5;width:min(920px,100%);display:grid;grid-template-columns:1fr 1fr;background:var(--paper);border-radius:30px;overflow:hidden;box-shadow:0 40px 90px -36px rgba(30,63,39,.35);border:1px solid var(--line);animation:cardIn .7s cubic-bezier(.16,1,.3,1)}
.pane{padding:52px 50px}
.logo{display:inline-flex;align-items:center;gap:9px;font-family:var(--fd);font-weight:700;font-size:20px;color:var(--green-dark);margin-bottom:26px}
.logo b{color:var(--gold)}
.pane h1{font-family:var(--fd);font-weight:700;font-size:clamp(24px,3vw,30px);line-height:1.15;color:var(--green-dark)}
.pane .sub{color:var(--ink-soft);margin:10px 0 26px;font-size:14.5px}
.alert{border-radius:14px;padding:13px 16px;font-size:13.5px;font-weight:600;margin-bottom:18px;display:flex;gap:9px;align-items:flex-start;background:#FBE3E1;color:#8E1F1F;border:1px solid #F0A199}
.field{margin-bottom:18px}
.field label{display:block;font-size:12px;font-weight:800;letter-spacing:.06em;text-transform:uppercase;color:var(--ink-soft);margin-bottom:7px}
.field .box{position:relative}
.field input{width:100%;padding:14px 16px;border-radius:14px;border:1.5px solid var(--line);background:#FFF;font:inherit;font-size:15px;color:var(--ink)}
.field input:focus{outline:none;border-color:var(--green);box-shadow:0 0 0 4px rgba(42,92,56,.12)}
.eye{position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;color:var(--ink-soft);display:flex;padding:4px}
.submit{width:100%;padding:15px;border-radius:14px;background:linear-gradient(135deg,var(--green),var(--green-dark));color:#fff;font-weight:700;font-size:15.5px;box-shadow:0 16px 30px -14px rgba(42,92,56,.6)}
.submit:hover{transform:translateY(-2px)}
.side{position:relative;background:linear-gradient(150deg,var(--green) 0%,var(--green-dark) 100%);color:#fff;display:flex;flex-direction:column;justify-content:center;padding:52px 44px;overflow:hidden}
.side::before,.side::after{content:"";position:absolute;border-radius:50%;background:rgba(255,255,255,.07)}
.side::before{width:300px;height:300px;top:-100px;right:-90px}
.side::after{width:220px;height:220px;bottom:-80px;left:-60px}
.side .badge{width:80px;height:80px;border-radius:50%;background:rgba(255,255,255,.14);border:1.5px dashed rgba(255,255,255,.45);display:flex;align-items:center;justify-content:center;margin:0 auto 22px;font-size:34px}
.side h2{font-family:var(--fd);font-weight:700;font-size:24px;text-align:center;margin-bottom:10px;position:relative;z-index:1}
.side p{text-align:center;color:rgba(255,255,255,.82);font-size:14px;max-width:280px;margin:0 auto;position:relative;z-index:1}
@media(max-width:760px){.auth{grid-template-columns:1fr}.side{display:none}.pane{padding:42px 30px}}
</style>
</head>
<body>
<span class="blob b1"></span><span class="blob b2"></span>
<a href="${ctx}/" class="back">← Về trang chủ</a>

<div class="auth">
  <div class="side">
    <div class="badge">🌿</div>
    <h2>Khu vực quản trị</h2>
    <p>Quản lý sản phẩm, đơn hàng và phản hồi khách hàng của Nhiệt Đới Xanh.</p>
  </div>
  <div class="pane">
    <a href="${ctx}/" class="logo">Nhiệt Đới <b>Xanh</b></a>
    <h1>Đăng nhập quản trị</h1>
    <p class="sub">Dành cho nhân viên &amp; quản lý cửa hàng.</p>

    <c:if test="${not empty errorMessage}"><div class="alert">⚠️ <c:out value="${errorMessage}"/></div></c:if>

    <form method="post" action="${ctx}/admin/login" autocomplete="on">
      <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
      <div class="field">
        <label for="username">Tên đăng nhập</label>
        <div class="box"><input type="text" id="username" name="username" placeholder="oanhttk" required autofocus value="${fn:escapeXml(param.username)}"></div>
      </div>
      <div class="field">
        <label for="password">Mật khẩu</label>
        <div class="box">
          <input type="password" id="password" name="password" placeholder="••••••••" required>
          <button type="button" class="eye" onclick="togglePw('password')" aria-label="Hiện mật khẩu"><i class="fa-regular fa-eye"></i></button>
        </div>
      </div>
      <button type="submit" class="submit">Đăng nhập</button>
    </form>
  </div>
</div>

<script>function togglePw(id){var i=document.getElementById(id);i.type=i.type==='password'?'text':'password';}</script>
</body>
</html>
