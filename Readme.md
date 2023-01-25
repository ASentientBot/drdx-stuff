# drdx-stuff
Compile [DinoRunDX](https://github.com/pixeljam/DinoRunDX) for macOS/Windows/iOS/Android with enhancements. Desktop builds are equivalent to Steam version, mobile are playable but incomplete and likely buggy.

![](Screenshot.png)

## dependencies
- macOS 13
- WINE (Windows)
- Adobe AIR 32 compiler
- JDK 8 (macOS), 19 (Windows)
- FRESteamworks ([waveofthought fork](https://github.com/waveofthought-code/FRESteamWorks)), Steamworks SDK (desktop)

## license
GPL v3 (derivative work of DinoRunDX). Support Pixeljam by purchasing on [Steam](https://store.steampowered.com/app/248330/Dino_Run_DX/) or [itch.io](https://pixeljam.itch.io/dino-run-dx)!

## run
```zsh
./Build.zsh mac build && cp -R Temp/Build.app ~/Desktop/DRDX_macOS.app
./Build.zsh windows build && cp -R Temp/Build ~/Desktop/DRDX_Windows
./Build.zsh ios build && cp Temp/Build.ipa ~/Desktop/DRDX_iOS.ipa
./Build.zsh android build && cp Temp/Build.apk ~/Desktop/DRDX_Android.apk
```

## builds
See [releases](https://github.com/ASentientBot/drdx-stuff/releases) for sideloadable IPA/APK files.

## mobile app progress
- [x] compiles and runs on iOS/Android
- [x] minimal touch inputs that allow completing the game
- [ ] adjustments to make main menu, upgrade screen, etc. more touch-friendly
- [ ] proper pause/continue/doom/win menus replacing my ugly buttons
- [ ] customizable control layout?
- [ ] alternate tap/gesture based controls?
- [ ] ?