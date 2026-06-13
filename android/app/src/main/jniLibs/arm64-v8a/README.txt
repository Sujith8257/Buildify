Buildify AI Server — bundled native binaries (Android arm64)

Why this folder (and not assets/):
  Android 10+ refuses to execute files from app writable storage
  (W^X + SELinux). Files shipped under jniLibs/<abi>/ are extracted
  by the package manager into ApplicationInfo.nativeLibraryDir at
  install time, which IS allowed to execute.

Required files in this folder:
  libllama-server.so          (renamed from llama.cpp's "llama-server")
  libllama.so
  libllama-common.so
  libggml.so
  libggml-base.so
  libggml-cpu-android_armv8.0_1.so
  libggml-cpu-android_armv8.2_1.so
  libggml-cpu-android_armv8.2_2.so
  libggml-cpu-android_armv8.6_1.so
  libggml-cpu-android_armv9.0_1.so
  libggml-cpu-android_armv9.2_1.so
  libggml-cpu-android_armv9.2_2.so
  libggml-rpc.so       (optional but small, keep)
  libmtmd.so           (optional, only for multimodal models)
  libcloudflared.so    (Cloudflare tunnel client for Android arm64)
  LICENSE              (keep for legal)

Quick copy script (PowerShell, edit $src to match your tarball folder):

  $src = "C:\Users\navad\Buildify\llama-b9075"
  $dst = "C:\Users\navad\Buildify\android\app\src\main\jniLibs\arm64-v8a"
  New-Item -ItemType Directory -Force -Path $dst | Out-Null

  # The executable -> rename to libllama-server.so
  Copy-Item -Force (Join-Path $src "llama-server") `
            -Destination (Join-Path $dst "libllama-server.so")

  # All the .so files
  $libs = @(
    "libllama.so","libllama-common.so","libggml.so","libggml-base.so",
    "libggml-cpu-android_armv8.0_1.so","libggml-cpu-android_armv8.2_1.so",
    "libggml-cpu-android_armv8.2_2.so","libggml-cpu-android_armv8.6_1.so",
    "libggml-cpu-android_armv9.0_1.so","libggml-cpu-android_armv9.2_1.so",
    "libggml-cpu-android_armv9.2_2.so","libggml-rpc.so","libmtmd.so",
    "LICENSE"
  )
  foreach ($f in $libs) { Copy-Item -Force (Join-Path $src $f) -Destination $dst }

  # cloudflared (arm64) — build from source, output MUST be named libcloudflared.so
  #
  # PowerShell (Go 1.21+ on Windows/macOS/Linux):
  #   git clone --depth=1 https://github.com/cloudflare/cloudflared.git
  #   cd cloudflared
  #   $env:CGO_ENABLED="0"; $env:GOOS="android"; $env:GOARCH="arm64"
  #   go build -trimpath -ldflags="-s -w" -o libcloudflared.so ./cmd/cloudflared/
  #   Copy-Item -Force .\libcloudflared.so <this-folder>\libcloudflared.so
  #
  # Verify: file size ~25–30 MB, ELF magic 7F 45 4C 46. Rebuild APK after copy.
  # Note: lib*.so here is gitignored — commit via Git LFS or ship in release artifacts.
  #
  # Android DNS: run scripts/build-cloudflared-android.ps1 from repo root (patches quick
  # tunnel registration, edge SRV discovery, and feature TXT lookups to use 1.1.1.1:53).
  # Without the patch you may see:
  #   lookup api.trycloudflare.com on [::1]:53: connection refused
  #   lookup region1.v2.argotunnel.com on [::1]:53: connection refused
  # Workaround: Settings → Network → Private DNS → Off.

After updating these files, fully rebuild the APK (flutter run).

The app:
  1. Resolves nativeLibraryDir at runtime.
  2. Launches llama-server:  libllama-server.so -m <model.gguf> --host 0.0.0.0 --port <port>
  3. Launches cloudflared:   libcloudflared.so tunnel --url http://localhost:<port>
  4. Sets LD_LIBRARY_PATH to nativeLibraryDir so the .so files are found.
