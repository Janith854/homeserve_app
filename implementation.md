Implement and fix the notification system in HomeServe.

### 1. Admin Notifications
- Make the Admin Notifications screen fully functional.
- Load real admin notifications from Firestore.
- Create notifications for important admin events, such as provider applications, booking updates, and complaints.
- Support marking notifications as read.
- Update unread notification badge counts in real time.
- Use real Firestore timestamps and show the newest notifications first.

### 2. Notification Management — Customer, Provider & Admin
Add both **Select & Delete** and **Clear All** options to all three notification screens.

- **Select & Delete:** Allow users to select multiple notifications and delete only the selected ones.
- **Clear All:** Add a button to clear all notifications belonging to the currently logged-in user.
- Show a confirmation dialog before deleting notifications.
- Update the notification list and unread badge count immediately after deletion.
- Display a friendly empty state when no notifications remain.

### Important
- Use the existing Firestore `notifications` collection and notification structure.
- Users must only be able to manage their own notifications.
- Do not delete bookings, reviews, complaints, provider applications, or other related records.
- Avoid duplicate notifications and duplicate code.
- Keep the existing HomeServe UI, colors, navigation, and booking functionality unchanged.

### Testing
Run `flutter analyze`, fix any errors, and test all three notification screens on the Android phone. Verify Admin notifications work, Select & Delete works, Clear All works, unread counts update correctly, and users cannot delete another user's notifications.

Only report completion after testing the actual functionality.