Fix the Customer Booking navigation and tracking flow.

Current problem:
After the customer confirms a booking and opens Booking Status, pressing Back returns to Home, but the Customer bottom navigation is missing.

Required flow:

Booking Confirmation
→ Back / Home
→ Customer Home with normal bottom navigation

Bottom navigation must show:
Home | Bookings | Notifications | Profile

Bookings tab:
→ Show the customer's existing Firestore bookings
→ Show booking details such as service, provider, date, time and status
→ Tapping a booking must open its Booking Status / Tracking screen

Booking Status:
Pending → Confirmed → In Progress → Completed

Important:
- The confirmed booking must remain saved in Firestore.
- Customer must be able to return to the same booking and track its status anytime from the Bookings tab.
- Provider status changes must update the customer's booking status.
- Do not create duplicate bookings.
- Do not use fake/sample booking data.
- Keep the existing UI/design.
- Fix only the navigation and booking tracking flow.
- Do not break the existing Customer, Provider or Admin flows.

After implementation:
1. Run flutter analyze.
2. Fix any errors.
3. Test on the Android phone:
   Confirm Booking → Back/Home → Bookings → Select Booking → Booking Status.
4. Verify the bottom navigation is always visible on Customer Home.