# Family Swim Tracker

A separate project based on the feature inventory of Evie Swim Tracker v1.17.2.1. No Evie data, account settings, keys, images, video, or badges are included.

## Run

1. Create a **new** Supabase project. Run `schema.sql` in its SQL editor. Do not use the database associated with Evie's tracker.
2. Set the project URL and publishable key in `config.js`. The publishable key is public. Never use a service-role key in the browser.
3. Serve this directory over HTTP (for example `python3 -m http.server 8000`) and open it in a browser. HTTPS is required for production.
4. Sign up as a parent. Confirm email if enabled in Supabase. Create swimmer profiles, then invite family members by entering the email address they used to sign up.

## Access model

The parent owns a family and is an administrator. Members sign up independently, then the parent grants each member `view` or `edit` for specific swimmers. An editor may edit that swimmer's records and goals. Only an administrator can manage the family, members, profiles, branding, and access. All reads and writes are checked by database row level security. A person with no family membership sees no swimmer data.

## Current implementation

Swimmer profiles and switching; official/unofficial results; personal bests; progress by event and course; personal and B/BB/A/AA goals; meets and meet result entry; custom events/courses/places; theme colors and family picture upload or logo URL; printable summary; JSON export; separate sign-ins and per-swimmer permissions. Data syncs through the new Supabase project.

Cheer Squad public links, data restore/import, and detailed split analysis from the original tracker are not implemented in this first build. Videos and badges are intentionally excluded. The site is hosted on GitHub Pages at https://sfisher1975.github.io/Swim_With_Me/. Family pictures selected from a JPG, PNG, or WebP file are resized and stored with the family record. Only family members can load them. A logo URL may still point to a public image you have permission to use.

## Updating the existing site

Replace the files in the GitHub repository root and commit. GitHub Pages will publish them. `schema.sql` documents a fresh database setup; do not rerun it against the existing Supabase project. The family and swimmer SELECT policies have already been updated in the existing project. After deployment, reload the page with Ctrl+Shift+R.

## Version

The version is shown in the header on sign-in and app screens. This build is **v1.0.1**. For each future release, update the visible version and the `?v=` values on the CSS and script tags in `index.html` so browsers fetch the current files.

## v1.1.0 — My Swim

Opens on My Swim (Kid view for editors): latest race reveal, previous-result comparison, personal goal feedback, upcoming meet/events, race replay, Ocean/Neon/Sunset styles, and downloadable PNG race cards. Comparisons match event, course, and official/unofficial status. Same-day races use last-updated timestamps; editing an older race can move it forward. Card styles are temporary session choices.

Results refresh every 15 seconds while the kid screen is visible and signed in. Internet is required; this is not instant push. No database migration is needed.

Replace app.js, index.html, and style.css in the existing repository. Keep config.js. Do not rerun schema.sql. This is a web build, not an APK. Family messages, replies, saved reactions, and child-editable profile customization remain future work.

Validation: JavaScript syntax and drop/slower time, goal, course/status isolation, and empty-screen checks passed. Phone layout and PNG downloads require device testing; no browser executable was available in the build environment.

## v1.2.0 — Animated result reveals

Alien UFO (default) beams dropped seconds up or added seconds down while the old time counts to the new result. Ocean Buddy and Simple are alternate reveals. Replay and Skip controls are included. Choice is saved per swimmer on this browser/device. First swims and ties have separate messages. Reduced-motion settings show the completed result immediately. Automatic refresh does not replay an already-seen result in this session. Comparisons continue to match event, course and official status.

Replace app.js, index.html and style.css; keep your config.js. No database changes. Not deployed or packaged as an Android APK. Syntax and drop/add/tie/first/course comparison checks passed. Animations and phone layout require browser/device testing.

## v1.2.1 — Active time transfer

Last time remains visible throughout the reveal. Signed seconds are extracted or delivered while the main time counts to the new result, with an explicit old-time +/- change = new-time equation. UFO swoops in, beams, and exits. Optional synthesized swoosh/beam/finish sounds and vibration toggles are remembered on this device. Tap Sound on then Play reveal to enable audio; vibration depends on browser/device support. Skip stops effects. Reduced motion shows the final result without autoplay effects. No database migration. Syntax and previous/change/result markup checks passed; visual, audio and vibration device testing remains necessary.

## v1.2.2 — Simplified reveal

Dropped seconds, changing result and feedback are green; added seconds are red. Ties and first swims remain neutral. Previous time stays visible. Removed calculation line, sound/vibration controls and all audio/haptics code. Removed official/unofficial labels from the kid reveal and exported race card; parent data and comparison rules are unchanged. Replace app.js, index.html and style.css; keep config.js. No database changes.

## v1.3.0 — Personal race card page

Kid view is one continuous column with no header or top tab menu. A temporary Back to menu button returns to Overview and restores the parent navigation. Race card includes swimmer identity, result, previous time, green/red change, goals, and a selectable reaction. Reaction saves per swimmer/race in this browser only and is included in the PNG. Style options are collapsed under Make it yours. Family messaging/synced reactions remain future work. No database changes. Replace app.js, index.html and style.css; keep config.js. Syntax checked; phone layout and card export require device testing.
