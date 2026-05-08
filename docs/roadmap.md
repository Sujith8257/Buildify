# Roadmap (reference)

Rough phases discussed during development. Status is indicative — check the codebase for truth.

| Phase | Topic | Status |
|-------|--------|--------|
| 1 | Flutter ↔ Kotlin MethodChannel (`buildify.ai/server`) | Done |
| 2 | Foreground service, notification, status | Done |
| 3 | Run llama.cpp server on device | Done (jniLibs + `libllama-server.so`) |
| 4 | Real GGUF download + progress + verify | Done (HTTP stream in `lib/main.dart`) |
| 5 | JNI / `libllama.so` in-process (performance) | Not started |
| — | Chat tab calls real HTTP instead of simulated text | Optional next |
| — | Wi‑Fi-only download toggle | Optional |
| — | API key + rate limit for LAN | Optional |
| — | QR code for base URL | Optional |
| — | Idle / thermal / battery auto-stop | Optional |

## Native binary source of truth

- Prefer **official** [llama.cpp Android arm64 release tarball](https://github.com/ggml-org/llama.cpp/releases).
- Document exact copy list in `android/app/src/main/jniLibs/arm64-v8a/README.txt`.
