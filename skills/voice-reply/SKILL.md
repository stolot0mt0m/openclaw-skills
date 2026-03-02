---
name: voice-reply
version: 1.1.0
description: |
  Local text-to-speech using Piper voices via sherpa-onnx. 100% offline, no API keys required.
  Use when user asks for a voice reply, audio response, spoken answer, or wants to hear something read aloud.
  Supports multiple languages including German (thorsten) and English (ryan) voices.
  Outputs Telegram-compatible voice notes with [[audio_as_voice]] tag.
metadata:
  openclaw:
    emoji: "🎤"
    os: ["linux"]
    requires:
      bins: ["ffmpeg"]
      env: ["SHERPA_ONNX_DIR", "PIPER_VOICES_DIR"]
---

# Voice Reply

Generate voice audio replies using local Piper TTS via sherpa-onnx. Completely offline, no cloud APIs needed.

## Runtime Entrypoint

The skill entrypoint is **`{baseDir}/bin/voice-reply`** — a self-contained Bash script included in this package.
It is the only file you need to run after installation. No additional wrapper needs to be downloaded or built.

## Features

- **100% Local** - No internet connection required after setup
- **No API Keys** - Free to use, no accounts needed
- **Multi-language** - German and English voices included
- **Telegram Ready** - Outputs voice notes that display as bubbles
- **Auto-detect Language** - Automatically selects voice based on text
- **User-local Install** - No root/sudo required (default)

## System Requirements

| Resource | Minimum |
|----------|---------|
| OS | Linux x86_64 (Ubuntu 22.04+ recommended) |
| Disk | ~200 MB (sherpa-onnx + 2 voices) |
| RAM | ~500 MB during synthesis |
| Dependencies | ffmpeg, curl |

## Prerequisites

1. **sherpa-onnx** runtime installed (via `scripts/install.sh`)
2. **Piper voice models** downloaded (via `scripts/install.sh`)
3. **ffmpeg** for audio conversion

## Installation

### Quick Install (User-Local, No Root Required)

```bash
cd scripts
./install.sh
```

Installs to `~/.local/share/voice-reply/`. No sudo needed (except for ffmpeg if missing).

### System-Wide Install

```bash
cd scripts
sudo ./install.sh --system
```

Installs to `/opt/sherpa-onnx` and `/opt/piper-voices`.

### Options

| Flag | Description |
|------|-------------|
| `--system` | Install to /opt (requires root) |
| `--prefix PATH` | Custom install prefix |
| `--german-only` | Only install German voice |
| `--english-only` | Only install English voice |
| `--skip-checksums` | Skip SHA256 verification (not recommended) |

### Manual Installation

See [README.md](README.md) for step-by-step manual installation instructions.

### After Installation

Set environment variables (the installer prints the exact values):

```bash
export SHERPA_ONNX_DIR="$HOME/.local/share/voice-reply/sherpa-onnx"
export PIPER_VOICES_DIR="$HOME/.local/share/voice-reply/piper-voices"
```

## Supply Chain Verification

All downloads are verified against SHA256 checksums published by the upstream project:

- **sherpa-onnx**: checksums from [v1.12.23 release](https://github.com/k2-fsa/sherpa-onnx/releases/tag/v1.12.23)
- **Voice models**: checksums from [tts-models release](https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models)

Use `--skip-checksums` to bypass (not recommended).

## Usage

```bash
{baseDir}/bin/voice-reply "Text to speak" [language]
```

### Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| text | The text to convert to speech | (required) |
| language | `de` for German, `en` for English | auto-detect |

### Examples

```bash
# German (explicit)
{baseDir}/bin/voice-reply "Hallo, ich bin dein Assistent!" de

# English (explicit)
{baseDir}/bin/voice-reply "Hello, I am your assistant!" en

# Auto-detect (detects German from umlauts and common words)
{baseDir}/bin/voice-reply "Guten Tag, wie geht es dir?"

# Auto-detect (defaults to English)
{baseDir}/bin/voice-reply "The weather is nice today."
```

## Output Format

The script outputs two lines that OpenClaw processes for Telegram:

```
[[audio_as_voice]]
MEDIA:/tmp/voice-reply-output.ogg
```

- `[[audio_as_voice]]` - Tag that tells Telegram to display as voice bubble
- `MEDIA:path` - Path to the generated OGG Opus audio file

## Available Voices

| Language | Voice | Quality | License | Description |
|----------|-------|---------|---------|-------------|
| German (de) | thorsten | medium | CC0 1.0 (public domain) | Natural male voice, clear pronunciation |
| English (en) | ryan | high | CC-BY-SA 4.0 | Clear US male voice, professional tone |

## Voice Model Licenses

- **Thorsten Voice** (German): Released under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/) by Thorsten Mueller. Free for any use.
- **Ryan Voice** (English): Released under [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/). Attribution required for redistribution.
- **sherpa-onnx runtime**: [Apache 2.0 License](https://github.com/k2-fsa/sherpa-onnx/blob/master/LICENSE)
- **Piper TTS engine**: [MIT License](https://github.com/rhasspy/piper/blob/master/LICENSE.md)

## Adding More Voices

Browse available Piper voices at:
- https://rhasspy.github.io/piper-samples/
- https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models

Download and extract to `$PIPER_VOICES_DIR`, then modify `bin/voice-reply` to include the new voice.

## Troubleshooting

### "TTS binary not found"
Ensure `SHERPA_ONNX_DIR` is set and contains `bin/sherpa-onnx-offline-tts`.

### "Failed to generate audio"
Check that voice model files exist: `*.onnx`, `tokens.txt`, `espeak-ng-data/`

### Audio plays as file instead of voice bubble
Ensure the output includes `[[audio_as_voice]]` tag on its own line before the `MEDIA:` line.

### Shared library errors
If you get `libsherpa-onnx-core.so: cannot open shared object file`, the runtime needs
its libraries on `LD_LIBRARY_PATH`. The `bin/voice-reply` script handles this automatically.

## Credits

- [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) - Offline speech processing (Apache 2.0)
- [Piper](https://github.com/rhasspy/piper) - Fast local TTS voices (MIT)
- [Thorsten Voice](https://github.com/thorstenMueller/Thorsten-Voice) - German voice dataset (CC0)
