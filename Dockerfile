# Sử dụng image Ubuntu 20.04 LTS làm base để đảm bảo môi trường ổn định
FROM ubuntu:20.04

# Cài đặt các công cụ cần thiết để build MTProxy
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

# QUAN TRỌNG: Sửa đổi Makefile để thêm -lrt và -lpthread vào biến LIBS
RUN sed -i 's/LIBS = -lssl -lcrypto -lz/LIBS = -lssl -lcrypto -lz -lrt -lpthread/' Makefile

# Build MTProxy
RUN make

# Đảm bảo file mtproto-proxy có quyền thực thi
RUN chmod +x objs/bin/mtproto-proxy

# Expose cổng mặc định (443)
EXPOSE 443

# Lệnh để chạy MTProxy khi container khởi động
# ĐÃ SỬA: Thay --secret bằng --mtproto-secret hoặc -S
# ĐÃ SỬA: Thay --tag bằng --proxy-tag hoặc -P
# ĐÃ SỬA: Thay --port bằng -p
CMD ["/app/objs/bin/mtproto-proxy", "--mtproto-secret", "$SECRET", "-p", "$PORT", "--nat-info", "0.0.0.0:$PORT", "--proxy-ipv6", "--max-conn", "8000", "--proxy-tag", "$TAG"]
