# Theme Package Guidelines

Design system for every app in this workspace: **one light theme, one dark theme** (optional custom accent), and a library of `Ui*` components.

## Layout
- `lib/theme.dart` — the only public import. Exports every group barrel.
- `lib/src/foundation/` — `UiColors` (palette, `ThemeExtension`), `UiTheme` (builds `ThemeData`), `UiTypography`, tokens (`UiSpace`, `UiRadius`, `UiMotion`, `UiShadows`, `UiBreakpoint`), `UiStatus`/`UiSize`/`UiTone`, `UiContext` extension, `UiGap`, `UiApp`/`UiThemeController`.
- `lib/src/<group>/` — one folder per component group, with a `<group>.dart` barrel that exports its public files.
- `doc/components/<group>.md` — reference for each group. `COMPONENTS.md` is the index.
- `test/<group>_test.dart` — widget tests. `test/flutter_test_config.dart` turns off Google Fonts.
- `example/` — gallery app (`make run-macos`).

## Component conventions (follow for every widget)
- Public names start with `Ui`. Private helpers start with `_`.
- Import only `package:flutter/material.dart` (plus `services`/`rendering` if needed) and `package:theme/src/...` files. No new pub dependencies without asking.
- **Never hardcode colors.** Read `context.colors` (`UiColors`) and `context.text` (`TextTheme`). Status colors come from `context.colors.tone(UiStatus.x)` → `color`, `onColor`, `soft`, `onSoft`.
- Use tokens: `UiSpace.*` for spacing, `UiRadius.*` for corners, `UiMotion.*` for durations/curves (wrap with `context.motion(d)` to honor reduced motion), `context.shadowSm/Md/Lg` for shadows.
- Sizes use `UiSize` (`sm`/`md`/`lg`; `.height`, `.iconSize`, `.fontSize`, `.padding`). Default is `md`.
- Look: flat surfaces with 1 px `colors.border`, generous radius (controls `UiRadius.md`, cards `UiRadius.lg`, sheets/dialogs `UiRadius.xl`, pills `UiRadius.full`), soft accent tints (`accentSoft`) for selection, no Material elevation tint.
- Must look right in both light and dark mode. Only use palette colors, never `Colors.white/black` except for scrims over images/video.
- A null callback (`onPressed`, `onChanged`, `onTap`) means disabled; show disabled styling (`textDisabled`, reduced opacity).
- Simple API: the most common use takes 1–3 arguments, e.g. `UiButton('Save', onPressed: save)`. Main content is a positional argument.
- Accessibility: tap targets ≥ 40 px, `Semantics`/`tooltip` on icon-only controls, text scales without overflow (use `Flexible`, ellipsis).
- No overflow in narrow (320 px) widths. Long text ellipsizes.
- Dispose every controller, timer, animation and listener you create. Accept external controllers where it makes sense, and don't dispose those.
- Static helpers that show overlays follow `UiDialog.show(context, ...)` / `context.showToast(...)` style and return a `Future`.
- `dart format` with line length 120. Code must pass `flutter analyze` with zero issues.

## Docs and tests
- Every public widget gets an entry in its group's `doc/components/<group>.md`: one-line purpose, a short code sample, and its params.
- When you add, rename or change a public widget, update the group doc and the table in `COMPONENTS.md`.
- Every public widget gets at least one widget test (renders in light and dark, main interaction works, no exceptions).

## Running & Testing
- `flutter analyze` and `flutter test` in `theme/`.
- Use `example/` (`example/lib/main.dart`) to preview components.
- Theme change flow for apps: edit → build → push → bump the dep in each consumer app (`flutter pub upgrade theme`).
