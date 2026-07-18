/**
 * Nhiệt Đới Xanh — Trang /checkout.
 * - GPS: chỉ xin quyền khi user bấm nút "Lấy vị trí hiện tại" (không tự động).
 * - Chặn double-submit phía UI (server vẫn là chốt chặn chính qua checkoutToken).
 */
(function () {
    'use strict';

    function setGpsStatus(el, message, state) {
        if (!el) return;
        el.textContent = message || '';
        el.classList.remove('is-success', 'is-error');
        if (state) el.classList.add(state);
    }

    function initGps() {
        const gpsBtn = document.getElementById('gpsLocateBtn');
        const gpsStatus = document.getElementById('gpsStatusText');
        const latField = document.getElementById('latitudeField');
        const lngField = document.getElementById('longitudeField');
        if (!gpsBtn || !latField || !lngField) return;

        gpsBtn.addEventListener('click', () => {
            if (!('geolocation' in navigator)) {
                setGpsStatus(gpsStatus, 'Trình duyệt của bạn không hỗ trợ định vị GPS. Bạn có thể nhập địa chỉ thủ công.', 'is-error');
                return;
            }

            const originalHtml = gpsBtn.innerHTML;
            gpsBtn.disabled = true;
            gpsBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang lấy vị trí...';
            setGpsStatus(gpsStatus, '', null);

            navigator.geolocation.getCurrentPosition(
                (position) => {
                    latField.value = position.coords.latitude;
                    lngField.value = position.coords.longitude;
                    gpsBtn.disabled = false;
                    gpsBtn.innerHTML = originalHtml;
                    setGpsStatus(gpsStatus, 'Đã lấy vị trí hiện tại.', 'is-success');
                },
                (error) => {
                    gpsBtn.disabled = false;
                    gpsBtn.innerHTML = originalHtml;
                    if (error.code === error.PERMISSION_DENIED) {
                        setGpsStatus(gpsStatus, 'Bạn đã từ chối chia sẻ vị trí. Bạn có thể nhập địa chỉ thủ công.', 'is-error');
                    } else if (error.code === error.TIMEOUT) {
                        setGpsStatus(gpsStatus, 'Lấy vị trí quá thời gian chờ. Vui lòng thử lại hoặc nhập địa chỉ thủ công.', 'is-error');
                    } else {
                        setGpsStatus(gpsStatus, 'Không thể lấy vị trí hiện tại. Bạn có thể nhập địa chỉ thủ công.', 'is-error');
                    }
                },
                { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
            );
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

    document.addEventListener('DOMContentLoaded', () => {
        initGps();
        initSubmitGuard();
    });
})();
