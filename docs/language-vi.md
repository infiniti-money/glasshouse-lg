# Sử dụng Glasshouse bằng tiếng Việt

Glasshouse có cơ chế đa ngôn ngữ trong trình duyệt và ứng dụng TV. Bản dịch
`server/assets/i18n/vi.json` của nhánh này là **giai đoạn đầu**, ưu tiên
Trang chủ, trình khởi chạy tùy chỉnh, thanh bên, ứng dụng, điều khiển và các
thông báo thông dụng. Chưa phải bản dịch toàn bộ; những mục chưa dịch vẫn
hiển thị tiếng Anh để tránh hiểu sai các cài đặt kỹ thuật.

## Chọn tiếng Việt trên bảng điều khiển

1. Mở địa chỉ bảng điều khiển Glasshouse của TV (mặc định
   `http://192.168.2.145:8080/` nếu chưa đổi cổng).
2. Mở **Preferences / Tùy chọn** ở cuối thanh bên.
3. Tại **Language / Ngôn ngữ**, chọn **Tiếng Việt (partial)**.
4. Trang tự tải lại; những chuỗi đã dịch hiển thị bằng tiếng Việt.

Có thể xem nhanh qua tham số `?lang=vi`. Vì cài đặt ngôn ngữ được lưu
trên **từng trình duyệt**, nếu muốn TV và máy tính cùng dùng tiếng Việt cần
chọn trên cả hai.

## Các mục chính

- **Home** → **Trang chủ**
- **Choose your launcher** → **Chọn trình khởi chạy**
- **Custom launcher** → **Trình khởi chạy tùy chỉnh**
- **Upload a launcher** → **Tải lên trình khởi chạy**
- **LG Home** → **Trang chủ LG**
- **Apps** → **Ứng dụng**
- **Control** → **Điều khiển**
- **Server** → **Máy chủ**

## Kỹ thuật

Dữ liệu dịch có `text` (tiếng Việt) và `from` (tiếng Anh gốc) để bỏ
qua bản dịch cũ khi mã nguồn tiếng Anh đổi. Không dịch khóa cấu hình, tên
ứng dụng, chuỗi số và dữ liệu người dùng. Bản dịch không thay đổi hành vi của
phím Home, các tùy chọn root hoặc chế độ khôi phục LG Home.

Lệnh kiểm tra nguồn: `python3 scripts/check-strings.py`, rồi
`node test/test-i18n-pick.js`.

**Bổ sung sau:** hoàn thiện các mô tả dài, menu ít dùng và mọi thông báo
từ máy chủ; khi đạt đầy đủ mới bỏ đánh dấu `PARTIAL.vi`.
