# HZN Systems — App Icon Pack

Generated from the HZN Systems logo (`assets/icons/hzn_systems_logo.png`).

- **In-app / splash:** full logo (`app_icon_transparent.png`, `app_icon.png`, `app_icon_mac.png`)
- **Launcher / favicon / adaptive foreground:** cloud mark only (`app_icon_mark.png`) for legibility at small sizes

Regenerate all assets from the source logo:

```bash
python tool/generate_brand_assets.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

After `flutter_native_splash:create`, restore the `#splash-loading` removal in `web/index.html` if the generator overwrote it (see comment in `flutter_native_splash.yaml`).

## Platform outputs

`flutter_launcher_icons` and `flutter_native_splash` write directly into:

- `android/app/src/main/res/mipmap-*` — Android launcher + adaptive layers
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` — iOS app icon
- `web/favicon*.png`, `web/icons/`, `web/splash/` — web favicons and splash
- `windows/runner/resources/`, `macos/Runner/Assets.xcassets/` — desktop icons

The `icon_pack/` folder is a **reference snapshot** of web/Android/iOS icon layouts. Prefer the generated platform folders above for installs.

## Notes

- Source master: `hzn_systems_logo.png` (preferred) or `.jpg` at repo root — black (`#000000`) background, neon green cloud + `</>` mark, white “HZN” + green “systems” wordmark. Upscaled PNG with alpha is supported.
- `app_icon_mark.png` crops the cloud mark with a transparent background for adaptive icons and favicons.
- Per-organization logos uploaded in PocketBase still override the bundled default in-app via `OrgLogo`.
