#!/usr/bin/env bash
# Builds Hatari (Atari ST emulator) to WebAssembly and assembles the site in docs/.
# Requirements: emsdk activated (emcc on PATH), cmake, ninja, git, curl, unzip.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
# Hatari's emscripten link flags break on paths with spaces, so build outside the repo.
WORK="${WORK:-${TMPDIR:-/tmp}/dizzy-st-build}"
case "$WORK" in *" "*) echo "WORK path must not contain spaces: $WORK" >&2; exit 1;; esac
HATARI_REPO="https://github.com/hatari/hatari.git"
HATARI_COMMIT="5b078e14cf6b81362e1c00f9742bad7bee481d96"
EMUTOS_URL="https://downloads.sourceforge.net/project/emutos/emutos/1.3/emutos-192k-1.3.zip"

mkdir -p "$WORK"
cd "$WORK"

# 1. Hatari source at a pinned commit
if [ ! -d hatari ]; then
  git clone "$HATARI_REPO" hatari
fi
git -C hatari fetch --depth 1 origin "$HATARI_COMMIT" 2>/dev/null || true
git -C hatari checkout -q "$HATARI_COMMIT"
git -C hatari checkout -q -- src/CMakeLists.txt src/emscripten.js
cp "$ROOT/web/pre.js" hatari/src/emscripten.js

# Upstream's emscripten export list references functions that no longer
# exist; trim it. Our emulator command line replaces src/emscripten.js above.
python3 - "$WORK/hatari/src/CMakeLists.txt" <<'EOF'
import re, sys
path = sys.argv[1]
s = open(path).read()
s = re.sub(r"_Configuration_Change\w+','", "", s)
s = s.replace("-s ASSERTIONS=0", "-s ASSERTIONS=0 -s ALLOW_MEMORY_GROWTH=1")
open(path, "w").write(s)
EOF

# 2. EmuTOS (free GPL TOS replacement)
if [ ! -f emutos/etos192uk.img ]; then
  mkdir -p emutos
  curl -sL -o emutos.zip "$EMUTOS_URL"
  unzip -o -q -j emutos.zip 'emutos-192k-1.3/etos192uk.img' -d emutos
fi

# 3. Files preloaded into the virtual filesystem at /share/hatari/
BUILD="$WORK/hatari/build-wasm"
mkdir -p "$BUILD/files"
cp emutos/etos192uk.img "$BUILD/files/tos.img"
cp "$ROOT/game/dizzy.st" "$BUILD/files/dizzy.st"
cp "$ROOT/web/hatari.cfg" "$BUILD/files/hatari.cfg"

# 4. Configure + build
SDL2_DIR="$(dirname "$(command -v emcc)")/cache/sysroot/lib/cmake/SDL2"
if [ ! -d "$SDL2_DIR" ]; then
  embuilder build sdl2 zlib
fi
cd "$BUILD"
emcmake cmake .. -G Ninja \
  -DSDL2_DIR="$SDL2_DIR" -DENABLE_SDL3=OFF \
  -DENABLE_TOOLS=OFF -DENABLE_DSP_EMU=OFF -DENABLE_TRACING=OFF -DENABLE_MAN_PAGES=OFF
# Preloaded files and pre-js are not tracked as link dependencies; force a relink.
rm -f src/hatari.html
cmake --build . --target hatari

# 5. Assemble site
mkdir -p "$ROOT/docs"
cp src/hatari.js src/hatari.wasm src/hatari.data "$ROOT/docs/"
cp "$ROOT/web/index.html" "$ROOT/docs/index.html"
touch "$ROOT/docs/.nojekyll"
echo "Site built in $ROOT/docs"
