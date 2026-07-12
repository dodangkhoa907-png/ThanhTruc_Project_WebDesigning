<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<style>
/* ============================================================
   NHIỆT ĐỚI XANH — Admin Dashboard
   Style: Glossy 3D & Liquid Soft-UI
   Scoped under #admin-dashboard-wrapper
   ============================================================ */
#admin-dashboard-wrapper *, 
#admin-dashboard-wrapper *::before, 
#admin-dashboard-wrapper *::after {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

#admin-dashboard-wrapper {
  --bg: #F7F9F6;
  --card: #FFFFFF;
  --green: #2A5C38;
  --green-l: #3A7D4A;
  --green-d: #1E3F27;
  --mango: #FF9F1C;
  --mango-l: #FFB84D;
  --mango-d: #E8880A;
  --red: #E74C3C;
  --text: #1A2E1A;
  --text-s: #5A6E5A;
  --text-m: #8A9A8A;
  --border: #E8ECE6;
  --sidebar-w: 280px;
  --font: 'Be Vietnam Pro', sans-serif;
  --ease: cubic-bezier(.16, 1, .3, 1);
  --radius: 20px;

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

  font-family: var(--font);
  background: var(--bg);
  color: var(--text);
  line-height: 1.6;
  min-height: 100vh;
  position: relative;
}

#admin-dashboard-wrapper html {
  font-size: 16px;
  scroll-behavior: smooth;
}

/* ============================================================
   LAYOUT STRUCTURE
   ============================================================ */
#admin-dashboard-wrapper .dashboard {
  min-height: 100vh;
  position: relative;
}

/* ============================================================
   SIDEBAR — Liquid Navigation
   ============================================================ */
#admin-dashboard-wrapper .sidebar {
  background: linear-gradient(180deg, var(--green-d) 0%, #0F2618 100%);
  padding: 32px 20px;
  display: flex;
  flex-direction: column;
  position: fixed;
  top: 0;
  left: 0;
  bottom: 0;
  width: var(--sidebar-w);
  z-index: 100;
  overflow-y: auto;
}

/* Logo 3D */
#admin-dashboard-wrapper .sidebar-logo {
  text-align: center;
  padding: 8px 0 36px;
  border-bottom: 1px solid rgba(255, 255, 255, .08);
  margin-bottom: 28px;
}
#admin-dashboard-wrapper .sidebar-logo h1 {
  font-size: 1.5rem;
  font-weight: 900;
  background: linear-gradient(135deg, #4ADE80 0%, #A7F3D0 40%, #FDE68A 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  filter: drop-shadow(0 2px 8px rgba(74, 222, 128, .3));
  letter-spacing: -.5px;
  line-height: 1.3;
}
#admin-dashboard-wrapper .sidebar-logo span {
  display: block;
  font-size: .68rem;
  font-weight: 500;
  -webkit-text-fill-color: rgba(167, 243, 208, .5);
  letter-spacing: 2px;
  text-transform: uppercase;
  margin-top: 4px;
}

/* Nav Items — Liquid morph on hover */
#admin-dashboard-wrapper .nav-section {
  margin-bottom: 8px;
}
#admin-dashboard-wrapper .nav-section-title {
  font-size: .65rem;
  font-weight: 700;
  color: rgba(167, 243, 208, .35);
  text-transform: uppercase;
  letter-spacing: 2.5px;
  padding: 0 16px;
  margin-bottom: 8px;
}

#admin-dashboard-wrapper .nav-item {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 12px 18px;
  margin: 3px 0;
  color: rgba(255, 255, 255, .55);
  font-size: .88rem;
  font-weight: 500;
  border-radius: 14px;
  cursor: pointer;
  transition: all .4s var(--ease);
  position: relative;
  text-decoration: none;
}
#admin-dashboard-wrapper .nav-item:hover {
  color: rgba(255, 255, 255, .9);
  background: rgba(255, 255, 255, .06);
  border-radius: 30px 10px 30px 10px;
}
#admin-dashboard-wrapper .nav-item.active {
  color: #fff;
  font-weight: 600;
  background: linear-gradient(135deg, rgba(42, 92, 56, .6), rgba(58, 125, 74, .4));
  border-radius: 30px 10px 30px 10px;
  box-shadow: 0 4px 20px rgba(42, 92, 56, .3), inset 0 1px 0 rgba(255, 255, 255, .1);
}
#admin-dashboard-wrapper .nav-item.active::before {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 4px;
  height: 24px;
  border-radius: 0 4px 4px 0;
  background: linear-gradient(180deg, var(--mango), var(--mango-l));
  box-shadow: 0 0 12px rgba(255, 159, 28, .4);
}

#admin-dashboard-wrapper .nav-icon {
  width: 22px;
  height: 22px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1rem;
}
#admin-dashboard-wrapper .nav-badge {
  margin-left: auto;
  font-size: .7rem;
  font-weight: 700;
  background: linear-gradient(135deg, var(--mango), var(--mango-l));
  color: var(--green-d);
  padding: 2px 10px;
  border-radius: 50px;
  box-shadow: 0 2px 8px rgba(255, 159, 28, .3);
}

/* Logout */
#admin-dashboard-wrapper .nav-logout {
  margin-top: auto;
  padding-top: 20px;
  border-top: 1px solid rgba(255, 255, 255, .06);
}
#admin-dashboard-wrapper .nav-item.logout {
  color: rgba(231, 76, 60, .7);
}
#admin-dashboard-wrapper .nav-item.logout:hover {
  color: #fff;
  background: rgba(231, 76, 60, .15);
  border-radius: 30px 10px 30px 10px;
}

/* ============================================================
   MAIN CONTENT
   ============================================================ */
#admin-dashboard-wrapper .main {
  margin-left: var(--sidebar-w);
  padding: 28px 36px 60px;
  min-height: 100vh;
}

/* ── Glass Header ── */
#admin-dashboard-wrapper .glass-header {
  display: flex;
  align-items: center;
  gap: 20px;
  margin-bottom: 32px;
  padding: 20px 28px;
  background: rgba(255, 255, 255, .7);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, .8);
  border-radius: var(--radius);
  box-shadow: var(--shadow-card);
}
#admin-dashboard-wrapper .header-title {
  flex: 1;
}
#admin-dashboard-wrapper .header-title h2 {
  font-size: 1.5rem;
  font-weight: 800;
  color: var(--text);
  letter-spacing: -.3px;
}
#admin-dashboard-wrapper .header-title p {
  font-size: .82rem;
  color: var(--text-m);
  margin-top: 2px;
}

/* Search — Pill */
#admin-dashboard-wrapper .search-pill {
  display: flex;
  align-items: center;
  gap: 10px;
  background: var(--bg);
  border: 1.5px solid var(--border);
  border-radius: 50px;
  padding: 10px 20px;
  width: 280px;
  transition: all .3s var(--ease);
}
#admin-dashboard-wrapper .search-pill:focus-within {
  border-color: var(--green);
  box-shadow: 0 0 0 4px rgba(42, 92, 56, .08);
  background: #fff;
}
#admin-dashboard-wrapper .search-pill input {
  border: none;
  outline: none;
  background: transparent;
  font-family: var(--font);
  font-size: .88rem;
  color: var(--text);
  width: 100%;
}
#admin-dashboard-wrapper .search-pill input::placeholder {
  color: var(--text-m);
}
#admin-dashboard-wrapper .search-icon {
  color: var(--text-m);
  font-size: 1rem;
  flex-shrink: 0;
}

/* Avatar — Liquid morph */
#admin-dashboard-wrapper .avatar-liquid {
  width: 46px;
  height: 46px;
  border-radius: 50%;
  overflow: hidden;
  border: 2.5px solid var(--green);
  box-shadow: 0 4px 16px rgba(42, 92, 56, .15);
  animation: liquidMorph 8s ease-in-out infinite;
  cursor: pointer;
  flex-shrink: 0;
}
#admin-dashboard-wrapper .avatar-liquid img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

@keyframes liquidMorph {
  0%, 100% { border-radius: 50% 50% 50% 50%; }
  25% { border-radius: 40% 60% 55% 45%; }
  50% { border-radius: 55% 45% 40% 60%; }
  75% { border-radius: 45% 55% 60% 40%; }
}

/* ============================================================
   TABS VISIBILITY
   ============================================================ */
#admin-dashboard-wrapper .tab-content {
  display: none;
}
#admin-dashboard-wrapper .tab-content.active {
  display: block;
  animation: tabFadeIn 0.4s var(--ease) both;
}
@keyframes tabFadeIn {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}

/* ============================================================
   KPI CARDS — 3D Glossy
   ============================================================ */
#admin-dashboard-wrapper .kpi-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 32px;
}

#admin-dashboard-wrapper .kpi-card {
  background: var(--card);
  border: 1px solid rgba(255, 255, 255, .9);
  border-radius: var(--radius);
  padding: 28px 24px;
  box-shadow: var(--shadow-card);
  transition: all .4s var(--ease);
  position: relative;
  overflow: hidden;
  cursor: default;
}
#admin-dashboard-wrapper .kpi-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, var(--green), var(--green-l));
  border-radius: var(--radius) var(--radius) 0 0;
  opacity: 0;
  transition: opacity .3s;
}
#admin-dashboard-wrapper .kpi-card:hover {
  transform: translateY(-8px);
  box-shadow: var(--shadow-card-hover);
}
#admin-dashboard-wrapper .kpi-card:hover::before {
  opacity: 1;
}

#admin-dashboard-wrapper .kpi-card:nth-child(1)::before { background: linear-gradient(90deg, var(--green), var(--green-l)); }
#admin-dashboard-wrapper .kpi-card:nth-child(2)::before { background: linear-gradient(90deg, var(--mango), var(--mango-l)); }
#admin-dashboard-wrapper .kpi-card:nth-child(3)::before { background: linear-gradient(90deg, #6366F1, #818CF8); }
#admin-dashboard-wrapper .kpi-card:nth-child(4)::before { background: linear-gradient(90deg, #10B981, #34D399); }

#admin-dashboard-wrapper .kpi-icon {
  width: 52px;
  height: 52px;
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  margin-bottom: 18px;
  box-shadow:
    0 4px 12px rgba(0,0,0,.08),
    0 1px 2px rgba(0,0,0,.06),
    inset 0 -2px 4px rgba(0,0,0,.06),
    inset 0 2px 0 rgba(255,255,255,.6);
  transition: all .5s var(--ease);
}
#admin-dashboard-wrapper .kpi-card:hover .kpi-icon {
  animation: liquidMorph 3s ease-in-out infinite;
  transform: scale(1.08);
}

#admin-dashboard-wrapper .kpi-icon.green { background: linear-gradient(145deg, #D1FAE5, #A7F3D0); }
#admin-dashboard-wrapper .kpi-icon.orange { background: linear-gradient(145deg, #FEF3C7, #FDE68A); }
#admin-dashboard-wrapper .kpi-icon.purple { background: linear-gradient(145deg, #E0E7FF, #C7D2FE); }
#admin-dashboard-wrapper .kpi-icon.teal { background: linear-gradient(145deg, #CCFBF1, #99F6E4); }

#admin-dashboard-wrapper .kpi-label {
  font-size: .78rem;
  font-weight: 600;
  color: var(--text-m);
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 6px;
}
#admin-dashboard-wrapper .kpi-value {
  font-size: 2rem;
  font-weight: 900;
  color: var(--text);
  line-height: 1.1;
  letter-spacing: -1px;
}
#admin-dashboard-wrapper .kpi-sub {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-top: 10px;
  font-size: .78rem;
  color: var(--text-m);
}
#admin-dashboard-wrapper .kpi-up {
  color: #10B981;
  font-weight: 700;
}
#admin-dashboard-wrapper .kpi-down {
  color: var(--red);
  font-weight: 700;
}

/* ── Liquid Progress ── */
#admin-dashboard-wrapper .liquid-progress {
  width: 100%;
  height: 10px;
  background: var(--bg);
  border-radius: 50px;
  margin-top: 16px;
  overflow: hidden;
  position: relative;
  box-shadow: inset 0 2px 4px rgba(0,0,0,.06);
}
#admin-dashboard-wrapper .liquid-progress-fill {
  height: 100%;
  width: 98%;
  background: linear-gradient(90deg, #10B981, #34D399, #6EE7B7, #34D399);
  background-size: 200% 100%;
  border-radius: 50px;
  position: relative;
  animation: liquidWave 3s ease-in-out infinite;
}
#admin-dashboard-wrapper .liquid-progress-fill::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,.4), transparent);
  background-size: 200% 100%;
  animation: shimmer 2s linear infinite;
}

@keyframes liquidWave {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}
@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

/* ============================================================
   MIDDLE ROW: Chart + Donut + Top Fruits
   ============================================================ */
#admin-dashboard-wrapper .middle-row {
  display: grid;
  grid-template-columns: 4fr 3fr 3fr;
  gap: 24px;
  margin-bottom: 32px;
}
#admin-dashboard-wrapper .middle-row > div {
  min-height: 340px;
  height: auto;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}

/* ── Donut Chart ── */
#admin-dashboard-wrapper .donut-card {
  background: var(--card);
  border: 1px solid rgba(255, 255, 255, .9);
  border-radius: var(--radius);
  padding: 28px;
  box-shadow: var(--shadow-card);
  display: flex;
  flex-direction: column;
}
#admin-dashboard-wrapper .donut-card h3 {
  font-size: 1.1rem;
  font-weight: 700;
  margin-bottom: 24px;
  color: var(--text);
}
#admin-dashboard-wrapper .donut-chart-container {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
  flex: 1;
}
#admin-dashboard-wrapper .donut-chart {
  position: relative;
  width: 160px;
  height: 160px;
  border-radius: 50%;
  background: conic-gradient(
    var(--green) 0% 60%, 
    #34D399 60% 85%, 
    var(--mango) 85% 100%
  );
  box-shadow:
    0 10px 25px rgba(42, 92, 56, 0.15),
    inset 0 4px 12px rgba(0, 0, 0, 0.15);
  display: flex;
  align-items: center;
  justify-content: center;
}
#admin-dashboard-wrapper .donut-hole {
  position: absolute;
  width: 108px;
  height: 108px;
  background: var(--card);
  border-radius: 50%;
  box-shadow:
    inset 0 4px 10px rgba(0, 0, 0, 0.12),
    0 2px 4px rgba(255, 255, 255, 0.8);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
#admin-dashboard-wrapper .donut-value {
  font-family: var(--font);
  font-size: 1.15rem;
  font-weight: 900;
  color: var(--text);
  line-height: 1.2;
  white-space: nowrap;
}
#admin-dashboard-wrapper .donut-label {
  font-size: 0.7rem;
  font-weight: 700;
  color: var(--text-m);
  text-transform: uppercase;
  letter-spacing: 1px;
}
#admin-dashboard-wrapper .donut-legend {
  display: flex;
  flex-direction: column;
  gap: 10px;
  margin-top: auto;
  border-top: 1px solid var(--border);
  padding-top: 16px;
}
#admin-dashboard-wrapper .legend-item {
  display: flex;
  align-items: center;
  font-size: 0.8rem;
  color: var(--text-s);
  position: relative;
  cursor: pointer;
}
#admin-dashboard-wrapper .legend-item::after {
  content: attr(data-tooltip);
  position: absolute;
  bottom: 125%;
  left: 50%;
  transform: translateX(-50%) translateY(5px);
  background: var(--text);
  color: #fff;
  padding: 6px 12px;
  border-radius: 8px;
  font-size: 0.72rem;
  font-weight: 600;
  white-space: nowrap;
  opacity: 0;
  visibility: hidden;
  transition: all 0.25s var(--ease);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  z-index: 10;
}
#admin-dashboard-wrapper .legend-item::before {
  content: '';
  position: absolute;
  bottom: 110%;
  left: 50%;
  transform: translateX(-50%) translateY(5px);
  border: 6px solid transparent;
  border-top-color: var(--text);
  opacity: 0;
  visibility: hidden;
  transition: all 0.25s var(--ease);
  z-index: 10;
}
#admin-dashboard-wrapper .legend-item:hover::after,
#admin-dashboard-wrapper .legend-item:hover::before {
  opacity: 1;
  visibility: visible;
  transform: translateX(-50%) translateY(0);
}
#admin-dashboard-wrapper .legend-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  margin-right: 10px;
  flex-shrink: 0;
  box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.15);
}
#admin-dashboard-wrapper .legend-dot.green { background: var(--green); }
#admin-dashboard-wrapper .legend-dot.mint { background: #34D399; }
#admin-dashboard-wrapper .legend-dot.orange { background: var(--mango); }
#admin-dashboard-wrapper .legend-name {
  font-weight: 500;
  flex-grow: 1;
}
#admin-dashboard-wrapper .legend-pct {
  font-family: var(--font);
  font-weight: 700;
  color: var(--text);
  margin-left: auto;
}

/* ── 3D Liquid Bar Chart ── */
#admin-dashboard-wrapper .chart-card {
  background: var(--card);
  border: 1px solid rgba(255, 255, 255, .9);
  border-radius: var(--radius);
  padding: 28px;
  box-shadow: var(--shadow-card);
}
#admin-dashboard-wrapper .chart-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 28px;
}
#admin-dashboard-wrapper .chart-card-header h3 {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--text);
}
#admin-dashboard-wrapper .chart-period {
  display: flex;
  gap: 4px;
  background: var(--bg);
  border-radius: 10px;
  padding: 3px;
}
#admin-dashboard-wrapper .chart-period button {
  font-family: var(--font);
  font-size: .72rem;
  font-weight: 600;
  padding: 6px 14px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all .3s var(--ease);
  background: transparent;
  color: var(--text-m);
}
#admin-dashboard-wrapper .chart-period button.active {
  background: var(--card);
  color: var(--text);
  box-shadow: 0 2px 8px rgba(0,0,0,.08), inset 0 1px 0 rgba(255,255,255,1);
}

/* Bar Chart */
#admin-dashboard-wrapper .bar-chart {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  height: 180px;
  padding: 0 8px;
  gap: 12px;
  border-bottom: 2px solid var(--border);
  position: relative;
}

/* Y-axis grid lines */
#admin-dashboard-wrapper .bar-chart::before {
  content: '';
  position: absolute;
  inset: 0;
  background: repeating-linear-gradient(
    to bottom,
    transparent,
    transparent calc(25% - 1px),
    var(--border) calc(25% - 1px),
    var(--border) 25%
  );
  pointer-events: none;
  opacity: .4;
}

#admin-dashboard-wrapper .bar-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  position: relative;
  z-index: 1;
}

#admin-dashboard-wrapper .bar-wrapper {
  width: 100%;
  max-width: 48px;
  position: relative;
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

#admin-dashboard-wrapper .bar {
  width: 100%;
  border-radius: 12px 12px 6px 6px;
  background: linear-gradient(180deg, var(--mango) 0%, var(--mango-l) 40%, #FFD166 100%);
  position: relative;
  transition: all .5s var(--ease);
  box-shadow:
    0 4px 16px rgba(255,159,28,.25),
    inset 0 2px 0 rgba(255,255,255,.4),
    inset -2px 0 4px rgba(0,0,0,.05),
    inset 2px 0 4px rgba(0,0,0,.02);
  min-height: 20px;
  cursor: pointer;
}

/* 3D Reflection under bars */
#admin-dashboard-wrapper .bar::after {
  content: '';
  position: absolute;
  bottom: -12px;
  left: 10%;
  right: 10%;
  height: 12px;
  background: linear-gradient(180deg, rgba(255,159,28,.15), transparent);
  border-radius: 0 0 50% 50%;
  filter: blur(4px);
}

#admin-dashboard-wrapper .bar:hover {
  filter: brightness(1.08);
  transform: scaleY(1.03);
  transform-origin: bottom;
}

/* Value tooltip on hover */
#admin-dashboard-wrapper .bar-value {
  position: absolute;
  top: -32px;
  left: 50%;
  transform: translateX(-50%);
  background: var(--text);
  color: #fff;
  font-size: .68rem;
  font-weight: 700;
  padding: 4px 10px;
  border-radius: 8px;
  opacity: 0;
  transition: opacity .2s;
  white-space: nowrap;
  pointer-events: none;
}
#admin-dashboard-wrapper .bar-value::after {
  content: '';
  position: absolute;
  bottom: -4px;
  left: 50%;
  transform: translateX(-50%);
  border: 4px solid transparent;
  border-top-color: var(--text);
}
#admin-dashboard-wrapper .bar:hover .bar-value {
  opacity: 1;
}

#admin-dashboard-wrapper .bar-label {
  font-size: .72rem;
  font-weight: 600;
  color: var(--text-m);
  margin-top: 4px;
}

/* Green accent bars */
#admin-dashboard-wrapper .bar.green-bar {
  background: linear-gradient(180deg, var(--green) 0%, var(--green-l) 40%, #4ADE80 100%);
  box-shadow:
    0 4px 16px rgba(42,92,56,.2),
    inset 0 2px 0 rgba(255,255,255,.3),
    inset -2px 0 4px rgba(0,0,0,.08),
    inset 2px 0 4px rgba(0,0,0,.03);
}
#admin-dashboard-wrapper .bar.green-bar::after {
  background: linear-gradient(180deg, rgba(42,92,56,.12), transparent);
}

/* ── Top Fruits Card ── */
#admin-dashboard-wrapper .fruits-card {
  background: var(--card);
  border: 1px solid rgba(255, 255, 255, .9);
  border-radius: var(--radius);
  padding: 28px;
  box-shadow: var(--shadow-card);
}
#admin-dashboard-wrapper .fruits-card h3 {
  font-size: 1.1rem;
  font-weight: 700;
  margin-bottom: 16px;
}

#admin-dashboard-wrapper .fruit-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 6px 0;
  border-bottom: 1px solid var(--border);
  transition: all .3s var(--ease);
}
#admin-dashboard-wrapper .fruit-item:last-child {
  border-bottom: none;
}
#admin-dashboard-wrapper .fruit-item:hover {
  padding-left: 4px;
}

#admin-dashboard-wrapper .fruit-rank {
  width: 24px;
  height: 24px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: .68rem;
  font-weight: 800;
  color: #fff;
  flex-shrink: 0;
  box-shadow: 0 2px 6px rgba(0,0,0,.1), inset 0 1px 0 rgba(255,255,255,.2);
}
#admin-dashboard-wrapper .fruit-rank.r1 { background: linear-gradient(135deg, var(--mango), var(--mango-l)); }
#admin-dashboard-wrapper .fruit-rank.r2 { background: linear-gradient(135deg, #94A3B8, #CBD5E1); }
#admin-dashboard-wrapper .fruit-rank.r3 { background: linear-gradient(135deg, #D97706, #F59E0B); }

/* Blob container for fruit emoji */
#admin-dashboard-wrapper .fruit-blob {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
  background: linear-gradient(135deg, rgba(42, 92, 56, .06), rgba(244, 162, 97, .08));
  border-radius: 50%;
  animation: blobMorph 6s ease-in-out infinite;
  box-shadow:
    0 2px 8px rgba(0,0,0,.04),
    inset 0 1px 0 rgba(255,255,255,.6);
  flex-shrink: 0;
}
#admin-dashboard-wrapper .fruit-blob:nth-child(2) { animation-delay: -2s; }
#admin-dashboard-wrapper .fruit-blob:nth-child(3) { animation-delay: -4s; }

@keyframes blobMorph {
  0%, 100% { border-radius: 50% 50% 50% 50%; }
  20% { border-radius: 42% 58% 55% 45%; }
  40% { border-radius: 55% 45% 42% 58%; }
  60% { border-radius: 48% 52% 58% 42%; }
  80% { border-radius: 52% 48% 45% 55%; }
}

#admin-dashboard-wrapper .fruit-info {
  flex: 1;
}
#admin-dashboard-wrapper .fruit-name {
  font-size: .82rem;
  font-weight: 700;
  color: var(--text);
  line-height: 1.2;
}
#admin-dashboard-wrapper .fruit-count {
  font-size: .68rem;
  color: var(--text-m);
}

#admin-dashboard-wrapper .fruit-bar-wrap {
  width: 60px;
  height: 6px;
  background: var(--bg);
  border-radius: 50px;
  overflow: hidden;
  flex-shrink: 0;
}
#admin-dashboard-wrapper .fruit-bar-inner {
  height: 100%;
  border-radius: 50px;
  background: linear-gradient(90deg, var(--green), var(--green-l));
  box-shadow: inset 0 1px 0 rgba(255,255,255,.3);
}

/* ============================================================
   DATA TABLE — Orders
   ============================================================ */
#admin-dashboard-wrapper .table-card {
  background: var(--card);
  border: 1px solid rgba(255, 255, 255, .9);
  border-radius: var(--radius);
  padding: 28px;
  box-shadow: var(--shadow-card);
}
#admin-dashboard-wrapper .table-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}
#admin-dashboard-wrapper .table-card-header h3 {
  font-size: 1.1rem;
  font-weight: 700;
}
#admin-dashboard-wrapper .table-card-header .view-all {
  font-size: .78rem;
  font-weight: 600;
  color: var(--green);
  cursor: pointer;
  transition: color .2s;
}
#admin-dashboard-wrapper .table-card-header .view-all:hover {
  color: var(--mango);
}

#admin-dashboard-wrapper .data-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
}
#admin-dashboard-wrapper .data-table thead th {
  text-align: left;
  font-size: .7rem;
  font-weight: 700;
  color: var(--text-m);
  text-transform: uppercase;
  letter-spacing: 1.2px;
  padding: 12px 16px;
  border-bottom: 2px solid var(--border);
}
#admin-dashboard-wrapper .data-table tbody tr {
  transition: all .25s var(--ease);
  cursor: default;
}
#admin-dashboard-wrapper .data-table tbody tr:nth-child(even) {
  background: rgba(247, 249, 246, .6);
}
#admin-dashboard-wrapper .data-table tbody tr:hover {
  background: rgba(42, 92, 56, .03);
}

#admin-dashboard-wrapper .data-table tbody td {
  padding: 14px 16px;
  font-size: .88rem;
  border-bottom: 1px solid var(--border);
  vertical-align: middle;
}
#admin-dashboard-wrapper .data-table tbody tr:last-child td {
  border-bottom: none;
}

#admin-dashboard-wrapper .customer-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}
#admin-dashboard-wrapper .customer-avatar {
  width: 34px;
  height: 34px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: .82rem;
  font-weight: 700;
  color: #fff;
  flex-shrink: 0;
  box-shadow: 0 2px 6px rgba(0,0,0,.1), inset 0 1px 0 rgba(255,255,255,.2);
}
#admin-dashboard-wrapper .customer-name {
  font-weight: 600;
  color: var(--text);
}

#admin-dashboard-wrapper .order-detail {
  font-size: .82rem;
  color: var(--text-s);
}
#admin-dashboard-wrapper .order-note {
  display: inline-block;
  font-size: .68rem;
  font-weight: 600;
  color: var(--mango-d);
  background: rgba(255, 159, 28, .08);
  padding: 2px 8px;
  border-radius: 6px;
  margin-left: 6px;
}

#admin-dashboard-wrapper .price-cell {
  font-weight: 700;
  color: var(--text);
}

/* Status Badges — Glossy 3D */
#admin-dashboard-wrapper .badge {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  padding: 6px 14px;
  border-radius: 50px;
  font-size: .72rem;
  font-weight: 700;
  letter-spacing: .3px;
}
#admin-dashboard-wrapper .badge-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  flex-shrink: 0;
}

#admin-dashboard-wrapper .badge-success {
  background: linear-gradient(135deg, #D1FAE5, #A7F3D0);
  color: #065F46;
  box-shadow:
    0 2px 8px rgba(16,185,129,.15),
    inset 0 1px 0 rgba(255,255,255,.7),
    inset 0 -1px 2px rgba(0,0,0,.04);
}
#admin-dashboard-wrapper .badge-success .badge-dot {
  background: #10B981;
  box-shadow: 0 0 6px rgba(16,185,129,.4);
}

#admin-dashboard-wrapper .badge-pending {
  background: linear-gradient(135deg, #FEF3C7, #FDE68A);
  color: #92400E;
  box-shadow:
    0 2px 8px rgba(255,159,28,.15),
    inset 0 1px 0 rgba(255,255,255,.7),
    inset 0 -1px 2px rgba(0,0,0,.04);
}
#admin-dashboard-wrapper .badge-pending .badge-dot {
  background: var(--mango);
  box-shadow: 0 0 6px rgba(255,159,28,.4);
}

#admin-dashboard-wrapper .badge-process {
  background: linear-gradient(135deg, #E0E7FF, #C7D2FE);
  color: #3730A3;
  box-shadow:
    0 2px 8px rgba(99,102,241,.15),
    inset 0 1px 0 rgba(255,255,255,.7),
    inset 0 -1px 2px rgba(0,0,0,.04);
}
#admin-dashboard-wrapper .badge-process .badge-dot {
  background: #6366F1;
  box-shadow: 0 0 6px rgba(99,102,241,.4);
}

#admin-dashboard-wrapper .badge-cancel {
  background: linear-gradient(135deg, #FEE2E2, #FECACA);
  color: #991B1B;
  box-shadow:
    0 2px 8px rgba(231,76,60,.12),
    inset 0 1px 0 rgba(255,255,255,.7),
    inset 0 -1px 2px rgba(0,0,0,.04);
}
#admin-dashboard-wrapper .badge-cancel .badge-dot {
  background: var(--red);
  box-shadow: 0 0 6px rgba(231,76,60,.3);
}

/* ============================================================
   TAB 2 (Tinh chỉnh) — Glassmorphism Form
   ============================================================ */
#admin-dashboard-wrapper .glass-form-card {
  background: rgba(255, 255, 255, 0.45);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: var(--radius);
  padding: 40px;
  max-width: 1000px;
  margin: 0 auto;
  box-shadow: var(--shadow-card);
}
#admin-dashboard-wrapper .glass-form-card h3 {
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--text);
  margin-bottom: 8px;
  display: flex;
  align-items: center;
  gap: 10px;
}
#admin-dashboard-wrapper .form-subtitle {
  font-size: 0.88rem;
  color: var(--text-s);
  margin-bottom: 28px;
}
#admin-dashboard-wrapper .glass-form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
}
#admin-dashboard-wrapper .glass-form-section {
  display: flex;
  flex-direction: column;
}
#admin-dashboard-wrapper .section-title {
  font-size: 1.15rem;
  font-weight: 800;
  color: var(--green);
  margin-bottom: 24px;
  border-bottom: 1.5px solid var(--border);
  padding-bottom: 10px;
}
#admin-dashboard-wrapper .form-group {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}
#admin-dashboard-wrapper .form-group label {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--text-s);
}

/* Custom input wrappers */
#admin-dashboard-wrapper .input-group-3d {
  position: relative;
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.7);
  border: 1.5px solid var(--border);
  border-radius: 14px;
  padding: 4px 16px;
  transition: all 0.3s var(--ease);
}
#admin-dashboard-wrapper .input-group-3d:focus-within {
  border-color: var(--green);
  box-shadow: 0 0 0 4px rgba(42,92,56,0.08);
  background: #fff;
}
#admin-dashboard-wrapper .input-group-3d .input-icon {
  font-size: 1.25rem;
  margin-right: 12px;
  user-select: none;
}
#admin-dashboard-wrapper .input-group-3d input {
  font-family: var(--font);
  font-size: 0.95rem;
  border: none;
  background: transparent;
  outline: none;
  color: var(--text);
  width: 100%;
  padding: 12px 0;
}
#admin-dashboard-wrapper .input-group-3d::after {
  content: '';
  position: absolute;
  bottom: -1.5px;
  left: 50%;
  width: 0;
  height: 2px;
  background: linear-gradient(90deg, var(--green), var(--green-l));
  transition: all 0.4s var(--ease);
  transform: translateX(-50%);
}
#admin-dashboard-wrapper .input-group-3d:focus-within::after {
  width: 100%;
}

/* Custom sliders */
#admin-dashboard-wrapper .slider-group-3d {
  display: flex;
  align-items: center;
  gap: 16px;
  background: rgba(255, 255, 255, 0.7);
  border: 1.5px solid var(--border);
  border-radius: 14px;
  padding: 12px 18px;
}
#admin-dashboard-wrapper .slider-group-3d .input-icon {
  font-size: 1.25rem;
  user-select: none;
}
#admin-dashboard-wrapper .slider-group-3d input[type="range"] {
  -webkit-appearance: none;
  appearance: none;
  width: 100%;
  height: 8px;
  border-radius: 10px;
  background: #E8ECE6;
  outline: none;
  transition: background 0.3s ease;
}
#admin-dashboard-wrapper .slider-group-3d input[type="range"]::-webkit-slider-thumb {
  -webkit-appearance: none;
  appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #fff;
  border: 2px solid var(--green);
  box-shadow: 
    0 4px 10px rgba(42,92,56,0.3),
    inset 0 1px 0 rgba(255,255,255,1);
  cursor: pointer;
  transition: all 0.2s var(--ease);
}
#admin-dashboard-wrapper .slider-group-3d input[type="range"]::-webkit-slider-thumb:hover {
  transform: scale(1.15);
  box-shadow: 
    0 6px 14px rgba(42,92,56,0.4),
    inset 0 1px 0 rgba(255,255,255,1);
}
#admin-dashboard-wrapper .slider-group-3d input[type="range"]::-moz-range-thumb {
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: #fff;
  border: 2px solid var(--green);
  box-shadow: 0 4px 10px rgba(42,92,56,0.3);
  cursor: pointer;
  transition: all 0.2s var(--ease);
}
#admin-dashboard-wrapper .slider-group-3d input[type="range"]::-moz-range-thumb:hover {
  transform: scale(1.15);
}

/* Color Sphere Icons next to sliders */
#admin-dashboard-wrapper .color-sphere {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  flex-shrink: 0;
  box-shadow: 
    0 4px 8px rgba(0,0,0,0.12),
    inset 0 2px 4px rgba(255,255,255,0.4),
    inset 0 -2px 4px rgba(0,0,0,0.2);
}
#admin-dashboard-wrapper .color-sphere.green {
  background: radial-gradient(circle at 35% 35%, var(--green-l) 0%, var(--green) 70%, var(--green-d) 100%);
}
#admin-dashboard-wrapper .color-sphere.mint {
  background: radial-gradient(circle at 35% 35%, #A7F3D0 0%, #34D399 70%, #059669 100%);
}
#admin-dashboard-wrapper .color-sphere.orange {
  background: radial-gradient(circle at 35% 35%, var(--mango-l) 0%, var(--mango) 70%, var(--mango-d) 100%);
}

/* Individual slider color accents */
#admin-dashboard-wrapper #input-smoothie-pct::-webkit-slider-thumb {
  border-color: #34D399;
  box-shadow: 0 4px 10px rgba(52,211,153,0.3);
}
#admin-dashboard-wrapper #input-coffee-pct::-webkit-slider-thumb {
  border-color: var(--mango);
  box-shadow: 0 4px 10px rgba(255,159,28,0.3);
}

/* Slider badge */
#admin-dashboard-wrapper .slider-val-badge {
  font-family: var(--font);
  font-weight: 700;
  background: var(--bg);
  border: 1px solid var(--border);
  padding: 2px 10px;
  border-radius: 8px;
  font-size: 0.8rem;
  color: var(--text);
  margin-left: 6px;
  display: inline-block;
}

/* Category adjust table styles */
#admin-dashboard-wrapper .adjust-cat-table th {
  border-bottom: 2px solid var(--border);
  padding: 8px 4px;
}
#admin-dashboard-wrapper .adjust-cat-table td {
  padding: 8px 4px;
}
#admin-dashboard-wrapper .cat-pct-input::-webkit-outer-spin-button,
#admin-dashboard-wrapper .cat-pct-input::-webkit-inner-spin-button {
  -webkit-appearance: none;
  margin: 0;
}
#admin-dashboard-wrapper .cat-pct-input {
  -moz-appearance: textfield;
}

@media(max-width:800px){
  #admin-dashboard-wrapper .glass-form-grid {
    grid-template-columns: 1fr;
    gap: 28px;
  }
}

/* Percent warning */
#admin-dashboard-wrapper .pct-warning-msg {
  margin-top: 16px;
  text-align: center;
  font-size: 0.85rem;
  font-weight: 700;
  padding: 10px;
  border-radius: 10px;
  background: rgba(0,0,0,0.02);
}

/* Global button submit style */
#admin-dashboard-wrapper .btn-submit-3d {
  width: 100%;
  font-family: var(--font);
  font-size: 1rem;
  font-weight: 700;
  color: #fff;
  background: linear-gradient(135deg, var(--green) 0%, var(--green-l) 100%);
  border: none;
  border-radius: 14px;
  padding: 14px;
  cursor: pointer;
  transition: all 0.3s var(--ease);
  box-shadow: var(--shadow-btn);
}
#admin-dashboard-wrapper .btn-submit-3d:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-btn-hover);
}
#admin-dashboard-wrapper .btn-submit-3d:active {
  transform: translateY(1px);
}

/* Toast Notification styling */
#admin-dashboard-wrapper .toast-container {
  position: fixed;
  top: 24px;
  right: 24px;
  z-index: 1000;
  display: flex;
  flex-direction: column;
  gap: 12px;
  pointer-events: none;
}
#admin-dashboard-wrapper .toast {
  background: #fff;
  border-left: 4px solid var(--green);
  box-shadow: 
    0 10px 25px rgba(0,0,0,0.08), 
    0 4px 12px rgba(0,0,0,0.05);
  padding: 16px 24px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 320px;
  transform: translateX(120%);
  transition: transform 0.4s cubic-bezier(0.16, 1, 0.3, 1);
  pointer-events: auto;
}
#admin-dashboard-wrapper .toast.show {
  transform: translateX(0);
}
#admin-dashboard-wrapper .toast-icon {
  font-size: 1.25rem;
}
#admin-dashboard-wrapper .toast-content h5 {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--text);
  margin: 0;
}
#admin-dashboard-wrapper .toast-content p {
  font-size: 0.78rem;
  color: var(--text-s);
  margin: 2px 0 0 0;
}

/* ============================================================
   TAB 3 (Nền tảng) — Status Cards
   ============================================================ */
#admin-dashboard-wrapper .platform-card {
  background: rgba(255, 255, 255, 0.45);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: var(--radius);
  padding: 40px;
  max-width: 600px;
  margin: 0 auto;
  box-shadow: var(--shadow-card);
}
#admin-dashboard-wrapper .platform-card h3 {
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--text);
  margin-bottom: 24px;
  text-align: center;
}
#admin-dashboard-wrapper .platform-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}
#admin-dashboard-wrapper .platform-item {
  display: flex;
  align-items: center;
  gap: 20px;
  padding: 20px 24px;
  background: #fff;
  border-radius: 16px;
  border: 1px solid var(--border);
  box-shadow: 0 4px 12px rgba(0,0,0,0.03);
  transition: all 0.3s var(--ease);
}
#admin-dashboard-wrapper .platform-item:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(42, 92, 56, 0.08);
}
#admin-dashboard-wrapper .platform-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, rgba(42,92,56,0.06), rgba(244,162,97,0.08));
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  box-shadow: inset 0 1px 2px rgba(255,255,255,0.8);
}
#admin-dashboard-wrapper .platform-info {
  flex-grow: 1;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
}
#admin-dashboard-wrapper .platform-info h4 {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--text);
  line-height: 1.2;
}
#admin-dashboard-wrapper .platform-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
#admin-dashboard-wrapper .platform-link {
  font-size: 0.8rem;
  color: var(--text-s);
  text-decoration: none;
  transition: color 0.2s;
  word-break: break-all;
}
#admin-dashboard-wrapper .platform-link:hover {
  color: var(--green);
}
#admin-dashboard-wrapper .status-connected {
  font-size: 0.8rem;
  font-weight: 700;
  color: #10B981;
  background: rgba(16, 185, 129, 0.1);
  padding: 6px 14px;
  border-radius: 50px;
  box-shadow: inset 0 1px 2px rgba(255,255,255,0.5);
}

/* ============================================================
   RESPONSIVE DESIGN
   ============================================================ */
@media(max-width:1200px){
  #admin-dashboard-wrapper .middle-row{grid-template-columns:1fr}
  #admin-dashboard-wrapper .kpi-grid{grid-template-columns:repeat(2,1fr)}
}
@media(max-width:900px){
  #admin-dashboard-wrapper .sidebar{
    transform:translateX(-100%);
    transition:transform .4s var(--ease);
  }
  #admin-dashboard-wrapper .sidebar.open{
    transform:translateX(0);
  }
  #admin-dashboard-wrapper .main{
    margin-left:0;
    padding:20px 16px 60px;
  }
  #admin-dashboard-wrapper .glass-header{
    flex-wrap:wrap;
    gap:12px;
  }
  #admin-dashboard-wrapper .search-pill{
    width:100%;
    order:3;
  }
  #admin-dashboard-wrapper .kpi-grid{
    grid-template-columns:1fr 1fr;
  }
  #admin-dashboard-wrapper .bar-chart{
    height:160px;
  }
}
@media(max-width:600px){
  #admin-dashboard-wrapper .kpi-grid{
    grid-template-columns:1fr;
  }
  #admin-dashboard-wrapper .data-table{
    font-size:.8rem;
  }
  #admin-dashboard-wrapper .data-table thead th,
  #admin-dashboard-wrapper .data-table tbody td{
    padding:10px 10px;
  }
}

/* ============================================================
   SCROLLBAR & RESET ACTIONS
   ============================================================ */
#admin-dashboard-wrapper ::-webkit-scrollbar{width:6px}
#admin-dashboard-wrapper ::-webkit-scrollbar-track{background:transparent}
#admin-dashboard-wrapper ::-webkit-scrollbar-thumb{background:var(--border);border-radius:50px}
#admin-dashboard-wrapper ::-webkit-scrollbar-thumb:hover{background:var(--text-m)}

/* ============================================================
   ANIMATIONS
   ============================================================ */
@keyframes fadeInUp{
  from{opacity:0;transform:translateY(24px)}
  to{opacity:1;transform:translateY(0)}
}
#admin-dashboard-wrapper .animate-in{animation:fadeInUp .6s var(--ease) both}
#admin-dashboard-wrapper .delay-1{animation-delay:.1s}
#admin-dashboard-wrapper .delay-2{animation-delay:.2s}
#admin-dashboard-wrapper .delay-3{animation-delay:.3s}
#admin-dashboard-wrapper .delay-4{animation-delay:.4s}
#admin-dashboard-wrapper .delay-5{animation-delay:.5s}
#admin-dashboard-wrapper .delay-6{animation-delay:.6s}
#admin-dashboard-wrapper .delay-7{animation-delay:.7s}
</style>
</head>

<body>
<div id="admin-dashboard-wrapper">
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
        <a class="nav-item active" href="#" data-tab="tab-dashboard">
          <span class="nav-icon">📊</span> Dashboard
        </a>
        <a class="nav-item" href="#" data-tab="tab-adjust">
          <span class="nav-icon">⚙️</span> Tinh chỉnh
        </a>
        <a class="nav-item" href="#" data-tab="tab-platform">
          <span class="nav-icon">🌐</span> Nền tảng
        </a>
      </div>

      <div class="nav-logout">
        <a class="nav-item logout" href="${pageContext.request.contextPath}/">
          <span class="nav-icon">🚪</span> Về Trang Chủ
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
          <p>Chào buổi sáng, Oanh! Hôm nay có 12 đơn hàng mới cần xử lý.</p>
        </div>
        <div class="search-pill">
          <span class="search-icon">🔍</span>
          <input type="text" placeholder="Tìm đơn hàng, khách hàng...">
        </div>
        <div class="avatar-liquid">
          <img src="https://randomuser.me/api/portraits/women/12.jpg" alt="Admin">
        </div>
      </header>

      <!-- ================================================================
           TAB 1: DASHBOARD CONTENT
           ================================================================ -->
      <div id="tab-dashboard" class="tab-content active">
        <!-- KPI Cards -->
        <div class="kpi-grid">
          <div class="kpi-card animate-in delay-1">
            <div class="kpi-icon green">💰</div>
            <div class="kpi-label">Doanh thu</div>
            <div class="kpi-value" id="kpi-val-revenue">2.4M</div>
            <div class="kpi-sub"><span class="kpi-up">↑ 12.5%</span> so với tuần trước</div>
          </div>
          <div class="kpi-card animate-in delay-2">
            <div class="kpi-icon orange">🛒</div>
            <div class="kpi-label">Đơn mới</div>
            <div class="kpi-value" id="kpi-val-orders">45</div>
            <div class="kpi-sub"><span class="kpi-up">↑ 8.3%</span> so với tuần trước</div>
          </div>
          <div class="kpi-card animate-in delay-3">
            <div class="kpi-icon purple">⏳</div>
            <div class="kpi-label">Đang xử lý</div>
            <div class="kpi-value" id="kpi-val-processing">12</div>
            <div class="kpi-sub"><span class="kpi-down">↓ 3.1%</span> so với tuần trước</div>
          </div>
          <div class="kpi-card animate-in delay-4">
            <div class="kpi-icon teal">✅</div>
            <div class="kpi-label">Tỷ lệ thành công</div>
            <div class="kpi-value" id="kpi-val-rate">98%</div>
            <div class="liquid-progress">
              <div class="liquid-progress-fill" id="progress-val-rate" style="width: 98%;"></div>
            </div>
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
                  <span class="donut-value" id="donut-val-total">2.4M</span>
                  <span class="donut-label">Tổng</span>
                </div>
              </div>
            </div>
            <div class="donut-legend">
              <div class="legend-item" id="legend-item-juice" data-tooltip="Doanh thu: 1.44M">
                <span class="legend-dot green"></span>
                <span class="legend-name">Nước Ép Tươi</span>
                <span class="legend-pct">60%</span>
              </div>
              <div class="legend-item" id="legend-item-smoothie" data-tooltip="Doanh thu: 0.60M">
                <span class="legend-dot mint"></span>
                <span class="legend-name">Sinh Tố</span>
                <span class="legend-pct">25%</span>
              </div>
              <div class="legend-item" id="legend-item-coffee" data-tooltip="Doanh thu: 0.36M">
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
      </div>

      <!-- ================================================================
           TAB 2: TINH CHỈNH (GLASSMORPHISM FORM)
           ================================================================ -->
      <!-- ================================================================
           TAB 2: TINH CHỈNH (GLASSMORPHISM FORM)
           ================================================================ -->
      <div id="tab-adjust" class="tab-content">
        <div class="glass-form-card animate-in">
          <h3>🔧 Tinh Chỉnh Số Liệu Hệ Thống</h3>
          <p class="form-subtitle">Nhập số liệu mới dưới đây để cập nhật ngay lập tức lên Dashboard.</p>
          
          <form id="adjust-form" novalidate>
            <div class="glass-form-grid">
              
              <!-- Section 1: KPI Tổng Quan -->
              <div class="glass-form-section">
                <h4 class="section-title">📊 KPI Tổng Quan</h4>
                <div class="form-group">
                  <label for="input-revenue">Doanh thu (Ví dụ: 2.4M, 3.5M)</label>
                  <div class="input-group-3d">
                    <span class="input-icon">💰</span>
                    <input type="text" id="input-revenue" placeholder="2.4M" value="2.4M" required>
                  </div>
                </div>
                <div class="form-group">
                  <label for="input-orders">Số đơn đặt mới</label>
                  <div class="input-group-3d">
                    <span class="input-icon">🛒</span>
                    <input type="number" id="input-orders" placeholder="45" value="45" required>
                  </div>
                </div>
                <div class="form-group">
                  <label for="input-processing">Số đơn đang xử lý</label>
                  <div class="input-group-3d">
                    <span class="input-icon">⏳</span>
                    <input type="number" id="input-processing" placeholder="12" value="12" required>
                  </div>
                </div>
                <div class="form-group">
                  <label for="input-rate">Tỷ lệ đơn hàng thành công: <span id="val-rate-display" class="slider-val-badge">98%</span></label>
                  <div class="slider-group-3d">
                    <span class="input-icon">✅</span>
                    <input type="range" id="input-rate" min="0" max="100" value="98" required>
                  </div>
                </div>
              </div>

              <!-- Section 2: Cơ Cấu Biểu Đồ -->
              <div class="glass-form-section">
                <h4 class="section-title">🎨 Cơ Cấu Biểu Đồ</h4>
                
                <!-- Table for dynamic categories CRUD -->
                <div style="overflow-x:auto; margin-bottom:16px;">
                  <table class="adjust-cat-table" style="width:100%; border-collapse:collapse; font-size:0.85rem;">
                    <thead>
                      <tr style="border-bottom:1.5px solid var(--border); text-align:left; color:var(--text-s);">
                        <th style="padding:8px 4px; font-weight:600; width:10%;">Màu</th>
                        <th style="padding:8px 4px; font-weight:600; width:55%;">Tên loại nước uống</th>
                        <th style="padding:8px 4px; font-weight:600; width:25%;">Tỷ lệ (%)</th>
                        <th style="padding:8px 4px; font-weight:600; width:10%; text-align:center;">Xóa</th>
                      </tr>
                    </thead>
                    <tbody id="dynamic-sliders-container">
                      <!-- Dynamic rows injected here -->
                    </tbody>
                  </table>
                </div>
                
                <!-- Add beverage category control -->
                <div class="add-cat-group" style="display:flex; gap:12px; margin-top:20px; align-items:center;">
                  <div class="input-group-3d" style="flex:1; padding: 2px 12px; height: 42px;">
                    <input type="text" id="new-cat-name" placeholder="Thêm loại nước uống..." style="padding: 8px 0; font-size:0.85rem; height: 100%;" />
                  </div>
                  <div style="display:flex; align-items:center; gap:8px;">
                    <label for="new-cat-color" style="font-size:0.75rem; font-weight:700; color:var(--text-s); white-space:nowrap; margin-bottom:0;">Màu:</label>
                    <input type="color" id="new-cat-color" value="#3B82F6" style="width:36px; height:36px; border:none; border-radius:8px; cursor:pointer; background:transparent;" />
                  </div>
                  <button type="button" id="btn-add-category" class="btn-submit-3d" style="margin-top:0; padding:10px 18px; font-size:0.85rem; width:auto; flex-shrink:0; border-radius:12px; height: 42px;">➕ Thêm</button>
                </div>

                <div id="pct-warning" class="pct-warning-msg" style="margin-top: 24px;">
                  <span style="color:#10B981;">✓ Tổng tỷ lệ: 100% (Hợp lệ)</span>
                </div>
              </div>

            </div>
            
            <button type="submit" id="btn-save-adjustments" class="btn-submit-3d" style="margin-top: 32px;">🚀 Lưu & Cập Nhật Hệ Thống</button>
          </form>
        </div>
      </div>

      <!-- ================================================================
           TAB 3: NỀN TẢNG (PLATFORM CONNECTIVITY)
           ================================================================ -->
      <div id="tab-platform" class="tab-content">
        <div class="platform-card animate-in">
          <h3>🌐 Đồng Bộ Kênh Mạng Xã Hội</h3>
          <div class="platform-list">
            <!-- Facebook -->
            <div class="platform-item">
              <div class="platform-icon"><i class="fa-brands fa-facebook-f" style="color: #1877F2;"></i></div>
              <div class="platform-info">
                <div class="platform-text">
                  <h4>Facebook</h4>
                  <a href="https://www.facebook.com/share/1EMX9PdG2D/" target="_blank" class="platform-link">facebook.com/share/1EMX9PdG2D/</a>
                </div>
                <span class="status-connected">● Đã kết nối</span>
              </div>
            </div>
            <!-- Instagram -->
            <div class="platform-item">
              <div class="platform-icon"><i class="fa-brands fa-instagram" style="color: #E1306C;"></i></div>
              <div class="platform-info">
                <div class="platform-text">
                  <h4>Instagram</h4>
                  <a href="https://www.instagram.com/nhietdoixanh_05?igsh=dTR0dmgzcWg3aWV3" target="_blank" class="platform-link">@nhietdoixanh_05</a>
                </div>
                <span class="status-connected">● Đã kết nối</span>
              </div>
            </div>
            <!-- TikTok -->
            <div class="platform-item">
              <div class="platform-icon"><i class="fa-brands fa-tiktok" style="color: #000000;"></i></div>
              <div class="platform-info">
                <div class="platform-text">
                  <h4>TikTok</h4>
                  <a href="https://tiktok.com/@nuocepnhietdoixanh_05" target="_blank" class="platform-link">@nuocepnhietdoixanh_05</a>
                </div>
                <span class="status-connected">● Đã kết nối</span>
              </div>
            </div>
          </div>
        </div>
      </div>

    </main>
  </div>
</div>

<!-- ================================================================
     JAVASCRIPT LOGIC
     ================================================================ -->
<script>
(function(){
  // ── Navigation Tab Switching ──
  const navItems = document.querySelectorAll('#admin-dashboard-wrapper .nav-item:not(.logout)');
  const tabContents = document.querySelectorAll('#admin-dashboard-wrapper .tab-content');

  navItems.forEach(item => {
    item.addEventListener('click', function(e) {
      e.preventDefault();
      
      // Toggle sidebar active item
      navItems.forEach(nav => nav.classList.remove('active'));
      this.classList.add('active');
      
      // Toggle active tab content
      const targetTabId = this.getAttribute('data-tab');
      tabContents.forEach(tab => {
        if (tab.id === targetTabId) {
          tab.classList.add('active');
        } else {
          tab.classList.remove('active');
        }
      });
    });
  });

  // ── Slider Filling Effect & Value Display (For general rate slider) ──
  const rateSlider = document.getElementById('input-rate');
  if (rateSlider) {
    updateSliderFillDirect(rateSlider, 'var(--green)');
    rateSlider.addEventListener('input', function() {
      updateSliderFillDirect(this, 'var(--green)');
      const badge = document.getElementById('val-rate-display');
      if (badge) badge.textContent = this.value + '%';
    });
  }

  function updateSliderFillDirect(slider, color) {
    const min = slider.min || 0;
    const max = slider.max || 100;
    const val = slider.value;
    const pct = ((val - min) / (max - min)) * 100;
    slider.style.background = 'linear-gradient(to right, ' + color + ' 0%, ' + color + ' ' + pct + '%, #E8ECE6 ' + pct + '%, #E8ECE6 100%)';
  }

  // ── Global state for dynamic chart categories (CRUD) ──
  let chartCategories = [
    { id: 'juice', name: 'Nước Ép Tươi', pct: 60, color: '#2A5C38' },
    { id: 'smoothie', name: 'Sinh Tố', pct: 25, color: '#34D399' },
    { id: 'coffee', name: 'Cà Phê', pct: 15, color: '#FF9F1C' }
  ];

  // ── Render Dynamic Categories Table in Tinh chỉnh ──
  function renderAdjustmentSliders() {
    const container = document.getElementById('dynamic-sliders-container');
    if (!container) return;
    
    container.innerHTML = '';
    chartCategories.forEach((cat, idx) => {
      const row = document.createElement('tr');
      row.className = 'dynamic-cat-row';
      row.setAttribute('data-id', cat.id);
      row.style.borderBottom = '1px solid var(--border)';
      
      row.innerHTML = 
        '<td style="padding:8px 4px; vertical-align:middle;">' +
          '<input type="color" class="cat-color-picker" value="' + cat.color + '" style="width:28px; height:28px; border:none; border-radius:6px; cursor:pointer; background:transparent;" />' +
        '</td>' +
        '<td style="padding:8px 4px; vertical-align:middle;">' +
          '<div class="input-group-3d" style="padding:2px 10px; border-radius:8px;">' +
            '<input type="text" class="cat-name-input" value="' + cat.name + '" style="padding:6px 0; font-size:0.85rem; font-family:var(--font);" required />' +
          '</div>' +
        '</td>' +
        '<td style="padding:8px 4px; vertical-align:middle;">' +
          '<div class="input-group-3d" style="padding:2px 10px; border-radius:8px; width:75px;">' +
            '<input type="number" class="cat-pct-input" value="' + cat.pct + '" min="0" max="100" style="padding:6px 0; font-size:0.85rem; text-align:center; font-family:var(--font);" required />' +
          '</div>' +
        '</td>' +
        '<td style="padding:8px 4px; text-align:center; vertical-align:middle;">' +
          '<button type="button" class="btn-delete-cat" style="background:transparent; border:none; color:var(--red); cursor:pointer; font-size:1.15rem; padding:4px;" title="Xóa">🗑️</button>' +
        '</td>';
      
      container.appendChild(row);
    });
    
    // Attach change name events
    const nameInputs = container.querySelectorAll('.cat-name-input');
    nameInputs.forEach((input, idx) => {
      input.addEventListener('input', function() {
        chartCategories[idx].name = this.value.trim() || 'Không tên';
      });
    });
    
    // Attach change color events
    const colorPickers = container.querySelectorAll('.cat-color-picker');
    colorPickers.forEach((picker, idx) => {
      picker.addEventListener('input', function() {
        chartCategories[idx].color = this.value;
      });
    });
    
    // Attach input percent events (manual direct adjust)
    const pctInputs = container.querySelectorAll('.cat-pct-input');
    pctInputs.forEach((input, idx) => {
      input.addEventListener('input', function() {
        let val = parseInt(this.value);
        if (isNaN(val) || val < 0) val = 0;
        if (val > 100) val = 100;
        chartCategories[idx].pct = val;
        checkTotalPct();
      });
    });
    
    // Attach delete events
    const deleteBtns = container.querySelectorAll('.btn-delete-cat');
    deleteBtns.forEach((btn, idx) => {
      btn.addEventListener('click', function() {
        if (chartCategories.length <= 1) {
          showToast("Lỗi", "Phải giữ lại ít nhất 1 danh mục!", "⚠️");
          return;
        }
        const removedName = chartCategories[idx].name;
        chartCategories.splice(idx, 1);
        renderAdjustmentSliders();
        checkTotalPct();
        showToast("Đã xóa", "Đã xóa danh mục: " + removedName, "🗑️");
      });
    });
  }

  // ── Add Beverage Category Handler ──
  const addCategoryBtn = document.getElementById('btn-add-category');
  if (addCategoryBtn) {
    addCategoryBtn.addEventListener('click', function() {
      const nameInput = document.getElementById('new-cat-name');
      const colorInput = document.getElementById('new-cat-color');
      const name = nameInput.value.trim();
      if (!name) {
        showToast("Cảnh báo", "Vui lòng nhập tên loại nước uống!", "⚠️");
        return;
      }
      
      const dup = chartCategories.some(c => c.name.toLowerCase() === name.toLowerCase());
      if (dup) {
        showToast("Cảnh báo", "Tên loại nước này đã tồn tại!", "⚠️");
        return;
      }
      
      const color = colorInput.value || '#3B82F6';
      const newId = 'cat-' + Date.now();
      
      chartCategories.push({
        id: newId,
        name: name,
        pct: 0,
        color: color
      });
      
      nameInput.value = '';
      renderAdjustmentSliders();
      checkTotalPct();
      showToast("Thành công", "Đã thêm loại: " + name, "➕");
    });
  }

  // ── Check total percentage sum ──
  function checkTotalPct() {
    let total = 0;
    chartCategories.forEach(c => total += c.pct);
    
    const warning = document.getElementById('pct-warning');
    const submitBtn = document.getElementById('btn-save-adjustments');
    
    if (total === 100) {
      warning.innerHTML = '<span style="color:#10B981;">✓ Tổng tỷ lệ: 100% (Hợp lệ)</span>';
      if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.style.opacity = '1';
        submitBtn.style.cursor = 'pointer';
      }
    } else {
      warning.innerHTML = '<span style="color:var(--red);">✗ Tổng tỷ lệ phải bằng 100% (Hiện tại: ' + total + '%)</span>';
      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.style.opacity = '0.5';
        submitBtn.style.cursor = 'not-allowed';
      }
    }
  }

  // Run on start
  renderAdjustmentSliders();
  checkTotalPct();

  // ── Form Submit & Realtime State Management ──
  const adjustForm = document.getElementById('adjust-form');
  if (adjustForm) {
    adjustForm.addEventListener('submit', function(e) {
      e.preventDefault();
      
      const valRevenue = document.getElementById('input-revenue').value.trim();
      const valOrders = document.getElementById('input-orders').value.trim();
      const valProcessing = document.getElementById('input-processing').value.trim();
      const valRate = document.getElementById('input-rate').value;
      
      if (!valRevenue || !valOrders || !valProcessing || !valRate) {
        showToast("Lỗi nhập liệu", "Vui lòng điền đầy đủ các thông tin!", "❌");
        return;
      }
      
      // Calculate dynamic sum
      let sumPct = 0;
      chartCategories.forEach(c => sumPct += c.pct);
      if (sumPct !== 100) {
        showToast("Lỗi tỷ lệ", "Tổng tỷ lệ của biểu đồ phải bằng 100%!", "❌");
        return;
      }
      
      // Update DOM values in Tab 1 (Dashboard) - KPI cards
      const domRevenue = document.getElementById('kpi-val-revenue');
      const domOrders = document.getElementById('kpi-val-orders');
      const domProcessing = document.getElementById('kpi-val-processing');
      const domRate = document.getElementById('kpi-val-rate');
      const domProgressFill = document.getElementById('progress-val-rate');
      
      if (domRevenue) domRevenue.textContent = valRevenue;
      if (domOrders) domOrders.textContent = valOrders;
      if (domProcessing) domProcessing.textContent = valProcessing;
      if (domRate) domRate.textContent = valRate + '%';
      if (domProgressFill) domProgressFill.style.width = valRate + '%';
      
      // Update Donut Chart and Dynamic Legend Tooltips
      updateDonutChartAndLegend(valRevenue);
      
      // Switch view back to Tab 1 (Dashboard)
      const dashboardNavBtn = document.querySelector('#admin-dashboard-wrapper .nav-item[data-tab="tab-dashboard"]');
      if (dashboardNavBtn) {
        dashboardNavBtn.click();
      }
      
      // Trigger Toast Notification
      showToast("Thành công", "Đã cập nhật dữ liệu thành công!", "🚀");
    });
  }

  // ── Update Donut Chart & Legend dynamically from array ──
  function updateDonutChartAndLegend(valRevenue) {
    const donutChart = document.querySelector('#admin-dashboard-wrapper .donut-chart');
    if (!donutChart) return;
    
    // Remove existing SVG if any
    let svg = donutChart.querySelector('svg');
    if (svg) svg.remove();
    
    // Create new SVG
    svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('viewBox', '0 0 100 100');
    svg.style.width = '100%';
    svg.style.height = '100%';
    svg.style.transform = 'rotate(-90deg)';
    svg.style.position = 'absolute';
    svg.style.top = '0';
    svg.style.left = '0';
    svg.style.overflow = 'visible';
    
    const r = 38;
    const cx = 50;
    const cy = 50;
    const circumference = 2 * Math.PI * r;
    
    let currentOffset = 0;
    const numRevenue = parseFloat(valRevenue.replace(/[^0-9.]/g, '')) || 0;
    const suffix = valRevenue.replace(/[0-9. ]/g, '') || '';
    
    chartCategories.forEach(cat => {
      if (cat.pct <= 0) return;
      
      const strokeLength = circumference * (cat.pct / 100);
      const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
      circle.setAttribute('cx', cx);
      circle.setAttribute('cy', cy);
      circle.setAttribute('r', r);
      circle.setAttribute('fill', 'none');
      circle.setAttribute('stroke', cat.color);
      circle.setAttribute('stroke-width', '16');
      circle.setAttribute('stroke-dasharray', strokeLength + ' ' + (circumference - strokeLength));
      circle.setAttribute('stroke-dashoffset', -currentOffset);
      circle.style.transition = 'all 0.3s ease';
      circle.style.cursor = 'pointer';
      
      // Hover segment interaction
      circle.addEventListener('mouseenter', function() {
        this.setAttribute('stroke-width', '20');
        const amt = (numRevenue * cat.pct / 100).toFixed(2);
        const donutValue = document.getElementById('donut-val-total');
        const donutLabel = document.querySelector('#admin-dashboard-wrapper .donut-label');
        if (donutValue) {
          donutValue.textContent = amt + ' ' + suffix;
          donutValue.style.color = cat.color;
        }
        if (donutLabel) {
          donutLabel.textContent = cat.name;
          donutLabel.style.color = cat.color;
        }
      });
      
      circle.addEventListener('mouseleave', function() {
        this.setAttribute('stroke-width', '16');
        const donutValue = document.getElementById('donut-val-total');
        const donutLabel = document.querySelector('#admin-dashboard-wrapper .donut-label');
        if (donutValue) {
          donutValue.textContent = valRevenue;
          donutValue.style.color = 'var(--text)';
        }
        if (donutLabel) {
          donutLabel.textContent = 'Tổng';
          donutLabel.style.color = 'var(--text-m)';
        }
      });
      
      svg.appendChild(circle);
      currentOffset += strokeLength;
    });
    
    const hole = donutChart.querySelector('.donut-hole');
    if (hole) {
      donutChart.insertBefore(svg, hole);
    } else {
      donutChart.appendChild(svg);
    }
    
    // Re-render legend container
    const legendContainer = document.querySelector('#admin-dashboard-wrapper .donut-legend');
    if (legendContainer) {
      legendContainer.innerHTML = '';
      
      chartCategories.forEach(cat => {
        const amt = (numRevenue * cat.pct / 100).toFixed(2);
        
        const item = document.createElement('div');
        item.className = 'legend-item';
        item.id = 'legend-item-' + cat.id;
        item.setAttribute('data-tooltip', 'Doanh thu: ' + amt + ' ' + suffix);
        
        item.innerHTML = 
          '<span class="legend-dot" style="background:' + cat.color + ';"></span>' +
          '<span class="legend-name">' + cat.name + '</span>' +
          '<span class="legend-pct">' + cat.pct + '%</span>';
          
        legendContainer.appendChild(item);
      });
    }
  }

  // ── Toast Notification Helper ──
  function showToast(title, message, icon) {
    const container = document.getElementById('toast-container');
    if (!container) return;
    
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = 
      '<span class="toast-icon">' + (icon || '📢') + '</span>' +
      '<div class="toast-content">' +
        '<h5>' + title + '</h5>' +
        '<p>' + message + '</p>' +
      '</div>';
    
    container.appendChild(toast);
    
    // Trigger animation
    setTimeout(function() {
      toast.classList.add('show');
    }, 50);
    
    // Auto destroy after 3s
    setTimeout(function() {
      toast.classList.remove('show');
      setTimeout(function() {
        toast.remove();
      }, 400);
    }, 3000);
  }

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
  if (chart) {
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
  }

  // ── Animate bars on load ──
  setTimeout(function(){
    document.querySelectorAll('#admin-dashboard-wrapper .bar').forEach(function(bar){
      var h = bar.style.height;
      bar.style.height = '0%';
      bar.style.transition = 'height 1s cubic-bezier(.16,1,.3,1)';
      setTimeout(function(){ bar.style.height = h; }, 100);
    });
  }, 400);

  // ── Chart period toggle ──
  document.querySelectorAll('#admin-dashboard-wrapper .chart-period button').forEach(function(btn){
    btn.addEventListener('click', function(){
      document.querySelectorAll('#admin-dashboard-wrapper .chart-period button').forEach(function(b){ b.classList.remove('active'); });
      this.classList.add('active');
    });
  });

  // ── Mobile sidebar toggle ──
  var sidebar = document.getElementById('sidebar');
  document.addEventListener('click', function(e){
    if(window.innerWidth <= 900 && sidebar){
      if(!sidebar.contains(e.target)){
        sidebar.classList.remove('open');
      }
    }
  });

  // ── Initial Donut Tooltip Setup ──
  function initDonutTooltips() {
    updateDonutChartAndLegend('2.4M');
  }
  
  initDonutTooltips();
})();
</script>
  <!-- Toast Container -->
  <div class="toast-container" id="toast-container"></div>
</body>
</html>
