/**
 * Nhiệt Đới Xanh — Trang /checkout.
 * - GPS: chỉ xin quyền khi user bấm nút "Lấy vị trí hiện tại" (không tự động).
 * - Chặn double-submit phía UI (server vẫn là chốt chặn chính qua checkoutToken).
 * - Không gọi API ngoài/reverse geocoding, không dùng API key — chỉ hiển thị lat/lng thô.
 */
(function () {
    'use strict';

    function setGpsState(el, message, isSuccess) {
        if (!el) return;
        el.textContent = message || '';
        el.classList.toggle('is-success', !!isSuccess);
    }

    function showGpsCard(latField, lngField) {
        const card = document.getElementById('gpsResultCard');
        const latText = document.getElementById('gpsLatText');
        const lngText = document.getElementById('gpsLngText');
        if (!card) return;
        if (latText) latText.textContent = latField.value;
        if (lngText) lngText.textContent = lngField.value;
        card.classList.remove('is-hidden');
    }

    function hideGpsCard() {
        const card = document.getElementById('gpsResultCard');
        if (card) card.classList.add('is-hidden');
    }

    function showGpsError(message) {
        const errEl = document.getElementById('gpsErrorText');
        if (!errEl) return;
        if (!message) {
            errEl.hidden = true;
            errEl.textContent = '';
            return;
        }
        errEl.textContent = message;
        errEl.hidden = false;
    }

    function initGps() {
        const gpsBtn = document.getElementById('gpsLocateBtn');
        const gpsState = document.getElementById('gpsStateText');
        const clearBtn = document.getElementById('gpsClearBtn');
        const latField = document.getElementById('latitudeField');
        const lngField = document.getElementById('longitudeField');
        if (!gpsBtn || !latField || !lngField) return;

        gpsBtn.addEventListener('click', () => {
            if (!('geolocation' in navigator)) {
                showGpsError('Trình duyệt của bạn không hỗ trợ định vị GPS. Bạn vẫn có thể nhập địa chỉ thủ công.');
                return;
            }

            const originalHtml = gpsBtn.innerHTML;
            gpsBtn.disabled = true;
            gpsBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lấy vị trí...';
            setGpsState(gpsState, 'Đang lấy vị trí...', false);
            showGpsError(null);

            navigator.geolocation.getCurrentPosition(
                (position) => {
                    latField.value = position.coords.latitude;
                    lngField.value = position.coords.longitude;
                    gpsBtn.disabled = false;
                    gpsBtn.innerHTML = originalHtml;
                    setGpsState(gpsState, 'Đã lấy vị trí hiện tại.', true);
                    showGpsCard(latField, lngField);
                },
                (error) => {
                    gpsBtn.disabled = false;
                    gpsBtn.innerHTML = originalHtml;
                    setGpsState(gpsState, 'Chưa lấy vị trí.', false);
                    if (error.code === error.PERMISSION_DENIED) {
                        showGpsError('Không lấy được vị trí. Bạn vẫn có thể nhập địa chỉ thủ công.');
                    } else if (error.code === error.TIMEOUT) {
                        showGpsError('Lấy vị trí quá thời gian chờ. Bạn vẫn có thể nhập địa chỉ thủ công.');
                    } else {
                        showGpsError('Không lấy được vị trí. Bạn vẫn có thể nhập địa chỉ thủ công.');
                    }
                },
                { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
            );
        });

        if (clearBtn) {
            clearBtn.addEventListener('click', () => {
                latField.value = '';
                lngField.value = '';
                hideGpsCard();
                showGpsError(null);
                setGpsState(gpsState, 'Chưa lấy vị trí.', false);
            });
        }
    }

    function initSavedAddressSelect() {
        const select = document.getElementById('savedAddressSelect');
        const addressIdField = document.getElementById('addressIdField');
        const latField = document.getElementById('latitudeField');
        const lngField = document.getElementById('longitudeField');
        const gpsState = document.getElementById('gpsStateText');
        if (!select) return;

        const fieldMap = {
            recipientName: document.getElementById('recipientName'),
            recipientPhone: document.getElementById('recipientPhone'),
            addressLabel: document.getElementById('addressLabel'),
            provinceCity: document.getElementById('provinceCity'),
            district: document.getElementById('district'),
            ward: document.getElementById('ward'),
            houseNumberStreet: document.getElementById('houseNumberStreet')
        };

        select.addEventListener('change', () => {
            const opt = select.options[select.selectedIndex];
            if (!opt || !opt.value) {
                if (addressIdField) addressIdField.value = '';
                return;
            }

            if (addressIdField) addressIdField.value = opt.value;
            if (fieldMap.recipientName) fieldMap.recipientName.value = opt.dataset.recipient || '';
            if (fieldMap.recipientPhone) fieldMap.recipientPhone.value = opt.dataset.phone || '';
            if (fieldMap.addressLabel) fieldMap.addressLabel.value = opt.dataset.label || 'HOME';
            if (fieldMap.provinceCity) fieldMap.provinceCity.value = opt.dataset.province || '';
            if (fieldMap.district) fieldMap.district.value = opt.dataset.district || '';
            if (fieldMap.ward) fieldMap.ward.value = opt.dataset.ward || '';
            if (fieldMap.houseNumberStreet) fieldMap.houseNumberStreet.value = opt.dataset.house || '';

            const lat = opt.dataset.lat;
            const lng = opt.dataset.lng;
            if (lat && lng && latField && lngField) {
                latField.value = lat;
                lngField.value = lng;
                showGpsCard(latField, lngField);
                setGpsState(gpsState, 'Địa chỉ này đã có tọa độ.', true);
            } else {
                if (latField) latField.value = '';
                if (lngField) lngField.value = '';
                hideGpsCard();
                setGpsState(gpsState, 'Chưa lấy vị trí.', false);
            }
        });
    }

    function initSubmitGuard() {
        const form = document.getElementById('checkoutForm');
        const submitBtn = document.getElementById('placeOrderBtn');
        if (!form || !submitBtn) return;

        form.addEventListener('submit', () => {
            // Không preventDefault — chỉ vô hiệu hóa nút để tránh double-click,
            // form submission (điều hướng trang) vẫn tiếp tục bình thường.
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang xử lý...';
        });
    }

    function initPaymentMethod() {
        const radios = document.querySelectorAll('input[name="paymentMethod"]');
        const summaryMethod = document.getElementById('summaryPaymentMethod');
        if (!radios.length) return;

        function sync() {
            let selectedValue = 'COD';
            radios.forEach((r) => {
                const label = r.closest('.checkout-payment-option');
                if (label) label.classList.toggle('is-selected', r.checked);
                if (r.checked) selectedValue = r.value;
            });
            if (summaryMethod) {
                summaryMethod.textContent = selectedValue === 'PAYOS' ? 'PayOS' : 'COD';
            }
        }

        radios.forEach((r) => r.addEventListener('change', sync));
        sync();
    }

    document.addEventListener('DOMContentLoaded', () => {
        initGps();
        initSavedAddressSelect();
        initPaymentMethod();
        initSubmitGuard();
    });
})();
