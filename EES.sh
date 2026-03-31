#!/usr/bin/env bash
set -e

VRCHAT_APPID=438100
HOME_DIR="$HOME"
STEAM_DIR="$HOME_DIR/.steam/steam"
VRC_DIR="$STEAM_DIR/steamapps/common/VRChat"
VRCHAT_DIR="$STEAM_DIR/steamapps/common/VRChat"
PROTON_EXE=""
PROTON_DLL_URL="https://cdn.discordapp.com/attachments/1364230772185370797/1485947934766792825/version.dll?ex=69caf89b&is=69c9a71b&hm=aca70be2fcdde25cf3394ed2f60e8a49b48698bdb75594fbfe4c47cf1c76fe94&"

echo "[@] Welcome to EES, made by 6arth / pine."

if [ -d "$STEAM_DIR" ]; then
    echo "[OK] Native Steam found at $STEAM_DIR"
else
    echo "[*] Steam not found, attempting Flatpak installation..."
    pacman -S flatpak
    flatpak install flathub com.valvesoftware.Steam -y
fi


if [ -d "$VRC_DIR" ]; then
    echo "[OK] VRChat found at $VRC_DIR"
else
    echo "[*] VRChat not found, opening Steam (Flatpak) to install."
    if command -v flatpak >/dev/null 2>&1; then
        flatpak run com.valvesoftware.Steam steam://install/$VRCHAT_APPID
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open "steam://install/$VRCHAT_APPID"
    else
        echo "[ERROR] Could not find Flatpak or xdg-open. Please install Steam manually."
        exit 1
    fi
    echo "[INFO] Please install VRChat via Steam, Interact once VRChat Installed."
    read -r
fi

PROTON_EXE_CANDIDATES=("$STEAM_DIR/steamapps/common/Proton"*"/proton")
for candidate in "${PROTON_EXE_CANDIDATES[@]}"; do
    if [ -f "$candidate" ]; then
        PROTON_EXE="$candidate"
        echo "[OK] Proton executable found at $PROTON_EXE"
        break
    fi
done

if [ -z "$PROTON_EXE" ]; then
    echo "[ERROR] Proton executable not found! Install a Proton version in Steam."
    exit 1
fi

if [ -f "$VRCHAT_DIR/version.dll" ]; then
    echo "[OK] version.dll already exists in VRChat folder"
else
    echo "[*] Downloading version.dll..."
    curl -L -o "$VRCHAT_DIR/version.dll" "$PROTON_DLL_URL"
    echo "[OK] version.dll placed in VRChat folder"
fi

echo ""
echo "- Launching VRChat (3s)"
sleep 3
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR"
export STEAM_COMPAT_DATA_PATH="$STEAM_DIR/steamapps/compatdata/$VRCHAT_APPID"
WINEDLLOVERRIDES="version.dll=n,b" "$PROTON_EXE" run "$VRCHAT_DIR/launch.exe"
echo "[OK] VRChat should now be launching!"