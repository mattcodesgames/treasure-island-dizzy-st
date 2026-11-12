# Treasure Island Dizzy (Atari ST) in the browser

Runs the original Atari ST disk image of *Treasure Island Dizzy* (Code Masters, 1989)
in a web page. It uses [Hatari](https://hatari.tuxfamily.org/), an Atari ST emulator, compiled
to WebAssembly with Emscripten, and [EmuTOS](https://emutos.sourceforge.io/) (a free TOS replacement) as the ROM.

The game itself isn't rewritten. The emulator runs the original disk.

## Controls

- **Space**: start the game / jump (joystick fire)
- **Arrow keys**: move (joystick)
- **F12**: Hatari menu

## Layout

| Path | Purpose |
| --- | --- |
| `game/dizzy.st` | Original disk image |
| `web/index.html` | Page around the emulator canvas |
| `web/pre.js` | Hatari command line (machine, TOS, disk) |
| `web/hatari.cfg` | Joystick key mapping (fire = Space) |
| `build.sh` | Fetches pinned Hatari and EmuTOS 1.3, builds to wasm, writes `docs/` |
| `docs/` | Built site served by GitHub Pages |

## Building

Requires the [Emscripten SDK](https://emscripten.org/docs/getting_started/downloads.html) (activated), plus cmake, ninja, git, curl and unzip.

```bash
./build.sh
python3 -m http.server 8123 --directory docs
```

Then open http://localhost:8123. The page has to be served over HTTP; opening the file directly won't work.

## Licences

Hatari and EmuTOS are GPL-licensed. *Treasure Island Dizzy* is © Code Masters.
