DEVICE := iPhone 17

.PHONY: run run-macos build-macos android deploy docs commit check-assets

# example/assets/README.md is a symlink to the root README.md (kept in sync
# for free). On a checkout/export that doesn't preserve symlinks (some CI
# runners, zip exports, Windows without dev mode) it materializes empty or
# broken, and the app's Home section would silently show an error instead
# of the README — fail the build loudly here instead.
check-assets:
	@test -s example/assets/README.md || { \
		echo "error: example/assets/README.md is empty or missing (symlink to ../../README.md not preserved by this checkout)"; \
		exit 1; \
	}

run: check-assets
	xcrun simctl boot "$(DEVICE)" 2>/dev/null || true
	open -a Simulator
	until xcrun simctl list devices booted | grep -q "$(DEVICE)"; do sleep 1; done
	cd example && flutter pub get && flutter run -d "$(DEVICE)"

# Build the gallery as a release APK and install it on the connected Android phone.
android: check-assets
	cd example && flutter pub get && flutter build apk --release
	adb install -r example/build/app/outputs/flutter-apk/app-release.apk
	adb shell monkey -p com.itsash.theme_example -c android.intent.category.LAUNCHER 1 >/dev/null

run-macos: check-assets
	cd example && flutter pub get && flutter run -d macos

build-macos: check-assets
	cd example && flutter pub get && flutter build macos --release

deploy: docs commit
	git push

docs: check-assets
	cd example && flutter pub get && flutter build web --base-href / --release --no-tree-shake-icons
	find docs -mindepth 1 -not -name CNAME -delete
	cp -R example/build/web/. docs/
	touch docs/.nojekyll

commit:
	git add -A
	git diff --cached --quiet || git commit -m "$$(gh copilot -p 'Write a concise git commit message (subject line only, imperative mood, no quotes, under 72 chars) summarizing the currently staged git diff. Output only the commit message text, nothing else.' --allow-tool 'shell(git diff)' --allow-tool 'shell(git status)' --silent)"
