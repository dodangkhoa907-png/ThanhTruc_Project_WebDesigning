# Customer Header/Navbar Unification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace 5 drifted, hand-copied `<nav>` blocks (Home, Cart, Product List, Product Detail, Menu) with one shared JSP header fragment that has a complete menu, correct active-state highlighting, and a working cart badge on every customer page.

**Architecture:** A new JSP fragment (`WEB-INF/views/common/customer-header.jsp`) holds the canonical nav markup. Each of the 5 customer JSPs replaces its inline `<nav>...</nav>` block with `<%@ include file="/WEB-INF/views/common/customer-header.jsp" %>` (translation-time include — the fragment reads the including page's `pageContext`/`sessionScope`/`currentPage` request attribute directly, no parameter passing). Two servlets (`ProductController`, `CartController`) set `request.setAttribute("currentPage", ...)` before forwarding so the fragment knows which nav item to highlight. `/` (Home) has no servlet and sets nothing, so nothing is marked active there — matches current design decision.

**Tech Stack:** Jakarta EE servlets (Java), JSP + JSTL (`c`, `fmt`, `fn` taglibs), vanilla CSS (`css/style.css`), vanilla JS (`js/cart.js`, unchanged). Build via Maven (`mvn clean package`); no automated test suite exists in this project — verification is compile + manual browser walkthrough, per project convention.

## Global Constraints

- Do not modify the database or any DAO/model class.
- Do not implement checkout COD or Order creation in this change.
- Do not change the framework or add new dependencies.
- Do not break `/san-pham`, `/cart`, `/cart/add`, `/login`, `/register` routes or behavior.
- Do not touch admin sidebar/header (`WEB-INF/views/admin/**`, `admin.jsp`) unless directly required — it is not.
- Do not hard-code user data; always read from `sessionScope.user`.
- All links must use `${pageContext.request.contextPath}` — never hard-code `/NhietDoiXanh_Web`.
- Preserve `#navCartBadge` id and its `hidden`-attribute toggle logic exactly — `js/cart.js` depends on it and must not be modified.
- Guest (not logged in) header shows only "Đăng Nhập" — no "Đăng Ký" link (dropping the extra link `product-list.jsp`/`product-detail.jsp` currently have, to match Home's canonical behavior).
- Palette/theme values (already defined as CSS vars in `style.css`): `--cream: #FDFBF7`, `--green: #2A5C38`, `--green-dark: #1E3F27`, `--green-light: #3A7D4A`, `--gold: #F4A261`, `--gold-light: #F9C784`, `--text-body: #4A5D4A`, `--text-muted: #7A8D7A`, `--border: #E8E0D0`, `--cream-warm: #F8EED8`. Reuse these vars — do not introduce new hard-coded colors.

---

## Task 1: Create the shared customer header fragment

**Files:**
- Create: `src/main/webapp/WEB-INF/views/common/customer-header.jsp`

**Interfaces:**
- Consumes: `pageContext.request.contextPath` (implicit), `sessionScope.user` (`User` model, has `.fullName`), `sessionScope.cartCount` (Integer, may be empty/null), `sessionScope._csrf` (unused by header, used by page `<head>`, not this file), request attribute `currentPage` (String, one of `"menu"`, `"products"`, `"cart"`, or unset/null for Home and any page that doesn't set it).
- Produces: markup with `id="navbar"`, `id="navLinks"`, `id="navToggle"`, `id="navCartBadge"` — all 5 including pages' existing `<script>` blocks look up these exact ids via `getElementById`, so they must be preserved verbatim.

This fragment does **not** declare `<%@ page %>` or `<%@ taglib %>` directives — translation-time include (`<%@ include %>`) inlines this content into the including page at compile time, so it uses whichever taglib prefixes (`c`) the including page already declared. All 5 target pages already declare `<%@ taglib prefix="c" uri="jakarta.tags.core" %>` (verified).

- [ ] **Step 1: Write the fragment**

Create `src/main/webapp/WEB-INF/views/common/customer-header.jsp`:

```jsp
<%-- Shared customer navbar. Included via <%@ include %> so it shares the
     caller's pageContext/taglibs. Requires request attribute "currentPage"
     to be set by the caller's servlet for active-state highlighting
     ("menu" | "products" | "cart"); Home sets nothing and highlights nothing. --%>
<nav class="navbar" id="navbar">
    <div class="container">
        <a href="${pageContext.request.contextPath}/" class="navbar-brand">
            <div class="navbar-logo">
                <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path d="M17 8C8 10 5.9 16.17 3.82 21.34l1.89.66.95-2.3c.48.17.98.3 1.34.3C19 20 22 3 22 3c-1 2-8 2.25-13 3.25S2 11.5 2 13.5s1.75 3.75 1.75 3.75C7 8 17 8 17 8z"/>
                </svg>
            </div>
            <div class="navbar-name">Nhiệt Đới <span>Xanh</span></div>
        </a>

        <div class="nav-links" id="navLinks">
            <a href="${pageContext.request.contextPath}/#story">Câu Chuyện</a>
            <a href="${pageContext.request.contextPath}/#values">Giá Trị</a>
            <a href="${pageContext.request.contextPath}/thuc-don"
               class="${currentPage == 'menu' ? 'active' : ''}">Thực Đơn</a>
            <a href="${pageContext.request.contextPath}/san-pham"
               class="${currentPage == 'products' ? 'active' : ''}">Sản Phẩm</a>
            <a href="${pageContext.request.contextPath}/#team">Đội Ngũ</a>
            <a href="${pageContext.request.contextPath}/cart"
               class="nav-cart-link ${currentPage == 'cart' ? 'active' : ''}" aria-label="Giỏ hàng">
                <i class="fa-solid fa-basket-shopping"></i>
                <span class="nav-cart-badge" id="navCartBadge"
                      ${empty sessionScope.cartCount || sessionScope.cartCount == 0 ? 'hidden' : ''}>
                    ${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}
                </span>
            </a>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/">
                        <c:out value="${sessionScope.user.fullName}"/>
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login">Đăng Nhập</a>
                </c:otherwise>
            </c:choose>
            <a href="${pageContext.request.contextPath}/#checkout" class="nav-cta">Đặt Hàng</a>
        </div>

        <button class="nav-toggle" id="navToggle" aria-label="Menu">
            <span></span>
            <span></span>
            <span></span>
        </button>
    </div>
</nav>
```

- [ ] **Step 2: Verify the file was created correctly**

Run: `test -f src/main/webapp/WEB-INF/views/common/customer-header.jsp && echo OK`
Expected: `OK`

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/WEB-INF/views/common/customer-header.jsp
git commit -m "Add shared customer header JSP fragment"
```

---

## Task 2: Switch `index.jsp` (Home) to the shared fragment

**Files:**
- Modify: `src/main/webapp/index.jsp:33-76`

**Interfaces:**
- Consumes: Task 1's fragment at `WEB-INF/views/common/customer-header.jsp`.
- Produces: nothing new consumed by later tasks; Home is the visual reference for "what the header should look like everywhere else."

- [ ] **Step 1: Replace the inline nav block**

In `src/main/webapp/index.jsp`, replace lines 33-76 (the entire `<nav class="navbar" id="navbar">...</nav>` block, including its surrounding `<!-- NAVBAR — Glassmorphism -->` comment on lines 30-32) with:

```jsp
    <!-- ================================================================
     NAVBAR — Glassmorphism
     ================================================================ -->
    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>
```

- [ ] **Step 2: Build and confirm no compile errors**

Run: `cd /home/nhan/Downloads/ThanhTruc_Project_WebDesigning && mvn -q clean compile 2>&1 | tail -40`
Expected: no `[ERROR]` lines (JSPs aren't compiled by `mvn compile`, but this confirms the Java side still builds; JSP validity is confirmed in Task 7's `mvn clean package` + deploy).

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/index.jsp
git commit -m "Use shared header fragment on Home page"
```

---

## Task 3: Switch `menu.jsp` (`/thuc-don`) to the shared fragment, and set `currentPage` in `ProductController`

**Files:**
- Modify: `src/main/webapp/WEB-INF/views/menu.jsp:30-74`
- Modify: `src/main/java/com/nhietdoixanh/controller/ProductController.java:73-76` (inside `handleThucDon`)

**Interfaces:**
- Consumes: Task 1's fragment; reads `currentPage` request attribute.
- Produces: `ProductController` now sets `currentPage = "menu"` before forwarding to `menu.jsp` — this is the pattern Task 4 repeats for `/san-pham`.

- [ ] **Step 1: Replace the inline nav block in `menu.jsp`**

In `src/main/webapp/WEB-INF/views/menu.jsp`, replace lines 30-74 (the `<!-- NAVBAR -->` comment through `</nav>`) with:

```jsp
    <!-- ================================================================
     NAVBAR
     ================================================================ -->
    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>
```

- [ ] **Step 2: Set `currentPage` in `ProductController.handleThucDon`**

In `src/main/java/com/nhietdoixanh/controller/ProductController.java`, in `handleThucDon` (around line 73-76), change:

```java
        req.setAttribute("categories", categories);
        req.setAttribute("products", products);
        req.setAttribute("activeCategoryId", activeCategoryId);
        req.getRequestDispatcher("/WEB-INF/views/menu.jsp").forward(req, resp);
```

to:

```java
        req.setAttribute("categories", categories);
        req.setAttribute("products", products);
        req.setAttribute("activeCategoryId", activeCategoryId);
        req.setAttribute("currentPage", "menu");
        req.getRequestDispatcher("/WEB-INF/views/menu.jsp").forward(req, resp);
```

- [ ] **Step 3: Build and confirm no compile errors**

Run: `cd /home/nhan/Downloads/ThanhTruc_Project_WebDesigning && mvn -q clean compile 2>&1 | tail -40`
Expected: no `[ERROR]` lines.

- [ ] **Step 4: Commit**

```bash
git add src/main/webapp/WEB-INF/views/menu.jsp src/main/java/com/nhietdoixanh/controller/ProductController.java
git commit -m "Use shared header on /thuc-don and mark it active"
```

---

## Task 4: Switch `product-list.jsp` (`/san-pham`) to the shared fragment, and set `currentPage` in `ProductController`

**Files:**
- Modify: `src/main/webapp/WEB-INF/views/product-list.jsp:31-69`
- Modify: `src/main/java/com/nhietdoixanh/controller/ProductController.java:109-115` (inside `handleShopList`)

**Interfaces:**
- Consumes: Task 1's fragment.
- Produces: `ProductController` now sets `currentPage = "products"` before forwarding to `product-list.jsp`.

- [ ] **Step 1: Replace the inline nav block in `product-list.jsp`**

In `src/main/webapp/WEB-INF/views/product-list.jsp`, replace lines 31-69 (the `<!-- NAVBAR -->` comment through `</nav>`) with:

```jsp
    <!-- ================================================================
     NAVBAR
     ================================================================ -->
    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>
```

Note: this removes the page's local `<c:set var="cartCount" .../>` usage from the nav — that `<c:set>` on line 29 stays (it's declared before the nav and may be used elsewhere in the page); the shared fragment computes cart count inline from `sessionScope.cartCount` directly rather than relying on a page-local `cartCount` variable, so no behavior changes.

- [ ] **Step 2: Set `currentPage` in `ProductController.handleShopList`**

In `src/main/java/com/nhietdoixanh/controller/ProductController.java`, in `handleShopList` (around line 109-115), change:

```java
        req.setAttribute("categories", categories);
        req.setAttribute("products", products);
        req.setAttribute("activeCategoryId", categoryId);
        req.setAttribute("keyword", keyword);
        req.setAttribute("activeSort", sort.getParam());
        req.setAttribute("keepQuerySuffix", keepQuerySuffix);
        req.getRequestDispatcher("/WEB-INF/views/product-list.jsp").forward(req, resp);
```

to:

```java
        req.setAttribute("categories", categories);
        req.setAttribute("products", products);
        req.setAttribute("activeCategoryId", categoryId);
        req.setAttribute("keyword", keyword);
        req.setAttribute("activeSort", sort.getParam());
        req.setAttribute("keepQuerySuffix", keepQuerySuffix);
        req.setAttribute("currentPage", "products");
        req.getRequestDispatcher("/WEB-INF/views/product-list.jsp").forward(req, resp);
```

- [ ] **Step 3: Also mark `/san-pham/chi-tiet` (product detail) as "products" in `handleShopDetail`**

In the same file, `handleShopDetail` has two forward points — the not-found path and the success path. Change both. First, the not-found path (around line 147-151):

```java
        if (productOpt.isEmpty()) {
            req.setAttribute("errorMessage", "Sản phẩm không tồn tại hoặc đã ngừng kinh doanh.");
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            req.getRequestDispatcher("/WEB-INF/views/product-detail.jsp").forward(req, resp);
            return;
        }
```

to:

```java
        if (productOpt.isEmpty()) {
            req.setAttribute("errorMessage", "Sản phẩm không tồn tại hoặc đã ngừng kinh doanh.");
            req.setAttribute("currentPage", "products");
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            req.getRequestDispatcher("/WEB-INF/views/product-detail.jsp").forward(req, resp);
            return;
        }
```

Then the success path (around line 154-155):

```java
        req.setAttribute("product", productOpt.get());
        req.getRequestDispatcher("/WEB-INF/views/product-detail.jsp").forward(req, resp);
```

to:

```java
        req.setAttribute("product", productOpt.get());
        req.setAttribute("currentPage", "products");
        req.getRequestDispatcher("/WEB-INF/views/product-detail.jsp").forward(req, resp);
```

- [ ] **Step 4: Build and confirm no compile errors**

Run: `cd /home/nhan/Downloads/ThanhTruc_Project_WebDesigning && mvn -q clean compile 2>&1 | tail -40`
Expected: no `[ERROR]` lines.

- [ ] **Step 5: Commit**

```bash
git add src/main/webapp/WEB-INF/views/product-list.jsp src/main/java/com/nhietdoixanh/controller/ProductController.java
git commit -m "Use shared header on /san-pham and mark it active"
```

---

## Task 5: Switch `product-detail.jsp` (`/san-pham/chi-tiet`) to the shared fragment

**Files:**
- Modify: `src/main/webapp/WEB-INF/views/product-detail.jsp:29-67`

**Interfaces:**
- Consumes: Task 1's fragment, and Task 4's `currentPage = "products"` attribute (already wired up in Task 4 Step 3 — this task only touches the JSP).

- [ ] **Step 1: Replace the inline nav block in `product-detail.jsp`**

In `src/main/webapp/WEB-INF/views/product-detail.jsp`, replace lines 29-67 (the `<!-- NAVBAR -->` comment through `</nav>`) with:

```jsp
    <!-- ================================================================
     NAVBAR
     ================================================================ -->
    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>
```

The page-local `<c:set var="cartCount" .../>` on line 27 stays untouched (may be used elsewhere on the page) — same non-impact reasoning as Task 4 Step 1.

- [ ] **Step 2: Build and confirm no compile errors**

Run: `cd /home/nhan/Downloads/ThanhTruc_Project_WebDesigning && mvn -q clean compile 2>&1 | tail -40`
Expected: no `[ERROR]` lines.

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/WEB-INF/views/product-detail.jsp
git commit -m "Use shared header on product detail page"
```

---

## Task 6: Switch `cart.jsp` (`/cart`) to the shared fragment, and set `currentPage` in `CartController`

**Files:**
- Modify: `src/main/webapp/WEB-INF/views/cart.jsp:28-53`
- Modify: `src/main/java/com/nhietdoixanh/controller/CartController.java:127-129` (inside `handleViewCart`)

**Interfaces:**
- Consumes: Task 1's fragment.
- Produces: `CartController` now sets `currentPage = "cart"` before forwarding to `cart.jsp`.

- [ ] **Step 1: Replace the inline nav block in `cart.jsp`**

In `src/main/webapp/WEB-INF/views/cart.jsp`, replace lines 28-53 (the `<nav class="navbar" id="navbar">...</nav>` block) with:

```jsp
    <%@ include file="/WEB-INF/views/common/customer-header.jsp" %>
```

The page-local `<c:set var="cartCount" .../>` on line 26 stays untouched (used elsewhere on the page, e.g. summary calculations) — same non-impact reasoning as Task 4.

Note: `cart.jsp`'s current inline nav is missing `aria-label="Giỏ hàng"` and has an inline `style="color:var(--green);font-weight:700"` hack instead of a real active class — both go away entirely, replaced by the fragment's proper `.active` class driven by `currentPage`.

- [ ] **Step 2: Set `currentPage` in `CartController.handleViewCart`**

In `src/main/java/com/nhietdoixanh/controller/CartController.java`, in `handleViewCart` (around line 127-129), change:

```java
        List<CartLineItemDto> cartItems = cartItemDao.findLineItemsByUserId(user.getUserId());
        req.setAttribute("cartItems", cartItems);
        req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
```

to:

```java
        List<CartLineItemDto> cartItems = cartItemDao.findLineItemsByUserId(user.getUserId());
        req.setAttribute("cartItems", cartItems);
        req.setAttribute("currentPage", "cart");
        req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
```

- [ ] **Step 3: Build and confirm no compile errors**

Run: `cd /home/nhan/Downloads/ThanhTruc_Project_WebDesigning && mvn -q clean compile 2>&1 | tail -40`
Expected: no `[ERROR]` lines.

- [ ] **Step 4: Commit**

```bash
git add src/main/webapp/WEB-INF/views/cart.jsp src/main/java/com/nhietdoixanh/controller/CartController.java
git commit -m "Use shared header on /cart and mark it active"
```

---

## Task 7: Add active-state CSS

**Files:**
- Modify: `src/main/webapp/css/style.css:174-201` (the `.nav-links` block)

**Interfaces:**
- Consumes: the `.active` class emitted by the fragment built in Task 1 on `.nav-links a` and `.nav-cart-link`.

- [ ] **Step 1: Add the active-state rules**

In `src/main/webapp/css/style.css`, immediately after the existing block:

```css
.nav-links a:hover {
    color: var(--green);
    background: rgba(42,92,56,0.06);
}
```

(around line 184-187), insert:

```css

.nav-links a.active {
    color: var(--green);
    background: var(--cream-warm);
    font-weight: 600;
}

.nav-cart-link.active {
    background: var(--cream-warm);
    border-radius: 50px;
}
```

This only changes `color`/`background`/`font-weight` — no `padding`/`margin` changes, so active state cannot shift layout.

- [ ] **Step 2: Visually confirm the rule was added**

Run: `grep -n "nav-links a.active\|nav-cart-link.active" src/main/webapp/css/style.css`
Expected: both selectors listed with line numbers.

- [ ] **Step 3: Commit**

```bash
git add src/main/webapp/css/style.css
git commit -m "Add active-state styles for navbar links and cart icon"
```

---

## Task 8: Full build, deploy, and manual verification

**Files:**
- Create: `docs/ECOMMERCE_HEADER_FIX_REPORT.md`

**Interfaces:**
- Consumes: everything from Tasks 1-7.

- [ ] **Step 1: Full clean package build**

Run: `cd /home/nhan/Downloads/ThanhTruc_Project_WebDesigning && mvn clean package 2>&1 | tail -60`
Expected: `BUILD SUCCESS`, and a `.war` produced under `target/`. Capture the actual output for the report in Step 4.

- [ ] **Step 2: Deploy and manually walk the checklist**

Deploy the built WAR to the project's Tomcat (however this project is normally run — check `.smarttomcat/` config already present in the repo, or the user's existing local Tomcat setup) and manually verify, in a browser, against `http://localhost:8080/NhietDoiXanh_Web/`:

1. Open Home (`/`). Header renders full menu (Câu Chuyện, Giá Trị, Thực Đơn, Sản Phẩm, Đội Ngũ, cart icon, user/login, Đặt Hàng) exactly as before this change.
2. Open `/cart`. Header is now full-width and identical in content/spacing/color/font to Home's header.
3. Open `/san-pham`. Header matches Home; "Sản Phẩm" link shows `.active` styling (green text, `--cream-warm` pill background).
4. Open `/thuc-don`. Header matches Home; "Thực Đơn" link shows `.active` styling.
5. Open `/san-pham/chi-tiet?id=<any active product id>`. Header matches Home; "Sản Phẩm" link shows `.active` styling (same as list page, per Task 4 Step 3).
6. On `/cart`, the cart icon shows `.active` styling (pill background); on other pages it doesn't.
7. Click the logo from any page — lands on Home.
8. Click "Đặt Hàng" from `/cart` or `/san-pham` — navigates to Home and jumps to the `#checkout` section.
9. Click "Câu Chuyện"/"Giá Trị"/"Đội Ngũ" from `/cart` or `/san-pham` — navigates to Home and jumps to the corresponding anchor.
10. Log in as a test user — header shows the user's `fullName` on every page (Home, cart, san-pham, thuc-don, product detail).
11. Log out — header shows "Đăng Nhập" only (no "Đăng Ký") on every page.
12. Add an item to cart via `/san-pham` (AJAX add) — badge count updates live on that page without a reload, and the new count persists (shown correctly) after navigating to `/cart` or Home.
13. Open browser devtools console on each of the 5 pages — zero JS errors, zero 404s for CSS/JS/font assets.
14. Resize to mobile width (or use devtools device toolbar) on `/cart` and `/san-pham` — hamburger toggle opens/closes the nav, cart icon and user/login remain visible, layout doesn't break.

- [ ] **Step 3: Fix any issues found in Step 2**

If any checklist item fails, fix the specific file involved (fragment, servlet, or CSS) and re-run Steps 1-2 until all 14 items pass. Do not proceed to Step 4 until they do.

- [ ] **Step 4: Write the header fix report**

Create `docs/ECOMMERCE_HEADER_FIX_REPORT.md`:

```markdown
# Ecommerce Header Fix Report

Date: 2026-07-17

## Duplicate headers found before the fix

Each of these files had its own hand-copied `<nav class="navbar">` block that had drifted from Home's:

- `src/main/webapp/index.jsp` (Home) — canonical/fullest version, used as the source of truth.
- `src/main/webapp/WEB-INF/views/cart.jsp` — missing Câu Chuyện, Giá Trị, Đội Ngũ, CTA "Đặt Hàng", and any guest login link.
- `src/main/webapp/WEB-INF/views/product-list.jsp` — missing Câu Chuyện, Giá Trị, Đội Ngũ, CTA; had an extra "Đăng Ký" link Home didn't have.
- `src/main/webapp/WEB-INF/views/product-detail.jsp` — same gaps as product-list.jsp.
- `src/main/webapp/WEB-INF/views/menu.jsp` — closest to Home already, but still a separate hand-copy.

## What was created

- `src/main/webapp/WEB-INF/views/common/customer-header.jsp` — the single shared header fragment, included via `<%@ include %>` (translation-time) so it can read the including page's `pageContext`/`sessionScope` without parameter passing.

## Files switched to the shared header

- `index.jsp`
- `WEB-INF/views/cart.jsp`
- `WEB-INF/views/product-list.jsp`
- `WEB-INF/views/product-detail.jsp`
- `WEB-INF/views/menu.jsp`

## Active state

Handled via a `currentPage` request attribute set by the servlet before forwarding (not requestURI-sniffing in the JSP):

- `ProductController.handleThucDon` → `currentPage = "menu"`
- `ProductController.handleShopList` → `currentPage = "products"`
- `ProductController.handleShopDetail` → `currentPage = "products"` (both the not-found and success forward paths)
- `CartController.handleViewCart` → `currentPage = "cart"`
- `/` (Home) — no servlet runs for the welcome-file route, so no `currentPage` is set and no nav item is highlighted there, by design.

## mvn clean package result

[paste the actual BUILD SUCCESS output tail from Task 8 Step 1 here]

## Test checklist results

[paste pass/fail for each of the 14 items from Task 8 Step 2 here]
```

Fill in the two bracketed sections with the real build output and real checklist results from Steps 1-2 (not placeholder text — replace the brackets entirely).

- [ ] **Step 5: Commit**

```bash
git add docs/ECOMMERCE_HEADER_FIX_REPORT.md
git commit -m "Add header unification fix report"
```

---

## Self-Review Notes

- **Spec coverage:** Requirement 1 (shared header, full menu) → Tasks 1-6. Requirement 2 (active state via `currentPage`) → Tasks 1, 3, 4, 6. Requirement 3 (cart badge) → Task 1 (id/logic preserved verbatim, no `cart.js` changes). Requirement 4 (responsive) → preserved as-is since `.nav-toggle`/`.nav-links` markup and existing mobile CSS are untouched; verified in Task 8 Step 2 item 14. Requirement 5 (theme/palette) → Task 7 reuses existing CSS vars only. Requirement 6 (remove duplicate headers) → Tasks 2-6 each delete one duplicate. Requirement 7 (contextPath-safe links) → fragment in Task 1 uses `${pageContext.request.contextPath}` throughout, no hard-coded paths. Requirement 8 (test) → Task 8. Report → Task 8 Step 4.
- **Type/name consistency:** `currentPage` string values (`"menu"`, `"products"`, `"cart"`) are identical across Tasks 1, 3, 4, 6. Fragment id `navCartBadge` matches what `js/cart.js` expects (verified against `js/cart.js:38` during design). No new servlet, no new route, no DB/model changes anywhere in this plan.
