<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="isEdit" value="${not empty product}"/>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
.pf-back{display:inline-flex;align-items:center;gap:8px;color:var(--admin-text-light);font-weight:700;font-size:13.5px;margin-bottom:16px}
.pf-back:hover{color:var(--admin-primary)}
.pf-flash{padding:14px 18px;border-radius:12px;margin-bottom:20px;font-weight:600;font-size:14px}
.pf-flash.error{background:rgba(217,83,79,.1);color:var(--admin-red)}
.pf-grid{display:grid;grid-template-columns:2fr 1fr;gap:22px;align-items:start}
@media(max-width:1000px){.pf-grid{grid-template-columns:1fr}}
.pf-section-title{font-family:var(--fd);font-size:16px;margin-bottom:16px}
.pf-current-img{width:110px;height:110px;border-radius:14px;object-fit:cover;margin-bottom:10px;display:block;background:var(--admin-bg)}
.pf-hint{font-size:12.5px;color:var(--admin-text-light);margin-top:6px}
textarea.form-control{resize:vertical;min-height:100px}
#variantRows{display:flex;flex-direction:column;gap:10px;margin-bottom:14px}
.variant-row{display:flex;gap:10px;align-items:center;padding:10px;border:1.5px solid var(--admin-border);border-radius:12px}
.variant-row select{width:90px;padding:9px 10px;border:1.5px solid var(--admin-border);border-radius:9px;font-family:var(--fb)}
.variant-row .v-price{flex:1;padding:9px 12px;border:1.5px solid var(--admin-border);border-radius:9px;font-family:var(--fb)}
.variant-row.marked-removed{opacity:.45;background:rgba(217,83,79,.05)}
.variant-row .v-remove-btn{background:none;border:none;color:var(--admin-red);font-weight:700;cursor:pointer;font-size:13px;white-space:nowrap}
.pf-submit-row{display:flex;gap:10px;margin-top:22px}
</style>

<a class="pf-back" href="${ctx}/admin/san-pham"><i class="fa-solid fa-arrow-left"></i> Quay lại danh sách sản phẩm</a>

<c:if test="${not empty flashError}"><div class="pf-flash error"><c:out value="${flashError}"/></div></c:if>

<form method="post" enctype="multipart/form-data"
      action="${ctx}${isEdit ? '/admin/san-pham/sua' : '/admin/san-pham/them'}" id="productForm">
    <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
    <c:if test="${isEdit}"><input type="hidden" name="productId" value="${product.productId}"></c:if>

    <div class="pf-grid">
        <div>
            <div class="card">
                <h3 class="pf-section-title">Thông tin sản phẩm</h3>
                <div class="form-group">
                    <label>Tên sản phẩm</label>
                    <input type="text" name="name" class="form-control" required
                           value="${fn:escapeXml(product.name)}" placeholder="VD: Nước ép cam tươi">
                </div>
                <div class="form-group">
                    <label>Danh mục</label>
                    <select name="categoryId" class="form-control" required>
                        <option value="">-- Chọn danh mục --</option>
                        <c:forEach var="c" items="${categories}">
                            <option value="${c.categoryId}" ${isEdit and product.categoryId == c.categoryId ? 'selected' : ''}>
                                <c:out value="${c.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label>Mô tả</label>
                    <textarea name="description" class="form-control" placeholder="Mô tả ngắn về sản phẩm..."><c:out value="${product.description}"/></textarea>
                </div>
            </div>

            <div class="card">
                <h3 class="pf-section-title">Size &amp; Giá</h3>
                <div id="variantRows">
                    <c:forEach var="v" items="${product.variants}">
                        <div class="variant-row" data-existing="true">
                            <input type="hidden" name="variantId" value="${v.variantId}">
                            <select name="variantSize">
                                <option value="M" ${v.size == 'M' ? 'selected' : ''}>Size M</option>
                                <option value="L" ${v.size == 'L' ? 'selected' : ''}>Size L</option>
                            </select>
                            <input type="number" name="variantPrice" class="v-price" min="0" step="1000" required value="${v.price}" placeholder="Giá (đ)">
                            <input type="checkbox" name="variantRemove" class="v-remove-check" value="0" style="display:none">
                            <button type="button" class="v-remove-btn" onclick="toggleRemoveVariant(this)">Xóa</button>
                        </div>
                    </c:forEach>
                </div>
                <button type="button" class="btn btn-outline" onclick="addVariantRow()"><i class="fa-solid fa-plus"></i> Thêm size</button>
                <p class="pf-hint">Cần ít nhất 1 size đang hoạt động. Xóa biến thể đã tồn tại chỉ ẩn đi (không mất dữ liệu đơn hàng cũ).</p>
            </div>
        </div>

        <div>
            <div class="card">
                <h3 class="pf-section-title">Ảnh sản phẩm</h3>
                <c:if test="${isEdit and not empty product.imageUrl}">
                    <img class="pf-current-img" src="${ctx}${product.imageUrl}" alt="">
                </c:if>
                <div class="form-group">
                    <input type="file" name="imageFile" accept="image/jpeg,image/png,image/webp" ${isEdit ? '' : 'required'}>
                    <p class="pf-hint">JPG/PNG/WEBP, tối đa 3MB.${isEdit ? ' Bỏ trống để giữ ảnh hiện tại.' : ''}</p>
                </div>
            </div>

            <div class="pf-submit-row">
                <button type="submit" class="btn btn-primary"><i class="fa-solid fa-floppy-disk"></i> ${isEdit ? 'Lưu thay đổi' : 'Thêm sản phẩm'}</button>
                <a href="${ctx}/admin/san-pham" class="btn btn-outline">Hủy</a>
            </div>
        </div>
    </div>
</form>

<script>
function reindexVariants() {
    document.querySelectorAll('#variantRows .variant-row').forEach(function (row, idx) {
        row.querySelector('.v-remove-check').value = idx;
    });
}

function addVariantRow() {
    var container = document.getElementById('variantRows');
    var row = document.createElement('div');
    row.className = 'variant-row';
    row.dataset.existing = 'false';
    row.innerHTML =
        '<input type="hidden" name="variantId" value="0">' +
        '<select name="variantSize"><option value="M">Size M</option><option value="L">Size L</option></select>' +
        '<input type="number" name="variantPrice" class="v-price" min="0" step="1000" required placeholder="Giá (đ)">' +
        '<input type="checkbox" name="variantRemove" class="v-remove-check" value="0" style="display:none">' +
        '<button type="button" class="v-remove-btn" onclick="toggleRemoveVariant(this)">Xóa</button>';
    container.appendChild(row);
    reindexVariants();
}

function toggleRemoveVariant(btn) {
    var row = btn.closest('.variant-row');
    if (row.dataset.existing === 'false') {
        row.remove();
        reindexVariants();
        return;
    }
    var checkbox = row.querySelector('.v-remove-check');
    var isRemoved = row.classList.toggle('marked-removed');
    checkbox.checked = isRemoved;
    btn.textContent = isRemoved ? 'Hoàn tác' : 'Xóa';
    // Không disable input — field bị disable sẽ không được submit, nhưng server cần
    // variantId/variantSize/variantPrice của hàng bị xóa để biết đâu mà setActive(false).
}

reindexVariants();
</script>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
