# Family Swim Tracker

A separate project based on the feature inventory of Evie Swim Tracker v1.17.2.1. No Evie data, account settings, keys, images, video, or badges are included.

## Run

1. Create a **new** Supabase project. Run `schema.sql` in its SQL editor. Do not use the database associated with Evie's tracker.
2. Copy `config.example.js` to `config.js` and enter the new project's URL and publishable/anon key. Keep `config.js` out of public source control only if it contains other secrets; the publishable key itself is public. Never use a service-role key in the browser.
3. Serve this directory over HTTP (for example `python3 -m http.server 8000`) and open it in a browser. HTTPS is required for production.
4. Sign up as a parent. Confirm email if enabled in Supabase. Create swimmer profiles, then invite family members by entering the email address they used to sign up.

## Access model

The parent owns a family and is an administrator. Members sign up independently, then the parent grants each member `view` or `edit` for specific swimmers. An editor may edit that swimmer's records and goals. Only an administrator can manage the family, members, profiles, branding, and access. All reads and writes are checked by database row level security. A person with no family membership sees no swimmer data.

## Current implementation

Swimmer profiles and switching; official/unofficial results; personal bests; progress by event and course; personal and B/BB/A/AA goals; meets and meet result entry; custom events/courses/places; theme colors and logo URL; printable summary; JSON export; separate sign-ins and per-swimmer permissions. Data syncs through the new Supabase project.

Cheer Squad public links, data restore/import, and detailed split analysis from the original tracker are not implemented in this first build. Videos and badges are intentionally excluded. No production hosting has been configured. A logo URL should point to an image you have permission to use; a private upload workflow can be added later.
