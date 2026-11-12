# Level-up UI pieces

21 PNG textures for the approved level-up screen, exported at 2× the **1672 × 941** design canvas: **3344 × 1882**. Display each texture at its exported pixel size with scale `(1, 1)`; do not stretch the textures at runtime. Text, portraits and gameplay icons are separate content.

## Files

| Pieces | Final pixels |
|---|---|
| `background` | 3344 × 1882 |
| `offer_normal`, `offer_focused`, `offer_selected` | 1024 × 304 |
| `talent_normal`, `talent_selected` | 1024 × 200 |
| `active_tray` | 1024 × 176 |
| `button_normal`, `button_enabled`, `button_disabled` | 640 × 128 |
| `button_compact` | 480 × 96 |
| `button_back` | 208 × 80 |
| `portrait_frame` | 272 × 296 |
| `skill_frame`, `skill_slot_empty` | 112 × 112 |
| `offer_icon_frame` | 176 × 176 |
| `talent_icon_frame` | 104 × 104 |
| `talent_socket`, `talent_socket_empty` | 48 × 48 |
| `check_selected`, `check_muted` | 48 × 48 |

All pieces except the background have alpha transparency. Portrait and icon frames have transparent interiors; clip their inserted content to the aperture. Empty slots deliberately have a dark wooden interior. PNGs contain no labels or gameplay illustrations.

## Placement and states

- `manifest.json` records every final size, source crop, preparation method, suggested content rectangle and the preview's layout coordinates.
- Column origins: x = 128, 1184, 2240. Cards are 1024 pixels wide. The background has no baked column dividers, so layout is free to use the remaining gaps.
- Use `offer_normal` for idle offers, `offer_focused` for the open parent upgrade, and the selected variants for the actual selected choice. Selection check marks are separate sprites.
- Use `button_enabled` for the enabled primary confirmation, `button_normal` for a quieter enabled control and `button_disabled` when unavailable. Control captions and confirmed/ready state remain game UI, not image text.
- The preview is an assembly demonstration, not a finished scene or a new source of gameplay rules. Its empty slots are placeholders for game-supplied portraits and icons.

## Scale and integration

- Artwork was generated with the built-in image tool against the 1672 × 941 reference. The source sheets use that size. Pieces were upscaled, cropped and, where necessary, normalized offline to their exact exported dimensions with Lanczos filtering; the manifest records those operations. No runtime resizing is required for this asset set.
- These are fixed-size sprites, not runtime nine-slice textures. Keep state variants at the same bounds. The subtle frame differences between generated states are intentional artwork variations, not different control sizes.
- The project viewport is 3840 × 2160. `export_assets.py` upscales the 1672 × 941 sources by `SCALE = 2` once, offline, so the set fills 3344 × 1882 of it at native size.
- Godot should import these as lossless 2D textures with alpha preserved. Draw text and icons as separate controls. The gameplay scene has not been modified or wired to these files.

## Review and sources

- [Native-size assembly preview](../../../docs/attachments/level_up_assets_native_preview.png)
- [Labeled piece sheet](../../../docs/attachments/level_up_assets_contact_sheet.png)
- [Source sheets and generation prompts](../../../docs/attachments/level_up_asset_sources/prompts.md)
- `docs/attachments/level_up_asset_sources/export_assets.py` reproduces the crops, exports, manifest and previews using Pillow. Its font path is the local macOS Arial font used for preview labels only.

Verified: dimensions, alpha channels, transparent frame centers and consistency of state bounds. Reviewed the exported pieces together at native size.
