/**
 * Nhiệt Đới Xanh — Trang /checkout.
 * - GPS: chỉ xin quyền khi user bấm nút "Lấy vị trí hiện tại" (không tự động).
 * - Chặn double-submit phía UI (server vẫn là chốt chặn chính qua checkoutToken).
 * - Bản đồ Leaflet + ghim kéo-thả: chỉ hiện sau khi đã có tọa độ (GPS hoặc địa chỉ đã lưu),
 *   kéo ghim sẽ reverse-geocode qua Nominatim (OpenStreetMap, miễn phí, không cần API key)
 *   để tự điền lại Tỉnh/Thành - Quận/Huyện - Phường/Xã - Số nhà/Tên đường.
 */
(function () {
    'use strict';

    // ===== Bản đồ địa chỉ (addrMap) =====
    let addrMap = null;
    let addrMarker = null;

    function buildPinIcon() {
        return L.divIcon({
            className: '',
            html: '<div style="position:relative;width:28px;height:42px;filter:drop-shadow(0 3px 4px rgba(0,0,0,.35));transition:transform .3s cubic-bezier(.34,1.56,.64,1)">' +
                  '<svg width="28" height="42" viewBox="0 0 30 45" xmlns="http://www.w3.org/2000/svg">' +
                  '<path d="M15 0C6.7 0 0 6.7 0 15c0 11.25 15 30 15 30s15-18.75 15-30C30 6.7 23.3 0 15 0z" fill="#2A5C38"/>' +
                  '<circle cx="15" cy="14" r="6" fill="#fff"/></svg></div>',
            iconSize: [28, 42],
            iconAnchor: [14, 42],
            popupAnchor: [0, -38]
        });
    }

    function reverseGeoFillAddressFields(lat, lng, onDone) {
        const fields = {
            provinceCity: document.getElementById('provinceCity'),
            district: document.getElementById('district'),
            ward: document.getElementById('ward'),
            houseNumberStreet: document.getElementById('houseNumberStreet')
        };
        fetch('https://nominatim.openstreetmap.org/reverse?format=json&lat=' + lat + '&lon=' + lng + '&accept-language=vi&addressdetails=1')
            .then((r) => r.json())
            .then((d) => {
                const a = d.address || {};
                const houseParts = [];
                if (a.house_number) houseParts.push(a.house_number);
                if (a.road) houseParts.push(a.road);

                // Nominatim không có field cố định riêng cho Phường/Xã vs Quận/Huyện ở VN — cùng một
                // giá trị có thể nằm ở "suburb", "county" hay "city_district" tùy khu vực (đôi khi
                // "city_district" và "suburb" trả về CÙNG giá trị dùng cho cả hai cấp). Dò tiền tố
                // hành chính tiếng Việt trước (đáng tin hơn) rồi mới fallback theo thứ tự field cũ,
                // luôn loại trừ giá trị đã được dùng cho ward để tránh trùng lặp Quận/Huyện = Phường/Xã.
                const candidates = [a.quarter, a.suburb, a.city_district, a.county, a.town, a.village, a.neighbourhood].filter(Boolean);
                const wardPrefixes = ['Phường ', 'Xã ', 'Thị trấn '];
                const districtPrefixes = ['Quận ', 'Huyện ', 'Thị xã ', 'Thành phố '];

                let ward = candidates.find((c) => wardPrefixes.some((p) => c.startsWith(p)));
                let district = candidates.find((c) => c !== ward && districtPrefixes.some((p) => c.startsWith(p)));

                if (!ward) ward = a.quarter || a.village || a.town || a.neighbourhood || '';
                if (!district) district = [a.county, a.city_district, a.suburb].find((c) => c && c !== ward) || '';

                const city = a.city || a.state || a.province || '';

                // Cấp thôn/ấp (neighbourhood) không có field riêng trong form — nếu chưa dùng cho ward
                // thì gộp vào số nhà/tên đường cho đầy đủ thông tin (giống cách PureNut ghép 1 dòng).
                if (a.neighbourhood && a.neighbourhood !== ward) houseParts.push(a.neighbourhood);

                if (houseParts.length && fields.houseNumberStreet) fields.houseNumberStreet.value = houseParts.join(', ');
                if (ward && fields.ward) fields.ward.value = ward;
                if (district && fields.district) fields.district.value = district;
                if (city && fields.provinceCity) fields.provinceCity.value = city;

                if (addrMarker) {
                    const short = (a.road || '') + (a.quarter ? ', ' + a.quarter : '');
                    addrMarker.bindPopup('<b>' + (short || 'Vị trí đã chọn') + '</b><br><small>Kéo ghim để chỉnh vị trí</small>').openPopup();
                }
                if (onDone) onDone(true);
            })
            .catch((err) => {
                console.error('[checkout] Reverse-geocode thất bại:', err);
                if (onDone) onDone(false);
            });
    }

    function setAddrMapVisible(visible) {
        const mapDiv = document.getElementById('addrMap');
        const hint = document.getElementById('addrMapHint');
        if (mapDiv) mapDiv.classList.toggle('is-hidden', !visible);
        if (hint) hint.classList.toggle('is-hidden', !visible);
    }

    function showAddrMap(lat, lng) {
        if (typeof L === 'undefined') {
            console.error('[checkout] Leaflet (L) chưa được tải — không thể hiện bản đồ chọn vị trí.');
            return;
        }
        setAddrMapVisible(true);

        if (!addrMap) {
            addrMap = L.map('addrMap').setView([lat, lng], 17);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 19,
                attribution: '&copy; OpenStreetMap'
            }).addTo(addrMap);
            addrMarker = L.marker([lat, lng], { draggable: true, icon: buildPinIcon() }).addTo(addrMap);
            addrMarker.on('dragend', () => {
                const pos = addrMarker.getLatLng();
                applyCoords(pos.lat, pos.lng);
                reverseGeoFillAddressFields(pos.lat, pos.lng);
            });
        } else {
            addrMap.setView([lat, lng], 17);
            addrMarker.setLatLng([lat, lng]);
        }
        // Leaflet cần invalidateSize sau khi container vừa hiện ra (từ display:none).
        setTimeout(() => { if (addrMap) addrMap.invalidateSize(); }, 100);
    }

    function applyCoords(lat, lng) {
        const latField = document.getElementById('latitudeField');
        const lngField = document.getElementById('longitudeField');
        if (latField) latField.value = lat;
        if (lngField) lngField.value = lng;
        showGpsCard(latField, lngField);
    }

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
                    const lat = position.coords.latitude;
                    const lng = position.coords.longitude;
                    latField.value = lat;
                    lngField.value = lng;
                    gpsBtn.disabled = false;
                    gpsBtn.innerHTML = originalHtml;
                    setGpsState(gpsState, 'Đã lấy vị trí hiện tại. Đang tự điền địa chỉ...', true);
                    showGpsCard(latField, lngField);
                    showAddrMap(lat, lng);
                    // Tự điền địa chỉ ngay từ tọa độ GPS — không chỉ chờ user kéo ghim.
                    reverseGeoFillAddressFields(lat, lng, (success) => {
                        setGpsState(gpsState, success
                            ? 'Đã tự điền địa chỉ. Kéo ghim trên bản đồ để chỉnh lại nếu cần.'
                            : 'Đã lấy vị trí, nhưng không tự điền được địa chỉ — vui lòng nhập tay hoặc kéo ghim.', true);
                    });
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
                setAddrMapVisible(false);
            });
        }

        // Trang vừa tải với địa chỉ mặc định đã có sẵn tọa độ (prefillLat/prefillLng) — hiện bản đồ ngay.
        if (latField.value && lngField.value) {
            showAddrMap(parseFloat(latField.value), parseFloat(lngField.value));
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
                setGpsState(gpsState, 'Địa chỉ này đã có tọa độ. Kéo ghim trên bản đồ để chỉnh lại nếu cần.', true);
                showAddrMap(parseFloat(lat), parseFloat(lng));
            } else {
                if (latField) latField.value = '';
                if (lngField) lngField.value = '';
                hideGpsCard();
                setGpsState(gpsState, 'Chưa lấy vị trí.', false);
                setAddrMapVisible(false);
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

    // Cho phép trang khác dùng chung checkout.js (VD: account/addresses.jsp khi bấm "Sửa" một
    // địa chỉ đã có tọa độ sẵn) gọi lại đúng các hàm hiện bản đồ/card GPS mà không phải chép code.
    window.NDXAddrMap = { showAddrMap, setAddrMapVisible, showGpsCard, hideGpsCard, setGpsState };
})();
