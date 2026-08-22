# Kylie Fitness Gym — App Icon Pack

Generated from the emblem (diamond mark) of the Kylie Fitness Gym logo, on a solid black background. The "KYLIE FITNESS GYM" wordmark was intentionally left out of the icon itself since text isn't legible at small icon sizes (this is standard practice — use the full logo for splash screens, marketing, and in-app headers instead).

## Folder structure

```
ios/
  AppIcon.appiconset/       Drop this whole folder into Xcode's Assets.xcassets,
                            replacing the existing AppIcon.appiconset.
                            Contents.json is pre-configured with all filenames.

android/
  mipmap-mdpi/              48x48   standard + round launcher icons
  mipmap-hdpi/              72x72
  mipmap-xhdpi/             96x96
  mipmap-xxhdpi/            144x144
  mipmap-xxxhdpi/           192x192
  mipmap-anydpi-v26/        ic_launcher.xml + ic_launcher_round.xml
                            (adaptive icon definitions, Android 8.0+)
  playstore-icon-512.png    512x512 icon for the Play Console store listing

web/
  favicon.ico                      16/32/48px multi-size classic favicon
  favicon-16x16.png                 favicon-96x96.png
  favicon-32x32.png                 apple-touch-icon.png (180x180, iOS home screen)
  android-chrome-192x192.png       android-chrome-512x512.png (PWA / Chrome)
  web-app-manifest-192x192.png     web-app-manifest-512x512.png (same art, manifest-ready names)
  mstile-150x150.png               Windows Start tile
  safari-pinned-tab.svg            true vector trace, monochrome, for macOS Safari's pinned tab
  site.webmanifest                 PWA manifest referencing the android-chrome icons
  browserconfig.xml                Windows tile config
  head-snippet.html                copy-paste <head> tags wiring all of the above together
```

Each `mipmap-*` density folder also contains:
- `ic_launcher_background.png` — solid black background layer
- `ic_launcher_foreground.png` — transparent-background mark, sized to Android's
  108dp adaptive icon canvas with the logo kept inside the 66dp safe zone so it
  isn't clipped when the OS masks it into a circle, squircle, rounded square, etc.

## How to install

**iOS (Xcode):**
1. Open your project's `Assets.xcassets`.
2. Delete the existing `AppIcon` set (or rename this one to match).
3. Drag the `AppIcon.appiconset` folder from this pack into `Assets.xcassets`.

**Android (Android Studio):**
1. Copy all `mipmap-*` folders into `app/src/main/res/`, merging with existing folders.
2. Make sure your `AndroidManifest.xml` references:
   ```xml
   android:icon="@mipmap/ic_launcher"
   android:roundIcon="@mipmap/ic_launcher_round"
   ```
3. For Android 8.0+ adaptive icons, the `mipmap-anydpi-v26/ic_launcher.xml` will
   automatically take precedence over the static PNGs on supported devices.
4. Upload `playstore-icon-512.png` separately in the Play Console under
   Store presence > Main store listing.

**Web:**
1. Copy every file in the `web/` folder to your site's root (or wherever your
   static assets live, adjusting the paths in `head-snippet.html` to match).
2. Paste the contents of `head-snippet.html` into your site's `<head>`.
3. `site.webmanifest` and `browserconfig.xml` already point at the right
   filenames, so no further editing is needed unless you move the files.

## Notes

- Source master is a clean 924x924 px render with a true black (#000000)
  background and a crisp white mark, no JPEG artifacts.
- If you'd rather ship the full "KYLIE FITNESS GYM" wordmark as the icon
  instead of just the emblem, let me know and I can regenerate the pack from
  that version — just be aware the text will likely blur out at 20-40px sizes.
