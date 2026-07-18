package com.nhietdoixanh.controller;

import com.nhietdoixanh.dao.UserPreferencesDao;
import com.nhietdoixanh.dao.impl.UserPreferencesDaoImpl;
import com.nhietdoixanh.model.User;
import com.nhietdoixanh.model.UserPreferences;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** /account/preferences — sở thích cá nhân (UserPreferences, 1-1 với Users). Chỉ lưu và hiển thị lại. */
@WebServlet(name = "AccountPreferencesController", urlPatterns = {"/account/preferences"})
public class AccountPreferencesController extends HttpServlet {

    private UserPreferencesDao preferencesDao;

    @Override
    public void init() {
        preferencesDao = new UserPreferencesDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int userId = currentUserId(req);
        UserPreferences prefs = preferencesDao.findByUserId(userId).orElseGet(() -> {
            UserPreferences empty = new UserPreferences();
            empty.setUserId(userId);
            return empty;
        });

        req.setAttribute("prefs", prefs);
        req.setAttribute("currentPage", "account");
        req.setAttribute("accountTab", "preferences");
        consumeFlash(req);
        req.getRequestDispatcher("/WEB-INF/views/account/preferences.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        int userId = currentUserId(req);

        UserPreferences prefs = new UserPreferences();
        prefs.setUserId(userId);
        prefs.setPlantInterests(trimAndLimit(req.getParameter("plantInterests"), 300));
        prefs.setDecorStyles(trimAndLimit(req.getParameter("decorStyles"), 300));
        prefs.setSpaceType(trimAndLimit(req.getParameter("spaceType"), 50));
        prefs.setCareLevel(trimAndLimit(req.getParameter("careLevel"), 50));
        prefs.setNotes(trimAndLimit(req.getParameter("notes"), 1000));

        if (preferencesDao.upsertByUserId(prefs)) {
            flashSuccess(req, "Đã lưu sở thích của bạn.");
        } else {
            flashError(req, "Không thể lưu sở thích, vui lòng thử lại.");
        }
        resp.sendRedirect(req.getContextPath() + "/account/preferences");
    }

    private int currentUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        return user.getUserId();
    }

    private void flashSuccess(HttpServletRequest req, String message) {
        req.getSession(false).setAttribute("accountFlashSuccess", message);
    }

    private void flashError(HttpServletRequest req, String message) {
        req.getSession(false).setAttribute("accountFlashError", message);
    }

    private void consumeFlash(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return;
        Object success = session.getAttribute("accountFlashSuccess");
        Object error = session.getAttribute("accountFlashError");
        if (success != null) {
            req.setAttribute("flashSuccess", success);
            session.removeAttribute("accountFlashSuccess");
        }
        if (error != null) {
            req.setAttribute("flashError", error);
            session.removeAttribute("accountFlashError");
        }
    }

    private String trimAndLimit(String raw, int maxLen) {
        if (raw == null) return null;
        String trimmed = raw.trim();
        if (trimmed.isEmpty()) return null;
        return trimmed.length() > maxLen ? trimmed.substring(0, maxLen) : trimmed;
    }
}
