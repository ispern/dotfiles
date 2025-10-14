# Linux検証用Dockerfile - まっさらな環境でinstall.shをテスト
FROM ubuntu:22.04

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive

# 最小限のパッケージのみインストール（install.shが依存するもの）
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 作業ディレクトリの設定
WORKDIR /workspace

