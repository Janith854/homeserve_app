IMPORTANT: Fix the startup navigation to use EXACTLY this flow:

App Launch
→ Splash Screen
→ Onboarding 1
→ Onboarding 2
→ Onboarding 3
→ Login / Sign Up

The Splash Screen must NOT navigate directly to Login.

After Splash finishes, it must open Onboarding 1.

Onboarding 1 → Next → Onboarding 2
Onboarding 2 → Next → Onboarding 3
Onboarding 3 → Get Started → Login

Keep the existing Onboarding UI and buttons unchanged.

Do not skip Onboarding for a new user.

Only returning users who have already completed onboarding may bypass Onboarding according to the existing onboarding preference logic.

Test the complete startup flow on the Android phone and run flutter analyze.