# Speech-to-Text Desktop Dictation with Faster-Whisper

A lightweight, local, and offline speech-to-text dictation tool for Linux. Works seamlessly across **X11** and **Wayland** desktops (GNOME, KDE, Sway, i3, Hyprland, XFCE, etc.) with a single global shortcut.

Transcribes via [faster-whisper](https://github.com/SYSTRAN/faster-whisper) (CPU `int8`), types directly into whichever window is focused, and leaves your clipboard untouched.

---

## Quick Install (One-Liner)

Run this single command in your terminal to automatically detect your package manager (`apt`, `pacman`, `dnf`), detect your display server (**Wayland** or **X11**), install all dependencies, and set up the scripts:

```bash
# Default: Automatic multi-language detection (auto)
wget -qO- https://raw.githubusercontent.com/Jean28518/linux-guides/main/speech-to-text-for-desktop/install.sh | bash
```

> **Prefer a fixed language?** You can pass a language code (e.g. `de`, `en`, `es`, `fr`):
> ```bash
> wget -qO- https://raw.githubusercontent.com/Jean28518/linux-guides/main/speech-to-text-for-desktop/install.sh | bash -s -- de
> ```
> *(Or via curl: `curl -sSL https://raw.githubusercontent.com/Jean28518/linux-guides/main/speech-to-text-for-desktop/install.sh | bash -s -- de`)*

---

## Manual Installation

If you prefer to set up everything by hand, follow the steps below:

### 1. System Packages

Install audio tools, Python, and the keyboard typing simulator for your display server:

```bash
# Debian / Ubuntu / Linux Mint
# For Wayland:
sudo apt install -y ffmpeg wtype pulseaudio-utils python3-venv
# For X11:
sudo apt install -y ffmpeg xdotool pulseaudio-utils python3-venv

# Arch Linux
# For Wayland:
sudo pacman -S --needed ffmpeg wtype libpulse python
# For X11:
sudo pacman -S --needed ffmpeg xdotool libpulse python

# Fedora
# For Wayland:
sudo dnf install -y ffmpeg wtype pulseaudio-utils python3
# For X11:
sudo dnf install -y ffmpeg xdotool pulseaudio-utils python3
```

---

## 2. Python Environment

Set up the virtual environment and install `faster-whisper`:

```bash
mkdir -p ~/.local/share/whisper-dictation/sounds ~/.local/bin

python3 -m venv ~/.local/share/whisper-dictation/venv
~/.local/share/whisper-dictation/venv/bin/pip install --upgrade pip
~/.local/share/whisper-dictation/venv/bin/pip install faster-whisper "av<14"
```

---

## 3. Audio Cues (Feedback Chimes)

Generate subtle start/stop chimes so you know when recording begins and ends:

```bash
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

generate_chime(os.path.join(out_dir, "start.wav"), [587, 880]) # High rising chime
generate_chime(os.path.join(out_dir, "stop.wav"), [880, 587])  # Descending chime
EOF
```

---

## 4. Transcription Script

Create `~/.local/share/whisper-dictation/transcribe.py`:

```bash
cat << 'EOF' > ~/.local/share/whisper-dictation/transcribe.py
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

chmod +x ~/.local/share/whisper-dictation/transcribe.py
```

---

## 5. Universal Toggle Wrapper

This script manages start/stop state, avoids race conditions, and automatically detects whether you are on **Wayland** (`wtype`) or **X11** (`xdotool`).

Create `~/.local/bin/whisper-dictate`:

```bash
cat << 'EOF' > ~/.local/bin/whisper-dictate
#!/usr/bin/env bash
APP_DIR="$HOME/.local/share/whisper-dictation"
VENV_PYTHON="$APP_DIR/venv/bin/python3"
TRANSCRIBE_SCRIPT="$APP_DIR/transcribe.py"
PID_FILE="/tmp/whisper_dictate.pid"
LOCK_FILE="/tmp/whisper_dictate.lock"
AUDIO_FILE="/tmp/whisper_dictate.wav"
LOG_FILE="/tmp/whisper_dictate.log"
START_SOUND="$APP_DIR/sounds/start.wav"
STOP_SOUND="$APP_DIR/sounds/stop.wav"

# Configuration
MODEL="small"      # Options: tiny, base, small, medium, turbo
LANG="auto"        # Language: "auto" for auto-detection, or e.g. "de", "en", "fr"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# 1. Prevent race conditions while transcribing
if [ -f "$LOCK_FILE" ]; then
    log "Transcription in progress, ignoring toggle."
    exit 0
fi

# 2. Stop recording & transcribe
if [ -f "$PID_FILE" ]; then
    REC_PID=$(cat "$PID_FILE")
    rm -f "$PID_FILE"

    if ps -p "$REC_PID" > /dev/null 2>&1; then
        touch "$LOCK_FILE"
        kill -INT "$REC_PID" 2>/dev/null
        
        [ -f "$STOP_SOUND" ] && paplay "$STOP_SOUND" >/dev/null 2>&1 &
        
        while ps -p "$REC_PID" > /dev/null 2>&1; do
            sleep 0.05
        done

        log "Recording stopped. Transcribing..."

        if [ -f "$AUDIO_FILE" ] && [ -s "$AUDIO_FILE" ]; then
            TEXT=$("$VENV_PYTHON" "$TRANSCRIBE_SCRIPT" "$AUDIO_FILE" --model "$MODEL" --lang "$LANG")
            log "Transcribed: '$TEXT'"

            if [ -n "$TEXT" ]; then
                if [ -n "$WAYLAND_DISPLAY" ]; then
                    wtype -s 10 -d 3 -- "$TEXT "
                else
                    xdotool type --clearmodifiers --delay 2 -- "$TEXT "
                fi
            fi
        fi

        rm -f "$LOCK_FILE"
        exit 0
    fi
fi

# 3. Start recording
rm -f "$AUDIO_FILE" "$LOCK_FILE"
[ -f "$START_SOUND" ] && paplay "$START_SOUND" >/dev/null 2>&1 &

ffmpeg -y -f pulse -i default -ar 16000 -ac 1 "$AUDIO_FILE" >/dev/null 2>&1 &
echo $! > "$PID_FILE"
log "Recording started (PID $!)."
EOF

chmod +x ~/.local/bin/whisper-dictate
```

---

## 6. Hotkey Setup

Bind `~/.local/bin/whisper-dictate` to your preferred key combination (e.g. `Super + L`):

- **Sway** (`~/.config/sway/config`):
  ```sway
  bindsym $mod+l exec ~/.local/bin/whisper-dictate
  ```
- **i3** (`~/.config/i3/config`):
  ```i3
  bindsym $mod+l exec --no-startup-id ~/.local/bin/whisper-dictate
  ```
- **Hyprland** (`~/.config/hypr/hyprland.conf`):
  ```ini
  bind = $mainMod, L, exec, ~/.local/bin/whisper-dictate
  ```
- **GNOME / KDE Plasma / XFCE / Cinnamon:**
  Go to **Settings** → **Keyboard** → **Custom Shortcuts**, create a new shortcut pointing to `/home/<your-user>/.local/bin/whisper-dictate` and assign a key combination.

---

## 7. Usage & Notes

- **How to use:** Press your shortcut once to start speaking (high chime). Press it again to stop (low chime). The text types into your active window ~1–2 seconds later.
- **First Run:** Downloads the model (`small`, ~464 MB) automatically on first use. Subsequent runs use the local cache (`~/.cache/huggingface/hub/`) and are near-instant.
- **Language & Model:** Change `--lang de` or `--model small` in `transcribe.py` or `whisper-dictate` (`tiny` ~75 MB, `base` ~145 MB, `small` ~464 MB, `turbo` ~1.6 GB).
- **Logs:** Live troubleshooting via `tail -f /tmp/whisper_dictate.log`.
