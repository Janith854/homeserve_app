Update the HomeServe branding screens using the existing logo asset:

assets/images/homeserve_logo.png

I already placed the logo in the assets/images folder. Do not create another logo or replace this asset.

I want the app branding to match the provided sample image.

Required flow:

Onboarding Screen 3
→ Splash Screen
→ Login / Sign Up

SPLASH SCREEN:
- Show the same HomeServe logo from `assets/images/homeserve_logo.png`
- Center the logo on the screen
- White background
- Show the tagline below the logo:
  "Trusted help, right at home"
- Clean, simple, professional appearance
- Logo should be clearly visible and properly sized
- Keep the splash screen short, then navigate automatically to Login
- Do not add unnecessary animations or UI elements

LOGIN SCREEN:
- Show the exact same `assets/images/homeserve_logo.png` at the top
- Match the sample layout as closely as possible
- Keep the existing Login functionality unchanged

SIGN UP SCREEN:
- Show the exact same HomeServe logo at the top
- Use the same logo asset
- Keep the existing Sign Up functionality unchanged

IMPORTANT:
- Use ONE logo asset everywhere:
  `assets/images/homeserve_logo.png`
- Do not recreate the logo using Flutter widgets/text.
- Do not create another logo file.
- Do not change the logo colors, shape, or design.
- Keep the existing HomeServe colors and UI style.
- Do not change existing app functionality or navigation except adding the Splash Screen after Onboarding.
- Make sure the asset is correctly declared in `pubspec.yaml`.

Final flow should be:

Onboarding 1
→ Onboarding 2
→ Onboarding 3
→ HomeServe Splash Screen
→ Login

Test:
1. Run `flutter pub get`
2. Run `flutter analyze`
3. Run the app on the Android phone.
4. Verify the logo is visible correctly on Splash, Login, and Sign Up.
5. Verify the navigation works correctly.

If there are any errors, fix them and test again.