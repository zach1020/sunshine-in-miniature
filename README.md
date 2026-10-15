# Sunshine in Miniature

### A little world. A lot of atmosphere.

Three miniature-inspired post-processing presets for **Dolphin Emulator**. Start with a gentle color treatment, add a soft diorama lens, or turn everything up with **Diorama Max**.

**Shaders only.** Bring your own Dolphin installation and lawfully obtained game. No game images, extracted models, textures, saves, emulator binaries, or executable installers are included.

## Pick your look

| Preset | What it does | Best for |
| --- | --- | --- |
| **Clear** | Gentle warm color grading and a subtle vignette; no added blur, bloom, or pixelation | Dialogue, cinematics, and everyday play |
| **Diorama** | Warm highlights, cool shadows, bloom, pixel treatment, and a miniature focus band | A softer, atmospheric look |
| **Diorama Max** | Narrower focus, stronger blur, broader glow, chunkier pixels, and deeper edge shading | Going all-in on the miniature aesthetic |

## Install

1. Download this repository with **Code → Download ZIP**, then extract it.
2. In [Dolphin](https://dolphin-emu.org/download/), choose **File → Open User Folder**.
3. Copy the three files from this repository's **`shaders`** folder into the Dolphin user folder's **`Shaders`** folder. Create `Shaders` if it does not exist. Copy the files themselves, not an extra nested folder.
4. Restart Dolphin if it was already open, so it refreshes the shader list.
5. Open **Graphics → Enhancements → Post-Processing Effect** and select:
   - `SunshineDioramaClear`
   - `SunshineDiorama`
   - `SunshineDioramaMax`
6. Choose **Configure** beside the effect to tune it.

For portable Dolphin, the folder is usually `Dolphin-x64/User/Shaders`. Using **Open User Folder** avoids guessing the location on other systems.

To revert, select **Off** in the effect list or choose a different preset. Shader settings are separate from your game saves.

## Make Max comfortable to play

Max is deliberately exaggerated. If it obscures text or a cinematic subject, open **Configure** and enable **Crisp mode for dialogue and cutscenes**. This manually removes blur, pixelation, and bloom while retaining Max's color treatment and vignette. It is not an automatic scene detector.

Other useful controls:

- **Miniature blur:** lower it for a clearer foreground and background.
- **Focus band width:** increase it to keep more of the frame sharp.
- **Bloom glow:** reduce it if bright scenery looks washed out.
- **Pixel treatment:** reduce it for finer detail.
- **Keep HUD corners sharp:** protects corner regions, but cannot recognize every UI element.

For dependable readability throughout the whole frame, use **Clear**.

## What this can—and cannot—do

These shaders process Dolphin's finished image. They do not have access to scene depth, individual objects, or a separate UI layer. The miniature blur follows a horizontal band on the screen, not actual distance from the camera. Color treatment also affects UI colors.

This is an **HD-2D-inspired visual treatment**, not a remake: it does not replace characters with sprites, add ray tracing, soften the game's actual shadow edges, upscale texture assets, or add new world lighting. Original video compression and in-game blur remain. No runtime network connection is used by the shader files.

The presets were developed with Super Mario Sunshine in Dolphin **2609a**, using **Direct3D 11**, **2× native internal resolution**, and an **NVIDIA Quadro RTX 3000** on Windows. Other games, backends, platforms, and Dolphin versions have not been comprehensively tested. Max samples more pixels than the other presets and can cost more GPU time; no universal FPS claim is made.

## Files

```text
shaders/
  SunshineDioramaClear.glsl
  SunshineDiorama.glsl
  SunshineDioramaMax.glsl
docs/
  SCREENSHOTS.md
LICENSE
NOTICE.md
```

## Credits and license

Made by **zach1020**, with assistance from OpenAI Codex. Custom shader code and documentation are released under the [MIT License](LICENSE).

Game imagery in any demonstration screenshots belongs to its respective rights holders and is **not** covered by the MIT license. See [NOTICE.md](NOTICE.md). This is an independent, unofficial project, not affiliated with or endorsed by Nintendo, Square Enix, or the Dolphin Emulator Project.
