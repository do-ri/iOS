---
version: alpha
name: DoriDesignSystem
description: iOS SwiftUI color and typography tokens mirrored from DoriDesignSystem implementation sources.
colors:
  bgPrimary:         { light: "#FDFDFD", dark: "#111111" }
  bgSecondary:       { light: "#F2F4F6", dark: "#232323" }
  bgScrim:           { light: "#00000066", dark: "#00000099" }
  textPrimary:       { light: "#111111", dark: "#FDFDFD" }
  textSecondary:     { light: "#6B7684", dark: "#A0A0A0" }
  textDisabled:      { light: "#B0B8C1", dark: "#5A5A5A" }
  textPlaceholder:   { light: "#B0B8C1", dark: "#5A5A5A" }
  borderDefault:     { light: "#E5E8EB", dark: "#2E2E2E" }
  borderInput:       { light: "#B0B8C1", dark: "#5A5A5A" }
  brandMain:         { light: "#20346F", dark: "#6C8FF0" }
  onBrand:           { light: "#FFFFFF", dark: "#FFFFFF" }
  feedbackTextError: { light: "#E54848", dark: "#FF5A5F" }
legacyColors:
  # Pending designer review — no Figma equivalent. Stays deprecated until brand secondary spec lands.
  # Every reference emits a Swift deprecation warning.
  secondary: "#6482AD"
typography:
  "headline.h1":
    fontFamily: Pretendard
    fontSize: 16px
    fontWeight: 700
    lineHeight: 26px
    letterSpacing: 0px
  "title.t1":
    fontFamily: Pretendard
    fontSize: 16px
    fontWeight: 500
    lineHeight: 26px
    letterSpacing: 0px
  "subtitle.sb1":
    fontFamily: Pretendard
    fontSize: 20px
    fontWeight: 600
    lineHeight: 34px
    letterSpacing: 0px
  "subtitle.sb2":
    fontFamily: Pretendard
    fontSize: 14px
    fontWeight: 600
    lineHeight: 22px
    letterSpacing: 0px
  "subtitle.m2":
    fontFamily: Pretendard
    fontSize: 14px
    fontWeight: 500
    lineHeight: 22px
    letterSpacing: 0px
  "body.b1":
    fontFamily: Pretendard
    fontSize: 30px
    fontWeight: 700
    lineHeight: 54px
    letterSpacing: 0px
  "body.b4":
    fontFamily: Pretendard
    fontSize: 14px
    fontWeight: 700
    lineHeight: 22px
    letterSpacing: 0px
  "body.sb2":
    fontFamily: Pretendard
    fontSize: 16px
    fontWeight: 600
    lineHeight: 26px
    letterSpacing: 0px
  "body.sb3":
    fontFamily: Pretendard
    fontSize: 15px
    fontWeight: 600
    lineHeight: 24px
    letterSpacing: 0px
  "body.sb6":
    fontFamily: Pretendard
    fontSize: 12px
    fontWeight: 600
    lineHeight: 18px
    letterSpacing: 0px
  "body.m3":
    fontFamily: Pretendard
    fontSize: 15px
    fontWeight: 500
    lineHeight: 24px
    letterSpacing: 0px
  "body.m5":
    fontFamily: Pretendard
    fontSize: 13px
    fontWeight: 500
    lineHeight: 20px
    letterSpacing: 0px
  "body.r2":
    fontFamily: Pretendard
    fontSize: 16px
    fontWeight: 400
    lineHeight: 26px
    letterSpacing: 0px
  "body.r3":
    fontFamily: Pretendard
    fontSize: 15px
    fontWeight: 400
    lineHeight: 24px
    letterSpacing: 0px
  "body.r4":
    fontFamily: Pretendard
    fontSize: 14px
    fontWeight: 400
    lineHeight: 22px
    letterSpacing: 0px
  "body.r6":
    fontFamily: Pretendard
    fontSize: 12px
    fontWeight: 400
    lineHeight: 18px
    letterSpacing: 0px
  "caption.b1":
    fontFamily: Pretendard
    fontSize: 13px
    fontWeight: 700
    lineHeight: 20px
    letterSpacing: 0px
  "caption.b2":
    fontFamily: Pretendard
    fontSize: 11px
    fontWeight: 700
    lineHeight: 16px
    letterSpacing: 0px
  "caption.m2":
    fontFamily: Pretendard
    fontSize: 11px
    fontWeight: 500
    lineHeight: 16px
    letterSpacing: 0px
  "caption.r1":
    fontFamily: Pretendard
    fontSize: 13px
    fontWeight: 400
    lineHeight: 20px
    letterSpacing: 0px
  "caption.r2":
    fontFamily: Pretendard
    fontSize: 11px
    fontWeight: 400
    lineHeight: 16px
    letterSpacing: 0px
---

# DoriDesignSystem Design Tokens

Sync rules:

- When DoriDesignSystem color or typography tokens change, update this file in the same PR.
- When changing a color, update **both light and dark** hex values together. The asset catalog stores them as a single colorset with two appearance variants.

## Overview

This file documents the color and typography surface of `DoriDesignSystem` for iOS SwiftUI implementation. It intentionally covers only colors and typography; components, icons, images, spacing, radius, and elevation are outside this document's scope.

Implementation source of truth:

- Colors (semantic): `Resources/Colors.xcassets/Semantic/`
- Colors (legacy, deprecated): `Resources/Colors.xcassets/Brand/Secondary.colorset` only — pending designer review for a brand-secondary spec.
- Typography: `Sources/Typography/TypoStyle.swift`, `View+.swift`, `FontProvider+Impl.swift`, and `FontStyle.swift`

Use the YAML front matter as the machine-readable mirror of the current implementation. If the YAML and Swift/assets disagree, fix the source token and this document together instead of guessing.

## Colors

The system is **semantic tokens with built-in dark mode**. Each token resolves to a different hex value in light vs. dark via asset catalog appearance variants — SwiftUI swaps automatically, no runtime branching needed.

Use generated asset accessors instead of raw SwiftUI colors or duplicated hex values. Prefer SwiftUI asset shorthand such as `.foregroundStyle(.textPrimary)` and `.background(.bgPrimary)`. Use `UIAsset.Colors.<token>.color` or `DoriColors.<token>.color` when shorthand doesn't fit (UIKit interop, explicit `Color` value).

| Token | Asset name | Light | Dark | Swift usage |
| --- | --- | --- | --- | --- |
| `bgPrimary` | `Semantic/BgPrimary` | `#FDFDFD` | `#111111` | `.background(.bgPrimary)`, `DoriColors.bgPrimary.color` |
| `bgSecondary` | `Semantic/BgSecondary` | `#F2F4F6` | `#232323` | `.background(.bgSecondary)`, `DoriColors.bgSecondary.color` |
| `bgScrim` | `Semantic/BgScrim` | `#000000` α 0.4 | `#000000` α 0.6 | `.background(.bgScrim)`, `DoriColors.bgScrim.color` (modal/loading overlay) |
| `textPrimary` | `Semantic/TextPrimary` | `#111111` | `#FDFDFD` | `.foregroundStyle(.textPrimary)` |
| `textSecondary` | `Semantic/TextSecondary` | `#6B7684` | `#A0A0A0` | `.foregroundStyle(.textSecondary)` |
| `textDisabled` | `Semantic/TextDisabled` | `#B0B8C1` | `#5A5A5A` | `.foregroundStyle(.textDisabled)` |
| `textPlaceholder` | `Semantic/TextPlaceholder` | `#B0B8C1` | `#5A5A5A` | `.foregroundStyle(.textPlaceholder)` |
| `borderDefault` | `Semantic/BorderDefault` | `#E5E8EB` | `#2E2E2E` | `RoundedRectangle(...).stroke(.borderDefault, lineWidth: 1)` |
| `borderInput` | `Semantic/BorderInput` | `#B0B8C1` | `#5A5A5A` | `.stroke(.borderInput, lineWidth: 1)` |
| `brandMain` | `Semantic/BrandMain` | `#20346F` | `#6C8FF0` | `.foregroundStyle(.brandMain)`, `.background(.brandMain)` |
| `onBrand` | `Semantic/OnBrand` | `#FFFFFF` | `#FFFFFF` | `.foregroundStyle(.onBrand)` — text/icon on top of a brand-colored surface. Stays light in both modes. |
| `feedbackTextError` | `Semantic/FeedbackTextError` | `#E54848` | `#FF5A5F` | `.foregroundStyle(.feedbackTextError)` |

`textDisabled` and `textPlaceholder` share hex values today but are kept as separate tokens because their roles differ — a future design pass may diverge them.

### Deprecated tokens

`DoriColors.secondary` (light `#6482AD`) remains as the only legacy token. It is still referenced from the transaction-category accent (judori/outdori) because the Figma spec does not yet define a brand-secondary token. The asset stays at `Colors.xcassets/Brand/Secondary.colorset`, the Swift case is emitted with `@available(*, deprecated)`, and every reference produces a compiler warning.

Resolve with the designer: either promote it to a proper semantic token (`brandSecondary` with a defined dark variant) or migrate the remaining call sites to `brandMain` and delete the asset.

The original primitive palette (`main`, `doriWhite`, `doriBlack`, `grey50` ~ `grey900`) has been fully removed in PR2. Call sites were rewritten to the semantic tokens above; the colorset files no longer exist.

## Typography

Use `.pretendard(_:)` on SwiftUI views. Prefer semantic tokens when a matching role exists:

```swift
Text("도리")
  .pretendard(.headline(.h1))

Text("내용")
  .pretendard(.body(.r3))
```

Use primitive `TypoToken` values only when no semantic token fits:

```swift
Text("Label")
  .pretendard(.bold(.b15))
```

`PretendardProvider` maps token weights to these bundled font names:

| Weight | Font name | Numeric weight |
| --- | --- | --- |
| regular | `Pretendard-Regular` | 400 |
| medium | `Pretendard-Medium` | 500 |
| semiBold | `Pretendard-SemiBold` | 600 |
| bold | `Pretendard-Bold` | 700 |

Current line-height rule is implemented in `FontStyle`: `lineHeight = 2 * fontSize - 6`, and SwiftUI receives `lineSpacing = lineHeight - fontSize`. The front-matter typography dimensions use `px` for DESIGN.md compatibility, but they mirror the iOS `CGFloat` point sizes used by SwiftUI.

| Semantic token | Swift usage | Primitive token | Font name | Size | Line height |
| --- | --- | --- | --- | --- | --- |
| `headline.h1` | `.pretendard(.headline(.h1))` | `.bold(.b16)` | `Pretendard-Bold` | 16 | 26 |
| `title.t1` | `.pretendard(.title(.t1))` | `.medium(.m16)` | `Pretendard-Medium` | 16 | 26 |
| `subtitle.sb1` | `.pretendard(.subtitle(.sb1))` | `.semiBold(.sb20)` | `Pretendard-SemiBold` | 20 | 34 |
| `subtitle.sb2` | `.pretendard(.subtitle(.sb2))` | `.semiBold(.sb14)` | `Pretendard-SemiBold` | 14 | 22 |
| `subtitle.m2` | `.pretendard(.subtitle(.m2))` | `.medium(.m14)` | `Pretendard-Medium` | 14 | 22 |
| `body.b1` | `.pretendard(.body(.b1))` | `.bold(.b30)` | `Pretendard-Bold` | 30 | 54 |
| `body.b4` | `.pretendard(.body(.b4))` | `.bold(.b14)` | `Pretendard-Bold` | 14 | 22 |
| `body.sb2` | `.pretendard(.body(.sb2))` | `.semiBold(.sb16)` | `Pretendard-SemiBold` | 16 | 26 |
| `body.sb3` | `.pretendard(.body(.sb3))` | `.semiBold(.sb15)` | `Pretendard-SemiBold` | 15 | 24 |
| `body.sb6` | `.pretendard(.body(.sb6))` | `.semiBold(.sb12)` | `Pretendard-SemiBold` | 12 | 18 |
| `body.m3` | `.pretendard(.body(.m3))` | `.medium(.m15)` | `Pretendard-Medium` | 15 | 24 |
| `body.m5` | `.pretendard(.body(.m5))` | `.medium(.m13)` | `Pretendard-Medium` | 13 | 20 |
| `body.r2` | `.pretendard(.body(.r2))` | `.regular(.r16)` | `Pretendard-Regular` | 16 | 26 |
| `body.r3` | `.pretendard(.body(.r3))` | `.regular(.r15)` | `Pretendard-Regular` | 15 | 24 |
| `body.r4` | `.pretendard(.body(.r4))` | `.regular(.r14)` | `Pretendard-Regular` | 14 | 22 |
| `body.r6` | `.pretendard(.body(.r6))` | `.regular(.r12)` | `Pretendard-Regular` | 12 | 18 |
| `caption.b1` | `.pretendard(.caption(.b1))` | `.bold(.b13)` | `Pretendard-Bold` | 13 | 20 |
| `caption.b2` | `.pretendard(.caption(.b2))` | `.bold(.b11)` | `Pretendard-Bold` | 11 | 16 |
| `caption.m2` | `.pretendard(.caption(.m2))` | `.medium(.m11)` | `Pretendard-Medium` | 11 | 16 |
| `caption.r1` | `.pretendard(.caption(.r1))` | `.regular(.r13)` | `Pretendard-Regular` | 13 | 20 |
| `caption.r2` | `.pretendard(.caption(.r2))` | `.regular(.r11)` | `Pretendard-Regular` | 11 | 16 |

Available primitive `TypoToken` values:

| Weight | Tokens |
| --- | --- |
| `.bold` | `.b11`, `.b13`, `.b14`, `.b15`, `.b16`, `.b20`, `.b30` |
| `.semiBold` | `.sb12`, `.sb14`, `.sb15`, `.sb16`, `.sb20` |
| `.medium` | `.m11`, `.m12`, `.m13`, `.m14`, `.m15`, `.m16` |
| `.regular` | `.r11`, `.r12`, `.r13`, `.r14`, `.r15`, `.r16`, `.r18`, `.r20` |

### Non-Pretendard fonts

The Pretendard token system covers app-wide text. For brand or display surfaces that need a different face, add a dedicated `View` modifier per face instead of stretching the Pretendard tokens. These are intentional exceptions, not part of the semantic token system.

The current example is the splash/intro logo, which uses `SDSamliphopangcheTTFBasic` via `.hopangche(size:)`:

```swift
Text("도리")
  .hopangche(size: 55)
```

When introducing another non-Pretendard face, follow the same shape:

1. Add a `FontProvider` conformer for the face (see `SamlipHopangProvider` in `FontProvider+Impl.swift`).
2. Bundle the font file and register it through `FontManager`.
3. Expose a single `View` extension named after the face (mirroring `.hopangche(size:)`).
4. Document the intended scope here so the exception stays visible.

## Do's and Don'ts

- Do reach for semantic tokens (`bgPrimary`, `textSecondary`, `borderInput`, `brandMain`, ...) for all new code. Light/dark switching is automatic via the asset catalog.
- Do use SwiftUI shorthand (`.foregroundStyle(.textPrimary)`, `.background(.bgPrimary)`, `.stroke(.borderInput, lineWidth: 1)`) first; fall back to `UIAsset.Colors.<token>.color` / `DoriColors.<token>.color` only when shorthand doesn't fit.
- Do use `bgScrim` for modal and loading-overlay backdrops instead of `Color.black.opacity(...)`.
- Do use `onBrand` for text or icons sitting on top of a brand-colored fill — it intentionally stays light in both light and dark modes.
- Do use `.pretendard(.body(.r3))` and other `TypoSemantic` values before reaching for primitive `TypoToken` values.
- Do keep this document synchronized with `Colors.xcassets` and `Sources/Typography` in the same PR as any token change, and update both light and dark hex values together.
- Don't use `DoriColors.secondary` in new code. It is deprecated and slated for resolution with the designer.
- Don't introduce raw `Color(...)`, raw hex literals, or `Color.black.opacity(...)` for foregrounds/backgrounds in feature code. Shadow color arguments (`.shadow(color: .black.opacity(0.1), ...)`) and the dark info-toast background in `DoriToastView` are the documented exceptions.
- Don't set `Font.system(...)`, raw `.custom(...)`, or hardcoded Pretendard names in feature views when `.pretendard(...)` can express the intended token.
- Don't document or consume spacing, radius, elevation, icons, images, or component-specific styling from this file; those are not currently part of this DESIGN.md scope.
