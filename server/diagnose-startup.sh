#!/bin/sh
# Read-only boot diagnosis for rooted LG webOS 3.x / Glasshouse.
# It never installs a hook, starts Home, restarts SAM or edits system files.
# For tests only, GLASSHOUSE_DIAG_ROOT points at a fake filesystem tree.
set -u
ROOT=${GLASSHOUSE_DIAG_ROOT:-}
p() { printf '%s%s' "$ROOT" "$1"; }
BOOTLOG=$(p /var/lib/webosbrew/tvweb-boot.log)
HOOK=$(p /var/lib/webosbrew/init.d/50-tvweb)
HBC=$(p /var/lib/webosbrew/startup.sh)
STAGE=$(p /tmp/webosbrew_startup)
FAILSAFE=$(p /var/luna/preferences/webosbrew_failsafe)
CTL=$(p /var/lib/tvweb/tvwebctl)
NODE=$(p /usr/bin/node)
HOME_CFG=$(p /var/lib/tvweb/home.json)
SERVER=$(p /var/lib/tvweb/tvweb.js)

printf '%s\n' '=== Chẩn đoán Glasshouse sau khởi động (chỉ đọc) ==='
if [ -f "$STAGE" ]; then
  echo 'HOME BREW STARTUP: Đã chạy trong phiên khởi động hiện tại.'
else
  echo 'HOME BREW STARTUP: Không tìm thấy dấu hiệu đã chạy sau khi bật TV.'
fi
if [ -f "$HBC" ]; then
  echo 'HOME BREW BOOTSTRAP: Có tập lệnh startup.sh.'
else
  echo 'HOME BREW BOOTSTRAP: Không có startup.sh; cần kiểm tra cơ chế root tự khởi động.'
fi
if [ -e "$FAILSAFE" ]; then
  echo 'FAILSAFE: ĐANG BẬT. Không tự ý xóa cờ an toàn; tìm nguyên nhân khởi động lỗi.'
else
  echo 'FAILSAFE: Không có cờ lỗi khởi động.'
fi
if [ -L "$HOOK" ] && [ ! -e "$HOOK" ]; then
  echo 'GLASSHOUSE HOOK: Liên kết hỏng, đích không tồn tại.'
elif [ -x "$HOOK" ]; then
  echo 'GLASSHOUSE HOOK: Có và có quyền thực thi.'
elif [ -e "$HOOK" ]; then
  echo 'GLASSHOUSE HOOK: Có tệp nhưng thiếu quyền thực thi.'
else
  echo 'GLASSHOUSE HOOK: Không tồn tại.'
fi
if [ -x "$NODE" ] && [ -f "$SERVER" ]; then
  echo 'MAY CHU: Có Node.js và tvweb.js.'
else
  echo 'MAY CHU: Thiếu Node.js hoặc tvweb.js.'
fi
if [ -f "$HOME_CFG" ] && grep -q '"enabled"[[:space:]]*:[[:space:]]*true' "$HOME_CFG" 2>/dev/null; then
  echo 'GLASSHOUSE HOME: Đã bật trong home.json.'
else
  echo 'GLASSHOUSE HOME: Chưa bật hoặc chưa thể xác minh home.json.'
fi
if [ -x "$CTL" ]; then
  echo 'TRANG THAI MAY CHU:'
  "$CTL" status 2>&1 | head -n 6
else
  echo 'TRANG THAI MAY CHU: Thiếu tvwebctl.'
fi
if [ -f "$BOOTLOG" ]; then
  echo 'NHAT KY KHOI DONG:'
  # Never print arbitrary configuration, authentication tokens or QR links.
  # The allowlist contains only known boot hook status messages.
  tail -n 100 "$BOOTLOG" 2>/dev/null |
    grep -E 'starting$|Glasshouse Home not opened|Glasshouse Home opened over|could not|start failed|already running|not installed:|node not found' |
    tail -n 10 || true
else
  echo 'NHAT KY KHOI DONG: Chưa có tvweb-boot.log.'
fi
echo 'KET LUAN: Nếu Homebrew bootstrap chưa chạy, sửa liên kết Glasshouse không đủ.'
echo 'KET LUAN: Nếu bootstrap đã chạy nhưng hook thiếu/hỏng, cài lại hook bằng trình cài Glasshouse đúng phiên bản.'
echo 'AN TOAN: Không bật LG Input Hook, không xóa LG Home và không sửa phân vùng hệ thống.'
