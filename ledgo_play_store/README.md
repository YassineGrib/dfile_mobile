# Ledgo: Google Play store assets

Same style as the Ledgo launch video: hot pink, blue, yellow, green and orange, Bricolage Grotesque for headlines, the Expenses receipt icon as the logo, and the real app screens from the FigCraft designs in an iPhone 17 Pro frame.

| # | Asset | File | Spec | Checked |
|---|-------|------|------|---------|
| 1 | App icon | `1-app-icon/ledgo-icon-512.png` | 512 x 512, 32-bit PNG with alpha, max 1024 KB | 512 x 512, RGBA, 12 KB |
| 2 | Feature graphic | `2-feature-graphic/ledgo-feature-graphic-1024x500.png` | 1024 x 500, JPEG or 24-bit PNG | 1024 x 500, 24-bit PNG, 177 KB |
| 3 | Phone screenshots (8) | `3-screenshots-phone/ledgo-phone-01.png` to `08` | 2 to 8 images, 320 to 3840 px per side, ratio 2:1 or less, 24-bit PNG or JPEG, max 8 MB each | 1080 x 1920 (9:16), 24-bit PNG, 164 to 385 KB each |
| 4 | Preview video | `4-preview-video/ledgo-preview-30s.mp4` | 30 s to 2 min, uploaded to YouTube and linked | 30.0 s, 1080 x 1920, 30 fps, music |
| 5 | Title | `5-listing-text/title.txt` | 4 to 30 characters | 23 |
| 6 | Short description | `5-listing-text/short_description.txt` | max 80 characters | 75 |
|   | Full description | `5-listing-text/full_description.txt` | max 4000 characters | 2025 |

## Design rules followed

- **Icon:** a full-bleed square with the receipt glyph filling the space. No drop shadow and no pre-rounded corners, because Google Play adds both.
- **Feature graphic:** vivid pink background (not white, black or dark grey), the logo and name centred, the phones on the left and right edges. No words like "best", "top", "free" or "sale".
- **Screenshots:** one short headline each, one real app screen, no clutter. Order: Home, Projects, Clients, Payments, WhatsApp reminder, Expenses, Calendar, Friends' debts.
- **Text:** no emojis, no ranking or price claims.

## Things to know before uploading

- **Preview video:** the Play Console takes a YouTube link, not a file. Upload `ledgo-preview-30s.mp4` to YouTube first (public or unlisted), then paste the link. At exactly 30.0 seconds it sits right at the 30 second minimum; if the Console rejects it, add a second or two to the final logo hold.
- **Name:** "Ledgo" has not been checked as a trademark or against names already on Google Play. Search the Play Store and the trademark registers for your country before you publish under it. The app itself is still called Dfile in its code and on the phone.
- **Screens:** the screenshots come from the FigCraft designs, not from a phone screenshot. For the strictest review, replace them with real screenshots from the installed app.
- **Not covered here:** tablet (7 inch and 10 inch) screenshots, which are optional, and translations of the text.
