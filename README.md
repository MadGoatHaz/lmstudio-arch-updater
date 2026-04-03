# LM Studio Arch Linux Updater

![Bash](https://img.shields.io/badge/bash-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)

A professional utility to maintain the latest LM Studio releases on Arch Linux, resolving AUR update loops through direct version tracking.

## Features

- **Dual-Track Resolution**: Stable Header Inspection vs. Beta HTML Scraping.
- **AUR-Cohesive Deployment**: Works with or without `lmstudio-bin`.
- **Interactive Prompting**: User-friendly interface with automated timeouts.
- **Direct Version Tracking**: Reliable detection via `/opt/lm-studio/.version`.

## Installation

1. **Install to system path**:
```
sudo cp lmstudio-beta-updater.sh /usr/local/bin/update-lmstudio
```

2. **Make the script executable**:
```
sudo chmod +x /usr/local/bin/update-lmstudio
```

## Usage

Run `update-lmstudio` to manage your installation.

```
update-lmstudio
```
