---
triage: ready-for-agent
id: 1.1-1.2
requires:
  - "[[Mission map]]"
started: 2026-10-21
finished:
parent: "[[Missions]]"
---
# Done when

- Reaching a map node draws offers from its event type's bag; the player picks one to resolve the event (logged).
- The encounter draws from its own bag and resolves without a pick, then the mission ends.

## Problem

Reaching a map node does nothing: the event on it never happens.

## Solution

Every event works the same way: arriving draws from the event type's bag, then the event resolves — with the player's pick on posters dropped from the ceiling, or on its own.

## User stories

1. As the player, I want offers to drop from the ceiling when the coach arrives, so that the event happens on stage.
2. As the player, I want to pick one offer, so that I decide how the event resolves.
3. As the player, I want the map locked while offers are down, so that I resolve the event before moving on.
4. As the designer, I want each event type to name its bag, offer count and whether the player picks, so that a new kind of event is a table row.
5. As the designer, I want bags as Yard registries drawn through a filter, so that content is gated by conditions, not by authoring more bags.
6. As the designer, I want the same seed to draw the same offers, so that `map_seed` replays a whole mission.
7. As the designer, I want the mission to play headless, so that it runs and is tested without input.

## Implementation decisions

- **Event table**, in `MapNode` beside `EVENT_ICONS`: bag, offer count, player picks.
  - `PLACEHOLDER` — placeholder bag, 3 offers, picked.
  - `ENCOUNTER` — encounter bag, 1 offer, resolves at once.
- **Content** in `mission_map/event/`:
  - `Offer` — `Resource`: name, description. Both bags hold it.
  - `placeholder/` — 5 placeholder offers; `placeholder_bag.tres` scans it. `encounter_bag.tres` scans it too until encounters have a folder of their own. Both Yard registries restricted to `Offer`, written by a headless script in Yard's format (Yard's own I/O needs the editor).
- **Draw**: `Bag.draw(registry, count, filter, rng) -> Array[StringName]` — distinct IDs at random from those `BagFilter` accepts; fewer when the bag is short. Only drawn entries load.
- **`BagFilter`**: empty, accepts every ID. Conditions land here later as `Registry.where` criteria.
- **Model** — `MissionModel` takes the seed; draws use their own seed derived from it.
  - `travel_to` draws at once (the model changes on click). A picked event leaves its offers pending; any other resolves with its first draw.
  - `get_offers`, `pick_offer`, `get_resolved_offer` (null when the draw was empty).
  - Nothing is open while offers are pending; what lies ahead keeps its visitation.
- **Controller**: after travel, if offers are pending, awaits `Stage.show_offers`; on `offer_pressed`, picks, awaits `Stage.hide_offers`. Logs `Event resolved: <name or none>` once resolved, then `Mission ended` if it did.
- **View** — `Stage` hands the offers to an `OfferPresenter` scene and relays its `offer_pressed`.
  - `OfferPresenter` (`@tool`): posters hang from its top edge, centred across its width, any count; `spacing` and `stagger` exported. In the editor it previews `preview_count` open posters, shown or hidden by `is_preview_shown`.
  - `Poster` scene: top roll with cord, body, bottom roll, name and description labels. `openness` (0 rolled, 1 open) scales the body and keeps the bottom roll on its lower edge.
  - Its `AnimationPlayer` holds `drop` (falls rolled, bounces, unrolls), `lift` (rolls up, rises) and `RESET`, bezier-keyed on the fall height and `openness`, timed by eye in the editor.
  - Hovered poster in blue. Input ignored while posters move.
- **Logging**: every line through `LimboConsole.info`, with `print_to_stdout=true`, so it reaches the in-game console and the output.

## Testing decisions

- Seam: `MissionModel` — missions played in code: offers pending after travel, the map locked until a pick, the same seed drawing the same offers, the encounter resolving without a pick.
- Seam: `Bag.draw` over fixture registries in `tests/doubles/`: distinct picks, a short bag returns fewer, the filter is applied, the same seed draws the same.
- Poster animation is judged by eye in the running scene.

## Out of scope

- Real offers and what resolving one does, heroes, party UI.
- Real filters, encounter data.
- An auto-play mode.

## Views

![[stage_missions_offers.png]]

![[Children.base#Open tickets]]

![[Children.base#Closed tickets]]
