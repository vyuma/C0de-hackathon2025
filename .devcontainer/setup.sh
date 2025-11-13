#!/usr/bin/env bash
set -euo pipefail

# =============================================================
# Devcontainer post-create setup script (repository-aware)
# - Backend: uv で back/ 用の仮想環境を構築し依存を同期
# - Frontend: Volta + Corepack + npm で frontend/ を初期化
# - 何度実行しても安全（冪等）
# =============================================================

echo "[setup] Start post-create setup..."

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
BACKEND_DIR="$ROOT_DIR/back"
FRONTEND_DIR="$ROOT_DIR/frontend"

cd "$ROOT_DIR"

has_cmd() { command -v "$1" >/dev/null 2>&1; }

read_python_requirement() {
  local pyproject_path="$1"
  [[ -f "$pyproject_path" ]] || return 0
  PYPROJECT_PATH="$pyproject_path" python3 - <<'PY' || true
import os
import re
import sys
try:
    import tomllib  # Python 3.11+
except ModuleNotFoundError:
    sys.exit(0)

path = os.environ.get("PYPROJECT_PATH")
if not path:
    sys.exit(0)

with open(path, "rb") as fp:
    data = tomllib.load(fp)

spec = data.get("project", {}).get("requires-python") or ""
match = re.search(r"(\d+(?:\.\d+)*)", spec)
if match:
    print(match.group(1))
PY
}

setup_backend_python() {
  local pyproject_file="$BACKEND_DIR/pyproject.toml"
  if [[ ! -f "$pyproject_file" ]]; then
    echo "[python] back/ に pyproject.toml がありません。スキップします。"
    return 0
  fi
  if ! has_cmd uv; then
    echo "[python] 'uv' が見つかりません。Dockerfile 経由で導入されている想定です。"
    return 1
  fi

  echo "[python] backend 仮想環境を準備します..."
  local required_python
  required_python="$(read_python_requirement "$pyproject_file" | tr -d '\r')"
  if [[ -n "$required_python" ]]; then
    uv python install "$required_python" || true
  else
    uv python install 3.12 || true
  fi

  local venv_dir="$BACKEND_DIR/.venv"
  if [[ ! -d "$venv_dir" ]]; then
    uv venv "$venv_dir"
  fi

  pushd "$BACKEND_DIR" >/dev/null
  UV_PYTHON="$venv_dir/bin/python" uv sync
  if [[ -x "$venv_dir/bin/python" ]]; then
    echo "[python] $( "$venv_dir/bin/python" --version )"
  fi
  popd >/dev/null
}

setup_frontend_node() {
  local package_json="$FRONTEND_DIR/package.json"
  if [[ ! -f "$package_json" ]]; then
    echo "[node] frontend/ に package.json がありません。スキップします。"
    return 0
  fi
  if ! has_cmd volta; then
    echo "[node] 'volta' が見つかりません。Dockerfile に含まれている想定です。"
    return 1
  fi

  echo "[node] frontend 用の Node.js を準備します..."
  volta install node@20 || true

  if has_cmd corepack; then
    corepack enable || true
  fi

  pushd "$FRONTEND_DIR" >/dev/null
  if [[ -f pnpm-lock.yaml ]]; then
    echo "[node] pnpm-lock.yaml を検出。pnpm で依存を導入します。"
    if has_cmd corepack; then
      corepack prepare pnpm@latest --activate || true
    else
      npm -g install pnpm || true
    fi
    pnpm install
  elif [[ -f yarn.lock ]]; then
    echo "[node] yarn.lock を検出。yarn で依存を導入します。"
    if has_cmd corepack; then
      corepack prepare yarn@stable --activate || true
    fi
    yarn install --frozen-lockfile || yarn install
  else
    echo "[node] npm (package-lock.json) で依存を導入します。"
    if [[ -f package-lock.json ]]; then
      npm ci || npm install
    else
      npm install
    fi
  fi
  echo "[node] Node $(node -v), npm $(npm -v)"
  popd >/dev/null
}

setup_backend_python
setup_frontend_node

echo "[setup] Done."
