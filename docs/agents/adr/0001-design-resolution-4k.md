# Design resolution is 3840×2160

The viewport is 3840×2160 and art is exported at that size, so a `Sprite2D` figure is 1:1 in design units and needs no per-texture scaling. `canvas_items` stretch scales the frame down to each screen (mipmaps on), and downscaling hand-drawn art stays clean where upscaling would soften it. Changing it later means re-exporting all art and moving every position in every scene.
