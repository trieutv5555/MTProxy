# Sử dụng image Ubuntu 20.04 LTS làm base để đảm bảo môi trường ổn định
FROM ubuntu:20.04

# Cài đặt các công cụ cần thiết để build MTProxy
# Thêm `sed` để chỉnh sửa Makefile
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        git \
        wget \
        net-tools \
        sed && \
    rm -rf /var/lib/apt/lists/*

# Clone mã nguồn MTProxy vào thư mục /app
WORKDIR /app
RUN git clone https://github.com/TelegramMessenger/MTProxy.git .

# **QUAN TRỌNG:** Sửa đổi Makefile để thêm -lrt và -lpthread vào biến LIBS
# Dòng 92 trong Makefile gốc là LIBS = -lssl -lcrypto -lz
# Lệnh sed này sẽ thêm " -lrt -lpthread" vào cuối dòng đó
RUN sed -i 's/LIBS = -lssl -lcrypto -lz/LIBS = -lssl -lcrypto -lz -lrt -lpthread/' Makefile

# Build MTProxy
# Không cần truyền LDFLAGS nữa vì đã sửa Makefile
RUN make

# Expose cổng mặc định (443)
EXPOSE 443

# Lệnh để chạy MTProxy khi container khởi động
# $SECRET và $TAG sẽ được Render cung cấp từ biến môi trường
# --ipv6 là tùy chọn, bạn có thể bỏ đi nếu không cần IPv6
# --nat-info được khuyến nghị để xử lý NAT đúng cách
# --max-conn 8000 (hoặc số khác) là giới hạn kết nối đồng thời
# --allow-unsafe-secret nếu bạn dùng secret có `dd` ở đầu và cần nó được chấp nhận (hầu hết các bản build hiện đại tự nhận ra)
CMD ["./mtproxy", "--secret", "$SECRET", "--port", "$PORT", "--nat-info", "0.0.0.0:$PORT", "--proxy-ipv6", "--max-conn", "8000", "--tag", "$TAG"]
