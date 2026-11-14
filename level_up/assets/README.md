# Level-up UI pieces

21 PNG textures for the approved level-up screen. The canvas is the project viewport, **3840 × 2160**. Display each texture at its exported pixel size with scale `(1, 1)`; do not stretch the textures at runtime. Text, portraits and gameplay icons are separate content.

## Files

| Pieces | Final pixels |
|---|---|
| `background` | 3840 × 2160 |
| `offer_normal`, `offer_focused`, `offer_selected` | 1176 × 349 |
| `talent_normal`, `talent_selected` | 1176 × 230 |
| `active_tray` | 1176 × 202 |
| `button_normal`, `button_enabled`, `button_disabled` | 735 × 147 |
| `button_compact` | 551 × 110 |
| `button_back` | 239 × 92 |
| `portrait_frame` | 312 × 340 |
| `skill_frame`, `skill_slot_empty` | 129 × 129 |
| `offer_icon_frame` | 202 × 202 |
| `talent_icon_frame` | 119 × 119 |
| `talent_socket`, `talent_socket_empty` | 55 × 55 |
| `check_selected`, `check_muted` | 55 × 55 |

All pieces except the background have alpha transparency. Portrait and icon frames have transparent interiors; clip their inserted content to the aperture. Empty slots deliberately have a dark wooden interior. PNGs contain no labels or gameplay illustrations.

## Placement and states

- `manifest.json` records every final size, source crop, preparation method, suggested content rectangle and the preview's layout coordinates.
- Column origins: x = 147, 1360, 2572. Cards are 1176 pixels wide. The background has no baked column dividers, so layout is free to use the remaining gaps.
- Use `offer_normal` for idle offers, `offer_focused` for the open parent upgrade, and the selected variants for the actual selected choice. Selection check marks are separate sprites.
- Use `button_enabled` for the enabled primary confirmation, `button_normal` for a quieter enabled control and `button_disabled` when unavailable. Control captions and confirmed/ready state remain game UI, not image text.
- The preview is an assembly demonstration, not a finished scene or a new source of gameplay rules. Its empty slots are placeholders for game-supplied portraits and icons.

## Scale and integration

- Artwork was generated with the built-in image tool against the 1672 × 941 reference. The final source sheets use that size. Pieces were cropped and, where necessary, normalized offline to their exact dimensions at that size, then every piece was scaled offline ×2.2966 to the 3840 × 2160 viewport, all with Lanczos filtering; the manifest records those operations. No runtime resizing is required for this asset set. They are to be redrawn at this size.
- These are fixed-size sprites, not runtime nine-slice textures. Keep state variants at the same bounds. The subtle frame differences between generated states are intentional artwork variations, not different control sizes.
- Godot should import these as lossless 2D textures with alpha preserved. Draw text and icons as separate controls.

## Review and sources

- [Assembly preview, at the 1672 × 941 source size](../../docs/attachments/level_up_assets_native_preview.png)
- [Labeled piece sheet](../../docs/attachments/level_up_assets_contact_sheet.png)
- [Source sheets and generation prompts](../../docs/attachments/level_up_asset_sources/prompts.md)
- `docs/attachments/level_up_asset_sources/export_assets.py` reproduces the crops, exports, manifest and previews at the source size using Pillow; the ×2.2966 scale is a step after it. Its font path is the local macOS Arial font used for preview labels only.

Verified: dimensions, alpha channels, transparent frame centers and consistency of state bounds. Reviewed the exported pieces together at native size.
