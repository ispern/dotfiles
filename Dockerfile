# Linux検証用Dockerfile - install.sh をフルに走らせる Phase 2 テスト土台
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      curl wget ca-certificates xz-utils sudo git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Determinate Installer は内部 sudo 昇格を行うため build 時は root で実行。
# 非 systemd コンテナでも動作するよう `--init none` を付ける。
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install linux --init none --no-confirm

# flake が想定する username `h.matsuoka` を作成し、Nix store を読み書きできるようにする。
# `--badname` はドット入りユーザー名を許可（Ubuntu 24.04 のデフォルト regex で必要）。
# `extra-trusted-users` 経由で h.matsuoka が nix-daemon を経由せず直接 store を扱えるようにする。
RUN useradd -m -s /bin/bash --badname h.matsuoka && \
    echo "h.matsuoka ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/h.matsuoka && \
    chmod 0440 /etc/sudoers.d/h.matsuoka && \
    echo "extra-trusted-users = h.matsuoka root" >> /etc/nix/nix.conf && \
    chown -R h.matsuoka:h.matsuoka /nix

USER h.matsuoka
ENV USER=h.matsuoka HOME=/home/h.matsuoka
ENV PATH=/nix/var/nix/profiles/default/bin:/home/h.matsuoka/.nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

WORKDIR /workspace
