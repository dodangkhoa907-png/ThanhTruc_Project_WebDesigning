package com.nhietdoixanh.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpServletResponseWrapper;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.zip.GZIPOutputStream;

@WebFilter(filterName = "GzipFilter", urlPatterns = {"/*"}, asyncSupported = true)
public class GzipFilter implements Filter {

    private static final int MIN_SIZE = 256;

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String ae = request.getHeader("Accept-Encoding");
        if (ae == null || !ae.contains("gzip")) {
            chain.doFilter(req, res);
            return;
        }

        String path = request.getServletPath();
        if (path != null && (path.endsWith(".png") || path.endsWith(".jpg")
                || path.endsWith(".jpeg") || path.endsWith(".gif")
                || path.endsWith(".webp") || path.endsWith(".ico"))) {
            chain.doFilter(req, res);
            return;
        }

        GzipResponseWrapper wrapper = new GzipResponseWrapper(response);
        chain.doFilter(req, wrapper);
        wrapper.flushBuffer();

        byte[] data = wrapper.getData();
        if (data == null || data.length < MIN_SIZE) {
            if (data != null) {
                response.getOutputStream().write(data);
            }
            return;
        }

        ByteArrayOutputStream gzBuf = new ByteArrayOutputStream(data.length / 2);
        try (GZIPOutputStream gz = new GZIPOutputStream(gzBuf)) {
            gz.write(data);
        }

        byte[] compressed = gzBuf.toByteArray();
        if (compressed.length < data.length) {
            response.setHeader("Content-Encoding", "gzip");
            response.setHeader("Vary", "Accept-Encoding");
            response.setContentLength(compressed.length);
            response.getOutputStream().write(compressed);
        } else {
            response.setContentLength(data.length);
            response.getOutputStream().write(data);
        }
    }

    private static class GzipResponseWrapper extends HttpServletResponseWrapper {
        private final ByteArrayOutputStream buf = new ByteArrayOutputStream(8192);
        private ServletOutputStream sos;
        private PrintWriter pw;

        GzipResponseWrapper(HttpServletResponse response) {
            super(response);
        }

        @Override
        public ServletOutputStream getOutputStream() {
            if (sos == null) {
                sos = new ServletOutputStream() {
                    @Override public void write(int b) { buf.write(b); }
                    @Override public void write(byte[] b, int off, int len) { buf.write(b, off, len); }
                    @Override public boolean isReady() { return true; }
                    @Override public void setWriteListener(WriteListener l) {}
                };
            }
            return sos;
        }

        @Override
        public PrintWriter getWriter() {
            if (pw == null) {
                String charset = getCharacterEncoding();
                if (charset == null) charset = "UTF-8";
                try {
                    pw = new PrintWriter(new OutputStreamWriter(buf, charset), false);
                } catch (java.io.UnsupportedEncodingException e) {
                    pw = new PrintWriter(new OutputStreamWriter(buf), false);
                }
            }
            return pw;
        }

        @Override
        public void flushBuffer() {
            if (pw != null) pw.flush();
        }

        @Override
        public void setContentLength(int len) { }

        @Override
        public void setContentLengthLong(long len) { }

        byte[] getData() {
            if (pw != null) pw.flush();
            return buf.size() > 0 ? buf.toByteArray() : null;
        }
    }
}
