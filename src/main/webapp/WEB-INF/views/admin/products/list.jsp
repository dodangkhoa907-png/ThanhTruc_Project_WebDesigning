<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
.pr-filters{display:flex;flex-wrap:wrap;gap:12px;align-items:flex-end;margin-bottom:20px}
.pr-filters .f-group{display:flex;flex-direction:column;gap:6px}
.pr-filters .f-group label{font-size:12px;font-weight:700;color:var(--admin-text-light)}
.pr-filters input,.pr-filters select{padding:10px 13px;border:1.5px solid var(--admin-border);border-radius:10px;font-size:14px;font-family:var(--fb);color:var(--admin-text)}
.pr-filters input:focus,.pr-filters select:focus{border-color:var(--admin-primary);outline:none}
.pr-filters .f-search{flex:1;min-width:220px}
.pr-flash{padding:14px 18px;border-radius:12px;margin-bottom:20px;font-weight:600;font-size:14px}
.pr-flash.success{background:rgba(42,92,56,.1);color:var(--admin-primary)}
.pr-flash.error{background:rgba(217,83,79,.1);color:var(--admin-red)}
.pr-empty{text-align:center;padding:60px 20px;color:var(--admin-text-light)}
.pr-empty i{font-size:40px;opacity:.3;margin-bottom:14px;display:block}
.pr-count{color:var(--admin-text-light);font-size:13px;font-weight:600;margin-bottom:14px;display:flex;justify-content:space-between;align-items:center}
.pr-thumb{width:50px;height:50px;border-radius:10px;object-fit:cover;background:var(--admin-bg);flex:none}
.pr-name-cell{display:flex;align-items:center;gap:12px}
.pr-name-cell .n{font-weight:700}
.pr-name-cell .cat{font-size:12.5px;color:var(--admin-text-light)}
.pr-variants{display:flex;flex-wrap:wrap;gap:6px}
.pr-variants span{background:var(--admin-bg);border-radius:8px;padding:3px 9px;font-size:12.5px;font-weight:700;color:var(--admin-text)}
.pr-actions{display:flex;gap:8px}
.badge-ACTIVE{background:rgba(42,92,56,.12);color:var(--status-done)}
.badge-INACTIVE{background:rgba(138,154,138,.15);color:var(--admin-text-light)}

/* -------- Modal Thêm/Sửa sản phẩm — đè ngay trên trang này, không điều hướng -------- */
.pf-overlay{position:fixed;inset:0;background:rgba(26,46,26,.45);backdrop-filter:blur(2px);
    display:none;align-items:center;justify-content:center;z-index:400;padding:20px;
    opacity:0;transition:opacity .2s ease}
.pf-overlay.show{display:flex;opacity:1}
.pf-modal{background:var(--admin-bg);border-radius:20px;padding:26px;width:100%;max-width:920px;
    max-height:90vh;overflow-y:auto;box-shadow:0 30px 70px -20px rgba(0,0,0,.45);
    transform:translateY(14px);transition:transform .2s ease}
.pf-overlay.show .pf-modal{transform:none}
.pf-modal-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:18px}
.pf-modal-head h3{font-family:var(--fd);font-size:19px}
.pf-modal-close{background:none;border:none;font-size:18px;color:var(--admin-text-light);cursor:pointer;
    width:34px;height:34px;border-radius:10px;display:flex;align-items:center;justify-content:center;transition:.15s}
.pf-modal-close:hover{background:var(--admin-border);color:var(--admin-text)}
.pf-grid{display:grid;grid-template-columns:2fr 1fr;gap:18px;align-items:start}
@media(max-width:800px){.pf-grid{grid-template-columns:1fr}}
.pf-section-title{font-family:var(--fd);font-size:15px;margin-bottom:14px}
.pf-current-img{width:100px;height:100px;border-radius:14px;object-fit:cover;margin-bottom:10px;display:block;background:var(--admin-bg)}
.pf-current-img[hidden]{display:none}
.pf-hint{font-size:12px;color:var(--admin-text-light);margin-top:6px}
.pf-modal textarea.form-control{resize:vertical;min-height:88px}
#variantRows{display:flex;flex-direction:column;gap:10px;margin-bottom:14px}
.variant-row{display:flex;gap:10px;align-items:center;padding:10px;border:1.5px solid var(--admin-border);border-radius:12px;background:var(--admin-surface)}
.variant-row select{width:90px;padding:9px 10px;border:1.5px solid var(--admin-border);border-radius:9px;font-family:var(--fb)}
.variant-row .v-price{flex:1;padding:9px 12px;border:1.5px solid var(--admin-border);border-radius:9px;font-family:var(--fb)}
.variant-row.marked-removed{opacity:.45;background:rgba(217,83,79,.05)}
.variant-row .v-remove-btn{background:none;border:none;color:var(--admin-red);font-weight:700;cursor:pointer;font-size:13px;white-space:nowrap}
.pf-submit-row{display:flex;gap:10px;margin-top:20px}
</style>

<c:if test="${not empty flashSuccess}"><div class="pr-flash success"><c:out value="${flashSuccess}"/></div></c:if>
<c:if test="${not empty flashError}"><div class="pr-flash error"><c:out value="${flashError}"/></div></c:if>

<div class="card">
    <form class="pr-filters" method="get" action="${ctx}/admin/san-pham">
        <div class="f-group f-search">
            <label>Tìm kiếm</label>
            <input type="text" name="q" placeholder="Tên sản phẩm..." value="${fn:escapeXml(q)}">
        </div>
        <div class="f-group">
            <label>Danh mục</label>
            <select name="categoryId">
                <option value="">Tất cả</option>
                <c:forEach var="c" items="${categories}">
                    <option value="${c.categoryId}" ${categoryId == c.categoryId ? 'selected' : ''}><c:out value="${c.name}"/></option>
                </c:forEach>
            </select>
        </div>
        <div class="f-group">
            <label>Trạng thái</label>
            <select name="status">
                <option value="">Tất cả</option>
                <option value="active" ${status == 'active' ? 'selected' : ''}>Đang bán</option>
                <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>Đã ẩn</option>
            </select>
        </div>
        <div class="f-group">
            <button type="submit" class="btn btn-primary"><i class="fa-solid fa-magnifying-glass"></i> Lọc</button>
        </div>
        <c:if test="${not empty q or not empty categoryId or not empty status}">
            <div class="f-group">
                <a href="${ctx}/admin/san-pham" class="btn btn-outline">Xóa lọc</a>
            </div>
        </c:if>
    </form>

    <div class="pr-count">
        <span>Tìm thấy <b><c:out value="${totalProducts}"/></b> sản phẩm</span>
        <button type="button" class="btn btn-primary" id="openCreateProductBtn"><i class="fa-solid fa-plus"></i> Thêm sản phẩm</button>
    </div>

    <c:choose>
        <c:when test="${not empty products}">
            <div class="table-responsive">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Sản phẩm</th>
                            <th>Size / Giá</th>
                            <th>Trạng thái</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="p" items="${products}">
                            <tr>
                                <td>
                                    <div class="pr-name-cell">
                                        <c:choose>
                                            <c:when test="${not empty p.imageUrl}">
                                                <img class="pr-thumb" src="${ctx}${p.imageUrl}" alt="">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="pr-thumb"></div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div>
                                            <div class="n"><c:out value="${p.name}"/></div>
                                            <div class="cat"><c:out value="${p.categoryName}"/></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="pr-variants">
                                        <c:forEach var="v" items="${p.variants}">
                                            <span><c:out value="${v.sizeLabel}"/>: <fmt:formatNumber value="${v.price}" type="number" groupingUsed="true"/>đ</span>
                                        </c:forEach>
                                        <c:if test="${empty p.variants}"><span>Chưa có biến thể</span></c:if>
                                    </div>
                                </td>
                                <td><span class="badge badge-${p.active ? 'ACTIVE' : 'INACTIVE'}">${p.active ? 'Đang bán' : 'Đã ẩn'}</span></td>
                                <td>
                                    <div class="pr-actions">
                                        <button type="button" class="btn btn-outline js-edit-product" data-id="${p.productId}">Sửa</button>
                                        <form method="post" action="${ctx}/admin/san-pham/an-hien"
                                              onsubmit="return confirm('${p.active ? 'Ẩn' : 'Hiện lại'} sản phẩm này?');">
                                            <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                                            <input type="hidden" name="id" value="${p.productId}">
                                            <input type="hidden" name="active" value="${p.active}">
                                            <button type="submit" class="btn ${p.active ? 'btn-danger' : 'btn-primary'}">${p.active ? 'Ẩn' : 'Hiện'}</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <div class="pr-empty">
                <i class="fa-regular fa-folder-open"></i>
                <p>Không tìm thấy sản phẩm nào khớp bộ lọc.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Modal Thêm/Sửa sản phẩm — dùng chung -->
<div class="pf-overlay" id="productFormOverlay" hidden>
    <div class="pf-modal" role="dialog" aria-modal="true" aria-labelledby="productFormTitle">
        <div class="pf-modal-head">
            <h3 id="productFormTitle">Thêm sản phẩm</h3>
            <button type="button" class="pf-modal-close" id="productFormClose" aria-label="Đóng"><i class="fa-solid fa-xmark"></i></button>
        </div>

        <form method="post" enctype="multipart/form-data" id="productForm">
            <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
            <input type="hidden" name="productId" id="pfProductId" value="">

            <div class="pf-grid">
                <div>
                    <div class="card">
                        <h3 class="pf-section-title">Thông tin sản phẩm</h3>
                        <div class="form-group">
                            <label>Tên sản phẩm</label>
                            <input type="text" name="name" id="pfName" class="form-control" required placeholder="VD: Nước ép cam tươi">
                        </div>
                        <div class="form-group">
                            <label>Danh mục</label>
                            <select name="categoryId" id="pfCategoryId" class="form-control" required>
                                <option value="">-- Chọn danh mục --</option>
                                <c:forEach var="c" items="${categories}">
                                    <option value="${c.categoryId}"><c:out value="${c.name}"/></option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Mô tả</label>
                            <textarea name="description" id="pfDescription" class="form-control" placeholder="Mô tả ngắn về sản phẩm..."></textarea>
                        </div>
                    </div>

                    <div class="card">
                        <h3 class="pf-section-title">Size &amp; Giá</h3>
                        <div id="variantRows"></div>
                        <button type="button" class="btn btn-outline" id="addVariantBtn"><i class="fa-solid fa-plus"></i> Thêm size</button>
                        <p class="pf-hint">Cần ít nhất 1 size đang hoạt động. Xóa biến thể đã tồn tại chỉ ẩn đi (không mất dữ liệu đơn hàng cũ).</p>
                    </div>
                </div>

                <div>
                    <div class="card">
                        <h3 class="pf-section-title">Ảnh sản phẩm</h3>
                        <img class="pf-current-img" id="pfCurrentImg" src="" alt="" hidden>
                        <div class="form-group">
                            <input type="file" name="imageFile" accept="image/jpeg,image/png,image/webp">
                            <p class="pf-hint" id="pfImageHint">JPG/PNG/WEBP, tối đa 3MB — không bắt buộc.
                                Nếu tên sản phẩm khớp trái cây có ảnh sẵn (cam/dưa hấu/thơm), trang chủ sẽ tự hiện ảnh đó.</p>
                        </div>
                    </div>

                    <div class="pf-submit-row">
                        <button type="submit" class="btn btn-primary" id="pfSubmitBtn"><i class="fa-solid fa-floppy-disk"></i> Thêm sản phẩm</button>
                        <button type="button" class="btn btn-outline" id="productFormCancel">Hủy</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script type="application/json" id="productsData">${productsJson}</script>

<script>
(function () {
    var ctx = '${ctx}';
    var productsData = [];
    try { productsData = JSON.parse(document.getElementById('productsData').textContent || '[]'); } catch (e) { productsData = []; }

    // ==================== Biến thể (size/giá) — thêm/xóa động ====================
    var variantRowsEl = document.getElementById('variantRows');

    function reindexVariants() {
        variantRowsEl.querySelectorAll('.variant-row').forEach(function (row, idx) {
            row.querySelector('.v-remove-check').value = idx;
        });
    }

    function buildVariantRow(variantId, size, price, existing) {
        var row = document.createElement('div');
        row.className = 'variant-row';
        row.dataset.existing = existing ? 'true' : 'false';
        row.innerHTML =
            '<input type="hidden" name="variantId" value="' + (variantId || 0) + '">' +
            '<select name="variantSize">' +
                '<option value="M"' + (size === 'M' ? ' selected' : '') + '>Size M</option>' +
                '<option value="L"' + (size === 'L' ? ' selected' : '') + '>Size L</option>' +
            '</select>' +
            '<input type="number" name="variantPrice" class="v-price" min="0" step="1000" required placeholder="Giá (đ)"' +
                (price != null ? ' value="' + price + '"' : '') + '>' +
            '<input type="checkbox" name="variantRemove" class="v-remove-check" value="0" style="display:none">' +
            '<button type="button" class="v-remove-btn">Xóa</button>';
        row.querySelector('.v-remove-btn').addEventListener('click', function () { toggleRemoveVariant(this); });
        return row;
    }

    function addVariantRow() {
        variantRowsEl.appendChild(buildVariantRow(0, 'M', null, false));
        reindexVariants();
    }
    document.getElementById('addVariantBtn').addEventListener('click', addVariantRow);

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

    // ==================== Modal Thêm/Sửa ====================
    var overlay = document.getElementById('productFormOverlay');
    var form = document.getElementById('productForm');
    var titleEl = document.getElementById('productFormTitle');
    var pfProductId = document.getElementById('pfProductId');
    var pfName = document.getElementById('pfName');
    var pfCategoryId = document.getElementById('pfCategoryId');
    var pfDescription = document.getElementById('pfDescription');
    var pfCurrentImg = document.getElementById('pfCurrentImg');
    var pfImageHint = document.getElementById('pfImageHint');
    var pfSubmitBtn = document.getElementById('pfSubmitBtn');
    var imageFileInput = form.querySelector('input[name="imageFile"]');

    function openProductForm(mode, data) {
        data = data || {};
        variantRowsEl.innerHTML = '';
        imageFileInput.value = '';

        if (mode === 'edit') {
            titleEl.textContent = 'Sửa sản phẩm';
            form.action = ctx + '/admin/san-pham/sua';
            pfProductId.value = data.productId || '';
            pfName.value = data.name || '';
            pfCategoryId.value = data.categoryId || '';
            pfDescription.value = data.description || '';
            if (data.imageUrl) {
                pfCurrentImg.src = ctx + data.imageUrl;
                pfCurrentImg.hidden = false;
            } else {
                pfCurrentImg.hidden = true;
            }
            pfImageHint.textContent = 'JPG/PNG/WEBP, tối đa 3MB — không bắt buộc. Bỏ trống để giữ ảnh hiện tại.';
            (data.variants && data.variants.length ? data.variants : [{ variantId: 0, size: 'M', price: null }])
                .forEach(function (v) { variantRowsEl.appendChild(buildVariantRow(v.variantId, v.size, v.price, v.variantId > 0)); });
            pfSubmitBtn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Lưu thay đổi';
        } else {
            titleEl.textContent = 'Thêm sản phẩm';
            form.action = ctx + '/admin/san-pham/them';
            pfProductId.value = '';
            pfName.value = '';
            pfCategoryId.value = '';
            pfDescription.value = '';
            pfCurrentImg.hidden = true;
            pfImageHint.textContent = 'JPG/PNG/WEBP, tối đa 3MB — không bắt buộc. Nếu tên sản phẩm khớp trái cây có ảnh sẵn (cam/dưa hấu/thơm), trang chủ sẽ tự hiện ảnh đó.';
            variantRowsEl.appendChild(buildVariantRow(0, 'M', null, false));
            pfSubmitBtn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Thêm sản phẩm';
        }
        reindexVariants();

        overlay.hidden = false;
        requestAnimationFrame(function () { overlay.classList.add('show'); });
        setTimeout(function () { pfName.focus(); }, 60);
    }

    function closeProductForm() {
        overlay.classList.remove('show');
        setTimeout(function () { overlay.hidden = true; }, 200);
    }

    document.getElementById('openCreateProductBtn').addEventListener('click', function () { openProductForm('create'); });
    document.querySelectorAll('.js-edit-product').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = parseInt(btn.dataset.id, 10);
            var data = productsData.find(function (p) { return p.productId === id; });
            openProductForm('edit', data);
        });
    });
    document.getElementById('productFormClose').addEventListener('click', closeProductForm);
    document.getElementById('productFormCancel').addEventListener('click', closeProductForm);
    overlay.addEventListener('click', function (e) { if (e.target === overlay) closeProductForm(); });
    document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !overlay.hidden) closeProductForm(); });

    // Mở lại đúng modal nếu server redirect về sau lỗi validate (xem AdminProductController —
    // không có "trang lỗi" riêng, luôn quay về chính trang này). Dữ liệu sửa lấy lại từ
    // productsData (không cố khôi phục input vừa gõ — biến thể/ảnh vốn không thể khôi phục qua URL).
    (function reopenOnError() {
        var params = new URLSearchParams(location.search);
        var formOpen = params.get('formOpen');
        if (formOpen === 'them') {
            openProductForm('create');
        } else if (formOpen === 'sua') {
            var editId = parseInt(params.get('editId'), 10);
            var data = productsData.find(function (p) { return p.productId === editId; });
            openProductForm('edit', data);
        }
        if (formOpen) history.replaceState(null, '', ctx + '/admin/san-pham');
    })();
})();
</script>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
