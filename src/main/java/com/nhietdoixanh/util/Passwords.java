package com.nhietdoixanh.util;

import org.mindrot.jbcrypt.BCrypt;

/** Tiện ích hash & kiểm tra mật khẩu bằng BCrypt. */
public final class Passwords {

    private Passwords() { }

    public static String hash(String plain) {
        return BCrypt.hashpw(plain, BCrypt.gensalt(10));
    }

    public static boolean matches(String plain, String hash) {
        if (plain == null || hash == null || hash.isEmpty()) return false;
        try {
            return BCrypt.checkpw(plain, hash);
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}
