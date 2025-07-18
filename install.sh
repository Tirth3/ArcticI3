#!/bin/bash

# === Config ===
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%s)"
mkdir -p "$BACKUP_DIR"

# Map of dotfiles (repo path → target path)
declare -A FILES_TO_SYMLINK=(
  [".zshrc"]="$HOME/.zshrc"
  [".Xresources"]="$HOME/.Xresources"
  [".config/i3"]="$HOME/.config/i3"
  [".config/polybar"]="$HOME/.config/polybar"
  [".config/picom"]="$HOME/.config/picom"
  [".config/dunst"]="$HOME/.config/dunst"
  [".config/rofi"]="$HOME/.config/rofi"
)

# === Dependencies ===
DEPENDENCIES=(
  zsh
  picom
  dunst
  rofi
  polybar
  brightnessctl
  playerctl
  python-pywal
)

# === Install Dotfiles ===
echo "📦 Installing dotfiles..."

for src in "${!FILES_TO_SYMLINK[@]}"; do
  dest="${FILES_TO_SYMLINK[$src]}"
  full_src="$DOTFILES_DIR/$src"

  # Backup if exists
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "🔁 Backing up $dest → $BACKUP_DIR/"
    mv "$dest" "$BACKUP_DIR/"
  fi

  # Create parent and symlink
  mkdir -p "$(dirname "$dest")"
  ln -s "$full_src" "$dest"
  echo "✅ Linked $src → $dest"
done

# === Prompt to Install Dependencies ===
echo
read -p "❓ Do you want to auto-install required dependencies? [Y/n] " REPLY
REPLY=${REPLY,,} # make lowercase

if [[ "$REPLY" =~ ^(yes|y| )*$ ]]; then
  echo "🚀 Installing dependencies..."

  if command -v pacman >/dev/null; then
    sudo pacman -S --needed "${DEPENDENCIES[@]}"
  elif command -v apt >/dev/null; then
    sudo apt update
    sudo apt install -y "${DEPENDENCIES[@]}"
  else
    echo "⚠️ Unknown package manager. Install manually:"
    printf '   %s\n' "${DEPENDENCIES[@]}"
    exit 1
  fi

  echo "✅ All dependencies installed."
else
  echo "❌ Skipping dependency install."
  echo "⚠️ Setup not fully configured due to missing dependencies."
fi

echo "🎉 Done!"
