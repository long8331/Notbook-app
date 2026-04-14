# Todo & Note Manager App

Một ứng dụng di động quản lý công việc và ghi chú cá nhân mạnh mẽ được xây dựng bằng **Flutter**, áp dụng các tiêu chuẩn **Clean Architecture** để đảm bảo khả năng mở rộng và dễ dàng bảo trì.

## 🚀 Tính năng nổi bật

- **Quản lý công việc (To-Do):** Tạo, chỉnh sửa, xóa và theo dõi tiến độ công việc một cách dễ dàng.
- **Lời nhắc thông minh:** Hẹn giờ thông báo nhắc nhở các công việc quan trọng ngay trên thiết bị thông qua _Local Notifications_.
- **Ghi chú chuẩn Rich-Text:** Soạn thảo ghi chú với đầy đủ tính năng định dạng (in đậm, in nghiêng, danh sách, hình ảnh...) sử dụng `flutter_quill`.
- **Xem theo Lịch (Calendar View):** Theo dõi công việc trực quan trên giao diện lịch tháng.
- **Hoạt động Offline 100%:** Toàn bộ dữ liệu được lưu trữ an toàn ngay trên thiết bị bằng hệ quản trị cơ sở dữ liệu `Drift` (SQLite). Không cần kết nối mạng để sử dụng cơ bản.

- ## 🛠️ Công nghệ & Thư viện cốt lõi

* **Framework:** Flutter (phiên bản SDK ^3.11.4)
* **Kiến trúc:** Clean Architecture (chia tách rõ ràng Data, Domain, Presentation)
* **Quản lý trạng thái (State Management):** Riverpod (`flutter_riverpod`, `riverpod_annotation`)
* **Định tuyến (Routing):** Go Router (`go_router`)
* **Chẩn đoán & Database:** Drift (`drift`, `sqlite3_flutter_libs`)
* **UI/UX Tương tác:** `table_calendar`, `flex_color_picker`, `google_fonts`
