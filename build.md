Fix the white screen issue in the HomeServe app.

Runtime error:
RenderFlex children have non-zero flex but incoming width constraints are unbounded.

The error is from:
lib/screens/admin/admin_dashboard_screen.dart
BottomNavigationBar

Fix the layout so the BottomNavigationBar gets a proper screen width.

Also fix the Firestore index error for:
providerApplications
status == pending
orderBy submittedAt descending

Do not remove any existing features or screens.
Do not add sample data or role-selection buttons.

After fixing, run:
flutter analyze

Then make sure the app opens normally and the Admin Dashboard works without the white screen.