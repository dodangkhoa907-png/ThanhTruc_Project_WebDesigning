<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Đăng nhập — Nhiệt Đới Xanh</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;700;800&family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
:root{--green:#2A5C38;--green-dark:#1E3F27;--green-light:#3A7D4A;--gold:#F4A261;--gold-light:#F9C784;--coral:#D9534F;--cream:#FDFBF7;--paper:#FFFFFF;--ink:#1A2E1A;--ink-soft:#7A8D7A;--line:#E8E0D0;--fd:'Baloo 2',sans-serif;--fb:'Be Vietnam Pro',sans-serif}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:var(--fb);background:var(--cream);color:var(--ink);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:28px;overflow-x:hidden}
a{text-decoration:none;color:inherit}button{font:inherit;cursor:pointer;border:none}
.blob{position:fixed;border-radius:50%;filter:blur(60px);opacity:.3;pointer-events:none;z-index:0;animation:drift 14s ease-in-out infinite}
.blob.b1{width:380px;height:380px;background:var(--gold-light);top:-120px;left:-100px}
.blob.b2{width:320px;height:320px;background:var(--green-light);opacity:.2;bottom:-100px;right:-80px;animation-delay:-6s}
@keyframes drift{0%,100%{transform:translate(0,0)}50%{transform:translate(26px,-30px)}}
.back{position:fixed;top:22px;left:24px;z-index:20;display:inline-flex;align-items:center;gap:8px;background:var(--paper);border:1px solid var(--line);padding:10px 20px;border-radius:99px;font-weight:600;font-size:13.5px;color:var(--ink-soft);box-shadow:0 10px 26px -14px rgba(20,30,20,.3);transition:transform .2s,color .2s}
.back:hover{transform:translateX(-3px);color:var(--green)}
@keyframes cardIn{from{opacity:0;transform:translateY(36px) scale(.97)}to{opacity:1;transform:none}}
.auth{position:relative;z-index:5;width:min(1000px,100%);display:grid;grid-template-columns:1.05fr .95fr;background:var(--paper);border-radius:30px;overflow:hidden;box-shadow:0 40px 90px -36px rgba(30,63,39,.35);border:1px solid var(--line);animation:cardIn .7s cubic-bezier(.16,1,.3,1)}
.pane{padding:52px 54px}
.logo{display:inline-flex;align-items:center;gap:9px;font-family:var(--fd);font-weight:700;font-size:22px;color:var(--green-dark);margin-bottom:26px}
.logo b{color:var(--gold)}
.pane h1{font-family:var(--fd);font-weight:700;font-size:clamp(26px,3vw,34px);line-height:1.15;color:var(--green-dark)}
.pane .sub{color:var(--ink-soft);margin:10px 0 26px;font-size:15px}
.alert{border-radius:14px;padding:13px 16px;font-size:13.5px;font-weight:600;margin-bottom:18px;display:flex;gap:9px;align-items:flex-start}
.alert.err{background:#FBE3E1;color:#8E1F1F;border:1px solid #F0A199}
.alert.ok{background:#E7F6EC;color:#187A43;border:1px solid #BFE4CC}
.field{margin-bottom:16px}
.field label{display:block;font-size:12px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:var(--ink-soft);margin-bottom:7px}
.field .box{position:relative}
.field input{width:100%;padding:14px 16px;border-radius:14px;border:1.5px solid var(--line);background:#FFF;font:inherit;font-size:15px;color:var(--ink);transition:border-color .2s,box-shadow .2s}
.field input:focus{outline:none;border-color:var(--green);box-shadow:0 0 0 4px rgba(42,92,56,.12)}
.eye{position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;color:var(--ink-soft);display:flex;padding:4px}
.row{display:flex;align-items:center;justify-content:space-between;margin:2px 0 20px;font-size:13.5px}
.row label{display:flex;align-items:center;gap:7px;color:var(--ink-soft);font-weight:600;cursor:pointer}
.row a{color:var(--green);font-weight:700}
.row a:hover{text-decoration:underline}
.submit{width:100%;padding:15px;border-radius:14px;background:linear-gradient(135deg,var(--green),var(--green-dark));color:#fff;font-weight:700;font-size:15.5px;box-shadow:0 16px 30px -14px rgba(42,92,56,.6);transition:transform .2s,box-shadow .2s}
.submit:hover{transform:translateY(-2px);box-shadow:0 20px 36px -14px rgba(42,92,56,.7)}
.alt{text-align:center;margin-top:22px;font-size:14px;color:var(--ink-soft)}
.alt a{color:var(--coral);font-weight:700}
.alt a:hover{text-decoration:underline}
.side{position:relative;background:linear-gradient(150deg,var(--green-light) 0%,var(--green) 55%,var(--green-dark) 100%);color:#fff;display:flex;flex-direction:column;justify-content:center;padding:52px 46px;overflow:hidden;perspective:900px}
.side::before,.side::after{content:"";position:absolute;border-radius:50%;background:rgba(255,255,255,.08)}
.side::before{width:340px;height:340px;top:-120px;right:-110px}
.side::after{width:240px;height:240px;bottom:-90px;left:-70px}
.side-inner{position:relative;z-index:2;transform-style:preserve-3d;transition:transform .25s ease-out}
.side .badge{width:86px;height:86px;border-radius:50%;background:rgba(255,255,255,.14);border:1.5px dashed rgba(255,255,255,.45);display:flex;align-items:center;justify-content:center;margin:0 auto 22px;font-size:38px;transform:translateZ(46px);animation:bob 5s ease-in-out infinite}
@keyframes bob{0%,100%{transform:translateZ(46px) translateY(0)}50%{transform:translateZ(46px) translateY(-9px)}}
.side h2{font-family:var(--fd);font-weight:700;font-size:26px;text-align:center;margin-bottom:10px;transform:translateZ(34px)}
.side p{text-align:center;color:rgba(255,255,255,.85);font-size:14.5px;max-width:300px;margin:0 auto 26px;transform:translateZ(24px)}
.perk{display:flex;align-items:center;gap:12px;background:rgba(255,255,255,.1);border:1px solid rgba(255,255,255,.16);border-radius:14px;padding:13px 16px;margin-bottom:11px;font-size:13.5px;font-weight:600;transform:translateZ(18px);transition:.3s;cursor:default}
.perk .ic{width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,.15);font-size:16px;flex:none;transition:transform .3s}
.perk:hover{transform:translateZ(30px) scale(1.03);box-shadow:0 16px 30px -14px rgba(0,0,0,.5)}
.perk:hover .ic{transform:scale(1.15) rotate(-6deg)}
.perk:nth-of-type(1):hover{background:var(--gold);border-color:var(--gold);color:#3a2b00}
.perk:nth-of-type(2):hover{background:var(--coral);border-color:var(--coral)}
.perk:nth-of-type(3):hover{background:#fff;border-color:#fff;color:var(--green-dark)}
@media(max-width:860px){.auth{grid-template-columns:1fr}.side{display:none}.pane{padding:42px 30px}}
@media(max-width:560px){
  body{padding:0;align-items:stretch;flex-direction:column}
  .blob{display:none}
  .back{position:fixed;top:0;left:0;right:0;z-index:20;margin:0;border-radius:0;border:none;border-bottom:1px solid var(--line);background:rgba(253,251,247,.92);backdrop-filter:blur(12px);box-shadow:none;padding:14px 20px;font-size:13px;font-weight:700;color:var(--green);gap:6px}
  .auth{border-radius:0;box-shadow:none;border:none;min-height:100vh;width:100%}
  .pane{padding:62px 28px 40px}
  .pane h1{font-size:28px}
  .row{flex-direction:column;align-items:flex-start;gap:10px}
}
</style>
</head>
<body>
<span class="blob b1"></span><span class="blob b2"></span>
<a href="${ctx}/" class="back">← Về trang chủ</a>

<div class="auth">
  <div class="pane">
    <a href="${ctx}/" class="logo">Nhiệt Đới <b>Xanh</b></a>
    <h1>Chào mừng trở lại!</h1>
    <p class="sub">Đăng nhập để đặt hàng nhanh hơn và theo dõi đơn của bạn.</p>

    <c:if test="${param.reset == 'success'}"><div class="alert ok">✅ Mật khẩu đã được đặt lại thành công. Hãy đăng nhập bằng mật khẩu mới.</div></c:if>
    <c:if test="${not empty errorMessage}"><div class="alert err">⚠️ <c:out value="${errorMessage}"/></div></c:if>

    <form method="post" action="${ctx}/login" autocomplete="on">
      <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
      <div class="field">
        <label for="email">Địa chỉ email</label>
        <div class="box"><input type="email" id="email" name="email" placeholder="ban@email.com" required autofocus value="${fn:escapeXml(param.email)}"></div>
      </div>
      <div class="field">
        <label for="password">Mật khẩu</label>
        <div class="box">
          <input type="password" id="password" name="password" placeholder="••••••••" required>
          <button type="button" class="eye" onclick="togglePw('password')" aria-label="Hiện mật khẩu"><i class="fa-regular fa-eye"></i></button>
        </div>
      </div>
      <div class="row">
        <label><input type="checkbox" name="remember"> Ghi nhớ đăng nhập</label>
        <a href="${ctx}/forgot-password">Quên mật khẩu?</a>
      </div>
      <button type="submit" class="submit">Đăng nhập</button>
    </form>
    <p class="alt">Chưa có tài khoản? <a href="${ctx}/register">Đăng ký ngay →</a></p>
  </div>

  <div class="side" id="side3d">
    <div class="side-inner" id="sideInner">
      <div class="badge">🍊</div>
      <h2>Chào mừng đến Nhiệt Đới Xanh</h2>
      <p>Nước ép trái cây tươi ép mỗi ngày — mua sắm nhanh chóng, giao tận tay trong 20–30 phút.</p>
      <div class="perk"><span class="ic">🍃</span> 100% trái cây tươi, không hương liệu</div>
      <div class="perk"><span class="ic">⚡</span> Giao hỏa tốc quanh khuôn viên trường</div>
      <div class="perk"><span class="ic">🎁</span> Lưu địa chỉ, đặt lại chỉ trong vài giây</div>
    </div>
  </div>
</div>

<script>
function togglePw(id){var i=document.getElementById(id);i.type=i.type==='password'?'text':'password';}
(function(){
  var side=document.getElementById('side3d'),inner=document.getElementById('sideInner');
  if(!side||!inner)return;
  side.addEventListener('mousemove',function(e){var r=side.getBoundingClientRect();var px=(e.clientX-r.left)/r.width-.5,py=(e.clientY-r.top)/r.height-.5;inner.style.transform='rotateY('+(px*14)+'deg) rotateX('+(-py*14)+'deg)';});
  side.addEventListener('mouseleave',function(){inner.style.transform='';});
})();
</script>
</body>
</html>
