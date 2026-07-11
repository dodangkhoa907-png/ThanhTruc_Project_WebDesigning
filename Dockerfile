# Stage 1: Build ứng dụng với Maven và JDK 21
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
# Copy file cấu hình pom.xml và source code vào container
COPY pom.xml .
COPY src ./src
# Build file .war (bỏ qua unit test để tối ưu thời gian build)
RUN mvn clean package -DskipTests

# Stage 2: Môi trường chạy với Tomcat (Tomcat 10.1+ hỗ trợ Jakarta EE 10 và JDK 21)
FROM tomcat:10.1-jdk21
# Xóa ứng dụng ROOT mặc định của Tomcat
RUN rm -rf /usr/local/tomcat/webapps/ROOT
# Copy file .war đã build từ Stage 1 vào Tomcat và đổi tên thành ROOT.war (để chạy trên domain gốc "/")
COPY --from=build /app/target/NhietDoiXanh_Web.war /usr/local/tomcat/webapps/ROOT.war
# Mở port 8080 của container
EXPOSE 8080
# Khởi động Tomcat
CMD ["catalina.sh", "run"]
