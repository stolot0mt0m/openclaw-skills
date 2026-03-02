# voice-reply

**Local Text-to-Speech for OpenClaw using Piper voices via sherpa-onnx**

Generate voice audio replies that work as Telegram voice notes - 100% offline, no API keys required.

## Features

- **100% Local** - No internet connection required after setup
- **No API Keys** - Completely free, no accounts needed
- **Multi-language** - German and English voices included (more available)
- **Telegram Ready** - Outputs as voice bubbles, not file attachments
- **Auto-detect Language** - Automatically selects the right voice
- **User-local Install** - No root/sudo required (default mode)
- **Checksum Verified** - All downloads verified against upstream SHA256 checksums

## Quick Start

### 1. Install Dependencies

```bash
cd scripts
./install.sh            # User-local install (no root needed)
# or
sudo ./install.sh --system   # System-wide install to /opt
```

This installs:
- sherpa-onnx runtime (~28 MB)
- German voice "thorsten" (~64 MB)
- English voice "ryan" (~110 MB)
- ffmpeg (if not present, requires sudo)

All downloads are SHA256-verified against checksums published by the upstream project.

### 2. Set Environment Variables

The installer prints the exact values. For user-local install:

```bash
export SHERPA_ONNX_DIR="$HOME/.local/share/voice-reply/sherpa-onnx"
export PIPER_VOICES_DIR="$HOME/.local/share/voice-reply/piper-voices"
```

### 3. Add to OpenClaw

Copy the skill to your OpenClaw skills directory:

```bash
cp -r . ~/.openclaw/skills/voice-reply
```

### 4. Use It

Ask your OpenClaw agent:
- "Reply with a voice message"
- "Say that as audio"
- "Read this aloud: Hello world"

Or call the entrypoint directly:
```bash
bin/voice-reply "Hello, how are you?" en
```

## Voices

| Language | Voice | Quality | Size | License |
|----------|-------|---------|------|---------|
| German | thorsten | medium | 64 MB | CC0 1.0 (public domain) |
| English | ryan | high | 110 MB | CC-BY-SA 4.0 |

More voices available at [Piper Samples](https://rhasspy.github.io/piper-samples/).

## Requirements

- Linux x86_64 (Ubuntu 22.04+ recommended)
- ~200 MB disk space
- ~500 MB RAM during synthesis
- ffmpeg

## Security

- **Checksum verification**: All downloads verified against SHA256 checksums from upstream release pages
- **No network at runtime**: After installation, the skill runs 100% offline
- **No root at runtime**: The `bin/voice-reply` entrypoint runs as the current user
- **Installer transparency**: The install script only downloads from `github.com/k2-fsa/sherpa-onnx` releases

## How It Works

1. Text is converted to speech using sherpa-onnx with Piper VITS models
2. WAV output is converted to OGG Opus (Telegram voice format)
3. Output includes `[[audio_as_voice]]` tag for Telegram voice bubbles

## Manual Installation

If you prefer not to use the installer:

### 1. Install sherpa-onnx

```bash
mkdir -p ~/.local/share/voice-reply/sherpa-onnx
cd ~/.local/share/voice-reply/sherpa-onnx
curl -L -o sherpa.tar.bz2 "https://github.com/k2-fsa/sherpa-onnx/releases/download/v1.12.23/sherpa-onnx-v1.12.23-linux-x64-shared.tar.bz2"
# Verify: sha256sum sherpa.tar.bz2
# Expected: db01ace06659c1adb6706c8bf26d2e51d2af20b87a560d1368458bfdbe3989a9
tar -xjf sherpa.tar.bz2 --strip-components=1
rm sherpa.tar.bz2
```

### 2. Download Voice Models

```bash
mkdir -p ~/.local/share/voice-reply/piper-voices
cd ~/.local/share/voice-reply/piper-voices

# German - thorsten (medium quality, natural male voice)
# SHA256: 50487d9c95fdf2191f31d2588569381063ba1591dcd4c7d4bdd30f12b2191714
curl -L -o thorsten.tar.bz2 "https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-de_DE-thorsten-medium.tar.bz2"
tar -xjf thorsten.tar.bz2 && rm thorsten.tar.bz2

# English - ryan (high quality, clear US male voice)
# SHA256: 6a71edf4d308b9cb2eaeadc8d1f3c6bf96120ecb7fe52c29a2b6e139c59760ed
curl -L -o ryan.tar.bz2 "https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-en_US-ryan-high.tar.bz2"
tar -xjf ryan.tar.bz2 && rm ryan.tar.bz2
```

### 3. Install ffmpeg

```bash
sudo apt install -y ffmpeg
```

### 4. Set Environment Variables

```bash
export SHERPA_ONNX_DIR="$HOME/.local/share/voice-reply/sherpa-onnx"
export PIPER_VOICES_DIR="$HOME/.local/share/voice-reply/piper-voices"
```

## Licenses

- **sherpa-onnx runtime**: [Apache 2.0](https://github.com/k2-fsa/sherpa-onnx/blob/master/LICENSE)
- **Piper TTS**: [MIT](https://github.com/rhasspy/piper/blob/master/LICENSE.md)
- **Thorsten Voice** (German): [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/) — public domain
- **Ryan Voice** (English): [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) — attribution required
- **This skill**: MIT License

## Credits

- [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx) - Offline speech processing
- [Piper](https://github.com/rhasspy/piper) - Fast local neural TTS
- [Thorsten Voice](https://github.com/thorstenMueller/Thorsten-Voice) - German voice dataset (CC0)
