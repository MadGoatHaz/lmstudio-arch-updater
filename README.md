# LM Studio Arch Linux Updater

![Bash](https://img.shields.io/badge/bash-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch%20Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)

A standalone helper script to fetch, download, and install the absolute latest LM Studio beta or stable release for Arch Linux.

## Features

- **Dual-Track Resolution**: Supports both stable release header inspection and beta release HTML scraping to ensure you always have the latest version.
- **AUR-Cohesive Deployment**: Works seamlessly with or without the `lmstudio-bin` AUR package, handling deployments to \`/opt/lm-studio\`.
- **Interactive Prompting**: Includes user-friendly interactive prompts with timeouts for automated or manual update flows.

## Dependencies

- \`curl\`
- \`grep\`
- \`awk\`
- \`sed\`
- \`pacman\`
- \`sudo\`

## Installation

1. **Clone the repository**:
   \`\`\`bash
   git clone https://github.com/yourusername/lmstudio-beta-updater.git
   cd lmstudio-beta-updater
   \`\`\`

2. **Make the script executable**:
   \`\`\`bash
   chmod +x lmstudio-beta-updater.sh
   \`\`\`

3. **Install to system path**:
   \`\`\`bash
   sudo cp lmstudio-beta-updater.sh /usr/local/bin/update-lmstudio
   \`\`\`

## Usage

Simply run the command to check for and apply updates:

\`\`\`bash
update-lmstudio
\`\`\`
