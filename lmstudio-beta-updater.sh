#!/bin/bash

# LM Studio Beta Helper Script (lmstudio-beta-updater.sh)
# Objective: Check for, download, and install latest LM Studio beta/stable on Arch Linux.
# Coexists with AUR lmstudio-bin or acts as standalone.

set -e

# --- Configuration & Constants ---
OPT_DIR="/opt/lm-studio"
APPIMAGE_PATH="${OPT_DIR}/lm-studio.AppImage"
VERSION_FILE="${OPT_DIR}/.version"
BIN_LINK="/usr/bin/lm-studio"
DESKTOP_FILE="/usr/share/applications/lmstudio.desktop"

# --- Chunk 1: Environment & Version Discovery ---

# Dependency Check
check_dependencies() {
    local deps=("curl" "grep" "awk" "sed" "pacman" "sudo")
    local missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        echo "Error: Missing mandatory dependencies: ${missing[*]}" >&2
        exit 1
    fi
}

# Discover local version and installation type
# Discover local version and installation type
discover_local() {
    IS_AUR=false
    LOCAL_VERSION="none"

    # 1. Determine if AUR package is installed (Sets flag only)
    if pacman -Q lmstudio-bin >/dev/null 2>&1; then
        IS_AUR=true
    fi

    # 2. Determine actual Local Version (Prioritize .version file)
    if [ -f "$VERSION_FILE" ]; then
        LOCAL_VERSION=$(cat "$VERSION_FILE")
        if [ "$IS_AUR" = true ]; then
            echo "Detected AUR installation base. Tracked script version: ${LOCAL_VERSION}"
        else
            echo "Detected standalone installation: version ${LOCAL_VERSION}"
        fi
    elif [ "$IS_AUR" = true ]; then
        # Fallback to pacman if .version missing (first run over an AUR install)
        LOCAL_VERSION=$(pacman -Q lmstudio-bin | awk '{print $2}')
        echo "Detected AUR installation: pacman version ${LOCAL_VERSION}"
    elif [ -f "$APPIMAGE_PATH" ]; then
        echo "Warning: /opt/lm-studio exists but .version file is missing."
        LOCAL_VERSION="unknown"
    else
        echo "No existing LM Studio installation detected."
    fi
}

# --- Chunk 2: Remote Version Scraping & Parsing ---

# Scrape the latest AppImage URL and extract the version
scrape_remote_info() {
    echo "Fetching latest version information..."

    # 1. Fetch Stable via Header Inspection
    local stable_redirect
    stable_redirect=$(curl -sI "https://lmstudio.ai/download/latest/linux/x64?format=AppImage" | grep -i '^location:' | awk '{print $2}' | tr -d '\r')
    local stable_version
    stable_version=$(echo "$stable_redirect" | sed -n 's/.*LM-Studio-\(.*\)-x64\.AppImage/\1/p')

    # 2. Fetch Beta via Page Scraping
    local beta_url="https://lmstudio.ai/beta-releases"
    local appimage_regex='https://[^"]+LM-Studio-[0-9a-zA-Z.-]+-x64\.AppImage'
    local beta_raw_link
    beta_raw_link=$(curl -sL "$beta_url" | grep -oE "$appimage_regex" | head -n 1 || true)
    local beta_version
    beta_version=$(echo "$beta_raw_link" | sed -n 's/.*LM-Studio-\(.*\)-x64\.AppImage/\1/p')

    # 3. Determine Winner
    if [ -n "$beta_version" ] && [ -n "$stable_version" ]; then
        local newest
        newest=$(printf "%s\n%s" "$stable_version" "$beta_version" | sort -V | tail -n 1)
        if [ "$newest" == "$beta_version" ]; then
            REMOTE_VERSION="$beta_version"
            REMOTE_URL="$beta_raw_link"
            echo "Beta version is newer or equal: ${REMOTE_VERSION}"
        else
            REMOTE_VERSION="$stable_version"
            REMOTE_URL="$stable_redirect"
            echo "Stable version is newer: ${REMOTE_VERSION}"
        fi
    elif [ -n "$stable_version" ]; then
        REMOTE_VERSION="$stable_version"
        REMOTE_URL="$stable_redirect"
        echo "Only Stable version found: ${REMOTE_VERSION}"
    elif [ -n "$beta_version" ]; then
        REMOTE_VERSION="$beta_version"
        REMOTE_URL="$beta_raw_link"
        echo "Only Beta version found: ${REMOTE_VERSION}"
    else
        echo "Error: Could not determine remote versions from Stable redirect or Beta page." >&2
        exit 1
    fi
}

# --- Chunk 3: Version Comparison & Interactive Prompt ---

# Compare local and remote versions
compare_versions() {
    if [ "$LOCAL_VERSION" == "none" ]; then
        echo "No local installation found. Proceeding with initial setup."
        SHOULD_UPDATE=true
        return
    fi

    if [ "$LOCAL_VERSION" == "unknown" ]; then
        echo "Local version unknown. Proceeding with update to remote version ${REMOTE_VERSION}."
        SHOULD_UPDATE=true
        return
    fi

    echo "Comparing Local: ${LOCAL_VERSION} with Remote: ${REMOTE_VERSION}"

    if [[ "$LOCAL_VERSION" == "$REMOTE_VERSION" ]]; then
        echo "LM Studio is already up to date (version ${LOCAL_VERSION})."
        SHOULD_UPDATE=false
    else
        # Use sort -V for version-aware comparison
        local newer_version
        newer_version=$(printf "%s\n%s" "$LOCAL_VERSION" "$REMOTE_VERSION" | sort -V | tail -n 1)

        if [[ "$newer_version" == "$REMOTE_VERSION" ]]; then
            echo "A newer version is available: ${REMOTE_VERSION}"
            SHOULD_UPDATE=true
        else
            echo "Local version ${LOCAL_VERSION} is newer than remote version ${REMOTE_VERSION}. No update required."
            SHOULD_UPDATE=false
        fi
    fi
}

# Prompt user for confirmation with timeout
prompt_update() {
    if [ "$SHOULD_UPDATE" = false ]; then
        return 0
    fi

    echo -n "New version found! Update to version ${REMOTE_VERSION}? [Y/n]: "
    # Interactive prompt with 15s timeout, default to 'Yes'
    if read -t 15 response; then
        case "$response" in
            [nN][oO]|[nN])
                echo "Update cancelled by user."
                exit 0
                ;;
            *)
                echo "Proceeding with update..."
                ;;
        esac
    else
        echo -e "\nTimeout reached. Proceeding with update (default: Yes)..."
    fi
}

# --- Chunk 4: Download & Deployment ---

# Download the new AppImage
download_appimage() {
    if [ "$SHOULD_UPDATE" = false ]; then
        return 0
    fi

    local tmp_file="/tmp/LM-Studio-${REMOTE_VERSION}-x64.AppImage"
    echo "Downloading LM Studio ${REMOTE_VERSION}..."
    if ! curl -L --progress-bar "$REMOTE_URL" -o "$tmp_file"; then
        echo "Error: Download failed!" >&2
        exit 1
    fi
    DOWNLOADED_FILE="$tmp_file"
}

# Deploy the downloaded AppImage
deploy_appimage() {
    if [ "$SHOULD_UPDATE" = false ]; then
        return 0
    fi

    echo "Deploying LM Studio ${REMOTE_VERSION}..."

    # Ensure OPT_DIR exists
    sudo mkdir -p "$OPT_DIR"

    # Move and set permissions
    sudo mv "$DOWNLOADED_FILE" "$APPIMAGE_PATH"
    sudo chmod +x "$APPIMAGE_PATH"

    # Write version file (Crucial for Standalone detection)
    echo "$REMOTE_VERSION" | sudo tee "$VERSION_FILE" >/dev/null

    # Setup symlink and desktop entry if NOT an AUR installation
    if [ "$IS_AUR" = false ]; then
        echo "Configuring standalone system integration..."

        # Create symlink in /usr/bin
        if [ ! -L "$BIN_LINK" ]; then
            sudo ln -sf "$APPIMAGE_PATH" "$BIN_LINK"
        fi

        # Generate .desktop file via heredoc
        sudo bash -c "cat << 'EOF' > $DESKTOP_FILE
[Desktop Entry]
Name=LM Studio
GenericName=Large Language Model Studio
Comment=A desktop app for exploring and running large language models locally
Exec=lm-studio %U
Icon=lmstudio-bin
Type=Application
Categories=Development;ArtificialIntelligence;
Terminal=false
StartupNotify=true
StartupWMClass=LM Studio
MimeType=text/plain;
EOF"
        echo "Desktop entry and symlink created."
    else
        echo "AUR installation detected. Updated binary in /opt/lm-studio."
        echo "Note: pacman database will still reflect the old version."
    fi

    echo "LM Studio ${REMOTE_VERSION} successfully installed."
}

main() {
    check_dependencies
    discover_local
    scrape_remote_info
    compare_versions
    prompt_update
    download_appimage
    deploy_appimage
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
