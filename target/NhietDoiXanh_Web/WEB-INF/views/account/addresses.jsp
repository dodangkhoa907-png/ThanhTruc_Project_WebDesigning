<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sổ Địa Chỉ — Nhiệt Đới Xanh</title>
    <meta name="csrf-token" content="${sessionScope._csrf}">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=${initParam.assetVer}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/account.css?v=${initParam.assetVer}">
</head>

<body class="shop-page-body">

    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>

    <section class="section" style="padding-top:130px;">
        <div class="container">

            <c:if test="${not empty flashSuccess}"><div class="account-flash success"><c:out value="${flashSuccess}"/></div></c:if>
            <c:if test="${not empty flashError}"><div class="account-flash error"><c:out value="${flashError}"/></div></c:if>

            <div class="account-page-header">
                <div class="account-page-title">Sổ Địa Chỉ</div>
                <div class="account-page-subtitle">Quản lý các địa chỉ giao hàng của bạn</div>
            </div>

            <div class="account-shell">
                <%@ include file="/WEB-INF/views/common/account-sidebar.jsp" %>

                <div>
                    <div class="account-card" id="addressFormCard">
                        <div class="account-card-title">
                            <span id="addressFormTitle">${not empty formAddress.addressId ? 'Sửa địa chỉ' : 'Thêm địa chỉ mới'}</span>
                        </div>

                        <form method="post" id="addressForm"
                              action="${pageContext.request.contextPath}/account/address/${not empty formAddress.addressId ? 'update' : 'create'}">
                            <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                            <input type="hidden" name="addressId" id="addressIdField" value="${formAddress.addressId}">
                            <input type="hidden" name="latitude" id="latitudeField" value="${formAddress.latitude}">
                            <input type="hidden" name="longitude" id="longitudeField" value="${formAddress.longitude}">

                            <div class="account-field ${not empty formErrors.label ? 'has-error' : ''}">
                                <label for="label">Nhãn địa chỉ</label>
                                <select id="label" name="label">
                                    <c:set var="labelVal" value="${not empty formAddress.label ? formAddress.label : 'HOME'}"/>
                                    <option value="HOME" ${labelVal == 'HOME' ? 'selected' : ''}>Nhà riêng</option>
                                    <option value="OFFICE" ${labelVal == 'OFFICE' ? 'selected' : ''}>Công ty</option>
                                    <option value="OTHER" ${labelVal == 'OTHER' ? 'selected' : ''}>Khác</option>
                                </select>
                            </div>

                            <div class="account-field-grid">
                                <div class="account-field ${not empty formErrors.recipientName ? 'has-error' : ''}">
                                    <label for="recipientName">Người nhận <span class="required">*</span></label>
                                    <input type="text" id="recipientName" name="recipientName" maxlength="100" required value="${fn:escapeXml(formAddress.recipientName)}">
                                    <c:if test="${not empty formErrors.recipientName}"><div class="account-field-error"><c:out value="${formErrors.recipientName}"/></div></c:if>
                                </div>
                                <div class="account-field ${not empty formErrors.phone ? 'has-error' : ''}">
                                    <label for="addrPhone">Số điện thoại <span class="required">*</span></label>
                                    <input type="tel" id="addrPhone" name="phone" maxlength="15" required value="${fn:escapeXml(formAddress.phone)}">
                                    <c:if test="${not empty formErrors.phone}"><div class="account-field-error"><c:out value="${formErrors.phone}"/></div></c:if>
                                </div>
                                <div class="account-field ${not empty formErrors.provinceCity ? 'has-error' : ''}">
                                    <label for="provinceCity">Tỉnh/Thành phố <span class="required">*</span></label>
                                    <input type="text" id="provinceCity" name="provinceCity" maxlength="100" required value="${fn:escapeXml(formAddress.provinceCity)}">
                                    <c:if test="${not empty formErrors.provinceCity}"><div class="account-field-error"><c:out value="${formErrors.provinceCity}"/></div></c:if>
                                </div>
                                <div class="account-field ${not empty formErrors.district ? 'has-error' : ''}">
                                    <label for="district">Quận/Huyện <span class="required">*</span></label>
                                    <input type="text" id="district" name="district" maxlength="100" required value="${fn:escapeXml(formAddress.district)}">
                                    <c:if test="${not empty formErrors.district}"><div class="account-field-error"><c:out value="${formErrors.district}"/></div></c:if>
                                </div>
                                <div class="account-field ${not empty formErrors.ward ? 'has-error' : ''}">
                                    <label for="ward">Phường/Xã <span class="required">*</span></label>
                                    <input type="text" id="ward" name="ward" maxlength="100" required value="${fn:escapeXml(formAddress.ward)}">
                                    <c:if test="${not empty formErrors.ward}"><div class="account-field-error"><c:out value="${formErrors.ward}"/></div></c:if>
                                </div>
                                <div class="account-field ${not empty formErrors.houseNumberStreet ? 'has-error' : ''}">
                                    <label for="houseNumberStreet">Số nhà/Tên đường <span class="required">*</span></label>
                                    <input type="text" id="houseNumberStreet" name="houseNumberStreet" maxlength="300" required value="${fn:escapeXml(formAddress.houseNumberStreet)}">
                                    <c:if test="${not empty formErrors.houseNumberStreet}"><div class="account-field-error"><c:out value="${formErrors.houseNumberStreet}"/></div></c:if>
                                </div>
                            </div>

                            <c:set var="prefillLat" value="${formAddress.latitude}"/>
                            <c:set var="prefillLng" value="${formAddress.longitude}"/>

                            <div class="account-gps-row">
                                <button type="button" class="account-gps-btn" id="gpsLocateBtn">
                                    <i class="fa-solid fa-location-crosshairs"></i> Lấy vị trí hiện tại
                                </button>
                                <span class="account-gps-status ${(not empty prefillLat && not empty prefillLng) ? 'is-success' : ''}" id="gpsStateText">
                                    <c:choose>
                                        <c:when test="${not empty prefillLat && not empty prefillLng}">Địa chỉ này đã có tọa độ.</c:when>
                                        <c:otherwise>Chưa lấy vị trí.</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="checkout-gps-card ${(empty prefillLat || empty prefillLng) ? 'is-hidden' : ''}" id="gpsResultCard">
                                <div class="checkout-gps-card-head">
                                    <i class="fa-solid fa-circle-check"></i> Đã lấy vị trí hiện tại
                                </div>
                                <div class="checkout-gps-card-coords">
                                    <span>Latitude: <strong id="gpsLatText">${fn:escapeXml(prefillLat)}</strong></span>
                                    <span>Longitude: <strong id="gpsLngText">${fn:escapeXml(prefillLng)}</strong></span>
                                </div>
                                <button type="button" class="checkout-gps-clear-btn" id="gpsClearBtn">
                                    <i class="fa-solid fa-trash-can"></i> Xóa vị trí
                                </button>
                            </div>
                            <div class="checkout-gps-error" id="gpsErrorText" hidden></div>

                            <div class="checkout-addr-map ${(empty prefillLat || empty prefillLng) ? 'is-hidden' : ''}" id="addrMap"></div>
                            <div class="checkout-addr-map-hint ${(empty prefillLat || empty prefillLng) ? 'is-hidden' : ''}" id="addrMapHint">
                                <i class="fa-solid fa-hand-pointer"></i> Kéo ghim trên bản đồ để chỉnh vị trí chính xác hơn.
                            </div>

                            <div class="account-field" id="isDefaultRow" ${not empty formAddress.addressId ? 'style="display:none"' : ''}>
                                <label style="display:flex;align-items:center;gap:10px;font-weight:600;cursor:pointer;">
                                    <input type="checkbox" name="isDefault" style="width:18px;height:18px;accent-color:var(--green);">
                                    Đặt làm địa chỉ mặc định
                                </label>
                            </div>

                            <div style="display:flex;gap:12px;">
                                <button type="submit" class="btn-shop btn-shop-primary"><i class="fa-solid fa-floppy-disk"></i> Lưu địa chỉ</button>
                                <a href="${pageContext.request.contextPath}/account/addresses" class="btn-shop btn-shop-outline" id="cancelEditLink"
                                   ${empty formAddress.addressId ? 'style="display:none"' : ''}>Hủy</a>
                            </div>
                        </form>
                    </div>

                    <div class="account-card">
                        <div class="account-card-title"><span><i class="fa-solid fa-location-dot"></i> Địa chỉ đã lưu (${fn:length(addresses)})</span></div>
                        <c:choose>
                            <c:when test="${not empty addresses}">
                                <c:forEach var="addr" items="${addresses}">
                                    <div class="account-address-card ${addr['default'] ? 'is-default' : ''}"
                                         data-id="${addr.addressId}" data-label="${addr.label}"
                                         data-recipient="${fn:escapeXml(addr.recipientName)}" data-phone="${fn:escapeXml(addr.phone)}"
                                         data-province="${fn:escapeXml(addr.provinceCity)}" data-district="${fn:escapeXml(addr.district)}"
                                         data-ward="${fn:escapeXml(addr.ward)}" data-house="${fn:escapeXml(addr.houseNumberStreet)}"
                                         data-lat="${addr.latitude}" data-lng="${addr.longitude}">
                                        <div class="account-address-top">
                                            <div class="account-address-label">
                                                <i class="fa-solid ${addr.label == 'HOME' ? 'fa-house' : (addr.label == 'OFFICE' ? 'fa-building' : 'fa-location-dot')}"></i>
                                                ${addr.label == 'HOME' ? 'Nhà riêng' : (addr.label == 'OFFICE' ? 'Công ty' : 'Khác')}
                                            </div>
                                            <c:if test="${addr['default']}"><span class="account-default-badge">Mặc định</span></c:if>
                                        </div>
                                        <div class="account-address-body">
                                            <b><c:out value="${addr.recipientName}"/></b> · <c:out value="${addr.phone}"/><br>
                                            <c:out value="${addr.houseNumberStreet}"/>, <c:out value="${addr.ward}"/>, <c:out value="${addr.district}"/>, <c:out value="${addr.provinceCity}"/>
                                        </div>
                                        <div class="account-address-actions">
                                            <button type="button" class="btn-shop btn-shop-outline js-edit-address"><i class="fa-solid fa-pen"></i> Sửa</button>
                                            <c:if test="${!addr['default']}">
                                                <form method="post" action="${pageContext.request.contextPath}/account/address/default">
                                                    <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                                                    <input type="hidden" name="addressId" value="${addr.addressId}">
                                                    <button type="submit" class="btn-shop btn-shop-outline"><i class="fa-solid fa-star"></i> Đặt mặc định</button>
                                                </form>
                                            </c:if>
                                            <form method="post" action="${pageContext.request.contextPath}/account/address/delete"
                                                  onsubmit="return confirm('Xóa địa chỉ này?');">
                                                <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                                                <input type="hidden" name="addressId" value="${addr.addressId}">
                                                <button type="submit" class="btn-shop btn-shop-outline" style="border-color:#b44242;color:#b44242;"><i class="fa-solid fa-trash-can"></i> Xóa</button>
                                            </form>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <div class="shop-empty" style="padding:40px 20px">
                                    <i class="fa-solid fa-location-dot"></i>
                                    <h3>Chưa có địa chỉ nào</h3>
                                    <p>Thêm địa chỉ giao hàng đầu tiên của bạn ở form phía trên.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script src="${pageContext.request.contextPath}/js/checkout.js?v=${initParam.assetVer}"></script>
    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 50));
        navbar.classList.add('scrolled');
        const navToggle = document.getElementById('navToggle');
        const navLinks = document.getElementById('navLinks');
        navToggle.addEventListener('click', () => navLinks.classList.toggle('active'));

        const addressForm = document.getElementById('addressForm');
        const addressFormTitle = document.getElementById('addressFormTitle');
        const cancelEditLink = document.getElementById('cancelEditLink');
        const isDefaultRow = document.getElementById('isDefaultRow');
        const ctx = '${pageContext.request.contextPath}';

        document.querySelectorAll('.js-edit-address').forEach(btn => {
            btn.addEventListener('click', () => {
                const card = btn.closest('.account-address-card');
                addressForm.action = ctx + '/account/address/update';
                document.getElementById('addressIdField').value = card.dataset.id;
                document.getElementById('label').value = card.dataset.label;
                document.getElementById('recipientName').value = card.dataset.recipient;
                document.getElementById('addrPhone').value = card.dataset.phone;
                document.getElementById('provinceCity').value = card.dataset.province;
                document.getElementById('district').value = card.dataset.district;
                document.getElementById('ward').value = card.dataset.ward;
                document.getElementById('houseNumberStreet').value = card.dataset.house;
                document.getElementById('latitudeField').value = card.dataset.lat || '';
                document.getElementById('longitudeField').value = card.dataset.lng || '';

                const map = window.NDXAddrMap;
                if (card.dataset.lat && card.dataset.lng && map) {
                    const lat = parseFloat(card.dataset.lat);
                    const lng = parseFloat(card.dataset.lng);
                    const latField = document.getElementById('latitudeField');
                    const lngField = document.getElementById('longitudeField');
                    map.showGpsCard(latField, lngField);
                    map.setGpsState(document.getElementById('gpsStateText'), 'Địa chỉ này đã có tọa độ. Kéo ghim trên bản đồ để chỉnh lại nếu cần.', true);
                    map.showAddrMap(lat, lng);
                } else if (map) {
                    map.hideGpsCard();
                    map.setAddrMapVisible(false);
                    map.setGpsState(document.getElementById('gpsStateText'), 'Chưa lấy vị trí.', false);
                }

                addressFormTitle.textContent = 'Sửa địa chỉ';
                cancelEditLink.style.display = 'inline-flex';
                isDefaultRow.style.display = 'none';
                document.getElementById('addressFormCard').scrollIntoView({ behavior: 'smooth', block: 'start' });
            });
        });
    </script>
</body>
</html>
