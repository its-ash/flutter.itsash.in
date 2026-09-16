## 0.0.2

* `ThemeSearchableDropdown` now searches inline — the collapsed field becomes the search input on focus, filtering the overlay list directly (no separate search field inside the dropdown).
* Input fields now use the same border radius as cards (`inputRadius` defaults to 16, matching `cardRadius`) across all presets and the base `AppInputTheme` / `AppDropdownTheme`.
* Status button shadows (`ThemeButton` with `status`) preserve the white top-light on embossed two-tone styles like Claymorphism; only the bottom shadow is tinted with the status color.
* iOS deployment target raised to 14.0 for `file-picker-darwin` compatibility.

## 0.0.1

* Initial release: `AppTheme` light/dark `ThemeData` factories, `AppColors`, `AppTypography`, `AppShadowTheme`.
* `ThemeX` component library covering buttons, cards, navigation, inputs, lists, pickers, and feedback (see `COMPONENTS.md`).
* Public widgets: `Notify` (typed success/error/warning/info notifications), `AddToCartButton`, `PriceTag`, `RatingStars`, `ProfileAvatar`.
