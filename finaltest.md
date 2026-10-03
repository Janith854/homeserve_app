PROMPT 15 — FINAL CLEANUP, REAL DATA & COMPLETE FUNCTIONAL FLOW

Now make the HomeServe app fully functional and clean for the final implementation.

IMPORTANT:
The high-fidelity prototype was uploaded earlier only as the UI/design reference. 
Remove all sample/demo/mock data and prototype-only content from the actual app.

TASKS:

1. Remove all hardcoded/sample provider, customer, booking, review and admin data.

2. Remove all fake/demo buttons and temporary role-selection buttons from Login and Sign Up.
   Users must NOT manually select Customer / Provider / Admin during Sign Up or Login.

3. Use the real Firebase role system:
   - New users → role = customer
   - Customer applies to become provider
   - Admin approves/rejects provider application
   - Approved user → role = provider
   - Admin role is controlled separately

4. Complete and verify the full real flow:

   CUSTOMER:
   Sign Up → Login → Customer Dashboard → Search → Provider Profile →
   Price Estimate → Booking → Payment Simulation → Booking Status →
   Service History → Review / Complaint

   PROVIDER:
   Login → Provider Dashboard → Booking Requests →
   Accept/Reject → Update Booking Status → Availability → Provider Profile

   ADMIN:
   Login → Admin Dashboard → Provider Verification →
   Customer Management → Provider Management →
   Reviews & Complaints

5. All important data must come from Firebase Firestore.
   Do not use fake/local lists as final data.

6. Verify the main Firestore collections:
   users
   providerApplications
   providers
   bookings
   reviews
   complaints
   notifications

7. Keep the high-fidelity prototype UI/design as the visual reference.
   Do not unnecessarily redesign the existing screens.

8. Remove placeholder text such as:
   "Sample User"
   "Demo Provider"
   "Test Booking"
   fake ratings/reviews
   and any other prototype/sample information.

9. Check navigation and role-based routing carefully.
   Users must automatically reach the correct dashboard based on their Firebase role.

10. Check CRUD operations for the implemented features and make sure they use real Firestore data.

11. Check loading, empty and error states so the app does not show broken or fake content.

12. Do not remove any already-working Firebase Authentication or Firestore functionality.

13. Run:
   flutter pub get
   flutter analyze

14. Fix ALL errors and warnings.

15. Test the complete Customer → Provider → Admin flow using real Firebase data.

16. Do not claim a feature is complete if it is not actually working.

FINAL RESULT:
The app should be clean, with no prototype/sample data, no manual role-selection buttons, no fake data, and all implemented Customer, Provider and Admin features connected to the real Firebase backend.

Finally report:
- Files changed
- Features completed
- Sample/demo data removed
- Role-selection UI removed
- Firebase collections used
- CRUD operations verified
- flutter analyze result
- Any remaining issues