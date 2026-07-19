<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
/* ===== KPI row ===== */
.kpi-row{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:20px}
.kpi-card{background:var(--admin-surface);border-radius:18px;padding:22px;box-shadow:0 8px 22px -16px rgba(30,63,39,.2)}
.kpi-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:16px}
.kpi-ic{width:44px;height:44px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0}
.kpi-card.gold .kpi-ic{background:rgba(244,162,97,.16);color:#B96A2E}
.kpi-card.green .kpi-ic{background:rgba(42,92,56,.12);color:var(--admin-primary)}
.kpi-card.blue .kpi-ic{background:rgba(57,101,255,.12);color:#3965FF}
.kpi-card.coral .kpi-ic{background:rgba(217,83,79,.12);color:var(--admin-red)}
.kpi-trend{font-size:12px;font-weight:800;padding:5px 10px;border-radius:20px;display:inline-flex;align-items:center;gap:4px}
.kpi-trend.up{background:rgba(42,92,56,.1);color:var(--admin-primary)}
.kpi-trend.down{background:rgba(217,83,79,.1);color:var(--admin-red)}
.kpi-trend.flat{background:var(--admin-bg);color:var(--admin-text-light)}
.kpi-label{font-size:12.5px;font-weight:700;color:var(--admin-text-light);text-transform:uppercase;letter-spacing:.05em;margin-bottom:6px}
.kpi-value{font-family:var(--fd);font-size:27px;font-weight:700;line-height:1.1}
.kpi-sub{font-size:12px;color:var(--admin-text-light);font-weight:600;margin-top:4px}
.kpi-bar-track{height:6px;border-radius:6px;background:var(--admin-bg);margin-top:12px;overflow:hidden}
.kpi-bar-fill{height:100%;border-radius:6px;background:linear-gradient(90deg,var(--admin-primary),#4C8B5B)}

/* ===== middle row: chart + donut ===== */
.mid-row{display:grid;grid-template-columns:1.6fr 1fr;gap:16px;margin-bottom:16px}
.chart-card h3,.donut-card h3,.top-card h3{font-family:var(--fd);font-size:16.5px;margin-bottom:4px}
.card-sub{font-size:12.5px;color:var(--admin-text-light);font-weight:600;margin-bottom:20px}

.bars{display:flex;align-items:flex-end;justify-content:space-between;gap:10px;height:180px;padding:0 4px}
.bar-col{flex:1;display:flex;flex-direction:column;align-items:center;height:100%;justify-content:flex-end;gap:8px}
.bar-amt{font-size:10.5px;font-weight:700;color:var(--admin-text-light);opacity:0;transition:opacity .15s}
.bar-col:hover .bar-amt{opacity:1}
.bar-shape{width:26px;border-radius:13px 13px 6px 6px;background:linear-gradient(180deg,#8FBB9A,var(--admin-primary));min-height:6px;transition:height .5s cubic-bezier(.2,.8,.2,1)}
.bar-col.today .bar-shape{background:linear-gradient(180deg,#F9C08A,var(--admin-gold))}
.bar-lbl{font-size:12px;font-weight:700;color:var(--admin-text-light)}
.bar-col.today .bar-lbl{color:#B96A2E}

.donut-wrap{display:flex;flex-direction:column;align-items:center;gap:18px}
.donut{width:150px;height:150px;border-radius:50%;position:relative;display:flex;align-items:center;justify-content:center;background:conic-gradient(var(--admin-border) 0 100%)}
.donut::after{content:'';position:absolute;inset:20px;background:var(--admin-surface);border-radius:50%}
.donut-center{position:relative;z-index:1;text-align:center}
.donut-center b{display:block;font-family:var(--fd);font-size:18px}
.donut-center span{font-size:10.5px;color:var(--admin-text-light);font-weight:700;text-transform:uppercase;letter-spacing:.04em}
.donut-legend{width:100%;display:flex;flex-direction:column;gap:11px}
.donut-legend li{list-style:none;display:flex;align-items:center;gap:10px;font-size:13.5px;font-weight:600}
.dot{width:10px;height:10px;border-radius:50%;flex-shrink:0}
.donut-legend .pct{margin-left:auto;font-weight:800;color:var(--admin-text-light)}
.donut-empty{text-align:center;color:var(--admin-text-light);font-size:13.5px;padding:20px 0}

/* ===== bottom row: top products + recent orders ===== */
.bottom-row{display:grid;grid-template-columns:1fr 1.7fr;gap:16px}
.top-list{display:flex;flex-direction:column;gap:14px}
.top-item{display:flex;align-items:center;gap:13px}
.top-rank{width:30px;height:30px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-family:var(--fd);font-weight:700;font-size:13.5px;color:#fff;flex-shrink:0}
.top-rank.r1{background:linear-gradient(135deg,var(--admin-gold),#E08A3E)}
.top-rank.r2{background:linear-gradient(135deg,#9AB09F,#6D8873)}
.top-rank.r3{background:linear-gradient(135deg,#C98A5A,#A66840)}
.top-rank.rn{background:var(--admin-bg);color:var(--admin-text-light)}
.top-info b{display:block;font-size:14px;font-weight:700}
.top-info span{font-size:12px;color:var(--admin-text-light);font-weight:600}

@media(max-width:1100px){.mid-row,.bottom-row{grid-template-columns:1fr}}
@media(max-width:900px){.kpi-row{grid-template-columns:1fr 1fr}}
</style>

<div class="kpi-row">
  <div class="kpi-card gold">
    <div class="kpi-top">
      <div class="kpi-ic"><i class="fa-solid fa-sack-dollar"></i></div>
      <c:choose>
        <c:when test="${revenueChangePct == null}"><span class="kpi-trend flat">Mới</span></c:when>
        <c:when test="${revenueChangePct >= 0}"><span class="kpi-trend up"><i class="fa-solid fa-arrow-up"></i> ${revenueChangePct}%</span></c:when>
        <c:otherwise><span class="kpi-trend down"><i class="fa-solid fa-arrow-down"></i> ${-revenueChangePct}%</span></c:otherwise>
      </c:choose>
    </div>
    <div class="kpi-label">Doanh thu tuần này</div>
    <div class="kpi-value"><fmt:formatNumber value="${revenueThisWeek}" type="number" groupingUsed="true"/> đ</div>
    <div class="kpi-sub">so với tuần trước</div>
  </div>

  <div class="kpi-card blue">
    <div class="kpi-top">
      <div class="kpi-ic"><i class="fa-solid fa-cart-shopping"></i></div>
      <c:choose>
        <c:when test="${newOrdersChangePct == null}"><span class="kpi-trend flat">Mới</span></c:when>
        <c:when test="${newOrdersChangePct >= 0}"><span class="kpi-trend up"><i class="fa-solid fa-arrow-up"></i> ${newOrdersChangePct}%</span></c:when>
        <c:otherwise><span class="kpi-trend down"><i class="fa-solid fa-arrow-down"></i> ${-newOrdersChangePct}%</span></c:otherwise>
      </c:choose>
    </div>
    <div class="kpi-label">Đơn mới tuần này</div>
    <div class="kpi-value">${newOrdersThisWeek}</div>
    <div class="kpi-sub">so với tuần trước</div>
  </div>

  <div class="kpi-card coral">
    <div class="kpi-top">
      <div class="kpi-ic"><i class="fa-solid fa-hourglass-half"></i></div>
      <c:choose>
        <c:when test="${processingChangePct == null}"><span class="kpi-trend flat">Mới</span></c:when>
        <c:when test="${processingChangePct <= 0}"><span class="kpi-trend up"><i class="fa-solid fa-arrow-down"></i> ${-processingChangePct}%</span></c:when>
        <c:otherwise><span class="kpi-trend down"><i class="fa-solid fa-arrow-up"></i> ${processingChangePct}%</span></c:otherwise>
      </c:choose>
    </div>
    <div class="kpi-label">Đang xử lý</div>
    <div class="kpi-value">${processingNow}</div>
    <div class="kpi-sub">đơn cần xử lý ngay</div>
  </div>

  <div class="kpi-card green">
    <div class="kpi-top">
      <div class="kpi-ic"><i class="fa-solid fa-circle-check"></i></div>
    </div>
    <div class="kpi-label">Tỷ lệ thành công</div>
    <div class="kpi-value">${successRate}%</div>
    <div class="kpi-bar-track"><div class="kpi-bar-fill" style="width:${successRate}%"></div></div>
  </div>
</div>

<div class="mid-row">
  <div class="card chart-card">
    <h3>Doanh thu theo ngày</h3>
    <div class="card-sub">Tuần này (Thứ 2 – Chủ nhật)</div>
    <div class="bars">
      <c:forEach var="entry" items="${revenueByDay}">
        <c:set var="pct" value="${maxDayRevenue > 0 ? (entry.value * 100) / maxDayRevenue : 0}"/>
        <div class="bar-col ${entry.key == todayLabel ? 'today' : ''}">
          <span class="bar-amt"><fmt:formatNumber value="${entry.value}" type="number" groupingUsed="true"/>đ</span>
          <div class="bar-shape" style="height:${pct < 4 ? 4 : pct}%"></div>
          <span class="bar-lbl">${entry.key}</span>
        </div>
      </c:forEach>
    </div>
  </div>

  <div class="card donut-card">
    <h3>Cơ cấu doanh thu</h3>
    <div class="card-sub">Theo danh mục sản phẩm</div>
    <c:choose>
      <c:when test="${not empty categorySlices}">
        <div class="donut-wrap">
          <div class="donut" id="revenueDonut">
            <div class="donut-center"><b>${fn:length(categorySlices)}</b><span>Danh mục</span></div>
          </div>
          <ul class="donut-legend">
            <c:forEach var="s" items="${categorySlices}" varStatus="st">
              <li>
                <span class="dot" data-slice-color="${st.index}"></span>
                <c:out value="${s.name}"/>
                <span class="pct" data-slice-pct="${s.percent}">${s.percent}%</span>
              </li>
            </c:forEach>
          </ul>
        </div>
      </c:when>
      <c:otherwise>
        <div class="donut-empty"><i class="fa-regular fa-chart-bar" style="font-size:26px;opacity:.3;display:block;margin-bottom:10px"></i>Chưa có doanh thu để thống kê.</div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<div class="bottom-row">
  <div class="card top-card">
    <h3>Top sản phẩm bán chạy</h3>
    <div class="card-sub">Theo số lượng đã bán</div>
    <c:choose>
      <c:when test="${not empty topProducts}">
        <div class="top-list">
          <c:forEach var="p" items="${topProducts}" varStatus="st">
            <div class="top-item">
              <div class="top-rank ${st.index == 0 ? 'r1' : st.index == 1 ? 'r2' : st.index == 2 ? 'r3' : 'rn'}">${st.index + 1}</div>
              <div class="top-info">
                <b><c:out value="${p.name}"/></b>
                <span>${p.quantity} ly đã bán</span>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:when>
      <c:otherwise>
        <div class="dash-empty"><i class="fa-regular fa-lemon"></i><p>Chưa có sản phẩm nào được bán.</p></div>
      </c:otherwise>
    </c:choose>
  </div>

  <div class="card">
    <h3 style="font-family:var(--fd);font-size:16.5px;margin-bottom:18px">Đơn hàng gần đây</h3>
    <c:choose>
      <c:when test="${not empty recentOrders}">
        <div class="table-responsive">
          <table class="admin-table">
            <thead><tr><th>#</th><th>Khách hàng</th><th>Tổng tiền</th><th>Trạng thái</th><th>Ngày đặt</th></tr></thead>
            <tbody>
              <c:forEach var="o" items="${recentOrders}">
                <tr>
                  <td>#${o.orderId}</td>
                  <td><c:out value="${o.customerName}"/></td>
                  <td><fmt:formatNumber value="${o.finalAmount}" type="number" groupingUsed="true"/> đ</td>
                  <td><span class="badge badge-${o.orderStatus}"><c:out value="${o.orderStatusLabel}"/></span></td>
                  <td><fmt:formatDate value="${o.createdAt}" pattern="HH:mm dd/MM/yyyy"/></td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:when>
      <c:otherwise>
        <div class="dash-empty">
          <i class="fa-regular fa-folder-open"></i>
          <p>Chưa có đơn hàng nào.</p>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<style>
.dash-empty{text-align:center;padding:50px 20px;color:var(--admin-text-light)}
.dash-empty i{font-size:36px;opacity:.3;margin-bottom:12px;display:block}
</style>

<script>
(function () {
  var donut = document.getElementById('revenueDonut');
  if (!donut) return;
  var colors = ['var(--admin-primary)', 'var(--admin-gold)', 'var(--status-confirmed)', 'var(--status-shipping)', 'var(--admin-red)'];
  var dots = document.querySelectorAll('[data-slice-color]');
  var stops = [];
  var cum = 0;
  dots.forEach(function (dot, i) {
    var pctEl = dot.closest('li').querySelector('[data-slice-pct]');
    var pct = parseFloat(pctEl.getAttribute('data-slice-pct')) || 0;
    var color = colors[i % colors.length];
    dot.style.background = color;
    stops.push(color + ' ' + cum + '% ' + (cum + pct) + '%');
    cum += pct;
  });
  if (stops.length) donut.style.background = 'conic-gradient(' + stops.join(',') + ')';
})();
</script>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
