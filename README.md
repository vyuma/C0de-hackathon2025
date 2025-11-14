## C0deハッカソン

Next.js 16 + TypeScript（`front/`）と FastAPI（`back/`）で構成されたシンプルな
フルスタック構成です。両者を同時に起動するとフロントエンドがサーバーコンポーネントから
バックエンドの REST API を叩き、取得したメッセージを画面へ表示します。

### Backend

```bash
cd back
uv sync  # もしくは `pip install -r requirements.txt`
uv run uvicorn main:app --host 0.0.0.0  --port 8000

```

エンドポイント:

- `GET /api/health` : ヘルスチェック
- `GET /api/greeting?name=YOUR_NAME` : フロントエンドが利用するメッセージ API

ポートを変更したい場合は `BACKEND_PORT` 環境変数を設定してください。

### Frontend

```bash
cd front
npm install
NEXT_PUBLIC_BACKEND_URL="http://127.0.0.1:8000" npm run dev
```

`NEXT_PUBLIC_BACKEND_URL` は `.env.local` でも設定可能です（未設定時は
`http://127.0.0.1:8000` にフォールバックします）。

### 動作確認

1. 上記手順で FastAPI と Next.js の両方を起動
2. ブラウザで http://localhost:3000 を開く
3. 画面中央の「最新のバックエンドレスポンス」に API から取得したメッセージが表示されれば成功です 🎉

