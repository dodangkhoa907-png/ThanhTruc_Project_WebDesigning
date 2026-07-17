<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
.dash-stats{display:grid;grid-template-columns:repeat(4,1fr);gap:16px;margin-bottom:24px}
.dash-stat{background:var(--admin-surface);border-radius:16px;padding:22px;box-shadow:0 8px 22px -16px rgba(30,63,39,.2);display:flex;align-items:center;gap:16px}
.dash-stat-ic{width:52px;height:52px;border-radius:14px;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0}
.dash-stat.amber .dash-stat-ic{background:rgba(244,162,97,.15);color:#B96A2E}
.dash-stat.green .dash-stat-ic{background:rgba(42,92,56,.12);color:var(--admin-primary)}
.dash-stat.coral .dash-stat-ic{background:rgba(217,83,79,.12);color:var(--admin-red)}
.dash-stat.blue .dash-stat-ic{background:rgba(57,101,255,.12);color:#3965FF}
.dash-stat b{display:block;font-family:var(--fd);font-size:26px;line-height:1}
.dash-stat span{font-size:12.5px;color:var(--admin-text-light);font-weight:600}
.dash-empty{text-align:center;padding:50px 20px;color:var(--admin-text-light)}
.dash-empty i{font-size:36px;opacity:.3;margin-bottom:12px;display:block}
@media(max-width:900px){.dash-stats{grid-template-columns:1fr 1fr}}
</style>

<div class="dash-stats">
  <div class="dash-stat amber"><div class="dash-stat-ic"><i class="fa-solid fa-clock"></i></div><div><b>${pendingOrders}</b><span>Đơn chờ xử lý</span></div></div>
  <div class="dash-stat green"><div class="dash-stat-ic"><i class="fa-solid fa-circle-check"></i></div><div><b>${doneOrders}</b><span>Đơn hoàn thành</span></div></div>
  <div class="dash-stat blue"><div class="dash-stat-ic"><i class="fa-solid fa-box"></i></div><div><b>${totalProducts}</b><span>Sản phẩm</span></div></div>
  <div class="dash-stat coral"><div class="dash-stat-ic"><i class="fa-solid fa-comment-dots"></i></div><div><b>${newFeedback}</b><span>Phản hồi mới</span></div></div>
</div>

<div class="card">
  <h3 style="font-family:var(--fd);font-size:17px;margin-bottom:18px">Đơn hàng gần đây</h3>
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
                <td><span class="badge badge-${o.orderStatus}"><c:out value="${o.orderStatus}"/></span></td>
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

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
