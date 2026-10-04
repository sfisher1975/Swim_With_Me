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

## v1.4.0 — Splash Planet with 50 visitors

Five collections (Space, Ocean, Animals, Fantasy, Machines), ten visitors each. Pick one visitor, Random within a collection, or Random from all 50. Replay keeps the current visitor; Surprise me again picks another. Preferences save per swimmer on this device. Distinct generated entrance/working/exit paths plus beam, bubble, splash, portal, flame and other transfer effects use lightweight emoji characters; artwork appearance depends on the device. Last time remains visible while signed green/red seconds transfer and the old time counts to the result. Ties/first swims are neutral. Reduced-motion setting bypasses animation. No sound/vibration or result-status labels. Reactions remain local; messaging is not implemented.

Replace app.js, index.html, style.css AND animations.js in the repository root. Keep config.js; no database changes. This is a web build, not an APK and not deployed. Syntax and collection/fixed/random/replay/shuffle checks passed. Phone animation/layout/card-download testing remains required.

## v1.4.1 — Simpler heading

Kid page heading shows only the swimmer’s first name. Removed Your lane/Your story tagline and manual Refresh results button. Automatic refresh remains; its failure notice no longer references the removed button. No database changes.

## v1.4.2 — One bubble

Entire kid page lives in one race bubble: name, Back to menu, reveal, goals, reactions and save button. Customize, My meet and My swims are collapsed sections inside the bubble. Removed outside heading/panels and routine refresh caption. All animations and automatic refresh remain. Replace app.js, index.html and style.css; keep animations.js and config.js. No database changes.

## v1.4.3 — Bubble section order

Make it yours is the final section at the bottom of the bubble, after My meet and My swims. No meet/history/customization panels outside the bubble.

## v1.5.0 — Family race conversations

Replaces reactions with a saved message thread and reply form inside each race bubble. Parents and family members with swimmer access can send; view-only members may message without editing swim data. Choose your display name when sending. Names are self-entered; each message remains tied to its authenticated sender. Latest 100 messages per race, displayed oldest first. Messages refresh with the existing 15-second polling. Drafts survive refresh within this session. No anonymous/public access.

SETUP: Run messages_migration.sql once in your EXISTING Swim With Me Supabase SQL editor. Do not rerun schema.sql. Then replace app.js, index.html and style.css; keep config.js and animations.js. The app shows setup feedback if the messages table is missing. No migration has been applied by this build. Database RLS migration needs verification in your Supabase project with two authorized accounts and one unauthorized account. Web build only, not deployed/APK.

## v1.5.1 — Kid-only reply experience

Run messages_migration.sql if not already installed, then kid_accounts_migration.sql once. In the parent Family tab, choose Kid account for on the correct member. Linking assigns View only access to that swimmer. The child opens directly to their linked profile and kid page; temporary Back to menu is only shown in adult previews. Family cheers displays race messages; only linked kid accounts see Reply to your family, with the swimmer name supplied automatically and stamped server-side. Adult previews cannot send from the kid page. A separate family send screen is future work; no family composer is included in this build. Linking is optional until child login is set up. Existing family messages remain.

Replace app.js, index.html and style.css; keep animations.js and config.js. Migration not applied by this package; signed-in permission and sync verification still needed. The migration restricts linked child accounts to their own swimmer and blocks edits to swim records through the existing permission functions. Existing grants stay stored for future access changes.
