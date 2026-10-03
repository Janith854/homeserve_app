# Admin Provider Verification System - Implementation Guide

## Overview
This document outlines the complete implementation of the Admin Provider Verification system for the HomeServe app.

## Components Implemented

### 1. **ProviderApplicationModel** 
**File**: `lib/models/provider_application_model.dart`
- Represents provider applications submitted by users
- Maps to `providerApplications` Firestore collection
- Fields:
  - `id`: Application document ID
  - `userId`: Reference to the user who applied
  - `name`: Full name of applicant
  - `email`: Email address
  - `phone`: Phone number
  - `serviceType`: Type of service (e.g., Electrical, Cleaning)
  - `experience`: Years/description of experience
  - `description`: Profile description
  - `availableAreas`: List of service areas
  - `status`: "pending", "approved", or "rejected"
  - `submittedAt`: Timestamp of submission
  - `reviewedBy`: UID of admin who reviewed (optional)
  - `reviewedAt`: Timestamp of review decision (optional)

### 2. **Updated ProviderModel**
**File**: `lib/models/provider_model.dart`
- Extended to include all required fields per build.md
- Now includes:
  - `userId`: Reference to users collection
  - `serviceType`: Service category
  - `experience`: Experience description
  - `description`: Provider profile description
  - `availableAreas`: List of service areas
  - `verificationStatus`: "approved", "pending", or "rejected"
  - `accountStatus`: "active" or "suspended"
  - `availability`: Map for scheduling (optional)

### 3. **ProviderVerificationService**
**File**: `lib/services/provider_verification_service.dart`
- Singleton service for provider verification operations
- Methods:
  - `watchPendingApplications()`: Real-time stream of pending applications
  - `watchAllApplications()`: Stream of all applications
  - `approveApplication(application)`: Approve a provider
  - `rejectApplication(application)`: Reject a provider

#### Approval Flow
```
Admin clicks "Approve" on application
  ↓
Show confirmation dialog
  ↓
If confirmed:
  1. Update providerApplications/{appId}.status = "approved"
  2. Set providerApplications/{appId}.reviewedAt = now
  3. Set providerApplications/{appId}.reviewedBy = adminUid
  4. Update users/{userId}.role = "provider"
  5. Update users/{userId}.providerStatus = "approved"
  6. Update users/{userId}.updatedAt = now
  7. Create/update providers/{userId} with full details
  ↓
Show success snackbar
```

#### Rejection Flow
```
Admin clicks "Reject" on application
  ↓
Show confirmation dialog
  ↓
If confirmed:
  1. Update providerApplications/{appId}.status = "rejected"
  2. Set providerApplications/{appId}.reviewedAt = now
  3. Set providerApplications/{appId}.reviewedBy = adminUid
  4. Update users/{userId}.providerStatus = "rejected"
  5. Update users/{userId}.updatedAt = now
  (role remains "customer")
  ↓
Show confirmation snackbar
```

### 4. **Updated AdminVerificationScreen**
**File**: `lib/screens/admin/admin_verification_screen.dart`
- Fully integrated with ProviderVerificationService
- Features:
  - Real-time stream of pending applications using Firestore
  - Displays all required fields:
    - Applicant name and photo placeholder
    - Email and phone
    - Service type
    - Experience level
    - Detailed description
    - Available areas (chip-based UI)
    - Submission date/time
  - Approve/Reject buttons with confirmation dialogs
  - Loading state while fetching from Firestore
  - Error handling with error messages
  - Empty state when no applications pending
  - Admin bottom navigation bar

## Firestore Structure

### Collections

#### `providerApplications`
```firestore
providerApplications/
  {applicationId}/
    userId: string
    name: string
    email: string
    phone: string
    serviceType: string
    experience: string
    description: string
    availableAreas: array<string>
    status: string ("pending" | "approved" | "rejected")
    submittedAt: timestamp
    reviewedBy: string (optional, admin UID)
    reviewedAt: timestamp (optional)
```

#### `users`
```firestore
users/
  {userId}/
    uid: string
    fullName: string
    email: string
    phone: string
    role: string ("customer" | "provider" | "admin")
    providerStatus: string ("none" | "pending" | "approved" | "rejected")
    accountStatus: string ("active" | "suspended")
    createdAt: timestamp
    updatedAt: timestamp
```

#### `providers`
```firestore
providers/
  {userId}/
    providerId: string (same as userId)
    userId: string
    name: string
    email: string
    phone: string
    serviceType: string
    experience: string
    description: string
    availableAreas: array<string>
    rating: number (default: 0)
    availability: object (optional)
    verificationStatus: string ("approved" | "pending" | "rejected")
    accountStatus: string ("active" | "suspended")
    createdAt: timestamp
    updatedAt: timestamp
```

## Security Considerations

### Firestore Security Rules (Recommended)
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only admins can read/write providerApplications
    match /providerApplications/{applicationId} {
      allow read, write: if request.auth.token.admin == true;
    }
    
    // Users can read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId || request.auth.token.admin == true;
    }
    
    // Public read of approved providers, but only admins can write
    match /providers/{providerId} {
      allow read: if true;
      allow write: if request.auth.token.admin == true;
    }
  }
}
```

### Code-Level Security
- ProviderVerificationService checks that current user is authenticated before approval/rejection
- Admin dashboard is only accessible to users with `role == 'admin'` (enforced by app_router.dart redirect logic)
- Non-admin users cannot call approval/rejection methods

## Implementation Checklist

✅ Created ProviderApplicationModel
✅ Updated ProviderModel with all required fields
✅ Created ProviderVerificationService
✅ Updated AdminVerificationScreen with real Firestore integration
✅ Added confirmation dialogs for approve/reject
✅ Added error handling and loading states
✅ Added empty state UI

## Testing Workflow

### Full Flow Test
```
1. Create test customer account
2. Have test customer submit provider application (via dedicated form - TBD)
3. Log in as admin
4. Navigate to Admin Dashboard → Provider Verification
5. See pending application with all fields
6. Click "Approve"
7. Confirm in dialog
8. Verify:
   - Application status changed to "approved"
   - User's role changed to "provider"
   - User's providerStatus set to "approved"
   - providers/{userId} document created
   - Snackbar shows success
9. Log out and log back in as the newly approved provider
10. Should see Provider Dashboard (not Customer Dashboard)
11. Verify user can access provider features
```

### Rejection Test
```
1. Create another test provider application
2. Log in as admin
3. Navigate to Provider Verification
4. Click "Reject" on the application
5. Confirm in dialog
6. Verify:
   - Application status changed to "rejected"
   - User's providerStatus set to "rejected"
   - User's role remains "customer"
   - Snackbar shows confirmation
7. Log out and log back in as the rejected user
8. Should see Customer Dashboard (not Provider Dashboard)
```

## Next Steps

### Immediate (Required)
- [ ] Create Provider Application Form screen for users to apply
- [ ] Add route to provider application form
- [ ] Create AuthService.signUpProvider() method
- [ ] Implement Firestore security rules
- [ ] Run flutter analyze to verify no errors
- [ ] Run flutter build to verify compilation

### Future Enhancements
- [ ] Add admin search/filter on provider verification screen
- [ ] Add bulk approval/rejection actions
- [ ] Add rejection reason/notes from admin
- [ ] Send email notifications to applicants on approval/rejection
- [ ] Add provider document creation as scheduled Cloud Function (instead of inline)
- [ ] Add provider onboarding workflow after approval
- [ ] Add provider verification expiry/renewal system
- [ ] Add admin audit logs for approvals/rejections

## File Changes Summary

| File | Status | Changes |
|------|--------|---------|
| `lib/models/provider_application_model.dart` | ✅ Created | New model for provider applications |
| `lib/models/provider_model.dart` | ✅ Updated | Extended with all required fields |
| `lib/services/provider_verification_service.dart` | ✅ Created | Approval/rejection service |
| `lib/screens/admin/admin_verification_screen.dart` | ✅ Updated | Real Firestore integration |
| `lib/routes/app_router.dart` | ✅ Existing | Admin access control enforced |

## Code Quality & Testing

- [ ] Run `dart analyze` - check for lint/type errors
- [ ] Run `dart format` - ensure consistent formatting
- [ ] Test with real Firestore database
- [ ] Test with emulated Firestore
- [ ] Test error scenarios (network failures, auth failures)
- [ ] Test concurrent approvals/rejections
