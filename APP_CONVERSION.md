# Turning Swim With Me into a store app

## Step 1 — Install it as an app today (free)
Open the site in your phone browser, then Share → Add to Home Screen (iPhone) or menu → Install app (Android). It runs full screen with its own icon.

## Step 2 — Wrap it as a real app (Capacitor)
Capacitor puts this exact web app inside a native shell. You need a computer with Node.js.
1. `npm init -y && npm i @capacitor/core @capacitor/cli @capacitor/android @capacitor/ios`
2. `npx cap init "Swim With Me" com.yourname.swimwithme --web-dir=www`
3. Copy these files into a `www` folder: index.html, style.css, phone.css, app.js, animations.js, shell.js, qrcode.min.js, config.js, manifest.json, and the icons.
4. `npx cap add android` / `npx cap add ios`, then `npx cap sync`
5. Android: open in Android Studio and build. iPhone: open in Xcode (needs a Mac).

## Things to know
- Google Play needs a one-time $25 developer fee; Apple needs $99 per year.
- In Supabase → Authentication → URL Configuration, add the app's redirect URL once you know it (Capacitor uses a custom scheme or https://localhost).
- The kid QR pairing links open the website. Inside the app, kids should type the pairing code, or you add a deep link later.
- Remove sw.js from the native build; the app already ships its own files.
