# 多阶段构建 - 生产环境
FROM python:3.11-slim as builder

WORKDIR /docs

# 安装 git（mkdocs-git-revision-date-localized-plugin 需要）
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 构建静态文件
RUN mkdocs build

# 生产环境 - 使用 nginx 提供服务
FROM nginx:alpine

# 复制构建的静态文件
COPY --from=builder /docs/site /usr/share/nginx/html

# 复制 nginx 配置（可选）
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]