# ============================================================================
# Stage 1 — Build .war
# ============================================================================
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# QUAN TRỌNG: copy pom.xml TRƯỚC và tải dependency ở một layer riêng.
# Trước đây `COPY src` nằm trên lệnh build nên chỉ cần sửa 1 dòng code là Docker
# huỷ cache và tải lại TOÀN BỘ dependency Maven -> deploy rất lâu.
# Tách ra thế này: sửa code chỉ chạy lại bước compile, dependency lấy từ cache.
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests

# ============================================================================
# Stage 2 — Runtime (JRE thay vì JDK: image nhẹ hơn -> Render kéo/khởi động nhanh hơn)
# ============================================================================
FROM tomcat:10.1-jre21-temurin
RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY --from=build /app/target/NhietDoiXanh_Web.war /usr/local/tomcat/webapps/ROOT.war

# Múi giờ VN cho log/đơn hàng hiển thị đúng giờ.
ENV TZ=Asia/Ho_Chi_Minh

# Tinh chỉnh JVM cho gói Render free (RAM ~512MB, CPU chia sẻ):
#  - MaxRAMPercentage: dùng theo % RAM container thay vì heap mặc định quá lớn
#  - TieredStopAtLevel=1 + XX:+UseSerialGC: rút ngắn thời gian khởi động (cold start)
#  - urandom: tránh treo khi JVM chờ entropy lúc khởi tạo SecureRandom
ENV JAVA_OPTS="-XX:MaxRAMPercentage=70 -XX:TieredStopAtLevel=1 -XX:+UseSerialGC -Djava.security.egd=file:/dev/./urandom -Dfile.encoding=UTF-8"

EXPOSE 8080
CMD ["catalina.sh", "run"]
