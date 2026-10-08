## v1.22.8 — Streamlined family joining
- Email invitations now open a dedicated Family & Friends entry flow with the invited email prefilled.
- New invitees create an account without entering a family code; their matching email invitation connects them automatically.
- Existing users who open an email invitation simply sign in and are connected automatically.
- Family codes are now reserved for people who already have a Swim With Me account and want to request access to another family.
- Updated family-code wording so owners know codes are for existing accounts.
- Kid View, Race Card sharing, meet/results/progress features, and EmailJS delivery behavior are otherwise unchanged.

## v1.22.4 — Race card share button fix
- Fixed the Kid View result reveal Share button: the reveal lives outside `#app`, so its click was never reaching the app action handler.
- Added a reveal-level Share handler and prepares the PNG while the result reveal is open, before the kid taps Share.
- Keeps one **Share my race card** button and the current v1.22.2 Kid View design unchanged.
- No database changes.

## v1.22.2 — Kid race card sharing
- Replaced the separate race-card save action with one **Share my race card** action.
- Uses the phone/browser native share sheet with the generated PNG attached, so installed Messages, Mail, social apps, Save to Files/photos, and other share targets can appear in one place.
- If image sharing is unavailable in the browser, falls back to downloading the PNG instead of losing the card.
- No database changes.

# v1.22.1
- Kid view: Family cheers now use dark text on light cards (was white on light).
- Previous-swim comparison now matches events the same way Family Portal does (50 Free = 50 Freestyle), so drop/add times show on reveals, the Done list, and Results.

# v1.22.0
- Kid view rebuilt around three moments: Meet (during the meet), result reveal (after a swim), History (look back).
- Meet tab: up-next card with time to beat and goal, coming-up list, done list with change and badges.
- 'Your time is in' full-screen reveal for kid devices when a parent enters a result, using the existing race animation.
- Playful celebrations: faster swim, new personal best, goal reached, B/BB/A/AA time earned (confetti, stars, bounce, vibration).
- History tab: progress chart and past meets. Me tab: colors and animations.
- Family Portal unchanged.

# v1.21.0
- Number-keypad time entry (10436 becomes 1:04.36) and quick-pick event chips in Add result.
- New Home screen: next meet, latest swim with change, goal progress.
- Goals shown as cards with progress bars and B/BB/A/AA standards, with Event picker.
- Tap a result to open a detail sheet with history and mini chart; Edit lives inside.
- People & Access and Family Portal unchanged.

# v1.19.3
- People & Access now opens with every accordion section collapsed.
- Family Portal rebuilt as a simple phone-first results feed.
- Removed race reveal animation from Family Portal only.
- Added previous time plus DROP/ADD comparison to each completed result.
- Kept meet/swimmer selectors and family cheer messaging.

# v1.19.2
- Reorganized People & Access into phone-first collapsible bubbles.
- Section order: Family Settings, Invites, Family, Kid Accounts & Devices, Swimmers.
- Family opens by default; all other sections start collapsed.
- Preserved existing owner/member permissions, invites, pairing, swimmer editing and family settings.

# Swim With Me Changelog

## v1.19.1
- Rebuilt People & Access as a phone-first screen.
- Added compact family member cards and role badges.
- Member permissions now open in a bottom sheet.
- Invite flow now opens in a bottom sheet.
- Pending requests and Kid Accounts & Devices moved to focused sheets.
- Preserved multiple owners, swimmer grants, kid pairing, removal, branding, and existing data logic.
