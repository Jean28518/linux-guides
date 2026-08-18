# My i3 setup 

This is not a complete tutorial but provides "building blocks" how my i3 desktop is configured.

## Basics & Menu:
```bash
# Default Applications
sudo apt install eog xfce4-terminal mousepad i3 slick-greeter chromium xarchiver gdebi evince thunar thunar-archive-plugin

sudo apt install j4-dmenu-desktop dmenu

vim .config/i3/config
# Change in the config the starter to j4-dmenu-desktop

workspace_layout tabbed

bindsym $mod+x exec chromium
bindsym $mod+c exec thunar
bindsym $mod+t exec mousepad -o window
bindsym $mod+Shift+c exec code
bindsym $mod+Shift+v exec virtualbox
bindsym $mod+Shift+g exec gnome-calculator
bindsym $mod+g exec chromium --app="https://gemini.google.com"


# Comment:
#bindsym $mod+Shift+c reload
```


## Dark Theme
```bash
yay -s arc-gtk-theme lxappearence
sudo apt install arc-theme lxappearance
gsettings set org.gnome.desktop.interface gtk-theme 'Arc-Dark' 
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

mkdir ~/.config/gtk-3.0/
vim ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Arc-Dark
gtk-application-prefer-dark-theme=1

# Set in lxappearence the default heme to Arc-Dark


## HOW TO REVERT:
gsettings set org.gnome.desktop.interface gtk-theme 'Arc' 
gsettings set org.gnome.desktop.interface color-scheme 'default'
rm ~/.config/gtk-3.0/settings.ini
```

## Xfce4-Terminal
```bash
sudo apt install gnome-terminal
# Rightclick on the blank space of the terminal, there you go to the preferences
# On general on the bottom disable unsafe paste warning
# On View disable the menubar
```

## Gnome-Terminal
```bash
sudo apt install gnome-terminal
bindsym $mod+Return exec gnome-terminal
bindsym $mod+KP_Enter exec gnome-terminal


# Rightclick on the blank space of the terminal, there you go to the preferences
```


## Natural Scrolling:
```bash
sudo vim /usr/share/X11/xorg.conf.d/40-libinput.conf

#In the touchpad section add:
Option "NaturalScrolling" "True"
```

## Touchpad enable tap to click

```bash
sudo vim /usr/share/X11/xorg.conf.d/40-libinput.conf

#In the touchpad section add:
Option "Tapping" "on"
```

## Polkit Agent:
```bash
sudo apt install policykit-1-gnome
# Bei neueren versionen:
sudo apt install mate-polkit
# sudo pacman -S polkit-gnome
vim .config/i3/config
exec --no-startup-id /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 &
# Oder Mit Mate polkit:
exec --no-startup-id /usr/libexec/mate-polkit/polkit-mate-authentication-agent-1 &

# Arch:
exec --no-startup-id /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

```

## Gnome Keyring and such stuff (For nextcloud client e.g.)
```bash
sudo apt install seahorse gnome-keyring libsecret-common

sudo pacman -S seahorse
sudo pacman -S gnome-keyring libsecret
```

## Change Brigthness
```bash
sudo apt install brightnessctl
sudo usermod -aG video jean
vim .config/i3/config
bindsym XF86MonBrightnessUp exec --no-startup-id brightnessctl set +5%
bindsym XF86MonBrightnessDown exec --no-startup-id brightnessctl set 5%-
```


## Screenshots:

```bash
sudo apt install scrot xclip
# sudo pacman -S scrot xclip
vim .config/i3/config
bindsym --release Print exec "scrot -e 'mv $f ~/Bilder/'"
bindsym --release Shift+Print exec "scrot -s -e 'mv $f ~/Bilder/'"
bindsym --release Shift+Control+Print exec "scrot -s -e 'xclip -selection clipboard -target image/png -i $f && rm $f'"



```

## Disable Notifications:
```bash
sudo apt purge dunst
# sudo pacman -R dunst
```

## Lock Screen:
```bash
sudo apt install i3lock gnome-backgrounds
vim .config/i3/config
bindsym $mod+Ctrl+l exec i3lock -i /home/jean/Pictures/myimg.jpg
```

## Window Theme, Icon Theme, etc...
```bash
sudo apt install lxappearance
```

## SSH Key Agent:
```bash
mkdir -p .scripts
vim .scripts/start-ssh-agent.sh
#!/bin/sh 
SSH_ENV="$HOME/.ssh/environment" 
# Start the agent if it's not running 
if [ ! -f "$SSH_ENV" ]; then 
  ssh-agent -s > "$SSH_ENV" 
  chmod 600 "$SSH_ENV" 
fi 
# Load the agent's environment variables 
. "$SSH_ENV"

chmod +x .scripts/start-ssh-agent.sh
vim .xprofile
# Check if a display manager is running
if [ -n "$DISPLAY" ] && [ -z "$SSH_AUTH_SOCK" ]; then
    # Start the ssh-agent if it isn't already running
    eval $(ssh-agent -s)
fi
```

## Sound Control
```bash
sudo pacman -S wireplumber pipewire pipewire-pulse
sudo systemctl --user enable --now pipewire pipewire-pulse wireplumber

sudo pacman -S pasystray pavucontrol

vim .config/i3/config
exec --no-startup-id pasystray &
# Lautstärke erhöhen
bindsym XF86AudioRaiseVolume exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
# Lautstärke reduzieren
bindsym XF86AudioLowerVolume exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
# Stummschalten (Mute)
bindsym XF86AudioMute exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

```

## Bluetooth
```bash
sudo pacman -S blueman bluez
sudo systemctl enable bluetooth.service --now
```


## Background:
```bash
sudo pacman -S feh
vim .config/i3/config
exec --no-startup-id feh --bg-fill /home/jean/Pictures/myimg.jpg


Bildschirmauflösung:
sudo apt install arandr
#Dann in arandr die auflösung speichern unter 16-9.sh
Dann in den autostart reinmachen
vim .config/i3/config
exec --no-startup-id ...
```

## i3status
```bash
mkdir .config/i3status/
vim .config/i3status/config 
general {
        colors = true
        interval = 1
}

#order += "ipv6"
#order += "wireless _first_"
order += "ethernet _first_"
#order += "battery all"
order += "disk /"
order += "load"
order += "memory"
order += "tztime local"

wireless _first_ {
        format_up = "W: (%quality at %essid) %ip"
        format_down = "W: down"
}

ethernet _first_ {
        format_up = "E: %ip (%speed)"
        format_down = "E: down"
}

battery all {
        format = "%status %percentage %remaining"
}

disk "/" {
        format = "%avail"
}

load {
        format = "%1min"
}

memory {
        format = "%used | %available"
        threshold_degraded = "1G"
        format_degraded = "MEMORY < %available"
}

tztime local {
        format = "%Y-%m-%d %H:%M:%S"
}

```

## Autostart

```bash
mkdir -p .scripts
vim .scripts/autostart_i3.sh
#!/bin/bash

i3-msg 'redshift -l 10.000000:-5.0000000' &

i3-msg 'workspace number 1; exec thunderbird' &
sleep 4
i3-msg 'workspace number 1; exec element-desktop' &
sleep 4
i3-msg 'workspace number 1; exec signal-desktop' &
sleep 5

i3-msg 'workspace number 3; exec keepassxc' &
sleep 4
i3-msg 'workspace number 3; exec bitwarden-desktop' &
sleep 4
obsidian 'obsidian://open?vault=Notizen' &
sleep 4

i3-msg 'workspace number 8; layout splith' &
i3-msg 'exec chromium https://my.nextcloud.de/index.php/apps/calendar/timeGridWeek/now  --new-window --hide-crash-restore-bubble' &
sleep 4
i3-msg 'exec chromium https://my_second_site --hide-crash-restore-bubble' &
sleep 1
i3-msg 'exec chromium https://mytasksapp.de --new-window --hide-crash-restore-bubble' &
sleep 1
i3-msg 'workspace number 10; exec chromium https://open.spotify.com/  --new-window --hide-crash-restore-bubble' &
sleep 1

i3-msg 'workspace number 8'
i3-msg 'workspace number 3; exec linux-assistant' &
sleep 1
i3-msg 'workspace number 2; exec bash -c "exec thunar; sleep 20; pkill -INT thunar"' &
sleep 4
i3-msg 'workspace number 1'

i3-msg 'exec nextcloud' &
i3-msg 'exec pasystray' &
i3-msg 'exec orage' &
i3-msg 'exec flameshot' &
exit 0



chmod +x .scripts/autostart_i3.sh
vim .config/i3/config 
exec --no-startup-id $HOME/.scripts/autostart_i3.sh


# In orage set the default start mode to hidden
```


## Multiple Monitors
```bash
vim .config/i3/config
workspace 1 output HDMI-0
workspace 2 output HDMI-0
workspace 3 output HDMI-0
workspace 4 output DVI-D-0
workspace 5 output DVI-D-0
workspace 6 output DVI-D-0
workspace 7 output DVI-D-0
workspace 8 output DP-1
workspace 9 output DP-1
workspace 10 output DP-1



# Laptop setup with external monitor:
vim .scripts/external_monitor_on_i3.sh
#!/usr/bin/env bash

# Ensure workspaces exist and force-migrate them
for ws in {1..3}; do
    i3-msg -q "workspace $ws; move workspace to output HDMI-A-0"
done
for ws in {4..10}; do
    i3-msg -q "workspace $ws; move workspace to output edP"
done


vim .scripts/external_monitor_off_i3.sh
#!/usr/bin/env bash

# Ensure workspaces exist and force-migrate them
for ws in {1..10}; do
    i3-msg -q "workspace $ws; move workspace to output eDP"
done


chmod +x .scripts/external_monitor*

vim .config/i3/config
bindsym $mod+o exec --no-startup-id ~/.scripts/external_monitor_on_i3.sh
bindsym $mod+Shift+o exec --no-startup-id ~/.scripts/external_monitor_off_i3.sh

workspace 1 output HDMI-A-0
workspace 2 output HDMI-A-0
workspace 3 output HDMI-A-0
workspace 4 output edP
workspace 5 output edP
workspace 6 output edP
workspace 7 output edP
workspace 8 output edP
workspace 9 output edP
workspace 10 output edP
```
