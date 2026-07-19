<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="uri" value="${requestScope['jakarta.servlet.forward.servlet_path']}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="ctx" content="${pageContext.request.contextPath}">
    <title>Nhiệt Đới Xanh · Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;700;800&family=Be+Vietnam+Pro:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root{
            --admin-bg:#F5F7F3;--admin-surface:#FFFFFF;
            --admin-sidebar:#1E3F27;--admin-sidebar-2:#2A5C38;
            --admin-primary:#2A5C38;--admin-primary-hover:#1E3F27;
            --admin-gold:#F4A261;--admin-red:#D9534F;
            --admin-text:#1A2E1A;--admin-text-light:#8A9A8A;
            --admin-border:#E8E0D0;
            --status-pending:#F4A261;--status-confirmed:#3965FF;--status-shipping:#7A5AF8;
            --status-done:#2A5C38;--status-cancelled:#D9534F;
            --fd:'Baloo 2',sans-serif;--fb:'Be Vietnam Pro',sans-serif;
        }
        *{margin:0;padding:0;box-sizing:border-box;font-family:var(--fb)}
        body{background:var(--admin-bg);color:var(--admin-text);display:flex;min-height:100vh;-webkit-font-smoothing:antialiased}
        a{text-decoration:none}
        ::-webkit-scrollbar{width:8px;height:8px}::-webkit-scrollbar-thumb{background:#d3ddd0;border-radius:8px}

        .sidebar{width:264px;background:linear-gradient(180deg,var(--admin-sidebar) 0%,var(--admin-sidebar-2) 100%);color:#fff;display:flex;flex-direction:column;position:fixed;height:100vh;left:0;top:0;z-index:100;box-shadow:6px 0 24px -12px rgba(30,63,39,.4)}
        .sidebar-brand{padding:26px 26px 22px;font-family:var(--fd);font-size:20px;font-weight:700;display:flex;align-items:center;gap:12px;border-bottom:1px solid rgba(255,255,255,.1)}
        .sidebar-brand .logo-dot{width:38px;height:38px;border-radius:50%;background:var(--admin-gold);display:flex;align-items:center;justify-content:center;flex:none;box-shadow:0 8px 18px -6px rgba(244,162,97,.6)}
        .sidebar-brand span{color:#fff}.sidebar-brand b{color:var(--admin-gold)}
        .side-scroll{flex:1;overflow-y:auto;padding:16px 0}
        .menu-label{padding:14px 26px 8px;font-size:11px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.4)}
        .sidebar-menu{list-style:none}
        .sidebar-menu li{padding:0 14px;margin-bottom:3px}
        .sidebar-menu a{display:flex;align-items:center;justify-content:space-between;padding:12px 16px;color:rgba(255,255,255,.72);font-weight:600;font-size:14.5px;gap:13px;border-radius:12px;transition:background .2s,color .2s}
        .sidebar-menu a .lbl{display:flex;align-items:center;gap:13px}
        .sidebar-menu a i{width:20px;text-align:center;font-size:16px}
        .sidebar-menu a:hover{background:rgba(255,255,255,.08);color:#fff}
        .sidebar-menu a.active{background:#fff;color:var(--admin-primary);box-shadow:0 10px 22px -10px rgba(0,0,0,.4)}
        .sidebar-menu a.active i{color:var(--admin-primary)}
        .sidebar-menu a.soon{cursor:default;opacity:.55}
        .sidebar-menu a.soon:hover{background:none;color:rgba(255,255,255,.72)}
        .soon-tag{font-size:9.5px;font-weight:800;text-transform:uppercase;letter-spacing:.04em;background:rgba(244,162,97,.2);color:var(--admin-gold);padding:3px 8px;border-radius:20px}
        .side-foot{padding:16px 20px;border-top:1px solid rgba(255,255,255,.1)}
        .side-foot a{display:flex;align-items:center;gap:12px;padding:11px 14px;border-radius:12px;font-weight:600;font-size:14px;transition:background .2s}
        .side-foot a.store{color:var(--admin-gold)}.side-foot a.store:hover{background:rgba(244,162,97,.14)}
        .side-foot a.logout{color:#FF9B93}.side-foot a.logout:hover{background:rgba(217,83,79,.16)}

        .main-content{flex:1;margin-left:264px;padding:26px 30px 40px;display:flex;flex-direction:column;width:calc(100% - 264px);min-width:0}
        .admin-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:26px;background:var(--admin-surface);padding:16px 26px;border-radius:18px;box-shadow:0 8px 22px -14px rgba(30,63,39,.18)}
        .admin-header-title{font-family:var(--fd);font-size:21px;font-weight:700}
        .admin-header-title small{display:block;font-family:var(--fb);font-size:12.5px;font-weight:500;color:var(--admin-text-light);margin-top:2px}
        .admin-header-right{display:flex;align-items:center;gap:16px}
        .hdr-ic{width:44px;height:44px;border-radius:12px;background:var(--admin-bg);display:flex;align-items:center;justify-content:center;color:var(--admin-primary);font-size:17px;position:relative;transition:background .2s;cursor:pointer;border:none}
        .hdr-ic:hover{background:#EAF0E7}
        .admin-user{display:flex;align-items:center;gap:12px;padding:6px 8px 6px 14px;background:var(--admin-bg);border-radius:14px}
        .admin-user .u-name{font-weight:700;font-size:14px;line-height:1.2}
        .admin-user .u-role{font-size:12px;color:var(--admin-text-light);font-weight:600;text-transform:capitalize}
        .admin-user img{width:40px;height:40px;border-radius:11px;object-fit:cover}

        .card{background:var(--admin-surface);border-radius:18px;padding:24px;box-shadow:0 8px 22px -16px rgba(30,63,39,.2);margin-bottom:24px}
        .btn{padding:11px 20px;border-radius:11px;font-weight:700;font-size:14px;cursor:pointer;border:none;transition:.2s;text-decoration:none;display:inline-flex;align-items:center;gap:8px}
        .btn-primary{background:var(--admin-primary);color:#fff;box-shadow:0 10px 22px -12px rgba(42,92,56,.7)}.btn-primary:hover{background:var(--admin-primary-hover);transform:translateY(-1px)}
        .btn-danger{background:var(--admin-red);color:#fff}
        .btn-outline{background:transparent;border:1.5px solid var(--admin-primary);color:var(--admin-primary)}.btn-outline:hover{background:var(--admin-primary);color:#fff}
        .table-responsive{overflow-x:auto}
        .admin-table{width:100%;border-collapse:collapse}
        .admin-table th,.admin-table td{padding:15px 16px;text-align:left;border-bottom:1px solid var(--admin-border)}
        .admin-table th{color:var(--admin-text-light);font-weight:600;font-size:12.5px;text-transform:uppercase;letter-spacing:.04em}
        .admin-table td{font-weight:500;font-size:14.5px}
        .admin-table tbody tr{transition:background .15s}.admin-table tbody tr:hover{background:#FaFbF8}

        /* -------- Tab điều hướng (underline style) — dùng chung cho đơn hàng, nhân viên... -------- */
        .admin-tabs{display:flex;flex-wrap:wrap;gap:2px;border-bottom:2px solid var(--admin-border);margin-bottom:20px}
        .admin-tab{
            position:relative;display:inline-flex;align-items:center;gap:9px;padding:13px 16px;
            font-family:var(--fb);font-size:14.5px;font-weight:700;color:#5B6B63;
            text-decoration:none;border-radius:10px 10px 0 0;
            transition:color .18s ease,background .18s ease;
        }
        .admin-tab::after{
            content:"";position:absolute;left:10px;right:10px;bottom:-2px;height:3.5px;border-radius:4px 4px 0 0;
            background:transparent;transition:background .18s ease,transform .18s ease;transform:scaleX(.6);
        }
        .admin-tab:hover{color:var(--admin-text);background:var(--admin-bg)}
        .admin-tab.active{color:var(--admin-primary);font-weight:800;background:rgba(42,92,56,.08)}
        .admin-tab.active::after{background:#10B981;transform:scaleX(1)}
        .admin-tab-count{
            min-width:22px;padding:2px 8px;border-radius:20px;background:var(--admin-bg);
            color:var(--admin-text-light);font-size:12.5px;font-weight:800;text-align:center;
            transition:background .18s ease,color .18s ease;
        }
        .admin-tab.active .admin-tab-count{background:var(--admin-primary);color:#fff}

        .badge{padding:6px 13px;border-radius:30px;font-size:12px;font-weight:800;text-transform:uppercase;letter-spacing:.03em;display:inline-block}
        .badge-PENDING{background:rgba(244,162,97,.15);color:#B96A2E}
        .badge-CONFIRMED{background:rgba(57,101,255,.12);color:var(--status-confirmed)}
        .badge-SHIPPING{background:rgba(122,90,248,.12);color:var(--status-shipping)}
        .badge-DONE{background:rgba(42,92,56,.12);color:var(--status-done)}
        .badge-AWAITING_CONFIRM{background:rgba(15,148,140,.12);color:#0F8F87}
        .badge-CANCELLED{background:rgba(217,83,79,.12);color:var(--status-cancelled)}
        .badge-PENDING_CANCEL{background:rgba(217,83,79,.1);color:#B9432E}
        .badge-NEW{background:rgba(244,162,97,.15);color:#B96A2E}
        .badge-UNPAID{background:rgba(138,154,138,.15);color:var(--admin-text-light)}
        .badge-PAID{background:rgba(42,92,56,.12);color:var(--status-done)}
        .badge-FAILED{background:rgba(217,83,79,.12);color:var(--status-cancelled)}
        .badge-REFUND_PENDING{background:rgba(244,162,97,.15);color:#B96A2E}
        .form-group{margin-bottom:20px}
        .form-group label{display:block;margin-bottom:8px;font-weight:700;font-size:13.5px}
        .form-control{width:100%;padding:12px 16px;border:1.5px solid var(--admin-border);border-radius:11px;font-size:15px;color:var(--admin-text);transition:.2s}
        .form-control:focus{border-color:var(--admin-primary);outline:none;box-shadow:0 0 0 4px rgba(42,92,56,.1)}

        @media(max-width:900px){
            .sidebar{transform:translateX(-100%);transition:transform .3s}
            .sidebar.open{transform:none}
            .main-content{margin-left:0;width:100%}
        }
    </style>
</head>
<body>
    <aside class="sidebar" id="adminSidebar">
        <div class="sidebar-brand">
            <span class="logo-dot">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="var(--admin-sidebar)"><path d="M17 8C8 10 5.9 16.17 3.82 21.34l1.89.66.95-2.3c.48.17.98.3 1.34.3C19 20 22 3 22 3c-1 2-8 2.25-13 3.25S2 11.5 2 13.5s1.75 3.75 1.75 3.75C7 8 17 8 17 8z"/></svg>
            </span>
            <span>Nhiệt Đới <b>Xanh</b> · Admin</span>
        </div>
        <div class="side-scroll">
            <div class="menu-label">Tổng quan</div>
            <ul class="sidebar-menu">
                <li><a href="${ctx}/admin" class="${uri.endsWith('/admin') or uri.contains('dashboard') ? 'active' : ''}"><span class="lbl"><i class="fa-solid fa-chart-pie"></i> Dashboard</span></a></li>
            </ul>
            <div class="menu-label">Vận hành</div>
            <ul class="sidebar-menu">
                <li><a href="${ctx}/admin/don-hang" class="${uri.contains('/don-hang') ? 'active' : ''}"><span class="lbl"><i class="fa-solid fa-cart-shopping"></i> Đơn hàng</span></a></li>
                <li><a href="${ctx}/admin/san-pham" class="${uri.contains('/san-pham') ? 'active' : ''}"><span class="lbl"><i class="fa-solid fa-box"></i> Sản phẩm</span></a></li>
                <li><a href="${ctx}/admin/phan-hoi" class="${uri.contains('/phan-hoi') ? 'active' : ''}"><span class="lbl"><i class="fa-solid fa-comment-dots"></i> Phản hồi</span></a></li>
            </ul>
            <div class="menu-label">Hệ thống</div>
            <ul class="sidebar-menu">
                <li><a href="${ctx}/admin/nhan-vien" class="${uri.contains('/nhan-vien') ? 'active' : ''}"><span class="lbl"><i class="fa-solid fa-users-gear"></i> Nhân viên</span></a></li>
                <li><a href="${ctx}/admin/nhat-ky" class="${uri.contains('/nhat-ky') ? 'active' : ''}"><span class="lbl"><i class="fa-solid fa-clock-rotate-left"></i> Nhật ký</span></a></li>
            </ul>
        </div>
        <div class="side-foot">
            <a href="${ctx}/" class="store"><i class="fa-solid fa-store"></i> Xem cửa hàng</a>
            <a href="${ctx}/admin/logout" class="logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a>
        </div>
    </aside>

    <main class="main-content">
        <header class="admin-header">
            <div class="admin-header-title">
                <c:out value="${pageTitle != null ? pageTitle : 'Dashboard'}"/>
                <small>Chào mừng trở lại, <c:out value="${sessionScope.adminUser.fullName}"/>!</small>
            </div>
            <div class="admin-header-right">
                <div class="admin-user">
                    <div>
                        <div class="u-name"><c:out value="${sessionScope.adminUser.fullName}"/></div>
                        <div class="u-role"><c:out value="${fn:toLowerCase(sessionScope.adminUser.role)}"/></div>
                    </div>
                    <img src="https://ui-avatars.com/api/?name=${fn:escapeXml(sessionScope.adminUser.fullName)}&background=2A5C38&color=fff&bold=true" alt="Avatar">
                </div>
            </div>
        </header>
