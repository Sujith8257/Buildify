# Architecture

Buildify turns an Android phone into a **small HTTP server** that runs a **GGUF** model locally. Other devices on the same Wi‑Fi call it like a mini “Ollama on a phone.”

## High-level flow

```text
┌─────────────────────────────────────────────────────────────┐
│  Flutter (Dart) — UI only                                    │
│  • Model picker, download progress, Start/Stop, logs, IP     │
└───────────────────────────┬─────────────────────────────────┘
                            │ MethodChannel: buildify.ai/server
                            │  startServer / stopServer / getServerStatus
                            │  getLocalIp / getModelBasePath
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  Kotlin — MainActivity + AiServerService (foreground)        │
│  • Notification while running                                │
│  • Spawns native process, sets LD_LIBRARY_PATH               │
└───────────────────────────┬─────────────────────────────────┘
                            │ ProcessBuilder
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  llama.cpp — llama-server (renamed libllama-server.so)      │
│  • Loads GGUF, inference, HTTP API                           │
│  • Binds --host 0.0.0.0 --port (default 8080)                │
└───────────────────────────┬─────────────────────────────────┘
                            │ reads
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  App-private storage: files/models/<name>.gguf             │
└─────────────────────────────────────────────────────────────┘
                            ▲
                   HTTP from laptops / other phones
                   http://<phone-lan-ip>:8080/...
```

## Design rules (project)

- **Flutter** owns UI and state; it does not embed the inference runtime.
- **No Termux** and **no Python/FastAPI** inside the shipped Android app (desktop prototypes like `llamaserver.py` are optional dev tools only).
- **Foreground service** is required so Android is less likely to kill the server.
- **Bind to `0.0.0.0`** (not only `127.0.0.1`) so LAN clients can connect.

## Key source files

| Area | Location |
|------|----------|
| UI + download + channel bridge | `lib/main.dart` |
| MethodChannel handlers | `android/.../MainActivity.kt` |
| Foreground service + process | `android/.../AiServerService.kt` |
| Resolve binary path | `android/.../LlamaServerBinary.kt` |
| Native libs layout | `android/app/src/main/jniLibs/arm64-v8a/` |

See [android-llama-engine.md](android-llama-engine.md) for why the binary lives under jniLibs.
