<%@ page pageEncoding="UTF-8" %>
    </main>
    <script>
        (function() {
            var toggle = document.getElementById('adminSidebarToggle');
            var sidebar = document.getElementById('adminSidebar');
            if (toggle && sidebar) {
                toggle.addEventListener('click', function(e) {
                    e.stopPropagation();
                    sidebar.classList.toggle('open');
                });
                document.addEventListener('click', function(e) {
                    if (sidebar.classList.contains('open') && !sidebar.contains(e.target) && e.target !== toggle) {
                        sidebar.classList.remove('open');
                    }
                });
            }
        })();
    </script>
</body>
</html>

