# Customer Header/Navbar Unification — Design

Date: 2026-07-17

## Problem

Five customer-facing JSPs each hand-copy their own `<nav class="navbar">` block, and the copies have drifted:

| Page | File | Missing vs Home |
|---|---|---|
| Home | `index.jsp` | — (canonical, full menu) |
| Cart | `WEB-INF/views/cart.jsp` | Câu Chuyện, Giá Trị, Đội Ngũ, CTA, guest login link |
| Product list | `WEB-INF/views/product-list.jsp` | Câu Chuyện, Giá Trị, Đội Ngũ, CTA (has extra "Đăng Ký" Home lacks) |
| Product detail | `WEB-INF/views/product-detail.jsp` | Same as product-list |
| Menu (`/thuc-don`) | `WEB-INF/views/menu.jsp` | Nothing missing — closest to Home, kept as reference for anchor-link pattern |

No page has any active-state indicator. Result: navigating from Home to `/cart` or `/san-pham` feels like landing on a different site.

## Routing facts (constrain the design)

- `/` → `index.jsp` directly, via `<welcome-file>` in `web.xml`. **No servlet runs for `/`.** It is a single-page scroller; "Câu Chuyện", "Giá Trị", "Đội Ngũ", and the "Đặt Hàng" CTA are anchor links (`#story`, `#values`, `#team`, `#checkout`) within that one page.
- `/thuc-don`, `/san-pham`, `/san-pham/chi-tiet` → `ProductController`, forwards to `menu.jsp` / `product-list.jsp` / `product-detail.jsp` respectively.
- `/cart` (GET) → `CartController`, forwards to `cart.jsp`.
- `/cart/add`, `/cart/update`, `/cart/remove`, `/cart/remove-selected`, `/cart/count` → `CartController`, JSON endpoints, already update `sessionScope.cartCount` and are consumed by `js/cart.js` via `#navCartBadge`. Not touched by this change.
- `/login`, `/register`, `/logout` → `AuthController`. No `/account` route exists yet.

## Decisions (confirmed with user)

1. **Anchor links from sub-pages**: Câu Chuyện / Giá Trị / Đội Ngũ / CTA "Đặt Hàng" always point back to Home with the anchor, e.g. `${pageContext.request.contextPath}/#story`, from every page including `/cart` and `/san-pham`. Clicking from a sub-page navigates to Home and the browser jumps to the anchor (no smooth scroll on that hard navigation — acceptable).
2. **Active state mechanism**: servlets that already run (`ProductController`, `CartController`) set `request.setAttribute("currentPage", ...)` before forwarding. `/` gets no new servlet and no active state — the logo/menu simply has nothing highlighted on Home, consistent with the original spec ("logo không cần active").
   - `currentPage = "menu"` for `/thuc-don`
   - `currentPage = "products"` for `/san-pham` and `/san-pham/chi-tiet`
   - `currentPage = "cart"` for `/cart`
3. **Include mechanism**: `<%@ include file="/WEB-INF/views/common/customer-header.jsp" %>` (translation-time include) in each of the 5 JSPs, replacing their inline `<nav>` block. Chosen over `<jsp:include>` because the header only needs read access to the including page's implicit objects (`pageContext`, `sessionScope`, the `currentPage` request attribute) — no parameters need to cross a request-time boundary.
4. **Guest state**: unauthenticated users see only "Đăng Nhập" (drop the "Đăng Ký" link that only `product-list.jsp`/`product-detail.jsp` currently have), matching Home's canonical behavior.
5. **Cart badge**: unchanged in behavior — `#navCartBadge` id, sourced from `sessionScope.cartCount`, still updated live by the existing AJAX handlers in `js/cart.js`. The shared fragment must preserve this exact id and the `hidden` attribute toggle logic so no JS changes are required.

## Shared fragment

New file: `src/main/webapp/WEB-INF/views/common/customer-header.jsp`

Structure (based on `index.jsp`'s current nav, since it's the fullest):

```
<nav class="navbar" id="navbar">
  <div class="container">
    <a href="${contextPath}/" class="navbar-brand"> logo + "Nhiệt Đới Xanh" </a>
    <div class="nav-links" id="navLinks">
      <a href="${contextPath}/#story"    class="${currentPage == 'story' ? 'active' : ''}">Câu Chuyện</a>
      <a href="${contextPath}/#values"   class="${currentPage == 'values' ? 'active' : ''}">Giá Trị</a>
      <a href="${contextPath}/thuc-don"  class="${currentPage == 'menu' ? 'active' : ''}">Thực Đơn</a>
      <a href="${contextPath}/san-pham"  class="${currentPage == 'products' ? 'active' : ''}">Sản Phẩm</a>
      <a href="${contextPath}/#team"     class="${currentPage == 'team' ? 'active' : ''}">Đội Ngũ</a>
      <a href="${contextPath}/cart" class="nav-cart-link ${currentPage == 'cart' ? 'active' : ''}" aria-label="Giỏ hàng">
        <i class="fa-solid fa-basket-shopping"></i>
        <span class="nav-cart-badge" id="navCartBadge" ${empty sessionScope.cartCount || sessionScope.cartCount == 0 ? 'hidden' : ''}>
          ${empty sessionScope.cartCount ? 0 : sessionScope.cartCount}
        </span>
      </a>
      <c:choose>
        <c:when test="${not empty sessionScope.user}">
          <a href="${contextPath}/"><c:out value="${sessionScope.user.fullName}"/></a>
        </c:when>
        <c:otherwise>
          <a href="${contextPath}/login">Đăng Nhập</a>
        </c:otherwise>
      </c:choose>
      <a href="${contextPath}/#checkout" class="nav-cta">Đặt Hàng</a>
    </div>
    <button class="nav-toggle" id="navToggle" aria-label="Menu"><span></span><span></span><span></span></button>
  </div>
</nav>
```

Notes:
- `story`/`values`/`team` never get set by any servlet today (no page currently marks them active), so those `.active` checks are effectively dormant scaffolding for consistency — harmless, costs nothing, and is ready if a future in-page scroll-spy sets them.
- Fragment does not declare its own `<%@ page %>` or taglib directives beyond what it needs — it relies on each including JSP already having `c` taglib imported (true for all 5 target files, verified).
- Each including JSP keeps its own `navbar.classList.add('scrolled')` / scroll-listener script as-is (page-specific behavior, e.g. cart.jsp starts pre-scrolled since it has no hero).

## CSS changes

In `src/main/webapp/css/style.css`, near the existing `.nav-links a` block (~line 174-201), add:

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

No padding/margin changes — active state only swaps color/background/font-weight so layout never shifts.

## Files touched

- **New**: `WEB-INF/views/common/customer-header.jsp`
- **Edited**: `index.jsp`, `WEB-INF/views/cart.jsp`, `WEB-INF/views/product-list.jsp`, `WEB-INF/views/product-detail.jsp`, `WEB-INF/views/menu.jsp` — replace inline `<nav>` with the include
- **Edited**: `ProductController.java` — set `currentPage` = `"menu"` / `"products"` before each forward
- **Edited**: `CartController.java` — set `currentPage` = `"cart"` before forwarding to `cart.jsp`
- **Edited**: `css/style.css` — add `.active` rules
- **Not touched**: admin views/layout, DB, checkout/order flow, `cart.js`, other routes

## Testing

Manual: `mvn clean package`, deploy, walk through the 17-point checklist in the original request (Home renders unchanged, `/cart` `/san-pham` `/thuc-don` all show the full header, active state correct per page, badge still live-updates, logo/CTA navigate correctly, guest vs logged-in states correct, no console/404 errors, mobile doesn't break).

Report written to `docs/ECOMMERCE_HEADER_FIX_REPORT.md` after implementation, per the original request's format.
