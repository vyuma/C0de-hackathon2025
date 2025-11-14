from __future__ import annotations

import os
from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn


app = FastAPI(title="C0de Hackathon Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/greeting")
def greeting(name: str | None = None) -> dict[str, str]:
    base_message = "Hello from the backend"
    if name:
        base_message = f"{base_message}, {name}!"
    else:
        base_message = f"{base_message}!"

    return {
        "message": base_message,
        "timestamp": datetime.now(tz=timezone.utc).isoformat(),
    }


def main() -> None:
    port = int(os.environ.get("BACKEND_PORT", "8000"))
    uvicorn.run(app, host="0.0.0.0", port=port)


if __name__ == "__main__":
    main()
