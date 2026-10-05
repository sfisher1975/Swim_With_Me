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

## v1.5.2 — 12 kid color palettes

Make it yours offers Splash Planet, Neon Purple, Sunset, Blue Lagoon, Bubblegum, Mint Magic, Galaxy, Coral Reef, Electric Blue, Golden Glow, Berry Blast and Tropical Teal. Choice styles the kid page background, bubble and saved PNG, and is remembered per swimmer on this device. Red adds/green drops stay consistent. No new database changes; keep earlier messaging/account migrations if installed. Replace app.js, style.css and index.html.

## v1.6.0 — Meet management

Add/edit/delete meets; event dropdown with built-in freestyle, backstroke, breaststroke, butterfly, IM and relay choices for SCY/SCM/LCM, plus family custom events and Other event. No manual list setup required. This built-in catalog was created for this app; it is not a verified extraction from the other app. Remove planned events without deleting their results. Delete meet confirmation offers Keep times or Delete linked times and shows a distinct-result count. Only explicitly linked swims are affected; manually entered unlinked swims are not inferred by date. Saved message threads cascade when linked swims are deleted. Downloaded race images remain.

Run meets_migration.sql in the existing Supabase project to install transactional deletion. Do not rerun schema.sql. Replace app.js, index.html and style.css; keep config.js and animations.js. Includes all 12 color themes. Other migrations are only needed for their respective kid-account/messaging features. Database migration not applied here; live permission/transaction testing is required.

## v1.7.0 — Meet-first kid bubble and history graph

Kid screen opens to today's meet, otherwise nearest future meet, otherwise most recent past meet. All meets are available in the meet dropdown. Planned events appear even before results exist. Select a completed event for its animated race reveal, card and message thread; pending events show their race target and waiting state. History graph is collapsed under My progress immediately before Make it yours; event/course selector, dated race times, personal and B/BB/A/AA goal lines, clickable/keyboard point details. Goal values are included in chart range. Family conversations remain per recorded race and become available after result entry. Meet-first screen includes all 50 visitors and 12 palettes. No new database migration; existing feature migrations are unchanged. Replace app.js, index.html, style.css; keep config.js and animations.js.

## v1.7.1 — Scroll to completed race

Tapping a completed meet event scrolls to its race reveal and replays its visitor animation. Pending events keep the existing behavior. Reduced-motion preference disables smooth scrolling and animation. No database changes.

## v1.7.2 — Meet selector placement

My meet selector now sits below Family cheers and immediately above My progress. The selected meet title and events remain at the top of the bubble. No database changes.

## v1.8.0 — Kid-device pairing

Parent email/password login plus kid QR/code entry, remembered restricted device sessions, parent device list and disconnect. See PAIRING_SETUP.md for required database migration, Anonymous Sign-Ins setting and setup/testing. Shared-phone admin lock is not included yet; parent previews remain parent sessions. No deployment or database mutation performed by this package.

Validation for v1.8.0: JavaScript syntax passed; DOM tests with mocked API responses passed parent QR/code display, guest code redemption, remembered kid navigation, no admin controls and no editing. SQL/PLpgSQL parsing passed. Live database transactions/RLS/session refresh/revocation and visual phone layout are not verified. Browser executable download failed in this environment.

## v1.9.0 — Family portal

Family sign-in option uses email/password. Invite email from parent Family access; family members sign up then sign in to accept invitation. Assign View only for each swimmer they may follow; No access hides that swimmer. Nonowner adult members open in the Family portal with no admin navigation, an assigned-swimmer picker, meets, animated results, progress and race messages. Linked kids continue to use their own kid page and automatic reply identity. Owners can open Family portal to send as parent, then Back to menu. Family portal shows no kid customization settings. Messages are linked to completed races; before result entry the pending-race message notice remains.

Run family_portal_migration.sql to allow only the owner to see member emails while assigning access. Existing swimmer/message RLS rules remain authoritative. Default View only grants do not permit editing swim data. Previously granted Can edit permissions are not silently removed; change those to View only if appropriate. Replace app.js, index.html and style.css; retain config.js, animations.js, qrcode.min.js. Previous migrations remain prerequisites for their features. No live changes or deployment performed here.


## v1.10.0 — Family signup without email invitations
Run family_signup_migration.sql after family_portal_migration.sql in the same Supabase project. Keep your config.js.
Parent: Family access → Create family code. Share this code with relatives. Replacing it invalidates the previous code for new requests.
Relative: Main page → Family → Create account, confirm email, sign in. Enter name and family code, then Request access.
Parent: Family access → Access requests → choose swimmers → Approve selected swimmers (view access), or Decline. Change later in existing member access selectors.
Relative: Click Check approval to open assigned swimmers. Requests grant no membership or swimmer access until approved. Existing invitations remain supported.
SQL uses owner checks, row-level security, confirmed adult accounts, and transactional approval. Syntax and mocked UI regressions checked; live Supabase execution and email flow must be verified after installation.
Set Supabase Authentication URL Configuration Site URL and allowed redirect URL to https://sfisher1975.github.io/Swim_With_Me/. Signup now explicitly requests the current app URL.


## v1.11.0 — Clear role-based login
Welcome screen offers Parent, Family & friends, and Swimmer. Parent/family entry separates Sign in and Create account. Family signup collects name and code and persists them with the account; after confirmed sign-in the app submits the access request automatically. Existing family accounts can still enter their code after login. Parents still approve selected swimmers. Confirmed-email callbacks now load the session and show the appropriate page. Password reset and kid device QR links remain supported. The camera app scans QR codes; the web page accepts pairing codes.
Remembered roles open their entry screen on return; Back returns to all roles. Valid sessions reopen the app. Overview opens first for parents and Kid view remains last. Family access is renamed People & access.
Replace index.html, app.js, and style.css, keeping config.js. No new SQL is required if family_signup_migration.sql and prior migrations are installed. UI/auth interactions checked using mock APIs; live email and database permission flow still needs installation testing.


## v1.12.0 — Readable member access and removal
Replace index.html, app.js, and style.css; retain config.js. Run family_member_removal_migration.sql in the existing Swim_With_Me database after the prior signup and device migrations. Installing it removes no data.
People & access now shows full-width member cards, readable names/emails, stacked mobile permission rows, and collapsed swimmer-account settings. Existing view/edit permission values remain unchanged. The family owner is displayed without removal or child-link controls.
Remove member requires confirmation and a parent-only database function. The transaction revokes that family’s swimmer grants, membership, child links, and connected-device access, declines join requests, and clears outstanding matching invitations so sign-in does not silently rejoin. It preserves the Auth account, swims, meets, goals, prior messages, and other families’ access. Rejoining requires a fresh request and approval. Already displayed or downloaded content cannot be erased remotely.
Mock UI checks passed for card controls, permission values, owner protection, cancellation and parent guards; SQL and PL/pgSQL syntax parsed. Live database removal still needs testing after installation.


## v1.12.1 — Remove all member-linked data for this family
This supersedes the v1.12.0 removal behavior. Rerun family_member_removal_migration.sql; installing it deletes nothing. Replace index.html and app.js, keeping config.js.
Remove member permanently deletes their race messages and replies in this family, membership, swimmer grants, linked child/device records, redeemed pairing-code records, requests and matching outstanding invitations. It clears a saved signup code only when it matches this family to prevent automatic re-request. Auth account and name/email remain, and other families’ access/messages remain. Swimmers, meets, times, goals and other authors’ messages stay intact. Previously removed members are not automatically cleaned retroactively. Historical imported cheers stored as meet notes have no authenticated author ID and cannot safely be matched to an account; those notes remain. Previously downloaded/displayed content cannot be remotely erased.
The UI confirmation explicitly describes permanent message deletion. Syntax and mocked interaction checks performed; live database behavior still needs verification after installation.
