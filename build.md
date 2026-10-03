Now implement proper Firebase Firestore Security Rules for HomeServe.

IMPORTANT:

Never use:

allow read, write: if true;

Use authenticated access control.

Roles are stored in:

users/{uid}.role

Roles:

customer
provider
admin

Rules must enforce:

CUSTOMER:

- Can read/update their own appropriate user data
- Can read their own bookings
- Can create appropriate bookings
- Can update/cancel their own permitted bookings
- Can create reviews for completed bookings
- Can read their own notifications
- Cannot access admin functionality
- Cannot modify their own role
- Cannot modify provider verification status

PROVIDER:

- Can read/update own provider profile where appropriate
- Can read relevant booking requests
- Can update permitted booking status
- Can manage own availability
- Cannot modify own role
- Cannot modify verificationStatus
- Cannot approve other providers

ADMIN:

- Can manage users
- Can manage provider applications
- Can manage providers
- Can manage complaints
- Can manage appropriate reviews
- Can access admin functionality

Ensure users cannot elevate themselves to admin/provider by modifying Firestore directly.

Also review Firebase Storage rules if Storage is being used.

Do not break existing application functionality.

After changing rules, explain exactly what was secured.

Run:

flutter analyze

and test important Firebase operations.