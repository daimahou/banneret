---
severity: minor
triage: ready-for-agent
started: 2026-10-26
finished: 2026-10-26
hours:
---

# Problem

```
E 0:00:05:157   skill_card.gd:145 @ _draw_wipe(): Invalid polygon data, triangulation failed.
  <C++ Error>   Condition "indices.is_empty()" is true.
  <C++ Source>  servers/rendering/renderer_canvas_cull.cpp:1770 @ canvas_item_add_polygon()
  <Stack Trace> skill_card.gd:145 @ _draw_wipe()
```

# Repro
