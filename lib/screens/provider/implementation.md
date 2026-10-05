Update the existing HomeServe app with these UI and flow changes.

IMPORTANT:
Keep the existing HomeServe design, colors, navigation, Firebase logic, and functionality.
Do not make unrelated changes.

### 1. Booking Service

After the customer taps **Save Booking**:

* Save the booking to Firestore as usual.
* Switch the screen to **Read-Only View Mode**.
* Show the saved:

  * Date
  * Time
  * Address
  * Note
* Do not keep the form editable in View Mode.

Show two buttons:

**Edit Booking**
→ Opens the editable form with the existing saved values.

**Continue to Payment**
→ Opens the Payment screen.

After editing:

**Edit Booking → Update Booking**
→ Update the SAME Firestore booking document.
→ Return to Read-Only View Mode.
→ Show the updated values.

Do NOT create a duplicate booking document.

### Date Selection

Replace the current horizontal date selector with a proper **Calendar / Date Picker**.

The selected date must be saved correctly to the booking.

### 2. Payment Screen

Remove **Mobile Wallet** completely.

Keep only:

* **Card**
* **Cash**

For Card:

* Add a proper Visa/card icon.
* Keep the design clean and professional.

For Cash:

* Add a proper cash/money icon.

Keep the existing HomeServe colors and design style.

### 3. Login & Sign Up

Improve the Google Sign-In button on both Login and Sign Up.

Use:

* White button/background
* Official colorful Google "G" icon
* Proper icon and text alignment
* Good spacing
* Clean modern appearance

Keep the existing Google Sign-In functionality unchanged.

### IMPORTANT

Do not change:

* Firebase configuration
* Firestore structure
* Existing booking/payment logic
* Existing navigation
* HomeServe branding
* Other screens unnecessarily

After implementing:

1. Run `flutter analyze`
2. Fix any errors.
3. Run the app on the Android phone.
4. Test:

   * Save Booking → View Mode
   * Edit Booking → Update Booking
   * Same Firestore booking document is updated
   * Calendar Date Picker
   * Continue to Payment
   * Card/Cash options
   * Google Sign-In on Login
   * Google Sign-In on Sign Up

Only report COMPLETE after everything works correctly.
