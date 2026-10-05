# Kid device pairing — v1.8.0

## Setup

Use the existing Swim With Me Supabase project. Never place a service-role key in config.js.

1. If not previously installed, run messages_migration.sql then kid_accounts_migration.sql. Both are safe to rerun.
2. Run device_pairing_migration.sql. This adds one-use code redemption, devices, disconnect, and database restrictions. Run this BEFORE enabling anonymous sign-ins.
3. In Supabase Auth settings enable Anonymous Sign-Ins. Parent email/password sign-in stays enabled. Supabase Auth provides sign-up rate limits; if CAPTCHA is enabled in the project, this first build needs CAPTCHA integration before anonymous sign-up will work.
4. Upload app.js, index.html, style.css and qrcode.min.js to the existing repository root. Keep animations.js and your config.js.

## Parent

Sign in normally. Open Family. Under a swimmer tap Connect kid device. A QR code and 16-character code appear. QR codes are generated locally, with no third-party QR service. Use the child's phone camera to scan the code, or open the app and choose I'm a swimmer. The code expires in 10 minutes and works once. Generating a new code cancels older unused codes for that swimmer. Connected devices show under the swimmer list. Disconnect removes database access immediately; a currently open page clears on its next refresh. Previously displayed/downloaded content cannot be remotely erased.

## Kid

Choose I'm a swimmer, enter code and a device label, then Connect my device. No email/password is requested. The browser keeps its own Supabase session and opens the linked swimmer's bubble. It can read that swimmer's races/goals/meets, customize locally and send race replies. It cannot manage swimmers, edit times/goals, create families or issue pairing codes. Clearing browser storage, leaving the session, or using a new device requires a new pairing code. Use each phone's normal browser, not private browsing.

## Shared parent phone

Parent Kid view is still a PREVIEW using the parent session. It is not a locked child session. Do not hand over this session as a child login. Pair a signed-out separate device/browser profile instead. A password/device-auth lock for switching back to admin on a shared phone is not implemented in this release.

## Testing before rollout

Test parent creation, valid pairing, reuse rejected, expired code rejected, wrong code rejected, same code simultaneously redeemed only once, child read limited to its profile, forbidden admin/edit writes, reply identity, reconnect after storage clear and parent disconnect. Test both the app UI and direct API requests. Existing email-based kid account links still work. SQL permission and race-condition checks need live verification in your Supabase project. This package does not change your running database or hosted site.

## Session design

The anonymous Supabase user is a device identity, not unrestricted public access. Pairing binds that identity to a swimmer and view-only access in one database transaction. Codes are random 64-bit values and stored only as SHA-256 hashes. Invalid redemption attempts are limited per identity to five per ten minutes. Auth-level sign-up rate limits are also needed to limit identity creation. Maximum ten active paired identities per swimmer. Revoked child links remain restricted even if their Auth identity later changes.
