#!/bin/bash
# voice-reply skill - Installation Script
# Installs sherpa-onnx runtime and Piper voice models
#
# Usage:
#   ./install.sh [OPTIONS]              # User-local install (recommended)
#   sudo ./install.sh --system [OPTIONS] # System-wide install to /opt
#
# Options:
#   --system          Install to /opt (requires root)
#   --prefix PATH     Custom install prefix (default: ~/.local/share/voice-reply)
#   --german-only     Only install German voice
#   --english-only    Only install English voice
#   --skip-checksums  Skip SHA256 verification (not recommended)
#   --all             Install all voices (default)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Known SHA256 checksums for supply-chain verification ---
# Update these when upgrading versions. Verify against upstream release pages:
#   https://github.com/k2-fsa/sherpa-onnx/releases/tag/v1.12.23
#   https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models
SHERPA_SHA256="db01ace06659c1adb6706c8bf26d2e51d2af20b87a560d1368458bfdbe3989a9"
THORSTEN_SHA256="50487d9c95fdf2191f31d2588569381063ba1591dcd4c7d4bdd30f12b2191714"
RYAN_SHA256="6a71edf4d308b9cb2eaeadc8d1f3c6bf96120ecb7fe52c29a2b6e139c59760ed"
# Source: upstream checksum.txt files from GitHub releases
#   https://github.com/k2-fsa/sherpa-onnx/releases/tag/v1.12.23
#   https://github.com/k2-fsa/sherpa-onnx/releases/tag/tts-models

echo -e "${GREEN}=== Voice Reply Skill Installer ===${NC}"
echo ""

# Parse arguments
INSTALL_GERMAN=true
INSTALL_ENGLISH=true
SYSTEM_INSTALL=false
SKIP_CHECKSUMS=false
CUSTOM_PREFIX=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --german-only)
            INSTALL_ENGLISH=false
            shift ;;
        --english-only)
            INSTALL_GERMAN=false
            shift ;;
        --system)
            SYSTEM_INSTALL=true
            shift ;;
        --prefix)
            CUSTOM_PREFIX="$2"
            shift 2 ;;
        --skip-checksums)
            SKIP_CHECKSUMS=true
            shift ;;
        --all|"")
            shift ;;
        --help|-h)
            echo "Usage: $0 [--system] [--prefix PATH] [--german-only|--english-only|--all] [--skip-checksums]"
            echo ""
            echo "  --system          Install to /opt (requires root)"
            echo "  --prefix PATH     Custom install prefix"
            echo "  --german-only     Only install German voice"
            echo "  --english-only    Only install English voice"
            echo "  --skip-checksums  Skip SHA256 verification"
            exit 0 ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information."
            exit 1 ;;
    esac
done

# Determine install prefix
if [ -n "$CUSTOM_PREFIX" ]; then
    INSTALL_PREFIX="$CUSTOM_PREFIX"
elif [ "$SYSTEM_INSTALL" = true ]; then
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: --system requires root. Run with sudo or use user-local install.${NC}"
        exit 1
    fi
    INSTALL_PREFIX="/opt"
else
    INSTALL_PREFIX="${HOME}/.local/share/voice-reply"
fi

SHERPA_DIR="$INSTALL_PREFIX/sherpa-onnx"
VOICES_DIR="$INSTALL_PREFIX/piper-voices"

echo "Install prefix: $INSTALL_PREFIX"
echo ""

# --- Helper: verify SHA256 checksum ---
verify_checksum() {
    local file="$1"
    local expected="$2"
    local name="$3"

    if [ "$SKIP_CHECKSUMS" = true ] || [ "$expected" = "SKIP" ]; then
        if [ "$expected" = "SKIP" ]; then
            echo -e "${YELLOW}  Checksum not available for $name (upstream does not publish checksums).${NC}"
            echo -e "${YELLOW}  To pin: sha256sum $file${NC}"
        else
            echo -e "${YELLOW}  Checksum verification skipped for $name.${NC}"
        fi
        return 0
    fi

    local actual
    actual=$(sha256sum "$file" | awk '{print $1}')
    if [ "$actual" = "$expected" ]; then
        echo -e "${GREEN}  Checksum OK for $name${NC}"
        return 0
    else
        echo -e "${RED}  Checksum FAILED for $name!${NC}"
        echo -e "${RED}  Expected: $expected${NC}"
        echo -e "${RED}  Got:      $actual${NC}"
        echo -e "${RED}  The download may be corrupted or tampered with.${NC}"
        echo -e "${RED}  Delete $file and retry, or use --skip-checksums to bypass.${NC}"
        return 1
    fi
}

# --- Step 1: Check ffmpeg ---
echo -e "${YELLOW}[1/5] Checking ffmpeg...${NC}"
if ! command -v ffmpeg &> /dev/null; then
    if [ "$EUID" -eq 0 ]; then
        echo "Installing ffmpeg via apt..."
        apt update && apt install -y ffmpeg
    else
        echo -e "${RED}ffmpeg is not installed.${NC}"
        echo "Install it with: sudo apt install -y ffmpeg"
        echo "Or on other distros: dnf/pacman/brew install ffmpeg"
        exit 1
    fi
else
    echo "ffmpeg already installed."
fi

# --- Step 2: Install sherpa-onnx ---
echo ""
echo -e "${YELLOW}[2/5] Installing sherpa-onnx runtime...${NC}"
SHERPA_VERSION="v1.12.23"
SHERPA_URL="https://github.com/k2-fsa/sherpa-onnx/releases/download/${SHERPA_VERSION}/sherpa-onnx-${SHERPA_VERSION}-linux-x64-shared.tar.bz2"

if [ -x "$SHERPA_DIR/bin/sherpa-onnx-offline-tts" ]; then
    echo "sherpa-onnx already installed at $SHERPA_DIR"
else
    mkdir -p "$SHERPA_DIR"
    DOWNLOAD_FILE=$(mktemp /tmp/sherpa-onnx-XXXXXX.tar.bz2)
    echo "Downloading sherpa-onnx $SHERPA_VERSION..."
    curl -L -o "$DOWNLOAD_FILE" "$SHERPA_URL"
    verify_checksum "$DOWNLOAD_FILE" "$SHERPA_SHA256" "sherpa-onnx"
    echo "Extracting to $SHERPA_DIR..."
    tar -xjf "$DOWNLOAD_FILE" -C "$SHERPA_DIR" --strip-components=1
    rm "$DOWNLOAD_FILE"
    echo -e "${GREEN}sherpa-onnx installed successfully.${NC}"
fi

# --- Step 3: Install voice models ---
echo ""
echo -e "${YELLOW}[3/5] Installing Piper voice models...${NC}"
mkdir -p "$VOICES_DIR"

if [ "$INSTALL_GERMAN" = true ]; then
    if [ -d "$VOICES_DIR/vits-piper-de_DE-thorsten-medium" ]; then
        echo "German voice (thorsten) already installed."
    else
        DOWNLOAD_FILE=$(mktemp /tmp/thorsten-XXXXXX.tar.bz2)
        echo "Downloading German voice (thorsten-medium)..."
        curl -L -o "$DOWNLOAD_FILE" "https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-de_DE-thorsten-medium.tar.bz2"
        verify_checksum "$DOWNLOAD_FILE" "$THORSTEN_SHA256" "thorsten voice model"
        tar -xjf "$DOWNLOAD_FILE" -C "$VOICES_DIR"
        rm "$DOWNLOAD_FILE"
        echo -e "${GREEN}German voice installed.${NC}"
    fi
fi

if [ "$INSTALL_ENGLISH" = true ]; then
    if [ -d "$VOICES_DIR/vits-piper-en_US-ryan-high" ]; then
        echo "English voice (ryan) already installed."
    else
        DOWNLOAD_FILE=$(mktemp /tmp/ryan-XXXXXX.tar.bz2)
        echo "Downloading English voice (ryan-high)..."
        curl -L -o "$DOWNLOAD_FILE" "https://github.com/k2-fsa/sherpa-onnx/releases/download/tts-models/vits-piper-en_US-ryan-high.tar.bz2"
        verify_checksum "$DOWNLOAD_FILE" "$RYAN_SHA256" "ryan voice model"
        tar -xjf "$DOWNLOAD_FILE" -C "$VOICES_DIR"
        rm "$DOWNLOAD_FILE"
        echo -e "${GREEN}English voice installed.${NC}"
    fi
fi

# --- Step 4: Verify entrypoint ---
echo ""
echo -e "${YELLOW}[4/5] Verifying skill entrypoint...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ENTRYPOINT="$SKILL_DIR/bin/voice-reply"

if [ -x "$ENTRYPOINT" ]; then
    echo -e "${GREEN}Entrypoint found: $ENTRYPOINT${NC}"
else
    echo -e "${RED}Warning: Entrypoint not found or not executable at $ENTRYPOINT${NC}"
    echo "The skill expects bin/voice-reply relative to the skill directory."
    if [ -f "$ENTRYPOINT" ]; then
        chmod +x "$ENTRYPOINT"
        echo -e "${GREEN}Made $ENTRYPOINT executable.${NC}"
    fi
fi

# --- Step 5: Configuration and test ---
echo ""
echo -e "${YELLOW}[5/5] Configuration and test...${NC}"
echo ""

if [ "$SYSTEM_INSTALL" = true ]; then
    echo "Add these environment variables to your OpenClaw service or shell profile:"
else
    echo "Add these environment variables to your shell profile (~/.bashrc or ~/.zshrc):"
fi
echo ""
echo -e "${GREEN}  export SHERPA_ONNX_DIR=\"$SHERPA_DIR\"${NC}"
echo -e "${GREEN}  export PIPER_VOICES_DIR=\"$VOICES_DIR\"${NC}"
echo ""

# Test TTS generation
echo -e "${YELLOW}Testing TTS generation...${NC}"
TEST_MODEL_DIR=""
if [ "$INSTALL_GERMAN" = true ] && [ -d "$VOICES_DIR/vits-piper-de_DE-thorsten-medium" ]; then
    TEST_MODEL_DIR="$VOICES_DIR/vits-piper-de_DE-thorsten-medium"
    TEST_MODEL_FILE="de_DE-thorsten-medium.onnx"
elif [ "$INSTALL_ENGLISH" = true ] && [ -d "$VOICES_DIR/vits-piper-en_US-ryan-high" ]; then
    TEST_MODEL_DIR="$VOICES_DIR/vits-piper-en_US-ryan-high"
    TEST_MODEL_FILE="en_US-ryan-high.onnx"
fi

if [ -n "$TEST_MODEL_DIR" ] && [ -x "$SHERPA_DIR/bin/sherpa-onnx-offline-tts" ]; then
    # sherpa-onnx needs its shared libs on LD_LIBRARY_PATH
    export LD_LIBRARY_PATH="$SHERPA_DIR/lib:${LD_LIBRARY_PATH:-}"
    if "$SHERPA_DIR/bin/sherpa-onnx-offline-tts" \
        --vits-model="$TEST_MODEL_DIR/$TEST_MODEL_FILE" \
        --vits-tokens="$TEST_MODEL_DIR/tokens.txt" \
        --vits-data-dir="$TEST_MODEL_DIR/espeak-ng-data" \
        --output-filename="/tmp/test-voice-reply.wav" \
        "Test" >/dev/null 2>&1 && [ -f "/tmp/test-voice-reply.wav" ]; then
        rm -f /tmp/test-voice-reply.wav
        echo -e "${GREEN}TTS test passed!${NC}"
    else
        echo -e "${RED}Warning: TTS test failed. Check that LD_LIBRARY_PATH includes $SHERPA_DIR/lib${NC}"
    fi
else
    echo -e "${YELLOW}Skipping TTS test (no model or binary available).${NC}"
fi

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "Disk usage:"
du -sh "$SHERPA_DIR" "$VOICES_DIR" 2>/dev/null || true
echo ""
echo "To use the skill, ensure the environment variables above are set, then run:"
echo "  $ENTRYPOINT \"Hello, this is a test.\" en"
