Update the existing HomeServe Payment screen.

IMPORTANT:
Do not change the existing payment logic, Firebase logic, navigation, or overall HomeServe design.

### 1. CASH PAYMENT OPTION

Improve the Cash payment option.

Currently the Cash option is too plain.

Make it look similar in quality to the Card option.

Show:

💵 Cash
Pay after service

Use a clean professional cash/money icon.

The Cash option should:
- Have a proper icon on the left
- Have clear "Cash" text
- Have "Pay after service" subtitle
- Use the same card style as the Card option
- Have proper spacing and alignment
- Use the HomeServe design style

When Cash is selected:
- Highlight the Cash card with Deep Teal
- Show the selected radio indicator
- Hide Card Number, MM/YY and CVV fields
- Keep the Pay button working

### 2. REPLACE THE WRONG PAYMENT IMAGES

The current Visa/Mastercard and Cash images shown on the Payment screen are incorrect/wrong images.

I have already added the correct image assets inside the project's assets folder.

IMPORTANT:

DO NOT use the currently displayed/wrong images.

First inspect the assets folder and find the exact payment images I added.

Use the exact asset files I provided for:

- Visa + Mastercard
- Cash / Money

Do not generate new images.
Do not use screenshots.
Do not use unrelated images.
Do not use placeholder images.

Use the existing asset filenames exactly as they are.

If needed, properly declare them in `pubspec.yaml`.

### 3. CARD PAYMENT OPTION

For Card:

Show the correct Visa + Mastercard asset from the assets folder.

Make sure:
- The image is properly sized
- It is not stretched
- It is not too small
- It does not look like a screenshot
- It fits cleanly inside the Card payment option
- It keeps the existing HomeServe style

### 4. CASH PAYMENT OPTION

Use the correct Cash/Money asset from the assets folder.

Make sure:
- Correct image is displayed
- Proper size
- Proper alignment
- No stretching
- No unwanted background
- Looks professional

### 5. DO NOT CHANGE PRICE

Keep the current improved price layout:

Service: Plumbing

Total Amount

Rs. 3600

Keep the price clearly visible.

### 6. FINAL PAYMENT UI

The payment methods should look like:

Card
Visa + Mastercard

Cash
Pay after service

Only Card and Cash.

No Mobile Wallet.

### 7. IMPORTANT

Do not:
- Create new payment images
- Use the wrong existing images
- Use screenshots as icons
- Change Firebase
- Change Firestore payment logic
- Change booking logic
- Change navigation
- Remove Card functionality
- Remove Cash functionality

Use the exact payment image assets I already added to the project.

### TEST

After making the changes:

1. Run `flutter pub get`
2. Run `flutter analyze`
3. Run the app on the Android phone.
4. Open Payment.
5. Verify the correct Visa/Mastercard image appears.
6. Verify the correct Cash image appears.
7. Select Card → card fields appear.
8. Select Cash → card fields disappear.
9. Both payment methods work correctly.
10. Pay & Confirm continues to Booking Tracking.

Only report COMPLETE after the correct assets are displayed and the payment flow still works.