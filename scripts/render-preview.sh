#!/bin/zsh
set -eu
cd "$(dirname "$0")/.."
mkdir -p .build docs/images
python3 - <<'PY'
from pathlib import Path
source = Path('Sources/main.swift').read_text().split('final class AppDelegate:')[0]
Path('.build/render-preview.swift').write_text(source + '\n' + Path('scripts/render-preview.swift').read_text())
PY
xcrun swiftc -module-cache-path "$PWD/.build/module-cache" .build/render-preview.swift -o .build/render-preview -framework AppKit
.build/render-preview "$PWD/docs/images/habibi-pet-bot-preview.png"
