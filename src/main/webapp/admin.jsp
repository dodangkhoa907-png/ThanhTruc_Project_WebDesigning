<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Nhiệt Đới Xanh — Admin Dashboard</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
<style>
/* ============================================================
   NHIỆT ĐỚI XANH — Admin Dashboard
   Style: Glossy 3D & Liquid Soft-UI
   ============================================================ */
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box}

:root{
  --bg:#F7F9F6;
  --card:#FFFFFF;
  --green:#2A5C38;
  --green-l:#3A7D4A;
  --green-d:#1E3F27;
  --mango:#FF9F1C;
  --mango-l:#FFB84D;
  --mango-d:#E8880A;
  --red:#E74C3C;
  --text:#1A2E1A;
  --text-s:#5A6E5A;
  --text-m:#8A9A8A;
  --border:#E8ECE6;
  --sidebar-w:280px;
  --font:'Be Vietnam Pro',sans-serif;
  --ease:cubic-bezier(.16,1,.3,1);
  --radius:20px;

  /* 3D shadow layers */
  --shadow-card:
    0 1px 2px rgba(0,0,0,.04),
    0 4px 8px rgba(0,0,0,.04),
    0 16px 32px rgba(0,0,0,.04),
    inset 0 2px 0 rgba(255,255,255,1);
  --shadow-card-hover:
    0 2px 4px rgba(0,0,0,.04),
    0 8px 16px rgba(0,0,0,.06),
    0 24px 48px rgba(0,0,0,.06),
    inset 0 2px 0 rgba(255,255,255,1);
  --shadow-btn:
    0 4px 12px rgba(42,92,56,.25),
    0 1px 3px rgba(42,92,56,.15),
    inset 0 1px 0 rgba(255,255,255,.25);
  --shadow-btn-hover:
    0 8px 24px rgba(42,92,56,.3),
    0 2px 4px rgba(42,92,56,.2),
    inset 0 1px 0 rgba(255,255,255,.3);
}

html{font-size:16px;scroll-behavior:smooth}
body{font-family:var(--font);background:var(--bg);color:var(--text);line-height:1.6;overflow-x:hidden;min-height:100vh}

/* ============================================================
   LAYOUT GRID
   ============================================================ */
.dashboard{min-height:100vh;position:relative}

/* ============================================================
   SIDEBAR — Liquid Navigation
   ============================================================ */
.sidebar{
  background:linear-gradient(180deg,var(--green-d) 0%,#0F2618 100%);
  padding:32px 20px;
  display:flex;flex-direction:column;
  position:fixed;top:0;left:0;bottom:0;width:var(--sidebar-w);
  z-index:100;overflow-y:auto;
}

/* Logo 3D */
.sidebar-logo{
  text-align:center;padding:8px 0 36px;
  border-bottom:1px solid rgba(255,255,255,.08);
  margin-bottom:28px;
}
.sidebar-logo h1{
  font-size:1.5rem;font-weight:900;
  background:linear-gradient(135deg,#4ADE80 0%,#A7F3D0 40%,#FDE68A 100%);
  -webkit-background-clip:text;-webkit-text-fill-color:transparent;
  background-clip:text;
  filter:drop-shadow(0 2px 8px rgba(74,222,128,.3));
  letter-spacing:-.5px;line-height:1.3;
}
.sidebar-logo span{
  display:block;font-size:.68rem;font-weight:500;
  -webkit-text-fill-color:rgba(167,243,208,.5);
  letter-spacing:2px;text-transform:uppercase;margin-top:4px;
}

/* Nav Items — Liquid morph on hover */
.nav-section{margin-bottom:8px}
.nav-section-title{
  font-size:.65rem;font-weight:700;
  color:rgba(167,243,208,.35);
  text-transform:uppercase;letter-spacing:2.5px;
  padding:0 16px;margin-bottom:8px;
}

.nav-item{
  display:flex;align-items:center;gap:14px;
  padding:12px 18px;margin:3px 0;
  color:rgba(255,255,255,.55);font-size:.88rem;font-weight:500;
  border-radius:14px;cursor:pointer;
  transition:all .4s var(--ease);position:relative;
  text-decoration:none;
}
.nav-item:hover{
  color:rgba(255,255,255,.9);
  background:rgba(255,255,255,.06);
  border-radius:30px 10px 30px 10px;
}
.nav-item.active{
  color:#fff;font-weight:600;
  background:linear-gradient(135deg,rgba(42,92,56,.6),rgba(58,125,74,.4));
  border-radius:30px 10px 30px 10px;
  box-shadow:0 4px 20px rgba(42,92,56,.3),inset 0 1px 0 rgba(255,255,255,.1);
}
.nav-item.active::before{
  content:'';position:absolute;left:0;top:50%;transform:translateY(-50%);
  width:4px;height:24px;border-radius:0 4px 4px 0;
  background:linear-gradient(180deg,var(--mango),var(--mango-l));
  box-shadow:0 0 12px rgba(255,159,28,.4);
}

.nav-icon{
  width:22px;height:22px;flex-shrink:0;
  display:flex;align-items:center;justify-content:center;
  font-size:1rem;
}
.nav-badge{
  margin-left:auto;font-size:.7rem;font-weight:700;
  background:linear-gradient(135deg,var(--mango),var(--mango-l));
  color:var(--green-d);padding:2px 10px;border-radius:50px;
  box-shadow:0 2px 8px rgba(255,159,28,.3);
}

/* Logout */
.nav-logout{
  margin-top:auto;padding-top:20px;
  border-top:1px solid rgba(255,255,255,.06);
}
.nav-item.logout{color:rgba(231,76,60,.7)}
.nav-item.logout:hover{
  color:#fff;
  background:rgba(231,76,60,.15);
  border-radius:30px 10px 30px 10px;
}

/* ============================================================
   MAIN CONTENT
   ============================================================ */
.main{
  margin-left:var(--sidebar-w);
  padding:28px 36px 60px;
  min-height:100vh;
}

/* ── Glass Header ── */
.glass-header{
  display:flex;align-items:center;gap:20px;
  margin-bottom:32px;padding:20px 28px;
  background:rgba(255,255,255,.7);
  backdrop-filter:blur(20px) saturate(180%);
  -webkit-backdrop-filter:blur(20px) saturate(180%);
  border:1px solid rgba(255,255,255,.8);
  border-radius:var(--radius);
  box-shadow:var(--shadow-card);
}
.header-title{flex:1}
.header-title h2{font-size:1.5rem;font-weight:800;color:var(--text);letter-spacing:-.3px}
.header-title p{font-size:.82rem;color:var(--text-m);margin-top:2px}

/* Search — Pill */
.search-pill{
  display:flex;align-items:center;gap:10px;
  background:var(--bg);
  border:1.5px solid var(--border);
  border-radius:50px;padding:10px 20px;
  width:280px;transition:all .3s var(--ease);
}
.search-pill:focus-within{
  border-color:var(--green);
  box-shadow:0 0 0 4px rgba(42,92,56,.08);
  background:#fff;
}
.search-pill input{
  border:none;outline:none;background:transparent;
  font-family:var(--font);font-size:.88rem;color:var(--text);
  width:100%;
}
.search-pill input::placeholder{color:var(--text-m)}
.search-icon{color:var(--text-m);font-size:1rem;flex-shrink:0}

/* Avatar — Liquid morph */
.avatar-liquid{
  width:46px;height:46px;border-radius:50%;overflow:hidden;
  border:2.5px solid var(--green);
  box-shadow:0 4px 16px rgba(42,92,56,.15);
  animation:liquidMorph 8s ease-in-out infinite;
  cursor:pointer;flex-shrink:0;
}
.avatar-liquid img{width:100%;height:100%;object-fit:cover}

@keyframes liquidMorph{
  0%,100%{border-radius:50% 50% 50% 50%}
  25%{border-radius:40% 60% 55% 45%}
  50%{border-radius:55% 45% 40% 60%}
  75%{border-radius:45% 55% 60% 40%}
}

/* ============================================================
   KPI CARDS — 3D Glossy
   ============================================================ */
.kpi-grid{
  display:grid;grid-template-columns:repeat(4,1fr);gap:20px;
  margin-bottom:32px;
}

.kpi-card{
  background:var(--card);
  border:1px solid rgba(255,255,255,.9);
  border-radius:var(--radius);
  padding:28px 24px;
  box-shadow:var(--shadow-card);
  transition:all .4s var(--ease);
  position:relative;overflow:hidden;
  cursor:default;
}
.kpi-card::before{
  content:'';position:absolute;top:0;left:0;right:0;height:3px;
  background:linear-gradient(90deg,var(--green),var(--green-l));
  border-radius:var(--radius) var(--radius) 0 0;
  opacity:0;transition:opacity .3s;
}
.kpi-card:hover{
  transform:translateY(-8px);
  box-shadow:var(--shadow-card-hover);
}
.kpi-card:hover::before{opacity:1}

.kpi-card:nth-child(1)::before{background:linear-gradient(90deg,var(--green),var(--green-l))}
.kpi-card:nth-child(2)::before{background:linear-gradient(90deg,var(--mango),var(--mango-l))}
.kpi-card:nth-child(3)::before{background:linear-gradient(90deg,#6366F1,#818CF8)}
.kpi-card:nth-child(4)::before{background:linear-gradient(90deg,#10B981,#34D399)}

.kpi-icon{
  width:52px;height:52px;border-radius:16px;
  display:flex;align-items:center;justify-content:center;
  font-size:1.5rem;margin-bottom:18px;
  box-shadow:
    0 4px 12px rgba(0,0,0,.08),
    0 1px 2px rgba(0,0,0,.06),
    inset 0 -2px 4px rgba(0,0,0,.06),
    inset 0 2px 0 rgba(255,255,255,.6);
  transition:all .5s var(--ease);
}
.kpi-card:hover .kpi-icon{
  animation:liquidMorph 3s ease-in-out infinite;
  transform:scale(1.08);
}

.kpi-icon.green{background:linear-gradient(145deg,#D1FAE5,#A7F3D0)}
.kpi-icon.orange{background:linear-gradient(145deg,#FEF3C7,#FDE68A)}
.kpi-icon.purple{background:linear-gradient(145deg,#E0E7FF,#C7D2FE)}
.kpi-icon.teal{background:linear-gradient(145deg,#CCFBF1,#99F6E4)}

.kpi-label{font-size:.78rem;font-weight:600;color:var(--text-m);text-transform:uppercase;letter-spacing:1px;margin-bottom:6px}
.kpi-value{font-size:2rem;font-weight:900;color:var(--text);line-height:1.1;letter-spacing:-1px}
.kpi-sub{display:flex;align-items:center;gap:6px;margin-top:10px;font-size:.78rem;color:var(--text-m)}
.kpi-up{color:#10B981;font-weight:700}
.kpi-down{color:var(--red);font-weight:700}

/* ── Liquid Progress (Success Rate Card) ── */
.liquid-progress{
  width:100%;height:10px;
  background:var(--bg);
  border-radius:50px;
  margin-top:16px;
  overflow:hidden;
  position:relative;
  box-shadow:inset 0 2px 4px rgba(0,0,0,.06);
}
.liquid-progress-fill{
  height:100%;width:98%;
  background:linear-gradient(90deg,#10B981,#34D399,#6EE7B7,#34D399);
  background-size:200% 100%;
  border-radius:50px;
  position:relative;
  animation:liquidWave 3s ease-in-out infinite;
}
.liquid-progress-fill::after{
  content:'';position:absolute;inset:0;
  background:linear-gradient(90deg,transparent,rgba(255,255,255,.4),transparent);
  background-size:200% 100%;
  animation:shimmer 2s linear infinite;
}

@keyframes liquidWave{
  0%,100%{background-position:0% 50%}
  50%{background-position:100% 50%}
}
@keyframes shimmer{
  0%{background-position:-200% 0}
  100%{background-position:200% 0}
}

/* ============================================================
   MIDDLE ROW: Chart + Donut + Top Fruits
   ============================================================ */
.middle-row{
  display:grid;grid-template-columns:4fr 3fr 3fr;gap:24px;
  margin-bottom:32px;
}
.middle-row > div {
  min-height: 340px;
  height: auto;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

/* ── Donut Chart ── */
.donut-card {
  background:var(--card);
  border:1px solid rgba(255,255,255,.9);
  border-radius:var(--radius);
  padding:28px;
  box-shadow:var(--shadow-card);
  display: flex;
  flex-direction: column;
}
.donut-card h3 {
  font-size:1.1rem;
  font-weight:700;
  margin-bottom:24px;
  color:var(--text);
}
.donut-chart-container {
  display:flex;
  align-items:center;
  justify-content:center;
  margin-bottom:20px;
  flex: 1;
}
.donut-chart {
  position:relative;
  width:160px;
  height:160px;
  border-radius:50%;
  background:conic-gradient(
    var(--green) 0% 60%, 
    #34D399 60% 85%, 
    var(--mango) 85% 100%
  );
  box-shadow:
    0 10px 25px rgba(42,92,56,0.15),
    inset 0 4px 12px rgba(0,0,0,0.15);
  display:flex;
  align-items:center;
  justify-content:center;
}
.donut-hole {
  position:absolute;
  width:108px;
  height:108px;
  background:var(--card);
  border-radius:50%;
  box-shadow:
    inset 0 4px 10px rgba(0,0,0,0.12),
    0 2px 4px rgba(255,255,255,0.8);
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:center;
}
.donut-value {
  font-family:var(--font);
  font-size:1.5rem;
  font-weight:900;
  color:var(--text);
  line-height:1.1;
}
.donut-label {
  font-size:0.7rem;
  font-weight:700;
  color:var(--text-m);
  text-transform:uppercase;
  letter-spacing:1px;
}
.donut-legend {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: auto;
  border-top: 1px solid var(--border);
  padding-top: 16px;
}
.legend-item {
  display: flex;
  align-items: center;
  font-size: 0.8rem;
  color: var(--text-s);
}
.legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 10px;
  flex-shrink: 0;
  box-shadow: inset 0 1px 2px rgba(0,0,0,0.15);
}
.legend-dot.green { background:var(--green); }
.legend-dot.mint { background:#34D399; }
.legend-dot.orange { background:var(--mango); }
.legend-name {
  font-weight: 500;
  flex-grow: 1;
}
.legend-pct {
  font-family: var(--font);
  font-weight: 700;
  color: var(--text);
  margin-left: auto;
}

/* ── 3D Liquid Bar Chart ── */
.chart-card{
  background:var(--card);
  border:1px solid rgba(255,255,255,.9);
  border-radius:var(--radius);
  padding:28px;
  box-shadow:var(--shadow-card);
}
.chart-card-header{
  display:flex;align-items:center;justify-content:space-between;
  margin-bottom:28px;
}
.chart-card-header h3{font-size:1.1rem;font-weight:700;color:var(--text)}
.chart-period{
  display:flex;gap:4px;
  background:var(--bg);border-radius:10px;padding:3px;
}
.chart-period button{
  font-family:var(--font);font-size:.72rem;font-weight:600;
  padding:6px 14px;border:none;border-radius:8px;
  cursor:pointer;transition:all .3s var(--ease);
  background:transparent;color:var(--text-m);
}
.chart-period button.active{
  background:var(--card);color:var(--text);
  box-shadow:0 2px 8px rgba(0,0,0,.08),inset 0 1px 0 rgba(255,255,255,1);
}

/* Bar Chart */
.bar-chart{
  display:flex;align-items:flex-end;justify-content:space-between;
  height:180px;padding:0 8px;gap:12px;
  border-bottom:2px solid var(--border);
  position:relative;
}

/* Y-axis grid lines */
.bar-chart::before{
  content:'';position:absolute;inset:0;
  background:repeating-linear-gradient(
    to bottom,
    transparent,
    transparent calc(25% - 1px),
    var(--border) calc(25% - 1px),
    var(--border) 25%
  );
  pointer-events:none;opacity:.4;
}

.bar-col{
  flex:1;display:flex;flex-direction:column;align-items:center;gap:8px;
  position:relative;z-index:1;
}

.bar-wrapper{
  width:100%;max-width:48px;position:relative;
  display:flex;align-items:flex-end;justify-content:center;
}

.bar{
  width:100%;border-radius:12px 12px 6px 6px;
  background:linear-gradient(180deg,var(--mango) 0%,var(--mango-l) 40%,#FFD166 100%);
  position:relative;
  transition:all .5s var(--ease);
  box-shadow:
    0 4px 16px rgba(255,159,28,.25),
    inset 0 2px 0 rgba(255,255,255,.4),
    inset -2px 0 4px rgba(0,0,0,.05),
    inset 2px 0 4px rgba(0,0,0,.02);
  min-height:20px;
  cursor:pointer;
}

/* 3D Reflection under bars */
.bar::after{
  content:'';position:absolute;
  bottom:-12px;left:10%;right:10%;height:12px;
  background:linear-gradient(180deg,rgba(255,159,28,.15),transparent);
  border-radius:0 0 50% 50%;
  filter:blur(4px);
}

.bar:hover{
  filter:brightness(1.08);
  transform:scaleY(1.03);
  transform-origin:bottom;
}

/* Value tooltip on hover */
.bar-value{
  position:absolute;top:-32px;left:50%;transform:translateX(-50%);
  background:var(--text);color:#fff;
  font-size:.68rem;font-weight:700;
  padding:4px 10px;border-radius:8px;
  opacity:0;transition:opacity .2s;
  white-space:nowrap;pointer-events:none;
}
.bar-value::after{
  content:'';position:absolute;bottom:-4px;left:50%;transform:translateX(-50%);
  border:4px solid transparent;border-top-color:var(--text);
}
.bar:hover .bar-value{opacity:1}

.bar-label{
  font-size:.72rem;font-weight:600;color:var(--text-m);
  margin-top:4px;
}

/* Green accent bars */
.bar.green-bar{
  background:linear-gradient(180deg,var(--green) 0%,var(--green-l) 40%,#4ADE80 100%);
  box-shadow:
    0 4px 16px rgba(42,92,56,.2),
    inset 0 2px 0 rgba(255,255,255,.3),
    inset -2px 0 4px rgba(0,0,0,.08),
    inset 2px 0 4px rgba(0,0,0,.03);
}
.bar.green-bar::after{
  background:linear-gradient(180deg,rgba(42,92,56,.12),transparent);
}

/* ── Top Fruits Card ── */
.fruits-card{
  background:var(--card);
  border:1px solid rgba(255,255,255,.9);
  border-radius:var(--radius);
  padding:28px;
  box-shadow:var(--shadow-card);
}
.fruits-card h3{font-size:1.1rem;font-weight:700;margin-bottom:16px}

.fruit-item{
  display:flex;align-items:center;gap:12px;
  padding:6px 0;
  border-bottom:1px solid var(--border);
  transition:all .3s var(--ease);
}
.fruit-item:last-child{border-bottom:none}
.fruit-item:hover{padding-left:4px}

.fruit-rank{
  width:24px;height:24px;border-radius:8px;
  display:flex;align-items:center;justify-content:center;
  font-size:.68rem;font-weight:800;color:#fff;flex-shrink:0;
  box-shadow:0 2px 6px rgba(0,0,0,.1),inset 0 1px 0 rgba(255,255,255,.2);
}
.fruit-rank.r1{background:linear-gradient(135deg,var(--mango),var(--mango-l))}
.fruit-rank.r2{background:linear-gradient(135deg,#94A3B8,#CBD5E1)}
.fruit-rank.r3{background:linear-gradient(135deg,#D97706,#F59E0B)}

/* Blob container for fruit emoji */
.fruit-blob{
  width:32px;height:32px;
  display:flex;align-items:center;justify-content:center;
  font-size:1.1rem;
  background:linear-gradient(135deg,rgba(42,92,56,.06),rgba(244,162,97,.08));
  border-radius:50%;
  animation:blobMorph 6s ease-in-out infinite;
  box-shadow:
    0 2px 8px rgba(0,0,0,.04),
    inset 0 1px 0 rgba(255,255,255,.6);
  flex-shrink:0;
}
.fruit-blob:nth-child(2){animation-delay:-2s}
.fruit-blob:nth-child(3){animation-delay:-4s}

@keyframes blobMorph{
  0%,100%{border-radius:50% 50% 50% 50%}
  20%{border-radius:42% 58% 55% 45%}
  40%{border-radius:55% 45% 42% 58%}
  60%{border-radius:48% 52% 58% 42%}
  80%{border-radius:52% 48% 45% 55%}
}

.fruit-info{flex:1}
.fruit-name{font-size:.82rem;font-weight:700;color:var(--text);line-height:1.2}
.fruit-count{font-size:.68rem;color:var(--text-m)}

.fruit-bar-wrap{width:60px;height:6px;background:var(--bg);border-radius:50px;overflow:hidden;flex-shrink:0}
.fruit-bar-inner{height:100%;border-radius:50px;
  background:linear-gradient(90deg,var(--green),var(--green-l));
  box-shadow:inset 0 1px 0 rgba(255,255,255,.3);
}

/* ============================================================
   DATA TABLE — Orders
   ============================================================ */
.table-card{
  background:var(--card);
  border:1px solid rgba(255,255,255,.9);
  border-radius:var(--radius);
  padding:28px;
  box-shadow:var(--shadow-card);
}
.table-card-header{
  display:flex;align-items:center;justify-content:space-between;
  margin-bottom:20px;
}
.table-card-header h3{font-size:1.1rem;font-weight:700}
.table-card-header .view-all{
  font-size:.78rem;font-weight:600;color:var(--green);
  cursor:pointer;transition:color .2s;
}
.table-card-header .view-all:hover{color:var(--mango)}

.data-table{width:100%;border-collapse:separate;border-spacing:0}
.data-table thead th{
  text-align:left;font-size:.7rem;font-weight:700;
  color:var(--text-m);text-transform:uppercase;letter-spacing:1.2px;
  padding:12px 16px;
  border-bottom:2px solid var(--border);
}
.data-table tbody tr{
  transition:all .25s var(--ease);cursor:default;
}
.data-table tbody tr:nth-child(even){background:rgba(247,249,246,.6)}
.data-table tbody tr:hover{background:rgba(42,92,56,.03)}

.data-table tbody td{
  padding:14px 16px;font-size:.88rem;
  border-bottom:1px solid var(--border);
  vertical-align:middle;
}
.data-table tbody tr:last-child td{border-bottom:none}

.customer-cell{display:flex;align-items:center;gap:10px}
.customer-avatar{
  width:34px;height:34px;border-radius:12px;
  display:flex;align-items:center;justify-content:center;
  font-size:.82rem;font-weight:700;color:#fff;flex-shrink:0;
  box-shadow:0 2px 6px rgba(0,0,0,.1),inset 0 1px 0 rgba(255,255,255,.2);
}
.customer-name{font-weight:600;color:var(--text)}

.order-detail{font-size:.82rem;color:var(--text-s)}
.order-note{
  display:inline-block;font-size:.68rem;font-weight:600;
  color:var(--mango-d);background:rgba(255,159,28,.08);
  padding:2px 8px;border-radius:6px;margin-left:6px;
}

.price-cell{font-weight:700;color:var(--text)}

/* Status Badges — Glossy 3D */
.badge{
  display:inline-flex;align-items:center;gap:5px;
  padding:6px 14px;border-radius:50px;
  font-size:.72rem;font-weight:700;
  letter-spacing:.3px;
}
.badge-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}

.badge-success{
  background:linear-gradient(135deg,#D1FAE5,#A7F3D0);
  color:#065F46;
  box-shadow:
    0 2px 8px rgba(16,185,129,.15),
    inset 0 1px 0 rgba(255,255,255,.7),
    inset 0 -1px 2px rgba(0,0,0,.04);
}
.badge-success .badge-dot{background:#10B981;box-shadow:0 0 6px rgba(16,185,129,.4)}

.badge-pending{
  background:linear-gradient(135deg,#FEF3C7,#FDE68A);
  color:#92400E;
  box-shadow:
    0 2px 8px rgba(255,159,28,.15),
    inset 0 1px 0 rgba(255,255,255,.7),
    inset 0 -1px 2px rgba(0,0,0,.04);
}
.badge-pending .badge-dot{background:var(--mango);box-shadow:0 0 6px rgba(255,159,28,.4)}

.badge-process{
  background:linear-gradient(135deg,#E0E7FF,#C7D2FE);
  color:#3730A3;
  box-shadow:
    0 2px 8px rgba(99,102,241,.15),
    inset 0 1px 0 rgba(255,255,255,.7),
    inset 0 -1px 2px rgba(0,0,0,.04);
}
.badge-process .badge-dot{background:#6366F1;box-shadow:0 0 6px rgba(99,102,241,.4)}

.badge-cancel{
  background:linear-gradient(135deg,#FEE2E2,#FECACA);
  color:#991B1B;
  box-shadow:
    0 2px 8px rgba(231,76,60,.12),
    inset 0 1px 0 rgba(255,255,255,.7),
    inset 0 -1px 2px rgba(0,0,0,.04);
}
.badge-cancel .badge-dot{background:var(--red);box-shadow:0 0 6px rgba(231,76,60,.3)}

/* ============================================================
   RESPONSIVE
   ============================================================ */
@media(max-width:1200px){
  .middle-row{grid-template-columns:1fr}
  .kpi-grid{grid-template-columns:repeat(2,1fr)}
}
@media(max-width:900px){
  .sidebar{
    transform:translateX(-100%);
    transition:transform .4s var(--ease);
  }
  .sidebar.open{transform:translateX(0)}
  .main{margin-left:0;padding:20px 16px 60px}
  .glass-header{flex-wrap:wrap;gap:12px}
  .search-pill{width:100%;order:3}
  .kpi-grid{grid-template-columns:1fr 1fr}
  .bar-chart{height:160px}
}
@media(max-width:600px){
  .kpi-grid{grid-template-columns:1fr}
  .data-table{font-size:.8rem}
  .data-table thead th,.data-table tbody td{padding:10px 10px}
}

/* ============================================================
   SCROLLBAR
   ============================================================ */
::-webkit-scrollbar{width:6px}
::-webkit-scrollbar-track{background:transparent}
::-webkit-scrollbar-thumb{background:var(--border);border-radius:50px}
::-webkit-scrollbar-thumb:hover{background:var(--text-m)}

/* ============================================================
   ANIMATIONS
   ============================================================ */
@keyframes fadeInUp{
  from{opacity:0;transform:translateY(24px)}
  to{opacity:1;transform:translateY(0)}
}
.animate-in{animation:fadeInUp .6s var(--ease) both}
.delay-1{animation-delay:.1s}
.delay-2{animation-delay:.2s}
.delay-3{animation-delay:.3s}
.delay-4{animation-delay:.4s}
.delay-5{animation-delay:.5s}
.delay-6{animation-delay:.6s}
.delay-7{animation-delay:.7s}
</style>
</head>

<body>
<div class="dashboard">

  <!-- ================================================================
       SIDEBAR
       ================================================================ -->
  <aside class="sidebar" id="sidebar">
    <div class="sidebar-logo">
      <h1>Nhiệt Đới Xanh<span>Admin Dashboard</span></h1>
    </div>

    <div class="nav-section">
      <div class="nav-section-title">Tổng quan</div>
      <a class="nav-item active" href="#">
        <span class="nav-icon">📊</span> Dashboard
      </a>
      <a class="nav-item" href="#">
        <span class="nav-icon">📦</span> Đơn hàng
        <span class="nav-badge">45</span>
      </a>
      <a class="nav-item" href="#">
        <span class="nav-icon">🍹</span> Sản phẩm
      </a>
    </div>

    <div class="nav-section">
      <div class="nav-section-title">Quản lý</div>
      <a class="nav-item" href="#">
        <span class="nav-icon">👥</span> Khách hàng
      </a>
      <a class="nav-item" href="#">
        <span class="nav-icon">📈</span> Thống kê
      </a>
      <a class="nav-item" href="#">
        <span class="nav-icon">⚙️</span> Cài đặt
      </a>
    </div>

    <div class="nav-logout">
      <a class="nav-item logout" href="#">
        <span class="nav-icon">🚪</span> Đăng xuất
      </a>
    </div>
  </aside>

  <!-- ================================================================
       MAIN CONTENT
       ================================================================ -->
  <main class="main">

    <!-- Glass Header -->
    <header class="glass-header animate-in">
      <div class="header-title">
        <h2>Dashboard Tổng Quan</h2>
        <p>Chào buổi sáng, Oanh! Hôm nay có 12 đơn hàng mới.</p>
      </div>
      <div class="search-pill">
        <span class="search-icon">🔍</span>
        <input type="text" placeholder="Tìm đơn hàng, khách hàng...">
      </div>
      <div class="avatar-liquid">
        <img src="https://randomuser.me/api/portraits/women/12.jpg" alt="Admin">
      </div>
    </header>

    <!-- KPI Cards -->
    <div class="kpi-grid">
      <div class="kpi-card animate-in delay-1">
        <div class="kpi-icon green">💰</div>
        <div class="kpi-label">Doanh thu</div>
        <div class="kpi-value">2.4M</div>
        <div class="kpi-sub"><span class="kpi-up">↑ 12.5%</span> so với tuần trước</div>
      </div>
      <div class="kpi-card animate-in delay-2">
        <div class="kpi-icon orange">🛒</div>
        <div class="kpi-label">Đơn mới</div>
        <div class="kpi-value">45</div>
        <div class="kpi-sub"><span class="kpi-up">↑ 8.3%</span> so với tuần trước</div>
      </div>
      <div class="kpi-card animate-in delay-3">
        <div class="kpi-icon purple">⏳</div>
        <div class="kpi-label">Đang xử lý</div>
        <div class="kpi-value">12</div>
        <div class="kpi-sub"><span class="kpi-down">↓ 3.1%</span> so với tuần trước</div>
      </div>
      <div class="kpi-card animate-in delay-4">
        <div class="kpi-icon teal">✅</div>
        <div class="kpi-label">Tỷ lệ thành công</div>
        <div class="kpi-value">98%</div>
        <div class="liquid-progress"><div class="liquid-progress-fill"></div></div>
      </div>
    </div>

    <!-- Middle Row: Chart + Donut + Top Fruits -->
    <div class="middle-row">

      <!-- Bar Chart -->
      <div class="chart-card animate-in delay-5">
        <div class="chart-card-header">
          <h3>Doanh Thu Theo Ngày</h3>
          <div class="chart-period">
            <button>Tháng</button>
            <button class="active">Tuần</button>
            <button>Ngày</button>
          </div>
        </div>
        <div class="bar-chart" id="barChart">
          <!-- Bars injected by JS -->
        </div>
      </div>

      <!-- Donut Chart Card -->
      <div class="donut-card animate-in delay-6">
        <h3>📊 Cơ Cấu Doanh Thu</h3>
        <div class="donut-chart-container">
          <div class="donut-chart">
            <div class="donut-hole">
              <span class="donut-value">2.4M</span>
              <span class="donut-label">Tổng</span>
            </div>
          </div>
        </div>
        <div class="donut-legend">
          <div class="legend-item">
            <span class="legend-dot green"></span>
            <span class="legend-name">Nước Ép Tươi</span>
            <span class="legend-pct">60%</span>
          </div>
          <div class="legend-item">
            <span class="legend-dot mint"></span>
            <span class="legend-name">Sinh Tố</span>
            <span class="legend-pct">25%</span>
          </div>
          <div class="legend-item">
            <span class="legend-dot orange"></span>
            <span class="legend-name">Cà Phê</span>
            <span class="legend-pct">15%</span>
          </div>
        </div>
      </div>

      <!-- Top Fruits -->
      <div class="fruits-card animate-in delay-7">
        <h3>🏆 Top Sản Phẩm Bán Chạy</h3>

        <div class="fruit-item">
          <div class="fruit-rank r1">1</div>
          <div class="fruit-blob">🍊</div>
          <div class="fruit-info">
            <div class="fruit-name">Nước Ép Cam</div>
            <div class="fruit-count">187 ly tuần này</div>
          </div>
          <div class="fruit-bar-wrap"><div class="fruit-bar-inner" style="width:100%"></div></div>
        </div>

        <div class="fruit-item">
          <div class="fruit-rank r2">2</div>
          <div class="fruit-blob">🍍</div>
          <div class="fruit-info">
            <div class="fruit-name">Nước Ép Thơm</div>
            <div class="fruit-count">142 ly tuần này</div>
          </div>
          <div class="fruit-bar-wrap"><div class="fruit-bar-inner" style="width:76%"></div></div>
        </div>

        <div class="fruit-item">
          <div class="fruit-rank r3">3</div>
          <div class="fruit-blob">🍉</div>
          <div class="fruit-info">
            <div class="fruit-name">Nước Ép Dưa Hấu</div>
            <div class="fruit-count">118 ly tuần này</div>
          </div>
          <div class="fruit-bar-wrap"><div class="fruit-bar-inner" style="width:63%"></div></div>
        </div>

        <div class="fruit-item">
          <div class="fruit-rank" style="background:linear-gradient(135deg,var(--green),var(--green-l))">4</div>
          <div class="fruit-blob">☕</div>
          <div class="fruit-info">
            <div class="fruit-name">Cà Phê Sữa</div>
            <div class="fruit-count">96 ly tuần này</div>
          </div>
          <div class="fruit-bar-wrap"><div class="fruit-bar-inner" style="width:51%"></div></div>
        </div>

        <div class="fruit-item">
          <div class="fruit-rank" style="background:linear-gradient(135deg,#64748B,#94A3B8)">5</div>
          <div class="fruit-blob">🥑</div>
          <div class="fruit-info">
            <div class="fruit-name">Sinh Tố Bơ</div>
            <div class="fruit-count">73 ly tuần này</div>
          </div>
          <div class="fruit-bar-wrap"><div class="fruit-bar-inner" style="width:39%"></div></div>
        </div>
      </div>
    </div>

    <!-- Orders Table -->
    <div class="table-card animate-in delay-7">
      <div class="table-card-header">
        <h3>📋 Đơn Hàng Gần Đây</h3>
        <span class="view-all">Xem tất cả →</span>
      </div>
      <div style="overflow-x:auto">
      <table class="data-table">
        <thead>
          <tr>
            <th>Mã Đơn</th>
            <th>Khách Hàng</th>
            <th>Món & Ghi Chú</th>
            <th>Giá</th>
            <th>Trạng Thái</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td style="font-weight:700;color:var(--green)">#NDX-1047</td>
            <td>
              <div class="customer-cell">
                <div class="customer-avatar" style="background:linear-gradient(135deg,#F59E0B,#FBBF24)">TL</div>
                <span class="customer-name">Trần Linh</span>
              </div>
            </td>
            <td>
              <span class="order-detail">Ép Cam (L) x2</span>
              <span class="order-note">K Đường</span>
            </td>
            <td class="price-cell">50K</td>
            <td><span class="badge badge-success"><span class="badge-dot"></span>Hoàn thành</span></td>
          </tr>
          <tr>
            <td style="font-weight:700;color:var(--green)">#NDX-1046</td>
            <td>
              <div class="customer-cell">
                <div class="customer-avatar" style="background:linear-gradient(135deg,#6366F1,#818CF8)">NM</div>
                <span class="customer-name">Nguyễn Minh</span>
              </div>
            </td>
            <td>
              <span class="order-detail">Cà Phê Sữa + Sinh Tố Bơ</span>
            </td>
            <td class="price-cell">65K</td>
            <td><span class="badge badge-process"><span class="badge-dot"></span>Đang pha chế</span></td>
          </tr>
          <tr>
            <td style="font-weight:700;color:var(--green)">#NDX-1045</td>
            <td>
              <div class="customer-cell">
                <div class="customer-avatar" style="background:linear-gradient(135deg,#10B981,#34D399)">PH</div>
                <span class="customer-name">Phạm Hương</span>
              </div>
            </td>
            <td>
              <span class="order-detail">Ép Thơm (M) x1, Dưa Hấu (L) x1</span>
              <span class="order-note">Ít đá</span>
            </td>
            <td class="price-cell">45K</td>
            <td><span class="badge badge-pending"><span class="badge-dot"></span>Chờ xác nhận</span></td>
          </tr>
          <tr>
            <td style="font-weight:700;color:var(--green)">#NDX-1044</td>
            <td>
              <div class="customer-cell">
                <div class="customer-avatar" style="background:linear-gradient(135deg,#EC4899,#F472B6)">LT</div>
                <span class="customer-name">Lê Thảo</span>
              </div>
            </td>
            <td>
              <span class="order-detail">Mix Cam + Thơm (L)</span>
              <span class="order-note">Giảm đường</span>
            </td>
            <td class="price-cell">30K</td>
            <td><span class="badge badge-success"><span class="badge-dot"></span>Hoàn thành</span></td>
          </tr>
          <tr>
            <td style="font-weight:700;color:var(--green)">#NDX-1043</td>
            <td>
              <div class="customer-cell">
                <div class="customer-avatar" style="background:linear-gradient(135deg,#F97316,#FB923C)">VD</div>
                <span class="customer-name">Võ Đức</span>
              </div>
            </td>
            <td>
              <span class="order-detail">Matcha Đá Xay x2</span>
            </td>
            <td class="price-cell">80K</td>
            <td><span class="badge badge-process"><span class="badge-dot"></span>Đang pha chế</span></td>
          </tr>
          <tr>
            <td style="font-weight:700;color:var(--green)">#NDX-1042</td>
            <td>
              <div class="customer-cell">
                <div class="customer-avatar" style="background:linear-gradient(135deg,#8B5CF6,#A78BFA)">HN</div>
                <span class="customer-name">Hoàng Nam</span>
              </div>
            </td>
            <td>
              <span class="order-detail">Cà Phê Đen x1</span>
            </td>
            <td class="price-cell">22K</td>
            <td><span class="badge badge-cancel"><span class="badge-dot"></span>Đã hủy</span></td>
          </tr>
          <tr>
            <td style="font-weight:700;color:var(--green)">#NDX-1041</td>
            <td>
              <div class="customer-cell">
                <div class="customer-avatar" style="background:linear-gradient(135deg,#14B8A6,#2DD4BF)">TT</div>
                <span class="customer-name">Thanh Trúc</span>
              </div>
            </td>
            <td>
              <span class="order-detail">Ép Bưởi (M), Ép Cam (L)</span>
              <span class="order-note">K Đường</span>
            </td>
            <td class="price-cell">45K</td>
            <td><span class="badge badge-success"><span class="badge-dot"></span>Hoàn thành</span></td>
          </tr>
        </tbody>
      </table>
      </div>
    </div>

  </main>
</div>

<!-- ================================================================
     JAVASCRIPT
     ================================================================ -->
<script>
(function(){
  // ── Bar Chart Data & Render ──
  const data = [
    {label:'T2', value:320, max:500},
    {label:'T3', value:410, max:500},
    {label:'T4', value:280, max:500},
    {label:'T5', value:460, max:500},
    {label:'T6', value:380, max:500},
    {label:'T7', value:500, max:500},
    {label:'CN', value:350, max:500},
  ];

  const chart = document.getElementById('barChart');
  data.forEach((d, i) => {
    const pct = (d.value / d.max) * 100;
    const isGreen = i === 5; // Saturday highlight
    const col = document.createElement('div');
    col.className = 'bar-col';
    col.style.animationDelay = (i * 0.08) + 's';
    col.innerHTML =
      '<div class="bar-wrapper">' +
        '<div class="bar' + (isGreen ? ' green-bar' : '') + '" style="height:' + pct + '%">' +
          '<span class="bar-value">' + d.value + 'K</span>' +
        '</div>' +
      '</div>' +
      '<span class="bar-label">' + d.label + '</span>';
    chart.appendChild(col);
  });

  // ── Animate bars on load ──
  setTimeout(function(){
    document.querySelectorAll('.bar').forEach(function(bar){
      var h = bar.style.height;
      bar.style.height = '0%';
      bar.style.transition = 'height 1s cubic-bezier(.16,1,.3,1)';
      setTimeout(function(){ bar.style.height = h; }, 100);
    });
  }, 400);

  // ── Chart period toggle ──
  document.querySelectorAll('.chart-period button').forEach(function(btn){
    btn.addEventListener('click', function(){
      document.querySelectorAll('.chart-period button').forEach(function(b){ b.classList.remove('active'); });
      this.classList.add('active');
    });
  });

  // ── Nav active toggle ──
  document.querySelectorAll('.nav-item:not(.logout)').forEach(function(item){
    item.addEventListener('click', function(e){
      e.preventDefault();
      document.querySelectorAll('.nav-item').forEach(function(n){ n.classList.remove('active'); });
      this.classList.add('active');
    });
  });

  // ── Mobile sidebar toggle ──
  var sidebar = document.getElementById('sidebar');
  document.addEventListener('click', function(e){
    if(window.innerWidth <= 900){
      if(!sidebar.contains(e.target)){
        sidebar.classList.remove('open');
      }
    }
  });
})();
</script>
</body>
</html>
