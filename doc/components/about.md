# App info

Sections every Ash Store app shows at the bottom of its settings screen, in this order: `UiUpdateSection`, then `UiDeveloperSection` (last).

```dart
const UiUpdateSection(storeId: 'linkdrop'),
const UiGap(UiSpace.lg),
const UiDeveloperSection(),
```

### UiUpdateSection
The "Updates" group. Shows the installed version (from `package_info_plus`). When it is shown it checks `https://api.github.com/repos/<owner>/<storeId>/releases/latest`; if the release is newer it shows an **Update** button that downloads `<storeId>.apk` in the browser. **Check** / **Retry** check again.
```dart
const UiUpdateSection(storeId: 'recoverx')
```
- `storeId` (required): store id = repo name = APK name
- `owner` = `'its-ash'`
- `checkForUpdates` = `true`. Needs the `INTERNET` permission in the app's main `AndroidManifest.xml`. Pass `false` for apps without internet: the row then only opens the latest APK download in the browser
- `header` = `'Updates'`

### UiUpdater
The logic behind `UiUpdateSection`.
- `UiUpdater.latest(storeId, owner:)` → `Future<UiRelease>` (`version` without `v`, `apkUrl`). Throws when offline, on a 404 (no release) or other GitHub errors
- `UiUpdater.isNewer(latest, current)`: compares `x.y.z`; ignores `v`, `+build` and `-pre`
- `UiUpdater.latestApkUrl(storeId, owner:)`: `https://github.com/<owner>/<id>/releases/latest/download/<id>.apk`

### UiDeveloperSection
The "Developer" group: "Developed by Ashvini Jangid" and a Portfolio row that opens `https://itsash.github.io`. Always the last group on a settings screen.
```dart
const UiDeveloperSection()
```
- `header` = `'Developer'`
- Name and link live in `UiDeveloper.name`, `UiDeveloper.website`, `UiDeveloper.websiteLabel`

### UiUrl
- `UiUrl.open(url)` → `Future<bool>`: opens a link in the browser or the app that handles it (`url_launcher`, external mode). False on failure
