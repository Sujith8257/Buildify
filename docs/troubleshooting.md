# Troubleshooting

## `Cannot run program ".../files/llama/llama-server": error=13, Permission denied`

**Cause:** Trying to execute a binary extracted into app **writable** storage.  
**Fix:** Use **jniLibs** + `libllama-server.so` under `android/app/src/main/jniLibs/arm64-v8a/` and code that launches from `nativeLibraryDir`. See [android-llama-engine.md](android-llama-engine.md).

## `Missing llama-server` / process exits immediately

- Confirm **`libllama-server.so`** exists under jniLibs and you did a **full reinstall** (`flutter run` after clean if needed).
- Confirm you copied **all** required `.so` files from the **Android arm64** tarball, not only the executable.
- Check logcat:  
  `adb logcat -s AiServerService LlamaServerBinary`

## Wrong architecture (e.g. Windows binary on phone)

Symptoms: immediate crash, `Exec format error`, or linker errors.  
**Fix:** Use **`llama-*-bin-android-arm64.tar.gz`** from [llama.cpp releases](https://github.com/ggml-org/llama.cpp/releases).

## Model path / “Model missing”

- File must be under `files/models/` with the **exact** name in `ModelProfile.fileName`.
- Use app logs or `adb shell run-as <pkg> ls files/models`.

## ADB: `cp: ... Permission denied` into `files/models`

**Cause:** `run-as` cannot read `/data/local/tmp` as source.  
**Fix:** Pipe: `cat /data/local/tmp/x | run-as ... sh -c 'cat > files/models/x'`. See [models-and-downloads.md](models-and-downloads.md).

## LAN cannot reach phone

- Server must bind **`0.0.0.0`** (Buildify passes this to llama-server).
- Same Wi‑Fi segment; some routers isolate clients (“AP isolation”).
- Firewall / VPN on PC or phone.
- Wrong IP (Wi‑Fi IP changes with DHCP).

## UI stuck on “Starting”

- Missing engine binary or model file — check logcat and `lastError` in native status.
- First start after install: allow **notification** permission if prompted (foreground service).

## Git / huge repo

- **jniLibs** `.so` files are large; use **Git LFS** or document manual copy if GitHub rejects file size.
