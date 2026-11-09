# Tizbin - Source Brief

## Title
Tizbin (تیزبین, "sharp-eyed")

## Description
Tizbin is a daily competition of five tiny visual games for a Persian-speaking audience.
Every day each player gets one official attempt: 15 challenges in 90 seconds of active
play. A right answer earns 100 points and every second left on the clock adds a bonus
point, up to 1,590. Players see where they stand on a daily board (accuracy first, then
speed) and a monthly board (their best 15 days), share results and invite friends with a
referral link. The interface is fully right-to-left, with big tap targets and almost no
text, so children and grandparents can play without instructions.

## Store links
Not yet published (portfolio POC).

## Platform
Android demo, iOS-ready codebase (Flutter).

## Category
Casual games / brain games.

## Features
- One-step registration: avatar, name, mobile number, optional referral code.
- Five games on one set of reusable parts: find the different picture, which picture
  disappeared, count identical objects, same or different, match identical pictures.
- Daily competition: 15 challenges, one 90-second clock, instant right/wrong feedback.
- Automatic scoring with a speed bonus, maximum 1,590; one official attempt per day.
- Daily and monthly leaderboards, own row pinned.
- Game history and total points.
- Result sharing and referral invite link.
- Basic admin: users and plays, flagged scores to approve or reject, manual prize record
  with automatic payouts switched off.
- Simulated server-side validation and abuse checks (re-scoring from a day seed, one attempt
  a day, impossible speed, many accounts on one device).
- Offline-tolerant: no network during play, finished runs queued until sent.

## Tech stack
- Flutter 3.35, Dart 3.9, Riverpod 3 (`Notifier`s), Material 3 with a Persian locale.
- Stack choice: the job names Flutter, so Flutter it is; Riverpod for state.
- Vazirmatn font (OFL) bundled; game pieces are drawn with `CustomPainter` (no image
  downloads).
- Mock backend (`ScoreServer`) behind a clear seam for Firebase or Supabase.
- Tests: 7 rule tests + 7 widget tests; Android screenshots and demo GIF captured on an
  emulator by GitHub Actions.

## Industry
Mobile gaming / casual competitions.

## Metrics
Unpublished POC, no usage metrics. Stated targets from the brief: a large Persian-speaking
audience, an architecture that can grow to hundreds of thousands or millions of users, and
smooth play on affordable Android phones with unstable internet.

## Research notes
- Verified in this POC: game logic, scoring (max 1,590), the 90-second limit, ranking order,
  monthly best-15 sum, one attempt per day, abuse flags and the offline queue are all
  covered by unit tests; every key screen has a widget test; the media are real emulator
  captures.
- Mocked: the backend (in-memory `ScoreServer`), sharing (copies text; a release build hands
  it to the system share sheet), registration (no SMS check), the admin is reached from the
  profile instead of a separate admin login.
- Simplifications: the monthly board is a rolling 30 days so it is never empty in a demo;
  production uses the calendar month (Jalali). Images are bundled photos from the design.
- Next steps: Firebase Auth (phone) or Supabase Auth, a Cloud Function / Edge Function that
  owns the day seed and scoring, Firestore or Postgres tables keyed by `(player_id, day)`,
  device integrity checks (Play Integrity), push reminders for the daily game, a prize
  administration screen with audit log, and the iOS build.
- Known design notes from the automated design check: the Stitch mockups used a yellow star
  glyph and 10px labels that fail contrast; the app uses the green token and 13px minimum
  instead.
- Design QA (screenshot mode, 97/100, Minor findings only, left as next steps): the eye mark
  on face-down match cards is low contrast (white on lavender, 1.8:1); the five game tiles on
  Home look tappable but only preview the games; the admin sample data has every user playing
  today; status bar icons sit on the welcome photo without a scrim.
