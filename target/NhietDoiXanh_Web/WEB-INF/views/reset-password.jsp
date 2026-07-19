<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Đặt lại mật khẩu — Nhiệt Đới Xanh</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;700;800&family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<style>
:root{--green:#2A5C38;--green-dark:#1E3F27;--gold:#F4A261;--coral:#D9534F;--cream:#FDFBF7;--paper:#FFFFFF;--ink:#1A2E1A;--ink-soft:#7A8D7A;--line:#E8E0D0;--fd:'Baloo 2',sans-serif;--fb:'Be Vietnam Pro',sans-serif}
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:var(--fb);background:var(--cream);color:var(--ink);min-height:100vh;min-height:100dvh;display:flex;align-items:center;justify-content:center;padding:28px}
a{text-decoration:none;color:inherit}button{font:inherit;cursor:pointer;border:none}
.blob{position:fixed;border-radius:50%;filter:blur(60px);opacity:.3;pointer-events:none;z-index:0;animation:drift 14s ease-in-out infinite}
.blob.b1{width:340px;height:340px;background:#C9E4D2;top:-110px;right:-90px}
.blob.b2{width:300px;height:300px;background:#F9C784;bottom:-100px;left:-80px;animation-delay:-6s}
@keyframes drift{0%,100%{transform:translate(0,0)}50%{transform:translate(26px,-30px)}}
.back{position:fixed;top:22px;left:24px;z-index:20;display:inline-flex;align-items:center;gap:8px;background:var(--paper);border:1px solid var(--line);padding:10px 20px;border-radius:99px;font-weight:600;font-size:13.5px;color:var(--ink-soft);box-shadow:0 10px 26px -14px rgba(20,30,20,.3);transition:transform .2s,color .2s}
.back:hover{transform:translateX(-3px);color:var(--green)}
@keyframes cardIn{from{opacity:0;transform:translateY(36px) scale(.97)}to{opacity:1;transform:none}}
.card{position:relative;z-index:5;width:min(480px,100%);background:var(--paper);border-radius:28px;border:1px solid var(--line);box-shadow:0 40px 90px -36px rgba(30,63,39,.35);padding:42px 40px;animation:cardIn .7s cubic-bezier(.16,1,.3,1);text-align:center}
.badge{width:76px;height:76px;border-radius:50%;background:linear-gradient(135deg,var(--green),var(--green-dark));display:flex;align-items:center;justify-content:center;margin:0 auto 16px;font-size:32px;box-shadow:0 18px 34px -14px rgba(42,92,56,.55);animation:bob 5s ease-in-out infinite}
@keyframes bob{0%,100%{transform:translateY(0)}50%{transform:translateY(-8px)}}
h1{font-family:var(--fd);font-weight:700;font-size:26px;color:var(--green-dark)}
.sub{color:var(--ink-soft);margin:8px 0 22px;font-size:13.5px;line-height:1.6}
.alert{border-radius:14px;padding:12px 14px;font-size:13px;font-weight:600;margin-bottom:14px;display:flex;gap:9px;text-align:left;background:#FBE3E1;color:#8E1F1F;border:1px solid #F0A199}
.field{text-align:left;margin-bottom:14px}
.field label{display:block;font-size:11px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:var(--ink-soft);margin-bottom:6px}
.field .box{position:relative}
.field input{width:100%;padding:13px 44px 13px 14px;border-radius:12px;border:1.5px solid var(--line);background:#FFF;font:inherit;font-size:14px;transition:border-color .2s,box-shadow .2s}
.field input:focus{outline:none;border-color:var(--green);box-shadow:0 0 0 3px rgba(42,92,56,.12)}
.field input.err-border{border-color:var(--coral);box-shadow:0 0 0 3px rgba(217,83,79,.08)}
.eye{position:absolute;right:10px;top:50%;transform:translateY(-50%);background:none;color:var(--ink-soft);display:flex;padding:4px}

.steps{display:flex;align-items:center;justify-content:center;gap:0;margin-bottom:20px}
.step-dot{width:10px;height:10px;border-radius:50%;background:var(--line);transition:all .3s}
.step-dot.active{width:28px;border-radius:99px;background:var(--green)}
.step-dot.done{background:var(--gold)}
.step-line{width:28px;height:2px;background:var(--line);margin:0 4px}
.step-line.done{background:var(--gold)}

.strength-wrap{margin-top:8px}
.strength-track{display:flex;gap:3px}
.strength-seg{flex:1;height:3px;border-radius:99px;background:var(--line);transition:background .3s}
.strength-label{display:flex;justify-content:space-between;align-items:center;margin-top:4px}
.strength-text{font-size:10px;font-weight:700;transition:color .3s}
.strength-pct{font-size:10px;color:var(--ink-soft);font-weight:600}

.pw-rules{background:#F8F6F1;border:1px solid var(--line);border-radius:12px;padding:12px 14px;margin-top:10px;text-align:left}
.pw-rules-title{font-size:10px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;color:var(--ink-soft);margin-bottom:8px}
.pw-rule{display:flex;align-items:center;gap:8px;padding:5px 0;font-size:12.5px;font-weight:500;color:var(--ink-soft);transition:color .3s}
.pw-rule + .pw-rule{border-top:1px solid rgba(36,31,24,.06)}
.pw-rule.pass{color:var(--green)}
.pw-rule .icon{width:20px;height:20px;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:11px;font-weight:700;transition:all .3s;border:1.5px solid var(--line);background:#fff;color:var(--ink-soft)}
.pw-rule.pass .icon{background:var(--green);border-color:var(--green);color:#fff;animation:popIn .3s cubic-bezier(.34,1.56,.64,1)}
@keyframes popIn{0%{transform:scale(0)}60%{transform:scale(1.2)}100%{transform:scale(1)}}

.match-row{display:flex;align-items:center;gap:7px;margin-top:6px;font-size:12px;font-weight:600;min-height:18px;transition:all .3s}
.match-row.ok{color:var(--green)}
.match-row.bad{color:var(--coral)}
.match-row .dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}
.match-row.ok .dot{background:var(--green)}
.match-row.bad .dot{background:var(--coral)}

.submit{width:100%;margin-top:16px;padding:14px;border-radius:12px;background:linear-gradient(135deg,var(--green),var(--green-dark));color:#fff;font-weight:700;font-size:15px;box-shadow:0 16px 30px -14px rgba(42,92,56,.6);transition:transform .2s,opacity .2s}
.submit:hover:not(:disabled){transform:translateY(-2px)}
.submit:disabled{opacity:.45;cursor:not-allowed;transform:none}

@media(max-width:520px){
  body{padding:16px 12px;align-items:flex-start;padding-top:68px}
  .back{top:14px;left:14px;padding:8px 14px;font-size:12px}
  .card{padding:24px 18px;border-radius:20px}
  .badge{width:60px;height:60px;font-size:26px;margin-bottom:12px}
  h1{font-size:21px}
}
</style>
</head>
<body>
<span class="blob b1"></span><span class="blob b2"></span>
<a href="${ctx}/login" class="back">&larr; Về đăng nhập</a>

<div class="card">
  <div class="steps">
    <span class="step-dot done"></span><span class="step-line done"></span>
    <span class="step-dot done"></span><span class="step-line done"></span>
    <span class="step-dot active"></span>
  </div>

  <div class="badge">🔒</div>
  <h1>Đặt lại mật khẩu</h1>
  <p class="sub">Tạo mật khẩu mới cho tài khoản của bạn. Sau khi đổi thành công, bạn sẽ được đưa về trang đăng nhập.</p>

  <c:if test="${not empty errorMessage}"><div class="alert">⚠️ <c:out value="${errorMessage}"/></div></c:if>

  <form method="post" action="${ctx}/reset-password" id="resetForm">
    <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
    <div class="field">
      <label for="password">Mật khẩu mới</label>
      <div class="box">
        <input type="password" id="password" name="password" placeholder="••••••••" required autofocus autocomplete="new-password">
        <button type="button" class="eye" onclick="togglePw('password',this)" aria-label="Hiện mật khẩu"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z"/><circle cx="12" cy="12" r="3"/></svg></button>
      </div>

      <div class="strength-wrap">
        <div class="strength-track">
          <span class="strength-seg" id="seg0"></span><span class="strength-seg" id="seg1"></span><span class="strength-seg" id="seg2"></span>
        </div>
        <div class="strength-label"><span class="strength-text" id="strengthText"></span><span class="strength-pct" id="strengthPct"></span></div>
      </div>

      <div class="pw-rules">
        <div class="pw-rules-title">Yêu cầu mật khẩu</div>
        <div class="pw-rule" id="rule-len"><span class="icon">&mdash;</span><span>Ít nhất <b>6 ký tự</b></span></div>
        <div class="pw-rule" id="rule-upper"><span class="icon">&mdash;</span><span>Có chữ <b>hoa</b> (A-Z)</span></div>
        <div class="pw-rule" id="rule-lower"><span class="icon">&mdash;</span><span>Có chữ <b>thường</b> (a-z)</span></div>
        <div class="pw-rule" id="rule-digit"><span class="icon">&mdash;</span><span>Có <b>chữ số</b> (0-9)</span></div>
      </div>
    </div>

    <div class="field">
      <label for="confirmPassword">Xác nhận mật khẩu mới</label>
      <div class="box">
        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="••••••••" required autocomplete="new-password">
        <button type="button" class="eye" onclick="togglePw('confirmPassword',this)" aria-label="Hiện mật khẩu"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z"/><circle cx="12" cy="12" r="3"/></svg></button>
      </div>
      <div class="match-row" id="matchRow"></div>
    </div>

    <button type="submit" class="submit" id="submitBtn" disabled>Đổi mật khẩu</button>
  </form>
</div>

<script>
function togglePw(id, btn){
  var inp = document.getElementById(id);
  var show = inp.type === 'password';
  inp.type = show ? 'text' : 'password';
  var svg = btn.querySelector('svg');
  svg.style.opacity = show ? '.5' : '1';
}

(function(){
  var pw = document.getElementById('password');
  var confirm = document.getElementById('confirmPassword');
  var submitBtn = document.getElementById('submitBtn');
  var matchRow = document.getElementById('matchRow');

  var rules = {
    len:   { el: document.getElementById('rule-len'),   test: function(v){ return v.length >= 6; } },
    upper: { el: document.getElementById('rule-upper'), test: function(v){ return /[A-Z]/.test(v); } },
    lower: { el: document.getElementById('rule-lower'), test: function(v){ return /[a-z]/.test(v); } },
    digit: { el: document.getElementById('rule-digit'), test: function(v){ return /\d/.test(v); } }
  };

  var segs = [document.getElementById('seg0'), document.getElementById('seg1'), document.getElementById('seg2')];
  var strengthText = document.getElementById('strengthText');
  var strengthPct = document.getElementById('strengthPct');
  var levels = [
    { color: '#D9534F', label: 'Yếu' },
    { color: '#F4A261', label: 'Trung bình' },
    { color: '#2A5C38', label: 'Mạnh' }
  ];

  function checkRules(){
    var v = pw.value, passed = 0;
    for(var key in rules){
      var r = rules[key], ok = r.test(v);
      r.el.className = 'pw-rule ' + (ok ? 'pass' : '');
      r.el.querySelector('.icon').textContent = ok ? '✓' : '—';
      if(ok) passed++;
    }
    if(!v){
      segs.forEach(function(s){ s.style.background = ''; });
      strengthText.textContent = ''; strengthPct.textContent = '';
    } else {
      var lvlIdx = Math.min(Math.max(Math.ceil(passed/4*3)-1,0),2);
      var lvl = levels[lvlIdx];
      segs.forEach(function(s, i){ s.style.background = i <= lvlIdx ? lvl.color : ''; });
      strengthText.textContent = lvl.label; strengthText.style.color = lvl.color;
      strengthPct.textContent = Math.round(passed/4*100) + '%';
    }
    checkMatch();
  }

  function checkMatch(){
    var v1 = pw.value, v2 = confirm.value;
    var allPass = true;
    for(var key in rules){ if(!rules[key].test(v1)){ allPass = false; break; } }

    if(!v2){
      matchRow.className = 'match-row'; matchRow.innerHTML = '';
      confirm.classList.remove('err-border'); submitBtn.disabled = true;
      return;
    }
    if(v1 === v2){
      matchRow.className = 'match-row ok'; matchRow.innerHTML = '<span class="dot"></span> Mật khẩu khớp';
      confirm.classList.remove('err-border'); submitBtn.disabled = !allPass;
    } else {
      matchRow.className = 'match-row bad'; matchRow.innerHTML = '<span class="dot"></span> Mật khẩu không khớp';
      confirm.classList.add('err-border'); submitBtn.disabled = true;
    }
  }

  pw.addEventListener('input', checkRules);
  confirm.addEventListener('input', checkMatch);
})();
</script>
</body>
</html>
