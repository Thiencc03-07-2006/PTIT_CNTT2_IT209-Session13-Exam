# BÀI THỰC HÀNH: ĐÓNG GÓI VÀ CHẠY CAMPUS HUB VỚI DOCKER

## Thông tin sinh viên
- **Họ và tên**: Cao Chí Thiện
- **Mã sinh viên**: PTIT-HN-135
- **Lớp / Khóa**: HN-KS24-CNTT2

---

## 1. Công nghệ sử dụng
- **Backend**: Java 21, Spring Boot 3.5.7, Gradle 8.14.3, Spring Data JPA, Flyway, Spring Boot Actuator.
- **Database**: MySQL 8.0.
- **Containerization**: Docker, Docker Compose.

---

## 2. Các tệp cấu hình Docker
- `Dockerfile`: Multi-stage build đóng gói ứng dụng Spring Boot sang file JAR bằng Gradle Wrapper và chạy trên nền Eclipse Temurin 21 JRE Alpine (chạy dưới quyền user non-root `appuser`).
- `.dockerignore`: Loại trừ `.git`, `build`, `.gradle`, cache, file log và thư mục không cần thiết để tối ưu hóa dung lượng build context.
- `compose.yml`: Định nghĩa điều phối 2 services `backend` và `mysql`, thiết lập named volume `mysql_data`, cơ chế `healthcheck` cho cả hai service và đảm bảo `backend` chỉ khởi chạy sau khi `mysql` đạt trạng thái `service_healthy`.
- `.env.example`: Tệp mẫu định nghĩa các biến môi trường cấu hình database và port.

---

## 3. Hướng dẫn cài đặt và khởi chạy hệ thống

### Bước 1: Chuẩn bị biến môi trường (Tùy chọn)
Nếu muốn thay đổi thông tin cấu hình mặc định, tạo tệp `.env` từ `.env.example`:
```powershell
# Windows PowerShell
Copy-Item .env.example .env
```
*(Nếu không tạo file `.env`, Docker Compose sẽ tự động áp dụng các giá trị mặc định an toàn đã khai báo trong `compose.yml`)*

### Bước 2: Kiểm tra cú pháp Compose
```powershell
docker compose config
```

### Bước 3: Build Docker Image và khởi động dịch vụ
```powershell
docker compose up -d --build
```

### Bước 4: Kiểm tra trạng thái các container
```powershell
docker compose ps
```
Cả hai container `campus-hub-mysql` và `campus-hub-backend` phải hiển thị trạng thái `Up (healthy)`.

---

## 4. Kiểm tra sức khỏe hệ thống (Health Check)

Sau khi hệ thống khởi động thành công, truy cập endpoint Actuator Health từ máy host:

- **URL kiểm tra**: [http://localhost:8080/actuator/health](http://localhost:8080/actuator/health)
- **Kết quả mong đợi**: HTTP Status `200 OK`
```json
{"status":"UP"}
```

Kiểm tra nhanh bằng PowerShell:
```powershell
curl http://localhost:8080/actuator/health
```
hoặc:
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/actuator/health"
```

---

## 5. Lệnh xem log và dừng hệ thống

### Xem log thời gian thực:
```powershell
# Xem log toàn bộ hệ thống
docker compose logs -f

# Hoặc chỉ xem log backend
docker compose logs -f backend

# Hoặc chỉ xem log MySQL
docker compose logs -f mysql
```

### Dừng hệ thống:
```powershell
# Dừng và giữ lại dữ liệu trong named volume
docker compose down

# Dừng và xóa sạch dữ liệu database (nếu muốn reset từ đầu)
docker compose down -v
```

---

## 6. Xử lý sự cố thường gặp (Troubleshooting)

1. **Backend không kết nối được MySQL**:
   - Kiểm tra trạng thái container database bằng `docker compose ps`. Nếu MySQL chưa đạt trạng thái `healthy`, backend sẽ chờ theo cấu hình `depends_on: service_healthy`.
   - Xem log chi tiết của MySQL: `docker compose logs mysql`.
   - Đảm bảo MySQL hostname trong JDBC URL là `mysql` (tên service trong `compose.yml`), không được để `localhost`.

2. **Trùng cổng 8080 trên máy host**:
   - Đổi giá trị `SERVER_PORT` trong file `.env` (ví dụ `SERVER_PORT=8081`) rồi chạy lại `docker compose up -d`.

---

## 7. Minh chứng hoàn thành (Screenshots)

Sinh viên thực hiện chụp ảnh thực tế màn hình kết quả và lưu vào thư mục `screenshots/` theo danh sách:

1. `screenshots/01-docker-image.png`: Ảnh chụp terminal thực hiện lệnh `docker images` thể hiện image `campus-hub-backend` được build thành công.
2. `screenshots/02-compose-services.png`: Ảnh chụp terminal thực hiện lệnh `docker compose ps` thể hiện cả hai container `campus-hub-backend` và `campus-hub-mysql` đều ở trạng thái `Up (healthy)`.
3. `screenshots/03-actuator-health.png`: Ảnh chụp trình duyệt hoặc Postman/Curl truy cập `http://localhost:8080/actuator/health` trả về `{"status":"UP"}` với mã phản hồi HTTP `200`.
