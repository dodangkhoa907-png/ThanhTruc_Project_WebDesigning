/**
 * Nhiệt Đới Xanh — Cắt/căn chỉnh ảnh đại diện trước khi lưu.
 * Thuần HTML5 Canvas, KHÔNG dùng thư viện ngoài (an toàn với CSP 'self').
 *
 * Luồng:
 *  - User chọn ảnh → validate type/size phía client → mở modal crop.
 *  - Kéo để di chuyển, slider để zoom, vùng crop cố định 1:1.
 *  - "Lưu ảnh" → xuất canvas ra JPEG Blob vuông → nhồi vào <input type=file name=avatar>
 *    qua DataTransfer để backend multipart hiện có xử lý nguyên vẹn (validate magic bytes,
 *    lưu file, refresh session). Cập nhật preview.
 *  - "Hủy" → không đổi gì.
 */
(function () {
    'use strict';

    var MAX_BYTES = 1000000;               // ~1MB, khớp AvatarUpload.MAX_BYTES
    var ALLOWED = ['image/jpeg', 'image/png', 'image/webp'];
    var OUTPUT_SIZE = 512;                  // ảnh xuất ra 512x512
    var OUTPUT_TYPE = 'image/jpeg';
    var OUTPUT_QUALITY = 0.9;

    function initAvatarCrop() {
        var input = document.getElementById('avatarInput');
        var preview = document.getElementById('avatarPreview');
        var modal = document.getElementById('avatarCropModal');
        if (!input || !preview || !modal) return;

        var canvas = document.getElementById('avatarCropCanvas');
        var zoom = document.getElementById('avatarCropZoom');
        var saveBtn = document.getElementById('avatarCropSave');
        var cancelBtn = document.getElementById('avatarCropCancel');
        var errorBox = document.getElementById('avatarCropError');
        var ctx = canvas.getContext('2d');

        var img = null;
        var minScale = 1, scale = 1;
        var offsetX = 0, offsetY = 0;     // toạ độ tâm ảnh so với tâm canvas
        var dragging = false, lastX = 0, lastY = 0;

        function showError(msg) {
            if (!errorBox) return;
            errorBox.textContent = msg || '';
            errorBox.hidden = !msg;
        }

        function openModal() { modal.classList.add('is-open'); document.body.style.overflow = 'hidden'; }
        function closeModal() {
            modal.classList.remove('is-open');
            document.body.style.overflow = '';
            // reset input để chọn lại cùng 1 file vẫn kích hoạt change
            input.value = '';
        }

        function clampOffsets() {
            var size = canvas.width;
            var drawW = img.width * scale;
            var drawH = img.height * scale;
            var maxX = Math.max(0, (drawW - size) / 2);
            var maxY = Math.max(0, (drawH - size) / 2);
            offsetX = Math.max(-maxX, Math.min(maxX, offsetX));
            offsetY = Math.max(-maxY, Math.min(maxY, offsetY));
        }

        function draw() {
            var size = canvas.width;
            ctx.clearRect(0, 0, size, size);
            var drawW = img.width * scale;
            var drawH = img.height * scale;
            var dx = (size - drawW) / 2 + offsetX;
            var dy = (size - drawH) / 2 + offsetY;
            ctx.drawImage(img, dx, dy, drawW, drawH);
        }

        function loadImage(file) {
            var url = URL.createObjectURL(file);
            var image = new Image();
            image.onload = function () {
                img = image;
                var size = canvas.width;
                // scale tối thiểu = phủ kín canvas (cover), để không bao giờ lộ nền trống.
                minScale = Math.max(size / image.width, size / image.height);
                scale = minScale;
                offsetX = 0; offsetY = 0;
                zoom.min = '1';
                zoom.max = '3';
                zoom.step = '0.01';
                zoom.value = '1';
                clampOffsets();
                draw();
                showError('');
                openModal();
                URL.revokeObjectURL(url);
            };
            image.onerror = function () {
                URL.revokeObjectURL(url);
                showError('Không đọc được ảnh. Vui lòng thử ảnh khác.');
            };
            image.src = url;
        }

        input.addEventListener('change', function () {
            var file = input.files && input.files[0];
            if (!file) return;
            if (ALLOWED.indexOf(file.type) === -1) {
                showError('Chỉ chấp nhận ảnh JPG, PNG hoặc WEBP.');
                input.value = '';
                return;
            }
            if (file.size > MAX_BYTES) {
                showError('Ảnh gốc vượt quá 1MB. Vui lòng chọn ảnh nhỏ hơn.');
                input.value = '';
                return;
            }
            loadImage(file);
        });

        zoom.addEventListener('input', function () {
            scale = minScale * parseFloat(zoom.value);
            clampOffsets();
            draw();
        });

        // Kéo bằng chuột
        canvas.addEventListener('mousedown', function (e) {
            dragging = true; lastX = e.clientX; lastY = e.clientY;
        });
        window.addEventListener('mousemove', function (e) {
            if (!dragging || !img) return;
            offsetX += (e.clientX - lastX);
            offsetY += (e.clientY - lastY);
            lastX = e.clientX; lastY = e.clientY;
            clampOffsets(); draw();
        });
        window.addEventListener('mouseup', function () { dragging = false; });

        // Kéo bằng cảm ứng (mobile)
        canvas.addEventListener('touchstart', function (e) {
            if (e.touches.length === 1) { dragging = true; lastX = e.touches[0].clientX; lastY = e.touches[0].clientY; }
        }, { passive: true });
        canvas.addEventListener('touchmove', function (e) {
            if (!dragging || !img || e.touches.length !== 1) return;
            offsetX += (e.touches[0].clientX - lastX);
            offsetY += (e.touches[0].clientY - lastY);
            lastX = e.touches[0].clientX; lastY = e.touches[0].clientY;
            clampOffsets(); draw();
        }, { passive: true });
        canvas.addEventListener('touchend', function () { dragging = false; });

        cancelBtn.addEventListener('click', closeModal);

        saveBtn.addEventListener('click', function () {
            if (!img) { closeModal(); return; }
            // Xuất vùng crop (chính là toàn bộ canvas vuông) ra ảnh 512x512.
            var out = document.createElement('canvas');
            out.width = OUTPUT_SIZE; out.height = OUTPUT_SIZE;
            var octx = out.getContext('2d');
            var size = canvas.width;
            var ratio = OUTPUT_SIZE / size;
            var drawW = img.width * scale * ratio;
            var drawH = img.height * scale * ratio;
            var dx = (OUTPUT_SIZE - drawW) / 2 + offsetX * ratio;
            var dy = (OUTPUT_SIZE - drawH) / 2 + offsetY * ratio;
            octx.drawImage(img, dx, dy, drawW, drawH);

            out.toBlob(function (blob) {
                if (!blob) { showError('Không thể xử lý ảnh. Vui lòng thử lại.'); return; }
                if (blob.size > MAX_BYTES) {
                    showError('Ảnh sau khi cắt vẫn vượt quá 1MB. Hãy thu nhỏ vùng chọn hoặc chọn ảnh khác.');
                    return;
                }
                var croppedFile = new File([blob], 'avatar.jpg', { type: OUTPUT_TYPE });
                var dt = new DataTransfer();
                dt.items.add(croppedFile);
                input.files = dt.files;
                preview.src = URL.createObjectURL(blob);
                preview.hidden = false;
                // Ẩn ô chữ cái fallback (nếu user chưa từng có ảnh) khi đã có ảnh crop.
                var fallback = document.getElementById('avatarPreviewFallback');
                if (fallback) fallback.hidden = true;
                modal.classList.remove('is-open');
                document.body.style.overflow = '';
                showError('');
            }, OUTPUT_TYPE, OUTPUT_QUALITY);
        });
    }

    document.addEventListener('DOMContentLoaded', initAvatarCrop);
})();
