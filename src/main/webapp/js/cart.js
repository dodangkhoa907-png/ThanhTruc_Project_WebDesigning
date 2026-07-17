/**
 * Nhiệt Đới Xanh — Giỏ hàng (AJAX add-to-cart, badge, toast).
 * Không lưu/tin bất kỳ giá tiền hay userId nào ở client — server luôn đọc lại
 * từ session + database.
 */
(function () {
    'use strict';

    const CONTEXT_PATH = (function () {
        // Suy ra context path từ vị trí file này: /<ctx>/js/cart.js
        const script = document.currentScript || document.querySelector('script[src*="cart.js"]');
        if (!script) return '';
        const src = script.getAttribute('src') || '';
        const idx = src.indexOf('/js/cart.js');
        return idx > 0 ? src.substring(0, idx) : '';
    })();

    function getCsrfToken() {
        const meta = document.querySelector('meta[name="csrf-token"]');
        return meta ? meta.getAttribute('content') : '';
    }

    function showToast(message, isError) {
        const stack = document.getElementById('toastStack');
        if (!stack) return;
        const toast = document.createElement('div');
        toast.className = 'toast' + (isError ? ' toast-error' : '');
        toast.innerHTML = '<i class="fa-solid ' + (isError ? 'fa-circle-exclamation' : 'fa-circle-check') + '"></i><span></span>';
        toast.querySelector('span').textContent = message;
        stack.appendChild(toast);
        setTimeout(() => {
            toast.classList.add('toast-out');
            setTimeout(() => toast.remove(), 320);
        }, 3200);
    }

    function updateBadge(count, animate) {
        const badge = document.getElementById('navCartBadge');
        if (!badge) return;
        badge.textContent = count;
        if (count > 0) {
            badge.removeAttribute('hidden');
        } else {
            badge.setAttribute('hidden', 'hidden');
        }
        if (animate) {
            badge.classList.remove('pulse');
            // force reflow để animation chạy lại
            void badge.offsetWidth;
            badge.classList.add('pulse');
        }
    }

    function refreshCartCount() {
        fetch(CONTEXT_PATH + '/cart/count', {
            headers: { 'X-Requested-With': 'XMLHttpRequest' }
        })
            .then(r => r.json())
            .then(data => {
                if (data && typeof data.cartCount === 'number') updateBadge(data.cartCount, false);
            })
            .catch(() => {});
    }

    function addToCart(variantId, quantity, triggerBtn) {
        if (!variantId) return;

        const originalHtml = triggerBtn ? triggerBtn.innerHTML : null;
        if (triggerBtn) {
            triggerBtn.disabled = true;
            triggerBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang thêm...';
        }

        const body = new URLSearchParams();
        body.set('variantId', String(variantId));
        body.set('quantity', String(quantity || 1));
        body.set('_csrf', getCsrfToken());

        fetch(CONTEXT_PATH + '/cart/add', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: body.toString()
        })
            .then(r => r.json().then(data => ({ status: r.status, data })))
            .then(({ status, data }) => {
                if (status === 401 && data && data.requireLogin) {
                    showToast('Vui lòng đăng nhập để thêm vào giỏ hàng.', true);
                    setTimeout(() => {
                        window.location.href = CONTEXT_PATH + (data.loginUrl ? data.loginUrl.replace(CONTEXT_PATH, '') : '/login');
                    }, 900);
                    return;
                }
                if (data && data.success) {
                    showToast(data.message || 'Đã thêm vào giỏ hàng.', false);
                    if (typeof data.cartCount === 'number') updateBadge(data.cartCount, true);
                } else {
                    showToast((data && data.message) || 'Không thể thêm vào giỏ hàng.', true);
                }
            })
            .catch(() => {
                showToast('Lỗi kết nối, vui lòng thử lại.', true);
            })
            .finally(() => {
                if (triggerBtn) {
                    triggerBtn.disabled = false;
                    triggerBtn.innerHTML = originalHtml;
                }
            });
    }

    function postForm(url, params) {
        const body = new URLSearchParams();
        Object.keys(params).forEach(key => {
            const value = params[key];
            if (Array.isArray(value)) {
                value.forEach(v => body.append(key, v));
            } else {
                body.set(key, String(value));
            }
        });
        body.set('_csrf', getCsrfToken());

        return fetch(CONTEXT_PATH + url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: body.toString()
        }).then(r => r.json().then(data => ({ status: r.status, data })));
    }

    function formatVnd(n) {
        return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + 'đ';
    }

    /**
     * Điều khiển trang /cart: chọn item, chọn tất cả, tăng/giảm/nhập số lượng,
     * xóa item, xóa nhiều item, chuẩn bị checkout.
     *
     * QUAN TRỌNG: mọi tính tiền ở đây CHỈ để hiển thị UX ngay lập tức. Nguồn sự
     * thật luôn là server — mỗi thao tác ghi (update/remove/checkout) đều gọi
     * lại backend và backend tự tính lại từ DB, không tin bất kỳ số nào từ đây.
     */
    function initCartPage() {
        const list = document.getElementById('cartItemsList');
        if (!list) return; // không phải trang /cart

        const selectAllCheckbox = document.getElementById('selectAllCheckbox');
        const removeSelectedBtn = document.getElementById('removeSelectedBtn');
        const checkoutBtn = document.getElementById('checkoutBtn');
        const checkoutBtnMobile = document.getElementById('checkoutBtnMobile');

        function getCards() {
            return Array.from(list.querySelectorAll('.cart-item-card'));
        }

        function getAvailableCheckboxes() {
            return Array.from(list.querySelectorAll('.cart-item-checkbox:not(:disabled)'));
        }

        function recalcSummary() {
            let selectedCount = 0;
            let total = 0;

            getCards().forEach(card => {
                const checkbox = card.querySelector('.cart-item-checkbox');
                const unitPrice = parseFloat(card.dataset.unitPrice) || 0;
                const qtyInput = card.querySelector('.cart-qty-input');
                const qty = qtyInput ? (parseInt(qtyInput.value, 10) || 0) : 0;

                if (checkbox && checkbox.checked && !checkbox.disabled) {
                    selectedCount++;
                    total += unitPrice * qty;
                }
            });

            const summarySelectedCount = document.getElementById('summarySelectedCount');
            const summarySubtotal = document.getElementById('summarySubtotal');
            const summaryTotal = document.getElementById('summaryTotal');
            const mobileSelectedCount = document.getElementById('mobileSelectedCount');
            const mobileTotal = document.getElementById('mobileTotal');

            if (summarySelectedCount) summarySelectedCount.textContent = selectedCount;
            if (summarySubtotal) summarySubtotal.textContent = formatVnd(total);
            if (summaryTotal) summaryTotal.textContent = formatVnd(total);
            if (mobileSelectedCount) mobileSelectedCount.textContent = selectedCount + ' sản phẩm';
            if (mobileTotal) mobileTotal.textContent = formatVnd(total);

            const hasSelection = selectedCount > 0;
            if (checkoutBtn) checkoutBtn.disabled = !hasSelection;
            if (checkoutBtnMobile) checkoutBtnMobile.disabled = !hasSelection;
            if (removeSelectedBtn) removeSelectedBtn.disabled = !hasSelection;

            const available = getAvailableCheckboxes();
            if (selectAllCheckbox) {
                const allChecked = available.length > 0 && available.every(cb => cb.checked);
                selectAllCheckbox.checked = allChecked;
                selectAllCheckbox.indeterminate = !allChecked && available.some(cb => cb.checked);
            }
        }

        function getSelectedIds() {
            return getCards()
                .map(card => {
                    const checkbox = card.querySelector('.cart-item-checkbox');
                    return (checkbox && checkbox.checked && !checkbox.disabled) ? card.dataset.cartItemId : null;
                })
                .filter(Boolean);
        }

        // ===== Chọn từng item =====
        list.addEventListener('change', (e) => {
            if (e.target.classList.contains('cart-item-checkbox')) {
                recalcSummary();
            }
        });

        // ===== Chọn tất cả / bỏ chọn tất cả =====
        if (selectAllCheckbox) {
            selectAllCheckbox.addEventListener('change', () => {
                getAvailableCheckboxes().forEach(cb => { cb.checked = selectAllCheckbox.checked; });
                recalcSummary();
            });
        }

        // ===== Tăng/giảm/nhập số lượng =====
        function clampQty(v) {
            v = parseInt(v, 10);
            if (isNaN(v)) v = 1;
            return Math.min(99, Math.max(1, v));
        }

        const quantityDebounce = new Map();

        function sendQuantityUpdate(card, qtyInput) {
            const cartItemId = card.dataset.cartItemId;
            const quantity = clampQty(qtyInput.value);
            qtyInput.value = quantity;
            recalcSummary();

            postForm('/cart/update', { cartItemId: cartItemId, quantity: quantity })
                .then(({ status, data }) => {
                    if (data && data.success) {
                        if (typeof data.cartCount === 'number') updateBadge(data.cartCount, true);
                    } else {
                        showToast((data && data.message) || 'Không thể cập nhật số lượng.', true);
                        // Rollback an toàn: tải lại trang để đồng bộ với DB thật.
                        window.location.reload();
                    }
                })
                .catch(() => {
                    showToast('Lỗi kết nối, vui lòng thử lại.', true);
                    window.location.reload();
                });
        }

        list.addEventListener('click', (e) => {
            const card = e.target.closest('.cart-item-card');
            if (!card) return;
            const qtyInput = card.querySelector('.cart-qty-input');
            if (!qtyInput) return;

            if (e.target.closest('.cart-qty-minus')) {
                qtyInput.value = clampQty(qtyInput.value) - 1 < 1 ? 1 : clampQty(qtyInput.value) - 1;
                sendQuantityUpdate(card, qtyInput);
            } else if (e.target.closest('.cart-qty-plus')) {
                qtyInput.value = clampQty(qtyInput.value) + 1 > 99 ? 99 : clampQty(qtyInput.value) + 1;
                sendQuantityUpdate(card, qtyInput);
            } else if (e.target.closest('.cart-item-remove-btn')) {
                removeItem(card);
            }
        });

        list.addEventListener('change', (e) => {
            if (!e.target.classList.contains('cart-qty-input')) return;
            const card = e.target.closest('.cart-item-card');
            if (!card) return;
            sendQuantityUpdate(card, e.target);
        });

        // Debounce khi nhập tay (nhấn giữ số/gõ nhiều ký tự) — chỉ gửi request sau khi ngừng gõ 500ms.
        list.addEventListener('input', (e) => {
            if (!e.target.classList.contains('cart-qty-input')) return;
            const card = e.target.closest('.cart-item-card');
            if (!card) return;
            const cartItemId = card.dataset.cartItemId;

            recalcSummary();

            if (quantityDebounce.has(cartItemId)) clearTimeout(quantityDebounce.get(cartItemId));
            quantityDebounce.set(cartItemId, setTimeout(() => {
                sendQuantityUpdate(card, e.target);
                quantityDebounce.delete(cartItemId);
            }, 500));
        });

        // ===== Xóa 1 item =====
        function removeItem(card) {
            const cartItemId = card.dataset.cartItemId;
            card.style.opacity = '0.5';
            card.style.pointerEvents = 'none';

            postForm('/cart/remove', { cartItemId: cartItemId })
                .then(({ status, data }) => {
                    if (data && data.success) {
                        card.remove();
                        showToast(data.message || 'Đã xóa sản phẩm khỏi giỏ hàng.', false);
                        if (typeof data.cartCount === 'number') updateBadge(data.cartCount, true);
                        recalcSummary();
                        if (getCards().length === 0) window.location.reload();
                    } else {
                        showToast((data && data.message) || 'Không thể xóa sản phẩm.', true);
                        card.style.opacity = '';
                        card.style.pointerEvents = '';
                    }
                })
                .catch(() => {
                    showToast('Lỗi kết nối, vui lòng thử lại.', true);
                    card.style.opacity = '';
                    card.style.pointerEvents = '';
                });
        }

        // ===== Xóa các item đã chọn =====
        if (removeSelectedBtn) {
            removeSelectedBtn.addEventListener('click', () => {
                const ids = getSelectedIds();
                if (ids.length === 0) return;
                if (!window.confirm('Xóa ' + ids.length + ' sản phẩm đã chọn khỏi giỏ hàng?')) return;

                removeSelectedBtn.disabled = true;
                postForm('/cart/remove-selected', { cartItemIds: ids })
                    .then(({ status, data }) => {
                        if (data && data.success) {
                            showToast(data.message || 'Đã xóa sản phẩm đã chọn.', false);
                            if (typeof data.cartCount === 'number') updateBadge(data.cartCount, true);
                            window.location.reload();
                        } else {
                            showToast((data && data.message) || 'Không thể xóa sản phẩm đã chọn.', true);
                            removeSelectedBtn.disabled = false;
                        }
                    })
                    .catch(() => {
                        showToast('Lỗi kết nối, vui lòng thử lại.', true);
                        removeSelectedBtn.disabled = false;
                    });
            });
        }

        // ===== Tiến hành thanh toán =====
        function submitCheckoutPrepare(triggerBtn) {
            const ids = getSelectedIds();
            if (ids.length === 0) {
                showToast('Vui lòng chọn ít nhất một sản phẩm để thanh toán.', true);
                return;
            }

            const originalHtml = triggerBtn.innerHTML;
            triggerBtn.disabled = true;
            triggerBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';

            postForm('/checkout/prepare', { cartItemIds: ids })
                .then(({ status, data }) => {
                    if (status === 401 && data && data.requireLogin) {
                        showToast('Vui lòng đăng nhập để tiếp tục.', true);
                        setTimeout(() => { window.location.href = CONTEXT_PATH + '/login'; }, 900);
                        return;
                    }
                    if (data && data.success) {
                        showToast(data.message || 'Đã chuẩn bị thanh toán.', false);
                        setTimeout(() => {
                            window.location.href = data.redirectUrl || (CONTEXT_PATH + '/checkout');
                        }, 400);
                    } else {
                        showToast((data && data.message) || 'Không thể chuẩn bị thanh toán.', true);
                        triggerBtn.disabled = false;
                        triggerBtn.innerHTML = originalHtml;
                        // Dữ liệu giỏ hàng có thể đã đổi (hết hàng, ngừng bán) — tải lại để đồng bộ.
                        setTimeout(() => window.location.reload(), 1200);
                    }
                })
                .catch(() => {
                    showToast('Lỗi kết nối, vui lòng thử lại.', true);
                    triggerBtn.disabled = false;
                    triggerBtn.innerHTML = originalHtml;
                });
        }

        if (checkoutBtn) {
            checkoutBtn.addEventListener('click', () => submitCheckoutPrepare(checkoutBtn));
        }
        if (checkoutBtnMobile) {
            checkoutBtnMobile.addEventListener('click', () => submitCheckoutPrepare(checkoutBtnMobile));
        }

        recalcSummary();
    }

    document.addEventListener('DOMContentLoaded', refreshCartCount);

    window.NhietDoiXanhCart = {
        addToCart: addToCart,
        refreshCartCount: refreshCartCount,
        initCartPage: initCartPage
    };
})();
