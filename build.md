Now implement the Admin Provider Verification system.

Admin role:

role = "admin"

Admin Dashboard must have:

Provider Verification

Display provider applications from:

providerApplications

Filter/list:

status = pending

For every application show:

- Applicant name
- Email
- Phone
- Service type
- Experience
- Description
- Available areas
- Submitted date
- Current status

Actions:

APPROVE
REJECT

APPROVE behavior:

1. providerApplications/{applicationId}.status = "approved"
2. providerApplications.reviewedAt = current timestamp
3. providerApplications.reviewedBy = admin UID
4. users/{userId}.role = "provider"
5. users/{userId}.providerStatus = "approved"
6. users/{userId}.updatedAt = current timestamp
7. Create/update providers/{userId}

Provider document:

providerId
userId
name
email
phone
serviceType
experience
description
availableAreas
rating
availability
verificationStatus = "approved"
accountStatus = "active"
createdAt
updatedAt

REJECT behavior:

1. providerApplications.status = "rejected"
2. users/{userId}.role remains "customer"
3. users/{userId}.providerStatus = "rejected"
4. Save reviewedBy
5. Save reviewedAt

Do not allow non-admin users to approve/reject applications through the UI.

Use Firestore.

After implementation:

flutter analyze

Fix errors.

Test the full flow:

Customer applies
→ pending
→ Admin sees application
→ Admin approves
→ User becomes provider

Report the implementation status.