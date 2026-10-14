# Padel Board roadmap

The plan borrows what got Club Kitten to the App Store in a day, and avoids what slowed it down.

**Kept from Club Kitten:** SwiftUI, iPhone only, iOS 17+, a single target with no packages, everything saved on the device, a GitHub Pages site for privacy and support, and the listing written down in `AppStore/metadata.md` before submitting.

**Avoided:** no accounts, server or multiplayer in v1. Club Kitten's cloud save and multiplayer added a Supabase project, account deletion, report and block, App Privacy changes and two extra review rounds. The one App Review rejection came from screens that didn't fit the 375 × 667 window iPad uses for iPhone apps, so every screen gets checked on an iPhone SE simulator before submitting.

## v1.0: free, ship it

- [x] Doubles and singles courts drawn to scale
- [x] Drag four players and the ball
- [x] Three steps with movement arrows, play button, ball hop, haptics
- [x] Positions saved on the device; reset a step
- [x] Fits an iPhone SE / iPad compatibility window
- [x] App icon (drawn by `scripts/make_icon.swift`; rerun with `swift scripts/make_icon.swift PadelBoard/Assets.xcassets/AppIcon.appiconset/icon.png`)
- [ ] Check the name "Padel Board" is free in App Store Connect; create the app record (bundle ID `com.eliasnemr.padelboard`)
- [ ] Publish `docs/` with GitHub Pages and fill in the privacy and support URLs
- [ ] Screenshots: 6.9-inch (1320 × 2868) and 6.5-inch (1284 × 2778)
- [ ] TestFlight on a real phone (drag feel, haptics), then submit

## v1.1: polish from first users

- Undo the last move
- Landscape or iPad layout, if people ask for it
- A short "drag a player" hint the first time the app opens

## Later: paid features (one-time unlock or subscription, StoreKit 2)

Decide pricing once v1 has real users. Candidates, roughly in order of how often coaches and players would use them:

- Save and name plays; a library of plays
- More than three steps per play
- Notes on each step
- Share a play as a video or image (to WhatsApp, Instagram)
- Custom player names, initials or photos
- Court colours and themes
- Drawing on the court (shot paths, lob arcs)

Adding the first paid feature also means: an In-App Purchase in App Store Connect, a restore purchases button, updated review notes, and a paywall that keeps the free board fully usable.
