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
