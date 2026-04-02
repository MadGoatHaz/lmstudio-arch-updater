# LM Studio Arch Linux Updater

A professional utility to maintain the latest LM Studio releases on Arch Linux, resolving AUR update loops through direct version tracking.

## Features

- **Dual-Track Resolution**: Precise detection using Stable Header Inspection vs. Beta HTML Scraping.
- **AUR-Cohesive Deployment**: Works seamlessly with or without the `lmstudio-bin` AUR package.
- **Interactive Prompting**: User-friendly interface with automated timeouts for efficient workflows.
- **Direct Version Tracking**: Reliable version detection via local tracking at `/opt/lm-studio/.version`.

## Installation

1. **Copy the script to your path**:
   ```bash
   sudo cp lmstudio-beta-updater.sh /usr/local/bin/update-lmstudio
   ```

2. **Ensure it is executable**:
   ```bash
   sudo chmod +x /usr/local/bin/update-lmstudio
   ```

## Usage

Run the following command to manage your LM Studio installation:

```bash
update-lmstudio
```
