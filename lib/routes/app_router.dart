import 'package:homeserve_app/services/auth_notifier.dart';
import 'package:homeserve_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:homeserve_app/screens/screens.dart';

/// Centralized Route Names
class AppRouteNames {
  AppRouteNames._();

  // Onboarding
  static const String onboarding1 = '/onboarding-1';
  static const String onboarding2 = '/onboarding-2';
  static const String onboarding3 = '/onboarding-3';

  // Auth
  static const String login = '/login';
  static const String signup = '/signup';

  // Dashboards (Role-based entry points)
  static const String customerDashboard = '/customer';
  static const String providerDashboard = '/provider';
  static const String adminDashboard = '/admin';

  // Customer Discovery & Booking
  static const String home = '/';
  static const String filter = '/filter';
  static const String providerProfile = '/provider-profile';
  static const String priceEstimate = '/price-estimate';
  static const String bookingScheduling = '/booking-scheduling';
  static const String payment = '/payment';
  static const String bookingTracking = '/booking-tracking';
  static const String notifications = '/notifications';
  static const String emergencyBooking = '/emergency-booking';
  static const String serviceHistory = '/service-history';
  static const String ratingReview = '/rating-review';

  // Provider
  static const String providerRequests = '/provider/requests';
  static const String providerAvailability = '/provider/availability';

  // Admin
  static const String adminVerification = '/admin/verification';
  static const String adminReviews = '/admin/reviews';
}

/// GoRouter configuration for Home Service Booking App
final GoRouter appRouter = GoRouter(
  initialLocation: AppRouteNames.onboarding1,
  refreshListenable: authNotifier,
  redirect: (context, state) {
    if (authNotifier.isLoading && authNotifier.user != null) {
      return null;
    }

    final bool isAuthenticated = authNotifier.isAuthenticated;
    final bool isAuthRoute = state.matchedLocation == AppRouteNames.login || 
                             state.matchedLocation == AppRouteNames.signup ||
                             state.matchedLocation.startsWith('/onboarding');
                             
    if (!isAuthenticated && !isAuthRoute) {
      if (!authNotifier.isLoading) {
        return AppRouteNames.login;
      }
      return null;
    }
    
    if (isAuthenticated) {
      final role = authNotifier.userModel?.role ?? 'customer';
      final providerStatus = authNotifier.userModel?.providerStatus ?? 'none';

      String targetRoute = AppRouteNames.customerDashboard;

      if (role == 'admin') {
        targetRoute = AppRouteNames.adminDashboard;
      } else if (role == 'provider' && providerStatus == 'approved') {
        targetRoute = AppRouteNames.providerDashboard;
      }

      if (isAuthRoute) {
        return targetRoute;
      }

      final location = state.matchedLocation;
      
      // Redirect to appropriate dashboard if accessing wrong role route
      if (role == 'admin' && location != AppRouteNames.adminDashboard && !location.startsWith('/admin')) {
        return targetRoute;
      }
      if (role == 'provider' && providerStatus == 'approved' && location != AppRouteNames.providerDashboard && !location.startsWith('/provider')) {
        return targetRoute;
      }
      if (role == 'customer' && (location.startsWith('/admin') || (location.startsWith('/provider') && location != '/provider-profile'))) {
        return targetRoute;
      }
    }
    
    return null;
  },
  routes: [
    // 0a. Onboarding 1/3
    GoRoute(
      path: AppRouteNames.onboarding1,
      builder: (context, state) => Onboarding1Screen(
        onNext: () => context.push(AppRouteNames.onboarding2),
        onSkip: () => context.go(AppRouteNames.login),
      ),
    ),

    // 0b. Onboarding 2/3
    GoRoute(
      path: AppRouteNames.onboarding2,
      builder: (context, state) => Onboarding2Screen(
        onNext: () => context.push(AppRouteNames.onboarding3),
        onSkip: () => context.go(AppRouteNames.login),
      ),
    ),

    // 0c. Onboarding 3/3
    GoRoute(
      path: AppRouteNames.onboarding3,
      builder: (context, state) => Onboarding3Screen(
        onGetStarted: () => context.go(AppRouteNames.login),
        onSkip: () => context.go(AppRouteNames.login),
      ),
    ),

    // 1. Login
    GoRoute(
      path: AppRouteNames.login,
      builder: (context, state) => LoginScreen(
        onLoginSuccess: () {
          // Route to appropriate dashboard based on user role
          final role = authNotifier.userModel?.role ?? 'customer';
          final providerStatus = authNotifier.userModel?.providerStatus ?? 'none';

          String targetRoute = AppRouteNames.customerDashboard;

          if (role == 'admin') {
            targetRoute = AppRouteNames.adminDashboard;
          } else if (role == 'provider' && providerStatus == 'approved') {
            targetRoute = AppRouteNames.providerDashboard;
          }

          context.go(targetRoute);
        },
        onNavigateToSignUp: () => context.push(AppRouteNames.signup),
        onForgotPassword: () {
          // TODO: Firebase send password reset email
        },
      ),
    ),

    // 1b. Sign Up
    GoRoute(
      path: AppRouteNames.signup,
      builder: (context, state) => SignUpScreen(
        onSignUpSuccess: () {
          // Route to appropriate dashboard based on user role
          final role = authNotifier.userModel?.role ?? 'customer';
          final providerStatus = authNotifier.userModel?.providerStatus ?? 'none';

          String targetRoute = AppRouteNames.customerDashboard;

          if (role == 'admin') {
            targetRoute = AppRouteNames.adminDashboard;
          } else if (role == 'provider' && providerStatus == 'approved') {
            targetRoute = AppRouteNames.providerDashboard;
          }

          context.go(targetRoute);
        },
        onNavigateToLogin: () => context.pop(),
        onBack: () => context.pop(),
      ),
    ),

    // 2a. Customer Dashboard (Role-based entry point)
    GoRoute(
      path: AppRouteNames.customerDashboard,
      builder: (context, state) => const CustomerDashboardScreen(),
    ),

    // 2b. Provider Dashboard (Role-based entry point)
    GoRoute(
      path: AppRouteNames.providerDashboard,
      builder: (context, state) => const ProviderDashboardScreen(),
    ),

    // 2c. Admin Dashboard (Role-based entry point)
    GoRoute(
      path: AppRouteNames.adminDashboard,
      builder: (context, state) => const AdminDashboardScreen(),
    ),

    // 3. Home / Search
    GoRoute(
      path: AppRouteNames.home,
      builder: (context, state) => HomeSearchScreen(
        onNotificationTap: () => context.push(AppRouteNames.notifications),
        onEmergencyBookingTap: () => context.push(AppRouteNames.emergencyBooking),
        onFilterTap: () => context.push(AppRouteNames.filter),
        onProviderTap: (providerId) => context.push(
          AppRouteNames.providerProfile,
          extra: providerId,
        ),
        onNavTap: (index) {
          if (index == 1) {
            context.push(AppRouteNames.serviceHistory);
          } else if (index == 2) {
            // Role switcher / Profile: navigate to Provider or Admin views for quick access
            _showRoleSelectionSheet(context);
          }
        },
      ),
    ),

    // 3. Filter Providers
    GoRoute(
      path: AppRouteNames.filter,
      builder: (context, state) => FilterProvidersScreen(
        onApplyFilters: () => context.pop(),
        onBack: () => context.pop(),
      ),
    ),

    // 4. Provider Profile
    GoRoute(
      path: AppRouteNames.providerProfile,
      builder: (context, state) {
        final providerId = (state.extra as String?) ?? 'p1';
        return ProviderProfileScreen(
          providerId: providerId,
          onBookNow: () => context.push(
            AppRouteNames.priceEstimate,
            extra: providerId,
          ),
          onBack: () => context.pop(),
        );
      },
    ),

    // 5. Price Estimate
    GoRoute(
      path: AppRouteNames.priceEstimate,
      builder: (context, state) {
        final providerId = (state.extra as String?) ?? 'p1';
        return PriceEstimateScreen(
          providerId: providerId,
          onProceedToBooking: () => context.push(AppRouteNames.bookingScheduling),
          onBack: () => context.pop(),
        );
      },
    ),

    // 6. Booking & Scheduling
    GoRoute(
      path: AppRouteNames.bookingScheduling,
      builder: (context, state) => BookingSchedulingScreen(
        onConfirmBooking: () => context.push(AppRouteNames.payment),
        onBack: () => context.pop(),
      ),
    ),

    // 7. Payment
    GoRoute(
      path: AppRouteNames.payment,
      builder: (context, state) => PaymentScreen(
        onPaymentSuccess: () => context.go(AppRouteNames.bookingTracking),
        onBack: () => context.pop(),
      ),
    ),

    // 8. Booking Status Tracking
    GoRoute(
      path: AppRouteNames.bookingTracking,
      builder: (context, state) => BookingTrackingScreen(
        onCancelBooking: () => context.go(AppRouteNames.home),
        onCallProvider: () {
          // TODO: Phone dialer
        },
        onBack: () => context.go(AppRouteNames.home),
      ),
    ),

    // 9. Notifications
    GoRoute(
      path: AppRouteNames.notifications,
      builder: (context, state) => NotificationsScreen(
        onNotificationTap: (id) {
          if (id == 'n4') {
            context.push(AppRouteNames.ratingReview);
          } else {
            context.push(AppRouteNames.bookingTracking);
          }
        },
        onBack: () => context.pop(),
      ),
    ),

    // 10. Emergency Booking
    GoRoute(
      path: AppRouteNames.emergencyBooking,
      builder: (context, state) => EmergencyBookingScreen(
        onRequestUrgentHelp: () => context.go(AppRouteNames.bookingTracking),
        onBack: () => context.pop(),
      ),
    ),

    // 11. Service History
    GoRoute(
      path: AppRouteNames.serviceHistory,
      builder: (context, state) => ServiceHistoryScreen(
        onBookingSelected: (id) => context.push(AppRouteNames.bookingTracking),
        onBack: () => context.pop(),
      ),
    ),

    // 12. Post-Job Rating & Review
    GoRoute(
      path: AppRouteNames.ratingReview,
      builder: (context, state) => RatingReviewScreen(
        onSubmitReview: () => context.go(AppRouteNames.home),
        onSkip: () => context.go(AppRouteNames.home),
      ),
    ),

    // 13. Provider â€” Booking Requests
    GoRoute(
      path: AppRouteNames.providerRequests,
      builder: (context, state) => ProviderBookingRequestsScreen(
        onNotificationTap: () => context.push(AppRouteNames.notifications),
        onProviderNavTap: (index) {
          if (index == 1) {
            context.go(AppRouteNames.providerAvailability);
          }
        },
      ),
    ),

    // 14. Provider â€” Availability & Profile
    GoRoute(
      path: AppRouteNames.providerAvailability,
      builder: (context, state) => ProviderAvailabilityScreen(
        onSaveChanges: () => context.pop(),
        onProviderNavTap: (index) {
          if (index == 0) {
            context.go(AppRouteNames.providerRequests);
          }
        },
        onBack: () => context.pop(),
      ),
    ),

    // 15. Admin â€” Provider Verification
    GoRoute(
      path: AppRouteNames.adminVerification,
      builder: (context, state) => AdminVerificationScreen(
        onAdminNavTap: (index) {
          if (index == 1) {
            context.go(AppRouteNames.adminReviews);
          }
        },
      ),
    ),

    // 16. Admin â€” Reviews & Complaints
    GoRoute(
      path: AppRouteNames.adminReviews,
      builder: (context, state) => AdminReviewsScreen(
        onAdminNavTap: (index) {
          if (index == 0) {
            context.go(AppRouteNames.adminVerification);
          }
        },
        onBack: () => context.pop(),
      ),
    ),
  ],
);

/// Helper bottom sheet for switching user portals (Customer, Provider, Admin)
void _showRoleSelectionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Switch Portal / Role',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF0F6B5C)),
                title: const Text('Customer Home'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go(AppRouteNames.home);
                },
              ),
              ListTile(
                leading: const Icon(Icons.engineering, color: Color(0xFF0F6B5C)),
                title: const Text('Service Provider Portal (Requests & Availability)'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go(AppRouteNames.providerRequests);
                },
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF0F6B5C)),
                title: const Text('Admin Console (Verification & Reviews)'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go(AppRouteNames.adminVerification);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await AuthService.instance.logout();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}



