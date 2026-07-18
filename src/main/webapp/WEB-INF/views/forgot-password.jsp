<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="isOtpStep" value="${not empty resetEmail}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${isOtpStep ? 'Xác thực OTP' : 'Quên mật khẩu'} — Nhiệt Đới Xanh</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;700;800&family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
:root{--green:#2A5C38;--green-dark:#1E3F27;--gold:#F4A261;--gold-light:#F9C784;--coral:#D9534F;--cream:#FDFBF7;--paper:#FFFFFF;--ink:#1A2E1A;--ink-soft:#7A8D7A;--line:#E8E0D0;--fd:'Baloo 2',sans-serif;--fb:'Be Vietnam Pro',sans-serif}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:var(--fb);background:var(--cream);color:var(--ink);min-height:100vh;min-height:100dvh;display:flex;align-items:center;justify-content:center;padding:28px}
a{text-decoration:none;color:inherit}button{font:inherit;cursor:pointer;border:none}
.blob{position:fixed;border-radius:50%;filter:blur(60px);opacity:.3;pointer-events:none;z-index:0;animation:drift 14s ease-in-out infinite}
.blob.b1{width:340px;height:340px;background:var(--gold-light);top:-110px;left:-90px}
.blob.b2{width:300px;height:300px;background:var(--green);opacity:.15;bottom:-100px;right:-80px;animation-delay:-6s}
@keyframes drift{0%,100%{transform:translate(0,0)}50%{transform:translate(26px,-30px)}}
.back{position:fixed;top:22px;left:24px;z-index:20;display:inline-flex;align-items:center;gap:8px;background:var(--paper);border:1px solid var(--line);padding:10px 20px;border-radius:99px;font-weight:600;font-size:13.5px;color:var(--ink-soft);box-shadow:0 10px 26px -14px rgba(20,30,20,.3);transition:transform .2s,color .2s}
.back:hover{transform:translateX(-3px);color:var(--green)}
@keyframes cardIn{from{opacity:0;transform:translateY(36px) scale(.97)}to{opacity:1;transform:none}}
.card{position:relative;z-index:5;width:min(480px,100%);background:var(--paper);border-radius:28px;border:1px solid var(--line);box-shadow:0 40px 90px -36px rgba(30,63,39,.4);padding:46px 44px;animation:cardIn .7s cubic-bezier(.16,1,.3,1);text-align:center}
.badge{width:84px;height:84px;border-radius:50%;background:linear-gradient(135deg,var(--green),var(--green-dark));display:flex;align-items:center;justify-content:center;margin:0 auto 20px;font-size:36px;box-shadow:0 18px 34px -14px rgba(42,92,56,.55);animation:bob 5s ease-in-out infinite}
@keyframes bob{0%,100%{transform:translateY(0)}50%{transform:translateY(-8px)}}
h1{font-family:var(--fd);font-weight:700;font-size:28px;color:var(--green-dark)}
.sub{color:var(--ink-soft);margin:10px 0 24px;font-size:14.5px;line-height:1.6}
.alert{border-radius:14px;padding:13px 16px;font-size:13.5px;font-weight:600;margin-bottom:16px;display:flex;gap:9px;text-align:left}
.alert.err{background:#FBE3E1;color:#8E1F1F;border:1px solid #F0A199}
.field{text-align:left;margin-bottom:18px}
.field label{display:block;font-size:12px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:var(--ink-soft);margin-bottom:7px}
.field input{width:100%;padding:14px 16px;border-radius:14px;border:1.5px solid var(--line);background:#FFF;font:inherit;font-size:15px;transition:border-color .2s,box-shadow .2s}
.field input:focus{outline:none;border-color:var(--green);box-shadow:0 0 0 4px rgba(42,92,56,.12)}
.submit{width:100%;padding:15px;border-radius:14px;background:linear-gradient(135deg,var(--green),var(--green-dark));color:#fff;font-weight:700;font-size:15.5px;box-shadow:0 16px 30px -14px rgba(42,92,56,.6);transition:transform .2s}
.submit:hover{transform:translateY(-2px)}
.alt{margin-top:20px;font-size:14px;color:var(--ink-soft)}
.alt a{color:var(--coral);font-weight:700}
.alt a:hover{text-decoration:underline}

.email-hint{background:#EAF2EC;border-radius:12px;padding:10px 14px;margin-bottom:18px;font-size:13px;color:var(--green-dark);font-weight:600;word-break:break-all;display:inline-flex;align-items:center;gap:6px}
.otp-wrap{display:flex;gap:8px;justify-content:center;margin-bottom:18px}
.otp-box{width:46px;height:56px;border-radius:12px;border:2px solid var(--line);background:#FFF;font-family:'Baloo 2',sans-serif;font-size:24px;font-weight:700;text-align:center;color:var(--green);caret-color:var(--green);transition:border-color .2s,box-shadow .2s,transform .15s}
.otp-box:focus{outline:none;border-color:var(--green);box-shadow:0 0 0 3px rgba(42,92,56,.12);transform:translateY(-2px)}
.otp-box.filled{border-color:var(--gold);background:#FEF6ED}
.otp-box.error{border-color:var(--coral);background:#FFF5F5;animation:shake .4s}
@keyframes shake{0%,100%{transform:translateX(0)}20%,60%{transform:translateX(-4px)}40%,80%{transform:translateX(4px)}}
.timer{text-align:center;margin-bottom:18px;font-size:13px;color:var(--ink-soft);font-weight:600}
.timer .time{font-family:'Baloo 2',sans-serif;font-size:18px;color:var(--green);font-weight:700;margin-left:4px}
.timer .time.expired{color:var(--coral)}
.resend-link{color:var(--green);font-weight:700;cursor:pointer;transition:color .2s}
.resend-link:hover{color:var(--coral);text-decoration:underline}
.resend-link.disabled{color:var(--ink-soft);pointer-events:none;opacity:.5}

.steps{display:flex;align-items:center;justify-content:center;gap:0;margin-bottom:24px}
.step-dot{width:10px;height:10px;border-radius:50%;background:var(--line);transition:all .3s}
.step-dot.active{width:28px;border-radius:99px;background:var(--green)}
.step-dot.done{background:var(--gold)}
.step-line{width:28px;height:2px;background:var(--line);margin:0 4px}
.step-line.done{background:var(--gold)}

.paste-hint{display:none;text-align:center;margin-bottom:14px;font-size:12px;color:var(--ink-soft);font-weight:500}
.paste-hint button{background:var(--green);color:#fff;border:none;padding:6px 14px;border-radius:8px;font-size:12px;font-weight:600;margin-left:6px}

@media(max-width:520px){
  body{padding:16px 12px;align-items:flex-start;padding-top:68px}
  .back{top:14px;left:14px;padding:8px 14px;font-size:12px}
  .card{padding:28px 20px;border-radius:22px}
  .badge{width:64px;height:64px;font-size:28px;margin-bottom:14px}
  h1{font-size:22px}
  .sub{font-size:13px;margin:8px 0 18px}
  .otp-box{width:42px;height:50px;font-size:20px;border-radius:10px}
  .paste-hint{display:block}
}
</style>
</head>
<body>
<span class="blob b1"></span><span class="blob b2"></span>
<a href="${ctx}/login" class="back">&larr; Về đăng nhập</a>

<div class="card">
<c:choose>
  <c:when test="${isOtpStep}">
    <div class="steps">
      <span class="step-dot done"></span><span class="step-line done"></span>
      <span class="step-dot active"></span><span class="step-line"></span>
      <span class="step-dot"></span>
    </div>

    <div class="badge">📲</div>
    <h1>Xác thực OTP</h1>
    <p class="sub">Nhập mã 6 chữ số đã gửi đến email của bạn.</p>
    <div class="email-hint">📧 ${resetEmail}</div>

    <c:if test="${not empty errorMessage}"><div class="alert err">⚠️ <c:out value="${errorMessage}"/></div></c:if>

    <div class="paste-hint" id="pasteHint">Đã copy mã OTP? <button type="button" id="pasteBtn">Dán mã</button></div>

    <form method="post" action="${ctx}/verify-otp" id="otpForm">
      <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
      <div class="otp-wrap" id="otpWrap">
        <input type="text" name="d1" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]" autocomplete="one-time-code" autofocus>
        <input type="text" name="d2" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
        <input type="text" name="d3" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
        <input type="text" name="d4" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
        <input type="text" name="d5" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
        <input type="text" name="d6" class="otp-box" maxlength="1" inputmode="numeric" pattern="[0-9]">
      </div>
      <div class="timer" id="timerArea"><span id="timerText">Mã hết hạn sau <span class="time" id="countdown"></span></span></div>
      <button type="submit" class="submit" id="verifyBtn">Xác nhận mã OTP</button>
    </form>

    <p class="alt" style="margin-top:14px"><a class="resend-link disabled" id="resendLink" href="${ctx}/resend-otp">Gửi lại mã</a></p>
    <p class="alt"><a href="${ctx}/forgot-password">&larr; Quay lại nhập email</a></p>

    <script>
    (function(){
      var boxes = document.querySelectorAll('.otp-box');
      var form = document.getElementById('otpForm');

      function fillBoxes(data){
        for(var j=0;j<Math.min(data.length,boxes.length);j++){ boxes[j].value=data[j]; boxes[j].classList.add('filled'); }
        var next=Math.min(data.length,boxes.length-1);
        boxes[next].focus();
        if(data.length>=6){
          var all=true; boxes.forEach(function(b){if(!b.value)all=false;});
          if(all) setTimeout(function(){form.submit();},200);
        }
      }

      boxes.forEach(function(box, i){
        box.addEventListener('input', function(){
          var v = this.value.replace(/[^0-9]/g,''); this.value = v;
          if(v){ this.classList.add('filled'); this.classList.remove('error'); if(i < boxes.length - 1) boxes[i+1].focus(); }
          else { this.classList.remove('filled'); }
        });
        box.addEventListener('keydown', function(e){
          if(e.key === 'Backspace' && !this.value && i > 0){ boxes[i-1].focus(); boxes[i-1].value=''; boxes[i-1].classList.remove('filled'); }
          if(e.key === 'ArrowLeft' && i > 0) boxes[i-1].focus();
          if(e.key === 'ArrowRight' && i < boxes.length-1) boxes[i+1].focus();
        });
        box.addEventListener('paste', function(e){ e.preventDefault(); var data=(e.clipboardData||window.clipboardData).getData('text').replace(/[^0-9]/g,''); fillBoxes(data); });
        box.addEventListener('focus', function(){ this.select(); });
      });

      var pasteBtn = document.getElementById('pasteBtn');
      if(pasteBtn){
        pasteBtn.addEventListener('click', function(){
          if(navigator.clipboard && navigator.clipboard.readText){
            navigator.clipboard.readText().then(function(text){ var data=text.replace(/[^0-9]/g,''); if(data.length>0) fillBoxes(data); }).catch(function(){});
          }
        });
      }

      <c:if test="${not empty errorMessage}">boxes.forEach(function(b){ b.classList.add('error'); });</c:if>

      var remaining = ${remainingMs};
      var countdownEl = document.getElementById('countdown');
      var timerText = document.getElementById('timerText');
      var resendLink = document.getElementById('resendLink');

      function pad(n){ return n < 10 ? '0' + n : '' + n; }
      function tick(){
        if(remaining <= 0){
          countdownEl.textContent = '00:00'; countdownEl.classList.add('expired');
          timerText.innerHTML = 'Mã OTP đã hết hạn'; resendLink.classList.remove('disabled');
          return;
        }
        var m = Math.floor(remaining / 60000), s = Math.floor((remaining % 60000) / 1000);
        countdownEl.textContent = pad(m) + ':' + pad(s);
        remaining -= 1000;
        setTimeout(tick, 1000);
      }
      tick();

      boxes[boxes.length-1].addEventListener('input', function(){
        var all = true; boxes.forEach(function(b){ if(!b.value) all = false; });
        if(all) setTimeout(function(){ form.submit(); }, 150);
      });
    })();
    </script>
  </c:when>

  <c:otherwise>
    <div class="steps">
      <span class="step-dot active"></span><span class="step-line"></span>
      <span class="step-dot"></span><span class="step-line"></span>
      <span class="step-dot"></span>
    </div>

    <div class="badge">🔑</div>
    <h1>Quên mật khẩu?</h1>
    <p class="sub">Nhập email đã đăng ký — chúng tôi sẽ gửi mã OTP 6 chữ số để xác thực (hiệu lực 5 phút).</p>

    <c:if test="${not empty errorMessage}"><div class="alert err">⚠️ <c:out value="${errorMessage}"/></div></c:if>

    <form method="post" action="${ctx}/forgot-password">
      <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
      <div class="field">
        <label for="email">Địa chỉ email</label>
        <input type="email" id="email" name="email" placeholder="ban@email.com" required autofocus value="${fn:escapeXml(param.email)}">
      </div>
      <button type="submit" class="submit">Gửi mã OTP</button>
    </form>
    <p class="alt">Chưa có tài khoản? <a href="${ctx}/register">Đăng ký ngay &rarr;</a></p>
  </c:otherwise>
</c:choose>
</div>
</body>
</html>
