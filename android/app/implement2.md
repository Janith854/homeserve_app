Update the HomeServe app to have one clear, consistent Status + Notification system for ALL three roles:

Customer
Provider
Admin

Do not change the existing UI structure unnecessarily. Improve the existing status and notification UI using the current HomeServe design.

### 1. USE ONE UNIVERSAL STATUS COLOR SYSTEM

Create/reuse one centralized status-color system so the SAME status always has the SAME color everywhere.

Use:

* Pending → Amber
* Confirmed / Approved → Blue
* In Progress → Purple
* Completed / Success → Green
* Rejected → Red
* Cancelled → Red
* Failed / Error → Dark Red
* Information → Light Blue
* Unread notification → Teal highlight + red unread badge

Keep HomeServe brand colors:

* Deep Teal #0F6B5C
* Warm Amber #F2A93B

Do NOT create different status colors for different roles.

For example:
Pending must always be Amber in:

* Customer Booking Tracking
* Customer Notifications
* Provider Booking Requests
* Provider Booking Status
* Admin Booking/Verification screens
* Booking Details
* Service History

### 2. BOOKING STATUS MUST BE REAL FIRESTORE DATA

Use the existing Firestore `bookings` collection.

The booking lifecycle should be:

Pending
→ Confirmed
→ In Progress
→ Completed

Other possible states:
Rejected
Cancelled
Failed

When the Provider accepts a booking:
Pending → Confirmed

When the Provider starts the job:
Confirmed → In Progress

When the Provider completes the job:
In Progress → Completed

Save every status change to the existing Firestore booking document.

Do NOT create duplicate booking documents.

### 3. KEEP CUSTOMER + PROVIDER + ADMIN IN SYNC

The same Firestore booking status must appear consistently for:

Customer:

* Booking Tracking
* Bookings
* Booking Details
* Service History
* Notifications

Provider:

* Booking Requests
* Booking Details
* Booking History
* Notifications

Admin:

* Relevant booking/management screens
* Notifications

Use real-time Firestore listeners where appropriate so status changes appear without requiring fake/hardcoded data.

Example:

Provider presses "Accept Booking"

Firestore:
status = confirmed

Then Customer should automatically see:

Confirmed 🔵

and receive a notification.

### 4. CREATE STATUS NOTIFICATIONS

Create a Firestore notification whenever an important booking status changes.

Use the existing `notifications` collection.

Examples:

Pending:
"Booking Request"
"Your booking request has been submitted."

Confirmed:
"Booking Confirmed"
"Your booking has been accepted by the provider."

In Progress:
"Service Started"
"Your service is now in progress."

Completed:
"Service Completed"
"Your service has been completed."

Rejected:
"Booking Rejected"
"Your booking request was rejected."

Cancelled:
"Booking Cancelled"
"Your booking has been cancelled."

Use the correct status color and icon for each notification.

Do not hardcode notification records.

### 5. NOTIFICATION DESIGN

Make notifications very easy to identify at a glance.

Each notification should clearly show:

* Status icon
* Status-colored indicator/badge
* Notification title
* Short message
* Related booking/service information when available
* Real date and time
* Read/unread state

Example:

🟢 Service Completed
Your plumbing service has been completed.
05 Oct 2026, 4:30 PM

Use the existing HomeServe visual style.

Do not make notifications visually confusing or overly colorful.

Use color mainly for status identification.

### 6. UNREAD NOTIFICATION BADGE

The Bell icon must show a red unread badge.

Use real Firestore data:

userId == currentUser.uid
AND
isRead == false

Show:

1, 2, 3 ... 9+

Hide the badge when unread count = 0.

Update the badge in real time when:

* New notification is created
* Notification is opened/read

When a notification is read:
isRead = true

Do not use hardcoded notification counts.

Apply this consistently to:

* Customer
* Provider
* Admin

### 7. REAL DATE AND TIME

Use Firestore:

FieldValue.serverTimestamp()

for notification `createdAt`.

Do NOT use hardcoded dates or times.

Display the actual notification time in the user's local time.

Examples:

Today, 3:42 PM
Yesterday, 10:15 AM
05 Oct 2026, 4:30 PM

Sort notifications by real `createdAt`, newest first.

### 8. STATUS UI COMPONENT

Create/reuse a reusable status widget/component instead of duplicating status-color logic in every screen.

For example, a reusable component can display:

Status icon + Status text + Correct status color

Use it everywhere possible.

This prevents:

* different colors for the same status
* inconsistent labels
* duplicated code

### 9. IMPORTANT: DO NOT BREAK EXISTING FLOWS

Keep all existing functionality working:

Customer:
Search Provider
→ Provider Profile
→ Book
→ Booking & Scheduling
→ Payment
→ Booking Tracking
→ Completed
→ Review / Complaint

Provider:
Login
→ Booking Requests
→ Accept
→ Confirmed
→ Start Job
→ In Progress
→ Complete
→ Completed

Admin:
Login
→ Dashboard
→ Provider Verification
→ Reviews & Complaints
→ Management

Do not remove existing screens or buttons.

Do not change Firebase configuration.

Do not create fake/local-only status data.

Use the existing Firestore structure.

### 10. FINAL TEST

Test the complete status lifecycle on the Android phone:

Customer creates booking
→ Pending 🟠
→ Provider accepts
→ Confirmed 🔵
→ Provider starts job
→ In Progress 🟣
→ Provider completes
→ Completed 🟢

Verify after every step:

1. Firestore booking status is updated.
2. Customer sees the correct status.
3. Provider sees the correct status.
4. Notification is created.
5. Notification has the correct status color.
6. Notification has the real date/time.
7. Bell unread count updates.
8. Opening notification marks it as read.
9. Completed booking remains completed.
10. No duplicate booking or notification records are created.

Also test:

* Rejected 🔴
* Cancelled 🔴
* Failed 🔴

Run:

flutter analyze

Fix any errors found.

Then run the app on the connected Android phone and verify the complete flow.

Do not report COMPLETE until the status, booking tracking, notifications, unread badge, colors, and Firestore synchronization are working correctly for Customer, Provider, and Admin.
