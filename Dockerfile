# ==============================================================================
# Stage 1: Build Application with Gradle Wrapper
# ==============================================================================
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Sao chép các tệp cấu hình Gradle và wrapper
COPY backend/gradle/ ./gradle/
COPY backend/gradlew backend/build.gradle backend/settings.gradle ./

# Chuẩn hóa line ending (CRLF sang LF cho Windows) và cấp quyền thực thi
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew

# Sao chép mã nguồn backend
COPY backend/src/ ./src/

# Đóng gói file JAR ứng dụng (bỏ qua unit test trong Docker build)
RUN ./gradlew bootJar --no-daemon -x test

# ==============================================================================
# Stage 2: Runtime Environment
# ==============================================================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Cài đặt curl phục vụ container healthcheck
RUN apk --no-cache add curl

# Tạo người dùng non-root vì lý do bảo mật
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Sao chép file JAR đã build từ stage builder
COPY --from=builder /app/build/libs/campus-hub-1.0.0.jar app.jar

# Phân quyền cho non-root user
RUN chown appuser:appgroup app.jar

USER appuser:appgroup

# Công khai cổng HTTP của Spring Boot backend
EXPOSE 8080

# Lệnh khởi chạy ứng dụng
ENTRYPOINT ["java", "-jar", "app.jar"]
