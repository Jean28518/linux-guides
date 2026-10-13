#!/usr/bin/env bash
set -e

# ==============================================================================
# Speech-to-Text Desktop Dictation Installer (faster-whisper)
# Supports: Arch, Debian/Ubuntu, Fedora | Wayland & X11
# Usage: ./install.sh [language] [model]
#        e.g. ./install.sh auto small (default)
#        e.g. ./install.sh de small
#        e.g. ./install.sh en base
# ==============================================================================

TARGET_LANG="${1:-auto}"
TARGET_MODEL="${2:-small}"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Installing Speech-to-Text Desktop Dictation..."
echo -e "${BLUE}==>${NC} Language configured: ${YELLOW}${TARGET_LANG}${NC} (use 'auto' for automatic multi-language detection)"
echo -e "${BLUE}==>${NC} Model configured: ${YELLOW}${TARGET_MODEL}${NC}"

# 1. Detect Display Server
SESSION="${XDG_SESSION_TYPE:-}"
if [ "$SESSION" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    IS_WAYLAND=true
    echo -e "${BLUE}==>${NC} Display server: Wayland detected"
else
    IS_WAYLAND=false
    echo -e "${BLUE}==>${NC} Display server: X11 detected"
fi

# 2. Detect Package Manager & Install System Packages
echo -e "${BLUE}==>${NC} Detecting package manager and installing dependencies..."

if command -v pacman &>/dev/null; then
    PKGS=("ffmpeg" "libpulse" "python")
    if [ "$IS_WAYLAND" = true ]; then
        PKGS+=("wtype")
    else
        PKGS+=("xdotool")
    fi
    echo -e "${BLUE}==>${NC} Running pacman..."
    sudo pacman -S --needed --noconfirm "${PKGS[@]}"

elif command -v apt-get &>/dev/null; then
    PKGS=("ffmpeg" "pulseaudio-utils" "python3" "python3-venv")
    if [ "$IS_WAYLAND" = true ]; then
        PKGS+=("wtype")
    else
        PKGS+=("xdotool")
    fi
    echo -e "${BLUE}==>${NC} Running apt update & install..."
    sudo apt-get update -qq
    sudo apt-get install -y "${PKGS[@]}"

elif command -v dnf &>/dev/null; then
    PKGS=("ffmpeg" "pulseaudio-utils" "python3")
    if [ "$IS_WAYLAND" = true ]; then
        PKGS+=("wtype")
    else
        PKGS+=("xdotool")
    fi
    echo -e "${BLUE}==>${NC} Running dnf..."
    sudo dnf install -y "${PKGS[@]}"

else
    echo -e "${RED}Error: Unsupported package manager. Please install dependencies manually.${NC}"
    exit 1
fi

# 3. Setup Directories
APP_DIR="$HOME/.local/share/whisper-dictation"
BIN_DIR="$HOME/.local/bin"
mkdir -p "$APP_DIR/sounds" "$BIN_DIR"

# 4. Create Python Virtual Environment
echo -e "${BLUE}==>${NC} Setting up Python virtual environment..."
python3 -m venv "$APP_DIR/venv"
"$APP_DIR/venv/bin/pip" install --upgrade pip -q
echo -e "${BLUE}==>${NC} Installing faster-whisper..."
"$APP_DIR/venv/bin/pip" install faster-whisper "av<14" -q

# 5. Generate Audio Feedback Chimes
echo -e "${BLUE}==>${NC} Generating audio chimes..."
python3 - << 'EOF'
import math, wave, struct, os

out_dir = os.path.expanduser("~/.local/share/whisper-dictation/sounds")
os.makedirs(out_dir, exist_ok=True)

def generate_chime(filename, freqs, duration_each=0.08, sample_rate=44100, volume=0.2):
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(sample_rate)
        for freq in freqs:
            n_samples = int(sample_rate * duration_each)
            for i in range(n_samples):
                env = 1.0
                attack = int(sample_rate * 0.01)
                decay = int(sample_rate * 0.02)
                if i < attack:
                    env = i / attack
                elif i > n_samples - decay:
                    env = (n_samples - i) / decay
                sample = volume * env * math.sin(2 * math.pi * freq * (i / sample_rate))
                wav.writeframes(struct.pack('<h', int(sample * 32767)))

generate_chime(os.path.join(out_dir, "start.wav"), [587, 880])
generate_chime(os.path.join(out_dir, "stop.wav"), [880, 587])
EOF

# 6. Create transcribe.py
echo -e "${BLUE}==>${NC} Creating transcription script..."
cat << 'EOF' > "$APP_DIR/transcribe.py"
#!/usr/bin/env python3
import sys
import os
import argparse
from faster_whisper import WhisperModel

def main():
    parser = argparse.ArgumentParser(description="Transcribe audio file with faster-whisper")
    parser.add_argument("audio_path", help="Path to wav file")
    parser.add_argument("--model", default="small", help="Model name: tiny, base, small, turbo")
    parser.add_argument("--lang", default="auto", help="Language code (auto, de, en, fr, etc.)")
    args = parser.parse_args()

    if not os.path.exists(args.audio_path) or os.path.getsize(args.audio_path) < 4000:
        return

    lang = None if args.lang in (None, "auto", "None", "") else args.lang
    model = WhisperModel(args.model, device="cpu", compute_type="int8", cpu_threads=4)

    segments, info = model.transcribe(
        args.audio_path,
        beam_size=3,
        language=lang,
        condition_on_previous_text=False,
        vad_filter=True,
        vad_parameters=dict(min_silence_duration_ms=500)
    )

    text_parts = []
    for segment in segments:
        if segment.no_speech_prob > 0.85:
            continue
        text = segment.text.strip()
        if text:
            text_parts.append(text)

    result = " ".join(text_parts).strip()
    if result:
        print(result)

if __name__ == "__main__":
    main()
EOF
chmod +x "$APP_DIR/transcribe.py"

# 7. Create whisper-dictate Toggle Script
echo -e "${BLUE}==>${NC} Creating toggle launcher..."
cat << EOF > "$BIN_DIR/whisper-dictate"
#!/usr/bin/env bash
# ==============================================================================
# Configuration
# MODEL: tiny, base, small, medium, turbo
# LANG:  auto (automatic detection), or fixed code: de, en, fr, es, it, etc.
# ==============================================================================
MODEL="${TARGET_MODEL}"
LANG="${TARGET_LANG}"

APP_DIR="\$HOME/.local/share/whisper-dictation"
VENV_PYTHON="\$APP_DIR/venv/bin/python3"
TRANSCRIBE_SCRIPT="\$APP_DIR/transcribe.py"
PID_FILE="/tmp/whisper_dictate.pid"
LOCK_FILE="/tmp/whisper_dictate.lock"
AUDIO_FILE="/tmp/whisper_dictate.wav"
LOG_FILE="/tmp/whisper_dictate.log"
START_SOUND="\$APP_DIR/sounds/start.wav"
STOP_SOUND="\$APP_DIR/sounds/stop.wav"

log() {
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] \$*" >> "\$LOG_FILE"
}

# 1. Prevent race conditions while transcribing
if [ -f "\$LOCK_FILE" ]; then
    log "Transcription in progress, ignoring toggle."
    exit 0
fi

# 2. Stop recording & transcribe
if [ -f "\$PID_FILE" ]; then
    REC_PID=\$(cat "\$PID_FILE")
    rm -f "\$PID_FILE"

    if ps -p "\$REC_PID" > /dev/null 2>&1; then
        touch "\$LOCK_FILE"
        kill -INT "\$REC_PID" 2>/dev/null
        
        [ -f "\$STOP_SOUND" ] && paplay "\$STOP_SOUND" >/dev/null 2>&1 &
        
        while ps -p "\$REC_PID" > /dev/null 2>&1; do
            sleep 0.05
        done

        log "Recording stopped. Transcribing..."

        if [ -f "\$AUDIO_FILE" ] && [ -s "\$AUDIO_FILE" ]; then
            TEXT=\$("\$VENV_PYTHON" "\$TRANSCRIBE_SCRIPT" "\$AUDIO_FILE" --model "\$MODEL" --lang "\$LANG")
            log "Transcribed: '\$TEXT'"

            if [ -n "\$TEXT" ]; then
                if [ -n "\$WAYLAND_DISPLAY" ]; then
                    wtype -s 10 -d 3 -- "\$TEXT "
                else
                    xdotool type --clearmodifiers --delay 2 -- "\$TEXT "
                fi
            fi
        fi

        rm -f "\$LOCK_FILE"
        exit 0
    fi
fi

# 3. Start recording
rm -f "\$AUDIO_FILE" "\$LOCK_FILE"
[ -f "\$START_SOUND" ] && paplay "\$START_SOUND" >/dev/null 2>&1 &

ffmpeg -y -f pulse -i default -ar 16000 -ac 1 "\$AUDIO_FILE" >/dev/null 2>&1 &
echo \$! > "\$PID_FILE"
log "Recording started (PID \$!)."
EOF
chmod +x "$BIN_DIR/whisper-dictate"

# 8. Pre-download Model
echo -e "${BLUE}==>${NC} Pre-downloading Whisper model ('${TARGET_MODEL}')..."
"$APP_DIR/venv/bin/python3" -c "from faster_whisper import WhisperModel; WhisperModel('${TARGET_MODEL}', device='cpu', compute_type='int8')"

echo ""
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}  Installation Complete!${NC}"
echo -e "${GREEN}================================================================${NC}"
echo ""
echo -e "Language: ${YELLOW}${TARGET_LANG}${NC} (change anytime in ~/.local/bin/whisper-dictate)"
echo -e "Model:    ${YELLOW}${TARGET_MODEL}${NC}"
echo ""
echo "Next step: Assign a hotkey to the script:"
echo -e "  Command: ${YELLOW}$BIN_DIR/whisper-dictate${NC}"
echo ""
echo "Examples:"
echo "  • Sway (~/.config/sway/config):      bindsym \$mod+l exec ~/.local/bin/whisper-dictate"
echo "  • i3 (~/.config/i3/config):          bindsym \$mod+l exec --no-startup-id ~/.local/bin/whisper-dictate"
echo "  • Hyprland (~/.config/hyprland.conf): bind = \$mainMod, L, exec, ~/.local/bin/whisper-dictate"
echo "  • GNOME / KDE / XFCE:               Settings -> Keyboard -> Shortcuts -> Custom Shortcut"
echo ""
