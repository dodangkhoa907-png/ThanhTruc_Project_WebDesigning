<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/admin/layout/header.jsp" />

<style>
.sf-flash{padding:14px 18px;border-radius:12px;margin-bottom:20px;font-weight:600;font-size:14px}
.sf-flash.success{background:rgba(42,92,56,.1);color:var(--admin-primary)}
.sf-flash.error{background:rgba(217,83,79,.1);color:var(--admin-red)}
.sf-count{color:var(--admin-text-light);font-size:13px;font-weight:600;margin-bottom:14px;display:flex;justify-content:space-between;align-items:center}
.sf-name-cell b{display:block;font-weight:700}
.sf-name-cell span{font-size:12.5px;color:var(--admin-text-light)}
.badge-ROLE{background:rgba(122,90,248,.12);color:#6A45E0}
.badge-ACTIVE{background:rgba(42,92,56,.12);color:var(--status-done)}
.badge-INACTIVE{background:rgba(138,154,138,.15);color:var(--admin-text-light)}
.sf-actions{display:flex;gap:8px;flex-wrap:wrap}
.sf-empty{text-align:center;padding:60px 20px;color:var(--admin-text-light)}
.sf-empty i{font-size:40px;opacity:.3;margin-bottom:14px;display:block}

/* -------- Modal dùng chung (Thêm/Sửa nhân viên · Đổi mật khẩu) -------- */
.sf-overlay{position:fixed;inset:0;background:rgba(26,46,26,.45);backdrop-filter:blur(2px);
    display:none;align-items:center;justify-content:center;z-index:400;padding:20px;
    opacity:0;transition:opacity .2s ease}
.sf-overlay.show{display:flex;opacity:1}
.sf-modal{background:#fff;border-radius:18px;padding:24px;width:100%;max-width:440px;
    box-shadow:0 30px 60px -20px rgba(0,0,0,.4);transform:translateY(12px);transition:transform .2s ease;
    max-height:90vh;overflow-y:auto}
.sf-overlay.show .sf-modal{transform:none}
.sf-modal h3{font-family:var(--fd);font-size:18px;margin-bottom:6px}
.sf-modal p{font-size:13.5px;color:var(--admin-text-light);margin-bottom:14px}
.sf-modal input{width:100%;padding:12px 14px;border:1.5px solid var(--admin-border);border-radius:11px;
    font-family:var(--fb);font-size:14px;color:var(--admin-text)}
.sf-modal input:focus{border-color:var(--admin-primary);outline:none;box-shadow:0 0 0 4px rgba(42,92,56,.1)}
.sf-modal input[readonly]{background:var(--admin-bg);color:var(--admin-text-light);cursor:default}
.sf-modal .form-group{margin-bottom:16px}
.sf-modal .sf-hint{font-size:12px;color:var(--admin-text-light);margin-top:6px;margin-bottom:0}
.sf-modal-actions{display:flex;gap:10px;margin-top:16px;justify-content:flex-end}

.sf-toast{position:fixed;bottom:26px;left:50%;transform:translate(-50%,20px);z-index:500;
    background:var(--admin-red);color:#fff;padding:13px 22px;border-radius:12px;font-weight:600;font-size:14px;
    box-shadow:0 16px 34px -16px rgba(217,83,79,.8);opacity:0;pointer-events:none;transition:opacity .25s,transform .25s}
.sf-toast.show{opacity:1;transform:translate(-50%,0)}
.sf-toast.ok{background:var(--admin-primary);box-shadow:0 16px 34px -16px rgba(42,92,56,.8)}
</style>

<c:if test="${not empty flashSuccess}"><div class="sf-flash success"><c:out value="${flashSuccess}"/></div></c:if>
<c:if test="${not empty flashError}"><div class="sf-flash error"><c:out value="${flashError}"/></div></c:if>

<div class="card">
    <nav class="admin-tabs" aria-label="Lọc theo vai trò">
        <a href="${ctx}/admin/nhan-vien" class="admin-tab ${empty roleFilter ? 'active' : ''}">Tất cả <span class="admin-tab-count">${totalAllStaff}</span></a>
        <c:forEach var="entry" items="${roles}">
            <a href="${ctx}/admin/nhan-vien?role=${entry.key}" class="admin-tab ${roleFilter == entry.key ? 'active' : ''}">
                <c:out value="${entry.value}"/> <span class="admin-tab-count">${roleCounts[entry.key]}</span></a>
        </c:forEach>
    </nav>

    <div class="sf-count">
        <span>Tìm thấy <b><c:out value="${totalStaff}"/></b> nhân viên</span>
        <button type="button" class="btn btn-primary" id="openCreateStaffBtn"><i class="fa-solid fa-user-plus"></i> Thêm nhân viên</button>
    </div>

    <c:choose>
        <c:when test="${not empty staffList}">
            <div class="table-responsive">
                <table class="admin-table" id="staffTable">
                    <thead>
                        <tr>
                            <th>Nhân viên</th>
                            <th>Vai trò</th>
                            <th>Trạng thái</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="s" items="${staffList}">
                            <tr data-staff-id="${s.staffId}">
                                <td class="sf-name-cell">
                                    <b><c:out value="${s.fullName}"/></b>
                                    <span>@<c:out value="${s.username}"/></span>
                                </td>
                                <td class="js-role-cell"><span class="badge badge-ROLE"><c:out value="${roles[s.role]}"/></span></td>
                                <td class="js-active-cell">
                                    <span class="badge badge-${s.active ? 'ACTIVE' : 'INACTIVE'}">${s.active ? 'Đang hoạt động' : 'Đã khóa'}</span>
                                </td>
                                <td>
                                    <div class="sf-actions">
                                        <button type="button" class="btn btn-outline js-edit-staff"
                                                data-id="${s.staffId}" data-username="<c:out value="${s.username}"/>"
                                                data-fullname="<c:out value="${s.fullName}"/>" data-role="${s.role}">Sửa</button>
                                        <button type="button" class="btn ${s.active ? 'btn-danger' : 'btn-primary'} js-toggle-active"
                                                data-id="${s.staffId}" data-active="${s.active}">${s.active ? 'Khóa' : 'Mở khóa'}</button>
                                        <button type="button" class="btn btn-outline js-reset-pw"
                                                data-id="${s.staffId}" data-name="<c:out value="${s.fullName}"/>">Đổi mật khẩu</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <div class="sf-empty">
                <i class="fa-regular fa-folder-open"></i>
                <p>Chưa có nhân viên nào.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<!-- Modal Thêm/Sửa nhân viên — dùng chung, đè ngay trên trang này, không điều hướng -->
<div class="sf-overlay" id="staffFormOverlay" hidden>
    <div class="sf-modal" role="dialog" aria-modal="true" aria-labelledby="staffFormTitle">
        <h3 id="staffFormTitle">Thêm nhân viên</h3>
        <form method="post" id="staffForm">
            <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
            <input type="hidden" name="staffId" id="sfStaffId" value="">

            <div class="form-group">
                <label>Tên đăng nhập</label>
                <input type="text" name="username" id="sfUsername" minlength="3" maxlength="32" placeholder="VD: nhanvien01">
                <p class="sf-hint" id="sfUsernameHint">3-32 ký tự: chữ, số, dấu chấm/gạch dưới/gạch ngang.</p>
            </div>

            <div class="form-group">
                <label>Họ tên</label>
                <input type="text" name="fullName" id="sfFullName" required placeholder="VD: Nguyễn Văn A">
            </div>

            <div class="form-group">
                <label>Vai trò</label>
                <select name="role" id="sfRole" class="form-control" required>
                    <c:forEach var="entry" items="${roles}">
                        <option value="${entry.key}"><c:out value="${entry.value}"/></option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group" id="sfPasswordGroup">
                <label>Mật khẩu</label>
                <input type="password" name="password" id="sfPassword" minlength="8"
                       autocomplete="new-password" placeholder="Tối thiểu 8 ký tự">
            </div>

            <div class="sf-modal-actions">
                <button type="button" class="btn btn-outline" id="staffFormDismiss">Hủy</button>
                <button type="submit" class="btn btn-primary" id="sfSubmitBtn">Tạo tài khoản</button>
            </div>
        </form>
    </div>
</div>

<!-- Modal đổi mật khẩu -->
<div class="sf-overlay" id="pwOverlay" hidden>
    <div class="sf-modal" role="dialog" aria-modal="true" aria-labelledby="pwTitle">
        <h3 id="pwTitle">Đổi mật khẩu — <span id="pwStaffName"></span></h3>
        <p>Đặt mật khẩu mới cho nhân viên này (tối thiểu 8 ký tự).</p>
        <input type="password" id="pwNewPassword" placeholder="Mật khẩu mới" autocomplete="new-password">
        <div class="sf-modal-actions">
            <button type="button" class="btn btn-outline" id="pwDismiss">Hủy</button>
            <button type="button" class="btn btn-primary" id="pwConfirm">Đặt mật khẩu mới</button>
        </div>
    </div>
</div>

<div class="sf-toast" id="sfToast" role="status" aria-live="polite" hidden></div>

<script>
(function () {
    var ctx = '${ctx}';
    var csrf = '${sessionScope._csrf}';
    var toast = document.getElementById('sfToast');

    function showToast(msg, ok) {
        toast.textContent = msg;
        toast.className = 'sf-toast show' + (ok ? ' ok' : '');
        toast.hidden = false;
        clearTimeout(toast._t);
        toast._t = setTimeout(function () { toast.className = 'sf-toast'; }, 3200);
    }

    function postForm(url, params) {
        var body = new URLSearchParams(params);
        body.set('_csrf', csrf);
        return fetch(url, {
            method: 'POST',
            headers: { 'X-Requested-With': 'XMLHttpRequest', 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body.toString()
        }).then(function (r) { return r.json().then(function (j) { return { ok: r.ok, data: j }; }); });
    }

    function openOverlay(el) {
        el.hidden = false;
        requestAnimationFrame(function () { el.classList.add('show'); });
    }
    function closeOverlay(el) {
        el.classList.remove('show');
        setTimeout(function () { el.hidden = true; }, 200);
    }

    // ==================== Modal Thêm / Sửa nhân viên ====================
    var staffOverlay = document.getElementById('staffFormOverlay');
    var staffForm = document.getElementById('staffForm');
    var sfTitle = document.getElementById('staffFormTitle');
    var sfStaffId = document.getElementById('sfStaffId');
    var sfUsername = document.getElementById('sfUsername');
    var sfUsernameHint = document.getElementById('sfUsernameHint');
    var sfFullName = document.getElementById('sfFullName');
    var sfRole = document.getElementById('sfRole');
    var sfPasswordGroup = document.getElementById('sfPasswordGroup');
    var sfPassword = document.getElementById('sfPassword');
    var sfSubmitBtn = document.getElementById('sfSubmitBtn');

    function openStaffForm(mode, data) {
        data = data || {};
        sfPassword.value = '';
        if (mode === 'create') {
            sfTitle.textContent = 'Thêm nhân viên';
            staffForm.action = ctx + '/admin/nhan-vien/them';
            sfStaffId.value = '';
            sfUsername.value = data.username || '';
            sfUsername.readOnly = false;
            sfUsername.required = true;
            sfUsernameHint.style.display = '';
            sfPasswordGroup.style.display = '';
            sfPassword.required = true;
            sfSubmitBtn.textContent = 'Tạo tài khoản';
        } else {
            sfTitle.textContent = 'Sửa nhân viên';
            staffForm.action = ctx + '/admin/nhan-vien/sua';
            sfStaffId.value = data.id || '';
            sfUsername.value = '@' + (data.username || '');
            sfUsername.readOnly = true;
            sfUsername.required = false;
            sfUsernameHint.style.display = 'none';
            sfPasswordGroup.style.display = 'none';
            sfPassword.required = false;
            sfSubmitBtn.textContent = 'Lưu thay đổi';
        }
        sfFullName.value = data.fullName || '';
        if (data.role) sfRole.value = data.role;
        openOverlay(staffOverlay);
        setTimeout(function () { (mode === 'create' ? sfUsername : sfFullName).focus(); }, 60);
    }
    function closeStaffForm() { closeOverlay(staffOverlay); }

    document.getElementById('openCreateStaffBtn').addEventListener('click', function () { openStaffForm('create'); });
    document.querySelectorAll('.js-edit-staff').forEach(function (btn) {
        btn.addEventListener('click', function () {
            openStaffForm('edit', {
                id: btn.dataset.id, username: btn.dataset.username,
                fullName: btn.dataset.fullname, role: btn.dataset.role
            });
        });
    });
    document.getElementById('staffFormDismiss').addEventListener('click', closeStaffForm);
    staffOverlay.addEventListener('click', function (e) { if (e.target === staffOverlay) closeStaffForm(); });

    // Mở lại đúng modal + đúng dữ liệu vừa nhập nếu server redirect về sau lỗi validate
    // (xem AdminStaffController — không có "trang lỗi" riêng, luôn quay về chính trang này).
    (function reopenOnError() {
        var params = new URLSearchParams(location.search);
        var formOpen = params.get('formOpen');
        if (formOpen === 'them') {
            openStaffForm('create', { username: params.get('username'), fullName: params.get('fullName'), role: params.get('role') });
        } else if (formOpen === 'sua') {
            openStaffForm('edit', {
                id: params.get('editId'), username: params.get('username'),
                fullName: params.get('fullName'), role: params.get('role')
            });
        }
        if (formOpen) history.replaceState(null, '', ctx + '/admin/nhan-vien');
    })();

    // ==================== Khóa / Mở khóa ====================
    document.querySelectorAll('.js-toggle-active').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = btn.dataset.id, active = btn.dataset.active === 'true';
            btn.disabled = true;
            postForm(ctx + '/admin/nhan-vien/khoa-mo', { id: id, active: active }).then(function (res) {
                btn.disabled = false;
                if (res.ok && res.data.success) {
                    var row = document.querySelector('#staffTable tr[data-staff-id="' + id + '"]');
                    var newActive = !active;
                    row.querySelector('.js-active-cell').innerHTML =
                        '<span class="badge badge-' + (newActive ? 'ACTIVE' : 'INACTIVE') + '">'
                        + (newActive ? 'Đang hoạt động' : 'Đã khóa') + '</span>';
                    btn.dataset.active = newActive;
                    btn.textContent = newActive ? 'Khóa' : 'Mở khóa';
                    btn.className = 'btn ' + (newActive ? 'btn-danger' : 'btn-primary') + ' js-toggle-active';
                    showToast(res.data.message, true);
                } else {
                    showToast(res.data.message || 'Không thể cập nhật.', false);
                }
            }).catch(function () { btn.disabled = false; showToast('Lỗi kết nối, vui lòng thử lại.', false); });
        });
    });

    // ==================== Đổi mật khẩu ====================
    var pwOverlay = document.getElementById('pwOverlay');
    var pwNameEl = document.getElementById('pwStaffName');
    var pwInput = document.getElementById('pwNewPassword');
    var pwTargetId = null;

    document.querySelectorAll('.js-reset-pw').forEach(function (btn) {
        btn.addEventListener('click', function () {
            pwTargetId = btn.dataset.id;
            pwNameEl.textContent = btn.dataset.name;
            pwInput.value = '';
            openOverlay(pwOverlay);
            setTimeout(function () { pwInput.focus(); }, 60);
        });
    });

    function closePwModal() { closeOverlay(pwOverlay); pwTargetId = null; }
    document.getElementById('pwDismiss').addEventListener('click', closePwModal);
    pwOverlay.addEventListener('click', function (e) { if (e.target === pwOverlay) closePwModal(); });

    document.getElementById('pwConfirm').addEventListener('click', function () {
        var pw = pwInput.value;
        if (!pw || pw.length < 8) { pwInput.focus(); showToast('Mật khẩu phải có ít nhất 8 ký tự.', false); return; }
        var btn = this;
        btn.disabled = true;
        postForm(ctx + '/admin/nhan-vien/doi-mat-khau', { id: pwTargetId, newPassword: pw }).then(function (res) {
            btn.disabled = false;
            if (res.ok && res.data.success) {
                closePwModal();
                showToast(res.data.message, true);
            } else {
                showToast(res.data.message || 'Không thể đổi mật khẩu.', false);
            }
        }).catch(function () { btn.disabled = false; showToast('Lỗi kết nối, vui lòng thử lại.', false); });
    });

    // Escape đóng bất kỳ modal nào đang mở
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape') return;
        if (!staffOverlay.hidden) closeStaffForm();
        else if (!pwOverlay.hidden) closePwModal();
    });
})();
</script>

<jsp:include page="/WEB-INF/views/admin/layout/footer.jsp" />
