# Models and downloads

## What runs on the phone

- Only **open-weight** models in **GGUF** format.
- The app uses **llama.cpp** (`llama-server`) as the engine. It does **not** load closed APIs (Gemini Flash, GPT‑4, Claude, etc.) as downloadable weights.

## Where files live on device

- **Directory:** app-private  
  `/data/data/<applicationId>/files/models/`
- **Flutter** gets the path via MethodChannel `getModelBasePath` (Kotlin: `File(filesDir, "models")`).
- **Catalog `fileName`** in `lib/main.dart` must match the on-disk filename exactly.

## In-app download

- The app streams HTTP(S) from curated URLs (Hugging Face `resolve` links) into  
  `files/models/<fileName>`.
- Partial downloads use a `*.part` file; success renames to the final `.gguf`.
- On startup, existing files larger than ~1 MB are detected and marked **Downloaded**.

## Manual install via ADB (developers)

The app sandbox is not writable from normal “Downloads” without **`run-as`** or a future “Import file” UX.

**Problem:** app UID often **cannot read** `/data/local/tmp` when using `run-as cp`.

**Workaround — pipe as `shell`, write as app:**

```bat
adb shell run-as com.example.buildify_flutter mkdir -p files/models
adb shell "cat /data/local/tmp/model.gguf | run-as com.example.buildify_flutter sh -c 'cat > files/models/your-exact-filename.gguf'"
```

Replace `com.example.buildify_flutter` if you change `applicationId`.

## Hugging Face and filenames

- URLs use `/resolve/main/...` for direct file access.
- GGUF names often include quantization (`Q4_K_M`, etc.). The **`ModelProfile.fileName`** in Dart must match what you actually store.

## Wi‑Fi vs mobile data

- Large GGUFs (600 MB–2.5 GB). Consider adding a “Wi‑Fi only” toggle in a future iteration (not always enforced today).
