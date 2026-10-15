# Sunshine in Miniature

### A little world. A lot of atmosphere.

Three miniature-inspired post-processing presets for **Dolphin Emulator**. Start with a gentle color treatment, add a soft diorama lens, or turn everything up with **Diorama Max**.

**Shaders only.** Bring your own Dolphin installation and lawfully obtained game. No game images, extracted models, textures, saves, emulator binaries, or executable installers are included.

## Pick your look

| Preset | What it does | Best for |
| --- | --- | --- |
| **Clear** | Gentle warm color grading and a subtle vignette; no added blur, bloom, or pixelation | Dialogue, cinematics, and everyday play |
| **Diorama** | Warm highlights, cool shadows, cascading sunlight rays, bloom, pixel treatment, and a miniature focus band | A softer, atmospheric look |
| **Diorama Max** | Sunlight rays, narrower focus, stronger blur, broader glow, chunkier pixels, and deeper edge shading | Going all-in on the miniature aesthetic |

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

## Install with ChatGPT / Codex or Claude

You can ask an assistant to handle the file copying and help select a preset. Automatic installation requires an assistant with permission to access files on your computer, such as [Codex](https://learn.chatgpt.com/docs/codex/cli) or [Claude Code](https://code.claude.com/docs/en/overview) with local tools enabled. In a chat without local tools, the same prompt works as a guided walkthrough; the assistant cannot install files just by replying.

Have Dolphin installed first, then paste this into your assistant:

```text
Help me install Sunshine in Miniature from this repository:
https://github.com/zach1020/sunshine-in-miniature

Read its README and inspect the three .glsl files in shaders/.
If you have local file access, locate my Dolphin installation and its
active user folder. Use Dolphin's File > Open User Folder to identify it,
or ask me for that folder path if you cannot determine it reliably.
If there are multiple installations, ask which one I use.

Download only SunshineDioramaClear.glsl, SunshineDiorama.glsl, and
SunshineDioramaMax.glsl from that repository. Back up existing files
with those names, then copy the three files into the active user
folder's Shaders directory. Create that directory if needed.
Verify the copied files match the downloaded sources.

Help me select SunshineDiorama in Dolphin's Graphics > Enhancements >
Post-Processing Effect menu. If Dolphin needs a restart, let me save
my game first. Explain how to choose Clear or Max, adjust sunlight
rays, use Max's Crisp mode, and revert to Off.

Keep my saves, controller mappings, other shaders, and game files
unchanged. Do not download or upload game data. No installer script
is needed. If you cannot access my files or control Dolphin, walk me
through these same steps instead and don't claim they are completed.
```

Once installed, switching presets happens entirely inside Dolphin; the assistant does not need to stay open.

## Cascading sunlight

**Diorama** and **Diorama Max** include warm, fanned-out sunlight shafts. The effect stretches light from bright areas in the upper image toward an adjustable screen position. It works best with bright sky and darker silhouettes that separate the beams.

In **Configure**:

- **Cascading sunlight rays:** toggle the effect. Turn it off to restore the previous preset's rendering.
- **Sunlight ray strength:** defaults to **1.15**; try **1.5–2.0** for a stronger look. Zero also restores the previous rendering.
- **Sunlight ray reach:** defaults to **0.85**; raise it to carry the shafts farther across the image.
- **Sunlight origin horizontal / vertical:** move the apparent source. Defaults are **0.32 / 0.02**, near the upper-left part of the image; the game camera does not move this source automatically.

These are screen-space rays, not volumetric or ray-traced lighting. Bright walls or text can sometimes contribute light, and shafts can appear over foreground objects because there is no depth buffer. Corner protection reduces their effect on corner HUD regions; it is not a complete UI mask. Use Clear, disable rays, or enable Max's Crisp mode when readability matters. Extra sampling adds GPU work.

After updating existing shader files, restart Dolphin or switch the post-processing effect off and back on to reload them. Save your game before restarting.

## Make Max comfortable to play

Max is deliberately exaggerated. If it obscures text or a cinematic subject, open **Configure** and enable **Crisp mode for dialogue and cutscenes**. This manually removes blur, pixelation, bloom, and sunlight rays while retaining Max's color treatment and vignette. It is not an automatic scene detector.

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
