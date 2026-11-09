# Capture flow

How the screenshots and the demo GIF in this repo are produced. Everything runs on a real
Android emulator; nothing is mocked up.

## On GitHub Actions (default)

```sh
gh workflow run capture.yml -R nhucsau1995/tizbin-flutter --ref main
gh run watch <run-id> -R nhucsau1995/tizbin-flutter --exit-status
gh run download <run-id> -R nhucsau1995/tizbin-flutter -n capture -D capture-tmp/artifact
```

`.github/workflows/capture.yml` (manual dispatch only):

1. Sets up Java 17, Gradle cache and Flutter 3.35.0.
2. Builds two debug APKs before the emulator boots (x86_64 only):
   `integration_test/screenshot_test.dart` and `integration_test/demo_test.dart`.
3. Boots a Pixel 6 emulator (API 34, KVM) and runs `.github/scripts/capture-emulator.sh flutter`:
   - `flutter drive` with `test_driver/integration_test.dart` writes every
     `binding.takeScreenshot('NN-name')` to `screenshots/NN-name.png`;
   - the demo test runs under `adb shell screenrecord`; it prints `POC_DEMO_START` and
     `POC_DEMO_END`, and the GIF is cut to that window from logcat timestamps;
   - ffmpeg palette pass: 12 fps, 300 px wide.
4. Uploads the `capture` artifact (PNGs + `demo.gif`) and a `capture-debug` artifact.

The runner never commits. The media are reviewed, then committed by hand.

## How the tests drive the app

- `integration_test/harness.dart`: fixed-time pumps (the clock ring never settles),
  `tapKey` on stable `Key`s, and `playOne`, which answers the current challenge through the
  same widgets a player taps (`opt-correct`, `card-<piece>-a/b`) and waits until the answer
  is registered.
- `screenshot_test.dart`: registers, starts today's run, takes one still per game type,
  finishes the run, then captures the result, both leaderboards, history, profile, admin
  and the home screen after playing.
- `demo_test.dart`: the same path at a watchable pace, with one deliberate wrong answer.

## Locally (machine with an Android emulator)

```sh
flutter pub get
flutter drive --driver test_driver/integration_test.dart \
  --target integration_test/screenshot_test.dart -d emulator-5554
```

## Checks without a device

```sh
flutter analyze && flutter test
```
