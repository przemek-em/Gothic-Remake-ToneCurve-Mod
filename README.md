# Gothic Remake ToneCurve Mod

Small UE4SS Lua mod for Unreal Engine games that automatically runs:

```text
show ToneCurve
show LocalExposure
```

This is meant for games where the default Unreal filmic tone curve makes the image too dark, too bright, or too aggressively cinematic, and where Local Exposure creates HDR-like halos around objects.

## What This Fixes

Unreal's default Filmic ACES tonemapper can look good in controlled shots and cinematics, but it can be hard to tune globally for a whole game. In some games it crushes shadows, pushes highlights, or creates a distracting cinematic look that is not always ideal for gameplay.

Running `show ToneCurve` disables Unreal's tone curve show flag for the game viewport. This gives a more raw render that can then be tone mapped with ReShade shaders such as:

```text
ACESNarkowicz.fx
UnchartedHable.fx
```

Running `show LocalExposure` disables Unreal's Local Exposure show flag. In UE5 this neutralizes the local exposure path, including the effect of settings such as:

```text
LocalExposureDetailStrength
LocalExposureBlurredLuminanceBlend
```

That means the old manual workaround is no longer needed for local exposure. This mod now toggles it off automatically together with the tone curve.

## Important Note

Both commands are toggles. If the mod already ran successfully, typing `show ToneCurve` or `show LocalExposure` manually will toggle that feature back on.

The mod tracks each command independently during startup retries, so it will not accidentally run the same command twice if only one command fails at first.

## Install UE4SS

1. Download a UE4SS build compatible with the game. For Gothic Remake, use the experimental UE4SS build that supports UE 5.4.3:

```text
https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest
```

2. Open the game's Win64 binary folder. For Gothic Remake this is:

```text
G1R\Binaries\Win64
```

3. Extract UE4SS into that folder, next to the shipping executable:

```text
G1R-Win64-Shipping.exe
```

After this, UE4SS should create or use a `Mods` folder in the same Win64 directory.

## Install This Mod

Copy this folder:

```text
ToneCurveShowToggleMod
```

into:

```text
G1R\Binaries\Win64\Mods
```

The final layout should look like:

```text
G1R\Binaries\Win64\Mods\ToneCurveShowToggleMod\Scripts\main.lua
```

Enable it in:

```text
G1R\Binaries\Win64\Mods\mods.txt
```

Add or keep this line:

```text
ToneCurveShowToggleMod : 1
```


## Install ReShade

1. Download and install ReShade into the same game executable:

```text
https://reshade.me/
```

```text
G1R\Binaries\Win64\G1R-Win64-Shipping.exe
```

2. Let ReShade create its `reshade-shaders` folder.

3. Download the Filmic Tonemapping ReShade shaders:

```text
https://github.com/Zackin5/Filmic-Tonemapping-ReShade
```

4. Put the shader files into the ReShade shader folder, usually:

```text
G1R\Binaries\Win64\reshade-shaders\Shaders
```

5. Launch the game, press `Home`, and enable the tone mapper you want, for example:

```text
ACESNarkowicz.fx
```

Optional sharpening:

```text
CAS.fx
```

CAS can help if the game uses TAA or TSR and the image looks soft.

## How It Works

On startup the mod waits briefly for a valid UE console context and then runs the two commands once through:

```text
UKismetSystemLibrary:ExecuteConsoleCommand
```

If that fails, it falls back to:

```text
Engine:ProcessConsoleExec
```

It retries a few times because UE4SS can load before the game viewport is fully ready.

Successful log lines look like:

```text
[ToneCurveShowToggleMod] Executed once: show ToneCurve
[ToneCurveShowToggleMod] Executed once: show LocalExposure
[ToneCurveShowToggleMod] All one-shot show commands completed.
```

## Known Downside

ReShade is applied to the final image, so the replacement tone mapper also affects UI elements. In practice this is usually still playable, but it is not the same as replacing Unreal's internal tonemapper before UI composition.

## Troubleshooting

If the image looks unchanged, open the UE4SS console and try the commands manually once:

```text
show ToneCurve
show LocalExposure
```

If typing the command manually changes the image, then the mod did not execute the command path correctly and the UE4SS log should show why.

If typing the command manually makes the image worse after the mod already ran, type it again to toggle it back.

## Screenshots

![Image](screenshots/1/1_OriginalFilmicAces.jpg)
![Image](screenshots/1/2_AcesNarkowicz.jpg)
![Image](screenshots/1/3_CurveOff.jpg)
![Image](screenshots/1/4_UnchartedHable.jpg)
![Image](screenshots/2/1_OriginalFilmicAces.jpg)
![Image](screenshots/2/2_AcesNarkowicz.jpg)
![Image](screenshots/2/3_CurveOff.jpg)
![Image](screenshots/2/4_UnchartedHable.jpg)
![Image](screenshots/3/1_OriginalFilmicAces.jpg)
![Image](screenshots/3/2_AcesNarkowicz.jpg)
![Image](screenshots/3/3_CurveOff.jpg)
![Image](screenshots/3/4_UnchartedHable.jpg)
![Image](screenshots/4/1_OriginalFilmicAces.jpg)
![Image](screenshots/4/2_AcesNarkowicz.jpg)
![Image](screenshots/4/3_CurveOff.jpg)
![Image](screenshots/4/4_UnchartedHable.jpg)
![Image](screenshots/5/1_OriginalFilmicAces.jpg)
![Image](screenshots/5/2_AcesNarkowicz.jpg)
![Image](screenshots/5/3_CurveOff.jpg)
![Image](screenshots/5/4_UnchartedHable.jpg)
