# Sử dụng image Ubuntu làm base để cài đặt các dependency cần thiết
FROM ubuntu:latest

# Cài đặt các công cụ cần thiết để build MTProxy
# Thêm `cmake` và `pkg-config` có thể hữu ích cho một số môi trường build
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        git \
        wget \
        net-tools \
        cmake \
        pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Clone mã nguồn MTProxy vào thư mục /app
WORKDIR /app
RUN git clone https://github.com/TelegramMessenger/MTProxy.git .

# Build MTProxy
# Thêm LDFLAGS để liên kết các thư viện cần thiết: -lrt (realtime) và -lpthread (POSIX threads)
# Đây là nguyên nhân phổ biến gây ra lỗi "ld returned 1 exit status"
RUN make LDFLAGS="-lrt -lpthread"

# Expose cổng mặc định (443)
EXPOSE 443

# Lệnh để chạy MTProxy khi container khởi động
# $SECRET và $TAG sẽ được Render cung cấp từ biến môi trường
# --ipv6 là tùy chọn, bạn có thể bỏ đi nếu không cần IPv6
# --nat-info được khuyến nghị để xử lý NAT đúng cách
# --max-conn 8000 (hoặc số khác) là giới hạn kết nối đồng thời
# --allow-unsafe-secret nếu bạn dùng secret có `dd` ở đầu và cần nó được chấp nhận (hầu hết các bản build hiện đại tự nhận ra)
CMD ["./mtproxy", "--secret", "$SECRET", "--port", "$PORT", "--nat-info", "0.0.0.0:$PORT", "--proxy-ipv6", "--max-conn", "8000", "--tag", "$TAG"]
