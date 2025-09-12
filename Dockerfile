FROM python:3.13-alpine AS base


FROM base AS pre-build

ARG PYPI=https://mirrors.ustc.edu.cn/pypi/web/simple/

WORKDIR /output

COPY pyproject.toml .
COPY uv.lock .

# Install uv & export requirements.txt
RUN set -eux \
    && pip install --no-cache-dir uv -i $PYPI \
    && uv --version \
    && uv export -o requirements.txt


FROM base AS builder

ARG PYPI=https://mirrors.ustc.edu.cn/pypi/web/simple/

WORKDIR /build

COPY --from=pre-build /output/requirements.txt .

COPY . .

# Install requirements & build
RUN set -eux \
    && pip install --no-cache-dir -r requirements.txt -i $PYPI \
    \
    && mkdocs build --clean --site-dir site


FROM nginx:alpine

COPY --from=builder /build/site /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
