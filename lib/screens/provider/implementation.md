Update the existing HomeServe User Profile and Service Provider Profile.

IMPORTANT:
Keep the existing HomeServe UI, colors, navigation, Firebase/Firestore structure, and functionality.
Do not make unrelated changes.
Do not create duplicate user/provider records.

### 1. USER / CUSTOMER PROFILE PHOTO

The current Customer/User Profile does not have a profile photo option.

Add a profile photo section at the top of the existing User Profile screen.

Requirements:

- Show a circular profile photo.
- If the user has no photo:
  → Show a clean placeholder/avatar with "Add Photo" or an upload icon.
- Allow the logged-in user to select a photo from the phone gallery.
- Show the selected photo immediately.
- Save the profile photo persistently to the user's existing profile data.
- When the app is reopened, the saved profile photo must still appear.
- Use the existing `users/{uid}` Firestore document.
- Do not create a separate user document.
- Keep the existing Name and Phone fields and profile functionality unchanged.

The photo should belong to the currently logged-in user only.

### 2. SERVICE PROVIDER PROFILE – VIEW MODE AFTER SAVE

Update the existing Service Provider Profile behavior.

CURRENT PROBLEM:

After editing the Provider Profile and pressing Save Profile, the screen still looks like it is in edit mode.

I need the profile to switch to READ-ONLY VIEW MODE after saving.

Required behavior:

Provider Profile
→ Edit Profile
→ Edit fields
→ Select/change profile photo
→ Save Profile
→ READ-ONLY VIEW MODE

After Save Profile:

- Disable text fields.
- Do not show editable input borders.
- Display the saved values clearly as profile information.
- Show the saved profile photo.
- Show the saved:
  - Name
  - Phone
  - Service Type
  - Experience
  - Description
  - Available Areas
  - Price (LKR)

Show an:

**Edit Profile**

button.

When the provider taps:

**Edit Profile**

→ Return to EDIT MODE.

The provider can then update:

- Name
- Phone
- Service Type
- Experience
- Description
- Available Areas
- Price (LKR)
- Profile Photo

Then:

**Save Profile**
→ Update the SAME existing provider/user data
→ Return immediately to READ-ONLY VIEW MODE.

### 3. PROFILE PHOTO SAVE

The Provider Profile photo must use the same Save Profile action.

Do NOT create a separate "Save Photo" button.

Flow:

Edit Profile
→ Select Photo
→ Change other details if needed
→ Save Profile
→ Photo + all profile changes saved
→ View Mode

The photo must remain after:

- Closing the profile
- Reopening the profile
- Restarting the app
- Logging out and logging back in

Use the existing Firebase/Firestore profile data structure.

If the project already has `profileImageUrl`, reuse it.

Do not create duplicate provider records.

### 4. FIRESTORE

Customer/User Profile:

Use the existing:

`users/{uid}`

Provider Profile:

Use the existing provider/user document structure.

Update the existing document instead of creating a new one.

Use real Firebase/Firestore data.

Do not use hardcoded profile information.

### 5. UI

Keep the existing HomeServe design.

Profile photo:

- Circular
- Professional
- Properly sized
- Top section of the profile
- Clean placeholder when no photo exists

Do not redesign the entire Profile screen.

Only add/fix the required profile photo and View/Edit behavior.

### 6. IMPORTANT ROLE RULES

Customer/User:

- Can update their own profile photo.
- Can update their allowed profile fields.

Provider:

- Can edit their own profile information.
- Cannot change their role.
- Cannot change verification status.
- Cannot change account status.

Admin:

- Existing Admin profile behavior should remain unchanged unless the same profile-photo feature already applies there.

### 7. TEST

Test Customer/User Profile:

Login
→ Profile
→ Add Profile Photo
→ Save
→ Leave Profile
→ Open Profile again
→ Verify photo remains
→ Restart app
→ Verify photo remains

Test Provider Profile:

Provider Login
→ Provider Profile
→ Verify current saved profile is READ-ONLY
→ Edit Profile
→ Change Name/Phone/Service/Experience/Description/Areas/Price
→ Select/change Profile Photo
→ Save Profile
→ Verify screen returns to READ-ONLY VIEW MODE
→ Tap Edit Profile again
→ Verify all saved values and photo are loaded
→ Make another change
→ Save Profile
→ Verify again

IMPORTANT:
- Same Firestore document must be updated.
- No duplicate provider records.
- No duplicate user records.
- Profile photo must persist.
- Provider Profile must NOT remain in edit mode after Save.
- Existing HomeServe UI must remain intact.

Run:

flutter analyze

Then run the app on the connected Android phone and test both Customer/User Profile and Provider Profile.

If anything fails, identify the root cause, fix it, and test again.