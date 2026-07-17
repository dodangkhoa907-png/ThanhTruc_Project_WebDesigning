<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh Toán — Nhiệt Đới Xanh</title>
    <meta name="csrf-token" content="${sessionScope._csrf}">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500&display=swap"
        rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=3">
</head>

<body class="shop-page-body">

    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>

    <section class="section" style="padding-top:130px;">
        <div class="container">

            <div class="checkout-page-header">
                <div class="checkout-page-title">Thanh Toán Đơn Hàng</div>
                <div class="checkout-page-subtitle">Kiểm tra thông tin và hoàn tất đặt hàng</div>
            </div>

            <c:if test="${not empty formErrors['_general']}">
                <div class="checkout-general-error">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <c:out value="${formErrors['_general']}"/>
                </div>
            </c:if>

            <div class="checkout-layout">
                <!-- ===== FORM THÔNG TIN GIAO HÀNG ===== -->
                <div>
                    <form id="checkoutForm" action="${pageContext.request.contextPath}/checkout/place-order" method="POST" novalidate>
                        <input type="hidden" name="_csrf" value="${sessionScope._csrf}">
                        <input type="hidden" name="checkoutToken" value="${checkoutToken}">
                        <input type="hidden" name="latitude" id="latitudeField" value="${fn:escapeXml(oldLatitude)}">
                        <input type="hidden" name="longitude" id="longitudeField" value="${fn:escapeXml(oldLongitude)}">

                        <div class="checkout-card">
                            <div class="checkout-card-title"><i class="fa-solid fa-user"></i> Thông Tin Người Nhận</div>
                            <div class="checkout-field-grid">
                                <div class="checkout-field ${not empty formErrors.recipientName ? 'has-error' : ''}">
                                    <label for="recipientName">Họ và tên người nhận <span class="required">*</span></label>
                                    <input type="text" id="recipientName" name="recipientName" maxlength="100" required
                                           value="${fn:escapeXml(not empty oldRecipientName ? oldRecipientName : (not empty defaultAddress.recipientName ? defaultAddress.recipientName : sessionScope.user.fullName))}">
                                    <c:if test="${not empty formErrors.recipientName}">
                                        <div class="checkout-field-error"><c:out value="${formErrors.recipientName}"/></div>
                                    </c:if>
                                </div>
                                <div class="checkout-field ${not empty formErrors.recipientPhone ? 'has-error' : ''}">
                                    <label for="recipientPhone">Số điện thoại <span class="required">*</span></label>
                                    <input type="tel" id="recipientPhone" name="recipientPhone" maxlength="15" required
                                           value="${fn:escapeXml(not empty oldRecipientPhone ? oldRecipientPhone : (not empty defaultAddress.phone ? defaultAddress.phone : sessionScope.user.phone))}">
                                    <c:if test="${not empty formErrors.recipientPhone}">
                                        <div class="checkout-field-error"><c:out value="${formErrors.recipientPhone}"/></div>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <div class="checkout-card">
                            <div class="checkout-card-title"><i class="fa-solid fa-location-dot"></i> Địa Chỉ Giao Hàng</div>

                            <div class="checkout-field">
                                <label for="addressLabel">Nhãn địa chỉ</label>
                                <select id="addressLabel" name="addressLabel">
                                    <c:set var="labelVal" value="${not empty oldAddressLabel ? oldAddressLabel : 'HOME'}"/>
                                    <option value="HOME" ${labelVal == 'HOME' ? 'selected' : ''}>Nhà riêng</option>
                                    <option value="OFFICE" ${labelVal == 'OFFICE' ? 'selected' : ''}>Công ty</option>
                                    <option value="OTHER" ${labelVal == 'OTHER' ? 'selected' : ''}>Khác</option>
                                </select>
                            </div>

                            <div class="checkout-field-grid">
                                <div class="checkout-field ${not empty formErrors.provinceCity ? 'has-error' : ''}">
                                    <label for="provinceCity">Tỉnh/Thành phố <span class="required">*</span></label>
                                    <input type="text" id="provinceCity" name="provinceCity" maxlength="100" required
                                           value="${fn:escapeXml(not empty oldProvinceCity ? oldProvinceCity : defaultAddress.provinceCity)}">
                                    <c:if test="${not empty formErrors.provinceCity}">
                                        <div class="checkout-field-error"><c:out value="${formErrors.provinceCity}"/></div>
                                    </c:if>
                                </div>
                                <div class="checkout-field ${not empty formErrors.district ? 'has-error' : ''}">
                                    <label for="district">Quận/Huyện <span class="required">*</span></label>
                                    <input type="text" id="district" name="district" maxlength="100" required
                                           value="${fn:escapeXml(not empty oldDistrict ? oldDistrict : defaultAddress.district)}">
                                    <c:if test="${not empty formErrors.district}">
                                        <div class="checkout-field-error"><c:out value="${formErrors.district}"/></div>
                                    </c:if>
                                </div>
                                <div class="checkout-field ${not empty formErrors.ward ? 'has-error' : ''}">
                                    <label for="ward">Phường/Xã <span class="required">*</span></label>
                                    <input type="text" id="ward" name="ward" maxlength="100" required
                                           value="${fn:escapeXml(not empty oldWard ? oldWard : defaultAddress.ward)}">
                                    <c:if test="${not empty formErrors.ward}">
                                        <div class="checkout-field-error"><c:out value="${formErrors.ward}"/></div>
                                    </c:if>
                                </div>
                                <div class="checkout-field ${not empty formErrors.houseNumberStreet ? 'has-error' : ''}">
                                    <label for="houseNumberStreet">Số nhà/Tên đường <span class="required">*</span></label>
                                    <input type="text" id="houseNumberStreet" name="houseNumberStreet" maxlength="300" required
                                           value="${fn:escapeXml(not empty oldHouseNumberStreet ? oldHouseNumberStreet : (not empty defaultAddress.houseNumberStreet ? defaultAddress.houseNumberStreet : defaultAddress.street))}">
                                    <c:if test="${not empty formErrors.houseNumberStreet}">
                                        <div class="checkout-field-error"><c:out value="${formErrors.houseNumberStreet}"/></div>
                                    </c:if>
                                </div>
                            </div>

                            <div class="checkout-gps-row">
                                <button type="button" class="checkout-gps-btn" id="gpsLocateBtn">
                                    <i class="fa-solid fa-location-crosshairs"></i> Lấy vị trí hiện tại
                                </button>
                                <span class="checkout-gps-status" id="gpsStatusText"></span>
                            </div>

                            <div class="checkout-field checkout-field-full ${not empty formErrors.note ? 'has-error' : ''}">
                                <label for="note">Ghi chú đơn hàng</label>
                                <textarea id="note" name="note" maxlength="500" placeholder="Ví dụ: giao giờ hành chính, gọi trước khi giao..."><c:out value="${oldNote}"/></textarea>
                                <c:if test="${not empty formErrors.note}">
                                    <div class="checkout-field-error"><c:out value="${formErrors.note}"/></div>
                                </c:if>
                            </div>
                        </div>

                        <div class="checkout-card">
                            <div class="checkout-card-title"><i class="fa-solid fa-wallet"></i> Phương Thức Thanh Toán</div>
                            <div class="checkout-payment-options">
                                <label class="checkout-payment-option is-selected">
                                    <input type="radio" name="paymentMethod" value="COD" checked>
                                    <div class="checkout-payment-icon"><i class="fa-solid fa-money-bill-wave"></i></div>
                                    <div class="checkout-payment-text">
                                        <strong>Tiền mặt khi nhận hàng (COD)</strong>
                                        <span>Thanh toán trực tiếp cho nhân viên giao hàng</span>
                                    </div>
                                </label>
                                <label class="checkout-payment-option is-disabled">
                                    <input type="radio" name="paymentMethodDisabled" value="PAYOS" disabled>
                                    <div class="checkout-payment-icon"><i class="fa-solid fa-qrcode"></i></div>
                                    <div class="checkout-payment-text">
                                        <strong>Thanh toán qua PayOS</strong>
                                        <span>Chuyển khoản / QR — sắp ra mắt</span>
                                    </div>
                                    <span class="checkout-payment-badge">Sắp hỗ trợ</span>
                                </label>
                            </div>
                            <c:if test="${not empty formErrors.paymentMethod}">
                                <div class="checkout-field-error" style="margin-top:10px;"><c:out value="${formErrors.paymentMethod}"/></div>
                            </c:if>
                        </div>
                    </form>
                </div>

                <!-- ===== TÓM TẮT ĐƠN HÀNG ===== -->
                <aside class="cart-summary checkout-summary">
                    <div class="cart-summary-title">Tóm Tắt Đơn Hàng</div>

                    <div class="checkout-summary-items">
                        <c:forEach var="item" items="${checkoutItems}">
                            <div class="checkout-summary-item">
                                <div class="checkout-summary-item-media">
                                    <c:choose>
                                        <c:when test="${not empty item.imageUrl}">
                                            <img src="${pageContext.request.contextPath}${item.imageUrl}" alt="${fn:escapeXml(item.productName)}">
                                        </c:when>
                                        <c:otherwise><i class="fa-solid fa-leaf ph-icon"></i></c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="checkout-summary-item-info">
                                    <div class="checkout-summary-item-name"><c:out value="${item.productName}"/></div>
                                    <div class="checkout-summary-item-meta">
                                        <c:if test="${not empty item.size}">
                                            <c:choose>
                                                <c:when test="${item.size == 'L'}">Size L</c:when>
                                                <c:when test="${item.size == 'M'}">Size M</c:when>
                                                <c:otherwise><c:out value="${item.size}"/></c:otherwise>
                                            </c:choose> ·
                                        </c:if>
                                        SL: ${item.quantity} × ${item.formattedPrice}đ
                                    </div>
                                </div>
                                <div class="checkout-summary-item-subtotal">${item.formattedTotalPrice}đ</div>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="cart-summary-divider"></div>

                    <div class="cart-summary-row">
                        <span>Tạm tính</span>
                        <strong><fmt:formatNumber value="${subtotal}" type="number" groupingUsed="true"/>đ</strong>
                    </div>
                    <div class="cart-summary-row">
                        <span>Phí giao hàng</span>
                        <strong>0đ</strong>
                    </div>
                    <div class="cart-summary-row">
                        <span>Phương thức</span>
                        <strong>COD</strong>
                    </div>

                    <div class="cart-summary-divider"></div>

                    <div class="cart-summary-total-row">
                        <span class="cart-summary-total-label">Tổng thanh toán</span>
                        <span class="cart-summary-total-value"><fmt:formatNumber value="${subtotal}" type="number" groupingUsed="true"/>đ</span>
                    </div>

                    <button type="submit" form="checkoutForm" class="btn-shop btn-shop-primary" id="placeOrderBtn">
                        <i class="fa-solid fa-check"></i> Đặt Hàng
                    </button>
                    <p class="cart-summary-note">
                        Bằng việc đặt hàng, bạn đồng ý thanh toán tiền mặt khi nhận được sản phẩm.
                    </p>
                </aside>
            </div>
        </div>
    </section>

    <script src="${pageContext.request.contextPath}/js/checkout.js?v=1"></script>
    <script>
        const navbar = document.getElementById('navbar');
        window.addEventListener('scroll', () => navbar.classList.toggle('scrolled', window.scrollY > 50));
        navbar.classList.add('scrolled');
        const navToggle = document.getElementById('navToggle');
        const navLinks = document.getElementById('navLinks');
        navToggle.addEventListener('click', () => navLinks.classList.toggle('active'));
    </script>
</body>
</html>
