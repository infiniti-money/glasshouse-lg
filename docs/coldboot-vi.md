# Kiểm tra Glasshouse không tự chạy sau khi khởi động (LG webOS 3.x)

Trên TV root webOS 3.4.x, nếu phải mở **Homebrew Channel** rồi mở
**Glasshouse** thì mới dùng được Trang chủ tùy chỉnh, hãy phân biệt:

1. **Homebrew chưa khởi động dịch vụ root sau cold boot**: các hook trong
   `/var/lib/webosbrew/init.d` chưa chạy. Glasshouse không tự khởi động được,
   dù tệp `50-tvweb` tồn tại và đúng quyền.
2. **Homebrew đã chạy nhưng hook Glasshouse hỏng/mất**: không thấy hoặc liên
   kết `/var/lib/webosbrew/init.d/50-tvweb` trỏ sai chỗ.
3. **Máy chủ Glasshouse đã chạy nhưng Custom Home chưa mở**: cần xem cấu hình
   `home.json`/tùy chọn **Mở Trang chủ khi bật TV**, loại khởi động
   (cold boot so với standby), lý do power-on và log
   `Glasshouse Home not opened`.

## Chẩn đoán an toàn

**Trước khi mở Homebrew Channel hoặc Glasshouse bằng tay sau khi bật TV**, kết
nối từ máy tính cùng mạng:

```sh
ssh root@192.168.2.145
```

Trên TV dùng bản Glasshouse chứa tệp này, chạy:

```sh
sh /var/lib/tvweb/diagnose-startup.sh
```

Trên bản cũ chưa có tệp chẩn đoán, chạy lệnh chỉ đọc sau:

```sh
/var/lib/tvweb/tvwebctl status
ls -l /var/lib/webosbrew/startup.sh /var/lib/webosbrew/init.d/50-tvweb
ls -l /tmp/webosbrew_startup /var/luna/preferences/webosbrew_failsafe 2>/dev/null
tail -n 30 /var/lib/webosbrew/tvweb-boot.log 2>/dev/null
```

**Không chia sẻ toàn bộ `config.json`, mã QR URL, mật khẩu hoặc token.**
Các lệnh trên kiểm tra tiến trình và dấu hiệu khởi động, không đặt lại root,
không gắn Home mới và không xóa hệ thống.

## Hướng khắc phục theo kết quả

- **Không có `/tmp/webosbrew_startup` trước khi mở Homebrew**: kiểm tra
  cơ chế root tự khởi động/persistent boot hook của Homebrew Channel trước.
  Việc chép lại `50-tvweb` **không sửa được** lỗi khi chính Homebrew bootstrap
  không chạy. Không tự cài thêm cron/daemon gọi Home ở lúc khởi động.
- **Homebrew đã chạy, `50-tvweb` thiếu hoặc là liên kết hỏng**: chạy lại
  trình cài Glasshouse phiên bản đang dùng để tái tạo hook. Bản cài dạng IPK
  của Glasshouse chủ động liên kết hook đến tệp nằm trong gói ứng dụng;
  tránh thay bằng tệp sao chép tồn tại sau khi gỡ Glasshouse.
- **Có hook và máy chủ vẫn không chạy**: xem nhật ký
  `/var/lib/webosbrew/tvweb-boot.log` và `/var/lib/tvweb/tvweb.log`
  (xóa token trước khi chia sẻ). Nếu chỉ cần đưa máy chủ lên **trong phiên
  hiện tại**, chạy `/var/lib/tvweb/tvwebctl start`. Đây không phải sửa lỗi
  khởi động tự động.
- **Máy chủ chạy nhưng TV vẫn vào LG Home**: trong bảng điều khiển Glasshouse,
  chọn **Trang chủ → Chọn trình khởi chạy → Tùy chỉnh**, kiểm tra Infiniti TV
  Home được chọn. Sau đó cân nhắc bật **Mở Trang chủ khi bật TV**. Đừng bật
  cơ chế boot của Infiniti và Glasshouse cùng lúc.

Trên webOS 3.x, ngay cả khi mọi phần đều hoạt động, LG Home ribbon có thể
xuất hiện thoáng qua. Glasshouse đọc phím Home của remote, nhưng webOS 3 không
có bộ lọc phím tương đương webOS mới để ngăn ribbon ngay từ đầu.

## Khôi phục an toàn

Khi cần quay về LG Home:

```sh
/var/lib/tvweb/tvwebctl restore-glasshouse-home
```

Không dùng LG Input Hook, không xóa app hệ thống, không đổi chế độ boot ngoài
lộ trình Glasshouse.
