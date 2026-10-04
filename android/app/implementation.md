Fix the Customer Provider Profile and Booking flow.

Current state:
- Approved providers are now correctly displayed on the Customer Home screen.
- Janith Nirmal (Plumbing) is visible in Nearby Providers.
- But when I tap the provider card, I cannot properly open the Provider Profile or continue to booking.

Required flow:
Customer Home
→ Tap Provider Card
→ Provider Profile
→ Book Now
→ Price Estimate
→ Booking & Scheduling
→ Select Date + Time + Address
→ Continue
→ Payment
→ Pay & Confirm
→ Booking Tracking

Please inspect the existing code and fix the issue.

Check specifically:
- Provider card `onTap` / `onProviderTap`
- Provider ID being passed through navigation
- `AppRouteNames.providerProfile`
- Provider Profile screen route/constructor
- Firestore provider document lookup
- `Book Now` button navigation
- Provider ID being passed from Profile → Price Estimate → Booking Scheduling
- Make sure the selected provider is the actual Firestore provider, not hardcoded/sample data.

Use the existing Provider Profile, Price Estimate, Booking Scheduling and Payment screens where possible.
Do not redesign the UI.
Do not change unrelated features.
Do not create fake provider data.

Also check the screenshot issue where there appear to be two bottom navigation bars. If the lower navigation bar is duplicated because HomeSearchScreen and CustomerDashboardScreen both render navigation, fix that without changing the intended navigation design.

After fixing:
1. Run flutter analyze.
2. Fix all errors.
3. Run the app on the connected Android phone.
4. Test:
   Home → Janith Plumbing → Provider Profile → Book Now → Price Estimate → Booking & Scheduling.
5. Verify the selected provider ID/name is correctly carried through the booking flow.