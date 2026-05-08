# Android: llama-server engine

## Why not `assets/` + extract to `files/`?

On **Android 10+**, executing a program stored under the app’s **writable** private storage (`/data/user/0/<pkg>/files/...`) often fails with:

```text
error=13, Permission denied
```

That is **SELinux + W^X policy**, not a missing `INTERNET` permission or “storage permission.” You cannot fix it with runtime permission toggles.

## Supported approach: jniLibs + `nativeLibraryDir`

1. Ship the Android **arm64** build from [llama.cpp releases](https://github.com/ggml-org/llama.cpp/releases) (asset name like `llama-bXXXX-bin-android-arm64.tar.gz`).
2. Place files under:

   `android/app/src/main/jniLibs/arm64-v8a/`

3. **Rename** the executable:

   `llama-server` → **`libllama-server.so`**

   Android’s packager only reliably ships ELF files under jniLibs when they are named `lib*.so`.

4. Copy **all required shared libraries** next to it (`libllama.so`, `libllama-common.so`, `libggml*.so`, per-CPU `libggml-cpu-android_*.so`, etc.). See tarball listing in [troubleshooting.md](troubleshooting.md) or `jniLibs/arm64-v8a/README.txt`.

5. **`android/app/build.gradle.kts`** uses:

   ```kotlin
   packaging { jniLibs { useLegacyPackaging = true } }
   ```

   so libraries are **extracted** to `ApplicationInfo.nativeLibraryDir` at install time (required for `dlopen` / dynamic linker).

## Runtime

- **Binary path:** `context.applicationInfo.nativeLibraryDir + "/libllama-server.so"`
- **Working directory:** same folder (or set explicitly) so relative loads behave.
- **`LD_LIBRARY_PATH`:** must include `nativeLibraryDir` so `libllama.so` and friends resolve.
- **Arguments (typical):**  
  `-m <absolute-path-to-.gguf> --host 0.0.0.0 --port <port>`

## Official tarball vs random Windows build

- Use **`llama-*-bin-android-arm64.tar.gz`** from releases — **not** Windows x64 binaries.
- The tarball contains many tools (`llama-cli`, `llama-bench`, …). For Buildify you only need **`llama-server`** + the **`.so` set** it depends on (see docs / README in jniLibs).

## Emulator

For **x86_64** emulator ABI, you would need a matching jniLibs folder and binaries built for that ABI (or test on a physical arm64 device).
