# Speech-to-Text Desktop Dictation with Faster-Whisper

A lightweight, local, and offline speech-to-text dictation tool for Linux. Works seamlessly across **X11** and **Wayland** desktops (GNOME, KDE, Sway, i3, Hyprland, XFCE, etc.) with a single global shortcut.

Transcribes via [faster-whisper](https://github.com/SYSTRAN/faster-whisper) (CPU `int8`), types directly into whichever window is focused, and automatically copies to your clipboard as a safe fallback.

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
sudo apt install -y ffmpeg wtype wl-clipboard pulseaudio-utils python3-venv python3-tk
# For X11:
sudo apt install -y ffmpeg xdotool xclip pulseaudio-utils python3-venv python3-tk

# Arch Linux
# For Wayland:
sudo pacman -S --needed ffmpeg wtype wl-clipboard libpulse python tk
# For X11:
sudo pacman -S --needed ffmpeg xdotool xclip libpulse python tk

# Fedora
# For Wayland:
sudo dnf install -y ffmpeg wtype wl-clipboard pulseaudio-utils python3 python3-tkinter
# For X11:
sudo dnf install -y ffmpeg xdotool xclip pulseaudio-utils python3 python3-tkinter
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
import traceback
from faster_whisper import WhisperModel

ALLOWED_AUTO_LANGUAGES = {"de", "en", "fr", "es", "it"}

def main():
    parser = argparse.ArgumentParser(description="Transcribe audio file with faster-whisper")
    parser.add_argument("audio_path", help="Path to wav file")
    parser.add_argument("--model", default="small", help="Model name: tiny, base, small, turbo")
    parser.add_argument("--lang", default="auto", help="Language code (auto, de, en, fr, etc.)")
    parser.add_argument("--fallback-lang", default="de", help="Fallback language if detection confidence is low or exotic")
    parser.add_argument("--vad", action="store_true", help="Enable VAD filter (default: False, checks entire audio)")
    args = parser.parse_args()

    if not os.path.exists(args.audio_path) or os.path.getsize(args.audio_path) < 4000:
        return

    try:
        lang = None if args.lang in (None, "auto", "None", "") else args.lang
        model = WhisperModel(args.model, device="cpu", compute_type="int8", cpu_threads=4)

        vad_params = dict(
            min_silence_duration_ms=500,
            speech_pad_ms=400,
            threshold=0.35,
        ) if args.vad else None

        # temperature=0.0 prevents 20-30 second multi-temperature fallback loops on unclear speech
        segments, info = model.transcribe(
            args.audio_path,
            beam_size=2,
            temperature=0.0,
            compression_ratio_threshold=2.8,
            language=lang,
            condition_on_previous_text=False,
            vad_filter=args.vad,
            vad_parameters=vad_params,
            max_initial_timestamp=5.0
        )

        # In auto mode: if confidence is low (< 0.6) or an exotic language was hallucinated (e.g. nn, cy), fallback
        needs_fallback = lang is None and (
            info.language_probability < 0.6 or info.language not in ALLOWED_AUTO_LANGUAGES
        )

        if needs_fallback:
            sys.stderr.write(
                f"[transcribe] Language '{info.language}' (confidence: {info.language_probability:.2f}) "
                f"unreliable, falling back to '{args.fallback_lang}'\n"
            )
            segments, info = model.transcribe(
                args.audio_path,
                beam_size=2,
                temperature=0.0,
                compression_ratio_threshold=2.8,
                language=args.fallback_lang,
                condition_on_previous_text=False,
                vad_filter=args.vad,
                vad_parameters=vad_params,
                max_initial_timestamp=5.0
            )

        sys.stderr.write(
            f"[transcribe] Detected language: {info.language} (confidence: {info.language_probability:.2f})\n"
        )

        text_parts = []
        for segment in segments:
            # Whisper internally filters no_speech. Only discard if no_speech_prob is high AND logprob is very poor.
            if segment.no_speech_prob > 0.85 and segment.avg_logprob < -1.0:
                continue
            cleaned = " ".join(segment.text.split())
            if cleaned:
                text_parts.append(cleaned)

        result = " ".join(text_parts).strip()
        if result:
            print(result)

    except Exception as e:
        sys.stderr.write(f"[transcribe] Error during transcription: {e}\n")
        traceback.print_exc(file=sys.stderr)

if __name__ == "__main__":
    main()
EOF

chmod +x ~/.local/share/whisper-dictation/transcribe.py
```

---

## 5. Visual Recording Indicator (Optional / Built-in)

To provide instant, language-neutral visual feedback on whether recording or transcribing is active (e.g. when using Bluetooth headphones where start chimes may be delayed or quiet), `indicator.py` displays a small, sleek floating badge (`●` red pulsing dot while recording / `⏳` hourglass while transcribing) in the corner of your screen without taking focus:

Create `~/.local/share/whisper-dictation/indicator.py`:

```bash
cat << 'EOF' > ~/.local/share/whisper-dictation/indicator.py
#!/usr/bin/env python3
"""
Minimal language-neutral floating recording indicator & feedback popup for whisper-dictate.

Supports:
1. Native Wayland Layer-Shell (via GtkLayerShell):
   - KeyboardMode.NONE: Physically impossible to receive or steal window/keyboard focus.
   - Works natively on Sway, Hyprland, Wayfire, River.
2. X11 / Fallback (via Tkinter):
   - Uses override_redirect and type notification for X11 desktops (i3, Cinnamon, XFCE).

Modes:
  1. Default (State monitor via /tmp/whisper_dictate.state):
     - 'recording': pulsing red dot (●)
     - 'transcribing': hourglass (⏳)
     - 'stop': automatically closes
  2. One-shot banner notification:
     python3 indicator.py --notify "Message text" [--icon "⚠️"] [--duration 2.5]
"""

import sys
import os
import time
import argparse

STATE_FILE = "/tmp/whisper_dictate.state"

# Try importing GTK Layer-Shell for zero-focus Wayland integration
HAS_LAYER_SHELL = False
try:
    if os.environ.get("WAYLAND_DISPLAY"):
        import gi
        gi.require_version('Gtk', '3.0')
        gi.require_version('GtkLayerShell', '0.1')
        from gi.repository import Gtk, Gdk, GtkLayerShell, GLib
        HAS_LAYER_SHELL = True
except Exception:
    HAS_LAYER_SHELL = False

# 1. Native Wayland Layer-Shell Implementation (Zero-focus guarantee)
if HAS_LAYER_SHELL:
    def run_gtk_banner(message: str, icon: str = "⚠️", duration: float = 2.5):
        window = Gtk.Window()
        GtkLayerShell.init_for_window(window)
        GtkLayerShell.set_layer(window, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_keyboard_mode(window, GtkLayerShell.KeyboardMode.NONE)
        GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_margin(window, GtkLayerShell.Edge.TOP, 16)
        GtkLayerShell.set_margin(window, GtkLayerShell.Edge.RIGHT, 16)

        css_provider = Gtk.CssProvider()
        css = b"""
        .banner-box {
            background-color: #181825;
            border: 2px solid #f38ba8;
            border-radius: 8px;
            padding: 8px 16px;
        }
        .banner-text {
            color: #f38ba8;
            font-weight: bold;
            font-size: 13px;
        }
        """
        css_provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        box = Gtk.Box()
        box.get_style_context().add_class("banner-box")
        lbl = Gtk.Label(label=f"{icon}  {message}")
        lbl.get_style_context().add_class("banner-text")
        box.pack_start(lbl, True, True, 0)
        window.add(box)
        window.show_all()

        GLib.timeout_add(int(duration * 1000), Gtk.main_quit)
        Gtk.main()

    def run_gtk_monitor():
        if not os.path.exists(STATE_FILE):
            return

        window = Gtk.Window()
        GtkLayerShell.init_for_window(window)
        GtkLayerShell.set_layer(window, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_keyboard_mode(window, GtkLayerShell.KeyboardMode.NONE)
        GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(window, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_margin(window, GtkLayerShell.Edge.TOP, 16)
        GtkLayerShell.set_margin(window, GtkLayerShell.Edge.RIGHT, 16)

        css_provider = Gtk.CssProvider()
        css = b"""
        window {
            background-color: transparent;
        }
        .indicator-box {
            background-color: #181825;
            border: 2px solid #45475a;
            border-radius: 8px;
            padding: 6px 12px;
        }
        .recording-dot {
            color: #ff5555;
            font-size: 22px;
            font-weight: bold;
        }
        .transcribing-icon {
            color: #f9e2af;
            font-size: 18px;
        }
        """
        css_provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        box = Gtk.Box()
        box.get_style_context().add_class("indicator-box")
        label = Gtk.Label(label="●")
        label.get_style_context().add_class("recording-dot")
        box.pack_start(label, True, True, 0)
        window.add(box)
        window.show_all()

        blink = [True]
        start_time = time.time()

        def update_state():
            if not os.path.exists(STATE_FILE):
                Gtk.main_quit()
                return False

            try:
                with open(STATE_FILE, "r") as f:
                    state = f.read().strip()
            except Exception:
                state = "recording"

            if state == "stop":
                Gtk.main_quit()
                return False
            elif state == "transcribing":
                label.set_text("⏳")
                label.get_style_context().remove_class("recording-dot")
                label.get_style_context().add_class("transcribing-icon")
                label.set_opacity(1.0)
            else:
                blink[0] = not blink[0]
                label.set_text("●")
                label.get_style_context().remove_class("transcribing-icon")
                label.get_style_context().add_class("recording-dot")
                label.set_opacity(1.0 if blink[0] else 0.3)

            if time.time() - start_time > 600:
                Gtk.main_quit()
                return False

            return True

        GLib.timeout_add(250, update_state)
        Gtk.main()

# 2. X11 / Tkinter Fallback Implementation
def run_tk_banner(message: str, icon: str = "⚠️", duration: float = 2.5):
    import tkinter as tk
    try:
        root = tk.Tk()
    except Exception:
        return

    root.title("Whisper Notification")
    try:
        root.attributes("-type", "notification")
    except Exception:
        pass
    root.overrideredirect(True)
    root.attributes("-topmost", True)

    text = f" {icon}  {message} "
    temp_lbl = tk.Label(root, text=text, font=("Sans", 11, "bold"))
    temp_lbl.pack()
    root.update_idletasks()
    width = max(240, temp_lbl.winfo_reqwidth() + 30)
    temp_lbl.destroy()

    height = 40
    sw = root.winfo_screenwidth()
    x = max(10, sw - width - 20)
    y = 20
    root.geometry(f"{width}x{height}+{x}+{y}")
    root.configure(bg="#181825")

    frame = tk.Frame(root, bg="#181825", highlightbackground="#f38ba8", highlightthickness=2)
    frame.pack(fill="both", expand=True)

    lbl = tk.Label(frame, text=text, font=("Sans", 11, "bold"), fg="#f38ba8", bg="#181825")
    lbl.pack(expand=True)

    root.after(int(duration * 1000), root.destroy)
    root.mainloop()

def run_tk_monitor():
    import tkinter as tk
    if not os.path.exists(STATE_FILE):
        return

    try:
        root = tk.Tk()
    except Exception:
        return

    root.title("Whisper Indicator")
    try:
        root.attributes("-type", "notification")
    except Exception:
        pass
    root.overrideredirect(True)
    root.attributes("-topmost", True)

    sw = root.winfo_screenwidth()
    size = 42
    x = max(10, sw - size - 20)
    y = 20
    root.geometry(f"{size}x{size}+{x}+{y}")
    root.configure(bg="#181825")

    frame = tk.Frame(root, bg="#181825", highlightbackground="#45475a", highlightthickness=1)
    frame.pack(fill="both", expand=True)

    icon_label = tk.Label(frame, text="●", font=("Sans", 18, "bold"), fg="#ff5555", bg="#181825")
    icon_label.pack(expand=True)

    start_time = time.time()
    blink = [True]

    def update_ui():
        if not os.path.exists(STATE_FILE):
            try:
                root.destroy()
                root.quit()
            except Exception:
                pass
            sys.exit(0)

        try:
            with open(STATE_FILE, "r") as f:
                state = f.read().strip()
        except Exception:
            state = "recording"

        if state == "stop":
            try:
                root.destroy()
                root.quit()
            except Exception:
                pass
            sys.exit(0)
        elif state == "transcribing":
            icon_label.configure(text="⏳", font=("Sans", 14), fg="#f9e2af")
        else: # recording
            blink[0] = not blink[0]
            icon_label.configure(text="●", font=("Sans", 18, "bold"), fg="#ff5555" if blink[0] else "#881111")

        if time.time() - start_time > 600:
            try:
                root.destroy()
                root.quit()
            except Exception:
                pass
            sys.exit(0)

        root.after(300, update_ui)

    root.after(100, update_ui)
    root.mainloop()

def main():
    parser = argparse.ArgumentParser(description="Whisper floating indicator & notification")
    parser.add_argument("--notify", type=str, help="Show notification banner message and exit")
    parser.add_argument("--icon", type=str, default="⚠️", help="Icon for notification banner")
    parser.add_argument("--duration", type=float, default=2.5, help="Duration in seconds for banner")
    args = parser.parse_args()

    if args.notify:
        if HAS_LAYER_SHELL:
            run_gtk_banner(args.notify, icon=args.icon, duration=args.duration)
        else:
            run_tk_banner(args.notify, icon=args.icon, duration=args.duration)
    else:
        if HAS_LAYER_SHELL:
            run_gtk_monitor()
        else:
            run_tk_monitor()

if __name__ == "__main__":
    main()
EOF

chmod +x ~/.local/share/whisper-dictation/indicator.py
```

---

## 6. Universal Toggle Wrapper

This script manages start/stop state, avoids race conditions, shows the visual overlay, and automatically detects whether you are on **Wayland** (`wtype`) or **X11** (`xdotool`).

Create `~/.local/bin/whisper-dictate`:

```bash
cat << 'EOF' > ~/.local/bin/whisper-dictate
#!/usr/bin/env bash
APP_DIR="$HOME/.local/share/whisper-dictation"
VENV_PYTHON="$APP_DIR/venv/bin/python3"
TRANSCRIBE_SCRIPT="$APP_DIR/transcribe.py"
INDICATOR_SCRIPT="$APP_DIR/indicator.py"
PID_FILE="/tmp/whisper_dictate.pid"
LOCK_FILE="/tmp/whisper_dictate.lock"
STATE_FILE="/tmp/whisper_dictate.state"
AUDIO_FILE="/tmp/whisper_dictate.wav"
LOG_FILE="/tmp/whisper_dictate.log"
START_SOUND="$APP_DIR/sounds/start.wav"
STOP_SOUND="$APP_DIR/sounds/stop.wav"

# Configuration
MODEL="${DICTATE_MODEL:-small}"      # Options: tiny, base, small, medium, turbo
LANG="${DICTATE_LANG:-auto}"        # Language: "auto" for auto-detection, or e.g. "de", "en", "fr"
FALLBACK_LANG="de"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

set_indicator() {
    local state="$1"
    echo "$state" > "$STATE_FILE"
    if [ "$state" = "recording" ] && [ -f "$INDICATOR_SCRIPT" ]; then
        pkill -f "whisper-dictation/indicator.py" 2>/dev/null || true
        python3 "$INDICATOR_SCRIPT" >/dev/null 2>&1 &
    fi
}

notify_user() {
    local message="$1"
    local icon="${2:-⚠️}"
    log "Notify: $message"
    if [ -f "$INDICATOR_SCRIPT" ]; then
        python3 "$INDICATOR_SCRIPT" --notify "$message" --icon "$icon" >/dev/null 2>&1 &
    fi
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Whisper Dictation" "$message" >/dev/null 2>&1 || true
    fi
}

# 1. Handle rapid consecutive toggle: wait if transcription is currently finishing
if [ -f "$LOCK_FILE" ]; then
    log "Transcription in progress, waiting for completion before starting new recording..."
    for i in {1..50}; do
        sleep 0.05
        [ ! -f "$LOCK_FILE" ] && break
    done
    if [ -f "$LOCK_FILE" ]; then
        log "Transcription lock timeout, ignoring toggle."
        exit 0
    fi
    sleep 0.1
fi

# 2. Stop recording & transcribe
if [ -f "$PID_FILE" ]; then
    REC_PID=$(cat "$PID_FILE")
    rm -f "$PID_FILE"

    if ps -p "$REC_PID" > /dev/null 2>&1; then
        touch "$LOCK_FILE"
        set_indicator "transcribing"
        kill -INT "$REC_PID" 2>/dev/null
        
        [ -f "$STOP_SOUND" ] && paplay "$STOP_SOUND" >/dev/null 2>&1 &
        
        while ps -p "$REC_PID" > /dev/null 2>&1; do
            sleep 0.05
        done

        log "Recording stopped. Transcribing..."

        # Save focused window ID to ensure text is typed into the right window
        FOCUSED_SWAY_ID=""
        FOCUSED_X11_ID=""
        if [ -n "$WAYLAND_DISPLAY" ] && command -v swaymsg >/dev/null 2>&1; then
            FOCUSED_SWAY_ID=$(swaymsg -t get_tree 2>/dev/null | jq -r '.. | select(.focused? == true) | .id' 2>/dev/null | head -n 1)
        elif [ -n "$DISPLAY" ] && command -v xdotool >/dev/null 2>&1; then
            FOCUSED_X11_ID=$(xdotool getactivewindow 2>/dev/null)
        fi

        if [ -f "$AUDIO_FILE" ] && [ -s "$AUDIO_FILE" ]; then
            TEXT=$("$VENV_PYTHON" "$TRANSCRIBE_SCRIPT" "$AUDIO_FILE" --model "$MODEL" --lang "$LANG" --fallback-lang "$FALLBACK_LANG" 2>> "$LOG_FILE")
            log "Transcribed: '$TEXT'"

            # Remove overlay BEFORE typing so window focus is guaranteed clean
            set_indicator "stop"
            rm -f "$STATE_FILE"
            pkill -f "whisper-dictation/indicator.py" 2>/dev/null || true
            sleep 0.05

            # Re-focus original window ONLY if focus actually drifted
            if [ -n "$FOCUSED_SWAY_ID" ]; then
                CURRENT_SWAY_ID=$(swaymsg -t get_tree 2>/dev/null | jq -r '.. | select(.focused? == true) | .id' 2>/dev/null | head -n 1)
                if [ "$CURRENT_SWAY_ID" != "$FOCUSED_SWAY_ID" ]; then
                    swaymsg "[con_id=\"$FOCUSED_SWAY_ID\"] focus" >/dev/null 2>&1 || true
                fi
            elif [ -n "$FOCUSED_X11_ID" ]; then
                CURRENT_X11_ID=$(xdotool getactivewindow 2>/dev/null)
                if [ "$CURRENT_X11_ID" != "$FOCUSED_X11_ID" ]; then
                    xdotool windowactivate "$FOCUSED_X11_ID" >/dev/null 2>&1 || true
                fi
            fi
            # Allow window manager and application to process focus and input buffer
            sleep 0.15

            if [ -n "$TEXT" ]; then
                # Put transcribed text into clipboard (Wayland & X11)
                if [ -n "$WAYLAND_DISPLAY" ] && command -v wl-copy >/dev/null 2>&1; then
                    wl-copy -n "$TEXT " 2>/dev/null || true
                elif [ -n "$DISPLAY" ] && command -v xclip >/dev/null 2>&1; then
                    printf "%s " "$TEXT" | xclip -selection clipboard 2>/dev/null || true
                fi

                # Type into active window
                if [ -n "$WAYLAND_DISPLAY" ]; then
                    wtype -m logo -m alt -m ctrl -m shift -s 15 -d 2 -- "$TEXT "
                else
                    xdotool type --clearmodifiers --delay 2 -- "$TEXT "
                fi
            else
                log "No text recognized."
                notify_user "Kein Text erkannt" "⚠️"
            fi
        else
            set_indicator "stop"
            rm -f "$STATE_FILE"
            pkill -f "whisper-dictation/indicator.py" 2>/dev/null || true
            notify_user "Aufnahme zu kurz oder leer" "⚠️"
        fi

        rm -f "$LOCK_FILE"
        exit 0
    fi
fi

# 3. Start recording
rm -f "$AUDIO_FILE" "$LOCK_FILE"
set_indicator "recording"
[ -f "$START_SOUND" ] && paplay "$START_SOUND" >/dev/null 2>&1 &

ffmpeg -y -f pulse -i default -ar 16000 -ac 1 "$AUDIO_FILE" >/dev/null 2>&1 &
echo $! > "$PID_FILE"
log "Recording started (PID $!)."
EOF

chmod +x ~/.local/bin/whisper-dictate
```

---

## 7. Hotkey Setup

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
