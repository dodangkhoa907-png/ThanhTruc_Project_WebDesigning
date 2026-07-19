<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Đăng ký — Nhiệt Đới Xanh</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;700;800&family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
:root{--green:#2A5C38;--green-dark:#1E3F27;--green-light:#3A7D4A;--gold:#F4A261;--gold-light:#F9C784;--coral:#D9534F;--coral-dark:#B8433F;--cream:#FDFBF7;--paper:#FFFFFF;--ink:#1A2E1A;--ink-soft:#7A8D7A;--line:#E8E0D0;--fd:'Baloo 2',sans-serif;--fb:'Be Vietnam Pro',sans-serif}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:var(--fb);background:var(--cream);color:var(--ink);min-height:100vh;display:flex;align-items:center;justify-content:center;padding:28px;overflow-x:hidden}
a{text-decoration:none;color:inherit}button{font:inherit;cursor:pointer;border:none}
.blob{position:fixed;border-radius:50%;filter:blur(60px);opacity:.3;pointer-events:none;z-index:0;animation:drift 14s ease-in-out infinite}
.blob.b1{width:380px;height:380px;background:#F0A199;top:-120px;right:-100px}
.blob.b2{width:320px;height:320px;background:var(--gold-light);bottom:-100px;left:-80px;animation-delay:-6s}
@keyframes drift{0%,100%{transform:translate(0,0)}50%{transform:translate(26px,-30px)}}
.back{position:fixed;top:22px;left:24px;z-index:20;display:inline-flex;align-items:center;gap:8px;background:var(--paper);border:1px solid var(--line);padding:10px 20px;border-radius:99px;font-weight:600;font-size:13.5px;color:var(--ink-soft);box-shadow:0 10px 26px -14px rgba(20,30,20,.3);transition:transform .2s,color .2s}
.back:hover{transform:translateX(-3px);color:var(--green)}
@keyframes cardIn{from{opacity:0;transform:translateY(36px) scale(.97)}to{opacity:1;transform:none}}
.auth{position:relative;z-index:5;width:min(1040px,100%);display:grid;grid-template-columns:.9fr 1.1fr;background:var(--paper);border-radius:30px;overflow:hidden;box-shadow:0 40px 90px -36px rgba(184,67,63,.3);border:1px solid var(--line);animation:cardIn .7s cubic-bezier(.16,1,.3,1)}
.pane{padding:48px 54px}
.logo{display:inline-flex;align-items:center;gap:9px;font-family:var(--fd);font-weight:700;font-size:22px;color:var(--green-dark);margin-bottom:20px}
.logo b{color:var(--gold)}
.pane h1{font-family:var(--fd);font-weight:700;font-size:clamp(26px,3vw,32px);line-height:1.15;color:var(--green-dark)}
.pane .sub{color:var(--ink-soft);margin:8px 0 22px;font-size:14.5px}
.alert{border-radius:14px;padding:13px 16px;font-size:13.5px;font-weight:600;margin-bottom:16px;display:flex;gap:9px;align-items:flex-start;background:#FBE3E1;color:#8E1F1F;border:1px solid #F0A199}
.field{margin-bottom:14px}
.grid2{display:grid;grid-template-columns:1fr 1fr;gap:14px}
.field label{display:block;font-size:12px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:var(--ink-soft);margin-bottom:6px}
.field .box{position:relative}
.field input{width:100%;padding:13px 15px;border-radius:14px;border:1.5px solid var(--line);background:#FFF;font:inherit;font-size:15px;color:var(--ink);transition:border-color .2s,box-shadow .2s}
.field input:focus{outline:none;border-color:var(--coral);box-shadow:0 0 0 4px rgba(217,83,79,.1)}
.eye{position:absolute;right:12px;top:50%;transform:translateY(-50%);background:none;color:var(--ink-soft);display:flex;padding:4px}
.hint{font-size:12px;color:var(--ink-soft);margin-top:5px}
.submit{width:100%;margin-top:8px;padding:15px;border-radius:14px;background:linear-gradient(135deg,var(--coral),var(--coral-dark));color:#fff;font-weight:700;font-size:15.5px;box-shadow:0 16px 30px -14px rgba(217,83,79,.55);transition:transform .2s,box-shadow .2s}
.submit:hover{transform:translateY(-2px);box-shadow:0 20px 36px -14px rgba(217,83,79,.65)}
.alt{text-align:center;margin-top:18px;font-size:14px;color:var(--ink-soft)}
.alt a{color:var(--green);font-weight:700}
.alt a:hover{text-decoration:underline}
.side{position:relative;background:linear-gradient(160deg,var(--coral) 0%,#7A2E3A 55%,var(--green-dark) 100%);color:#fff;display:flex;flex-direction:column;justify-content:center;padding:52px 44px;overflow:hidden;perspective:900px}
.side::before,.side::after{content:"";position:absolute;border-radius:50%;background:rgba(255,255,255,.07)}
.side::before{width:340px;height:340px;top:-120px;left:-110px}
.side::after{width:240px;height:240px;bottom:-90px;right:-70px}
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
.perk:nth-of-type(2):hover{background:#fff;border-color:#fff;color:var(--coral-dark)}
.perk:nth-of-type(3):hover{background:var(--green);border-color:var(--green)}
@media(max-width:900px){.auth{grid-template-columns:1fr}.side{display:none}.pane{padding:42px 30px}.grid2{grid-template-columns:1fr}}
.terms-overlay{position:fixed;inset:0;z-index:100;display:none;align-items:center;justify-content:center;background:rgba(0,0,0,.5);backdrop-filter:blur(4px);padding:20px}
.terms-overlay.open{display:flex}
.terms-panel{background:var(--paper);border-radius:20px;max-width:600px;width:100%;max-height:80vh;display:flex;flex-direction:column;box-shadow:0 40px 80px -20px rgba(0,0,0,.4);overflow:hidden}
.terms-hdr{padding:20px 24px 16px;border-bottom:1px solid var(--line);display:flex;justify-content:space-between;align-items:center}
.terms-hdr h2{font-family:var(--fd);font-size:22px;font-weight:700;color:var(--ink)}
.terms-close{background:none;font-size:22px;color:var(--ink-soft);padding:4px 8px;border-radius:8px}
.terms-close:hover{background:rgba(0,0,0,.05)}
.terms-body{padding:24px;overflow-y:auto;font-size:14px;line-height:1.8;color:var(--ink)}
.terms-body h3{font-family:var(--fd);font-size:16px;font-weight:700;margin:18px 0 8px;color:var(--green)}
.terms-body h3:first-child{margin-top:0}
.terms-body ul{padding-left:20px;margin:8px 0}
.terms-body li{margin-bottom:4px}
@media(max-width:560px){
  body{padding:0;align-items:stretch;flex-direction:column}
  .blob{display:none}
  .back{position:fixed;top:0;left:0;right:0;z-index:20;margin:0;border-radius:0;border:none;border-bottom:1px solid var(--line);background:rgba(253,251,247,.92);backdrop-filter:blur(12px);box-shadow:none;padding:14px 20px;font-size:13px;font-weight:700;color:var(--green);gap:6px}
  .auth{border-radius:0;box-shadow:none;border:none;min-height:100vh;width:100%}
  .pane{padding:62px 28px 40px}
  .pane h1{font-size:26px}
}
</style>
</head>
<body>
<span class="blob b1"></span><span class="blob b2"></span>
<a href="${ctx}/" class="back">← Về trang chủ</a>

<div class="auth">
  <div class="side" id="side3d">
    <div class="side-inner" id="sideInner">
      <div class="badge">🌱</div>
      <h2>Bắt đầu hành trình</h2>
      <p>Tạo tài khoản để lưu địa chỉ, theo dõi đơn hàng và đặt lại chỉ trong vài giây.</p>
      <div class="perk"><span class="ic">🛡️</span> Bảo mật thông tin tuyệt đối</div>
      <div class="perk"><span class="ic">📍</span> Lưu nhiều địa chỉ giao hàng</div>
      <div class="perk"><span class="ic">⚡</span> Đặt lại món yêu thích nhanh chóng</div>
    </div>
  </div>

  <div class="pane">
    <a href="${ctx}/" class="logo">Nhiệt Đới <b>Xanh</b></a>
    <h1>Tạo tài khoản</h1>
    <p class="sub">Tham gia Nhiệt Đới Xanh để đặt hàng nhanh hơn.</p>

    <c:if test="${not empty errorMessage}"><div class="alert">⚠️ <c:out value="${errorMessage}"/></div></c:if>

    <form method="post" action="${ctx}/register" autocomplete="on">
      <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
      <div class="field">
        <label for="fullName">Họ và tên *</label>
        <div class="box"><input type="text" id="fullName" name="fullName" placeholder="Nguyễn Văn A" required autofocus value="${fn:escapeXml(param.fullName)}"></div>
      </div>
      <div class="grid2">
        <div class="field">
          <label for="email">Email *</label>
          <div class="box"><input type="email" id="email" name="email" placeholder="ban@email.com" required value="${fn:escapeXml(param.email)}"></div>
        </div>
        <div class="field">
          <label for="phone">Số điện thoại</label>
          <div class="box"><input type="tel" id="phone" name="phone" placeholder="09xx xxx xxx" value="${fn:escapeXml(param.phone)}" pattern="0[0-9]{9,10}" maxlength="11" inputmode="numeric" title="Số điện thoại bắt đầu bằng 0, gồm 10–11 chữ số"></div>
        </div>
      </div>
      <div class="field">
        <label for="password">Mật khẩu *</label>
        <div class="box">
          <input type="password" id="password" name="password" placeholder="••••••••" required>
          <button type="button" class="eye" onclick="togglePw('password')" aria-label="Hiện mật khẩu"><i class="fa-regular fa-eye"></i></button>
        </div>
        <p class="hint">Tối thiểu 6 ký tự, gồm chữ hoa, chữ thường và số.</p>
      </div>
      <div class="field">
        <label for="confirmPassword">Xác nhận mật khẩu *</label>
        <div class="box">
          <input type="password" id="confirmPassword" name="confirmPassword" placeholder="••••••••" required>
          <button type="button" class="eye" onclick="togglePw('confirmPassword')" aria-label="Hiện mật khẩu"><i class="fa-regular fa-eye"></i></button>
        </div>
      </div>
      <div class="field" style="margin-bottom:16px">
        <label style="display:flex;align-items:flex-start;gap:10px;cursor:pointer;text-transform:none;letter-spacing:0;font-weight:500;font-size:13.5px;color:var(--ink)">
          <input type="checkbox" name="agreeTerms" id="agreeTerms" required style="width:18px;height:18px;margin-top:2px;accent-color:var(--coral);flex-shrink:0;cursor:pointer">
          <span>Tôi đồng ý với <a href="#" onclick="openModal(event,'termsModal')" style="color:var(--green);font-weight:700;text-decoration:underline">Điều khoản sử dụng</a> và <a href="#" onclick="openModal(event,'privacyModal')" style="color:var(--green);font-weight:700;text-decoration:underline">Chính sách bảo mật</a></span>
        </label>
      </div>
      <button type="submit" class="submit">Đăng ký</button>
    </form>
    <p class="alt">Đã có tài khoản? <a href="${ctx}/login">Đăng nhập →</a></p>
  </div>
</div>

<div class="terms-overlay" id="termsModal">
  <div class="terms-panel">
    <div class="terms-hdr"><h2>Điều khoản sử dụng</h2><button class="terms-close" onclick="closeModal('termsModal')">&times;</button></div>
    <div class="terms-body">
      <h3>1. Giới thiệu</h3>
      <p>Chào mừng bạn đến với Nhiệt Đới Xanh. Khi sử dụng dịch vụ, bạn đồng ý tuân thủ các điều khoản dưới đây.</p>
      <h3>2. Tài khoản</h3>
      <ul>
        <li>Cung cấp thông tin chính xác khi đăng ký.</li>
        <li>Bạn chịu trách nhiệm bảo mật thông tin đăng nhập của mình.</li>
      </ul>
      <h3>3. Đặt hàng và thanh toán</h3>
      <ul>
        <li>Giá món có thể thay đổi mà không cần thông báo trước.</li>
        <li>Bạn có thể hủy đơn trước khi đơn được xác nhận giao.</li>
      </ul>
      <h3>4. Thay đổi điều khoản</h3>
      <p>Chúng tôi có quyền cập nhật điều khoản này, có hiệu lực ngay khi đăng tải.</p>
    </div>
  </div>
</div>

<div class="terms-overlay" id="privacyModal">
  <div class="terms-panel">
    <div class="terms-hdr"><h2>Chính sách bảo mật</h2><button class="terms-close" onclick="closeModal('privacyModal')">&times;</button></div>
    <div class="terms-body">
      <h3>1. Thông tin thu thập</h3>
      <ul>
        <li>Họ tên, email, số điện thoại khi đăng ký tài khoản.</li>
        <li>Địa chỉ giao hàng, lịch sử mua hàng.</li>
      </ul>
      <h3>2. Bảo mật dữ liệu</h3>
      <ul>
        <li>Mật khẩu được mã hóa (BCrypt), không ai đọc được — kể cả admin.</li>
        <li>Chỉ nhân viên được ủy quyền mới truy cập dữ liệu khách hàng.</li>
      </ul>
      <h3>3. Chia sẻ thông tin</h3>
      <p>Chúng tôi không bán hoặc chia sẻ thông tin cá nhân cho bên thứ ba, trừ khi pháp luật yêu cầu.</p>
    </div>
  </div>
</div>

<script>
function togglePw(id){var i=document.getElementById(id);i.type=i.type==='password'?'text':'password';}
function openModal(e,id){e.preventDefault();document.getElementById(id).classList.add('open');}
function closeModal(id){document.getElementById(id).classList.remove('open');}
document.querySelectorAll('.terms-overlay').forEach(function(m){m.addEventListener('click',function(e){if(e.target===m)closeModal(m.id)});});
document.addEventListener('keydown',function(e){if(e.key==='Escape'){closeModal('termsModal');closeModal('privacyModal')}});
(function(){
  var side=document.getElementById('side3d'),inner=document.getElementById('sideInner');
  if(!side||!inner)return;
  side.addEventListener('mousemove',function(e){var r=side.getBoundingClientRect();var px=(e.clientX-r.left)/r.width-.5,py=(e.clientY-r.top)/r.height-.5;inner.style.transform='rotateY('+(px*14)+'deg) rotateX('+(-py*14)+'deg)';});
  side.addEventListener('mouseleave',function(){inner.style.transform='';});
})();
</script>
</body>
</html>
