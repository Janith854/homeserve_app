import 'package:homeserve_app/services/auth_notifier.dart';
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
  static const String providerProfileEdit = '/provider/profile';

  // Provider Application (Customer flow)
  static const String providerApplication = '/provider-application';

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
      final accountStatus = authNotifier.userModel?.accountStatus ?? 'suspended';

      String targetRoute = AppRouteNames.customerDashboard;

      if (role == 'admin') {
        targetRoute = AppRouteNames.adminDashboard;
      } else if (role == 'provider' &&
          providerStatus == 'approved' &&
          accountStatus == 'active') {
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
      if (role == 'provider' &&
          providerStatus == 'approved' &&
          accountStatus == 'active' &&
          location != AppRouteNames.providerDashboard &&
          !location.startsWith('/provider')) {
        return targetRoute;
      }
      if (role != 'admin' &&
          !(role == 'provider' &&
              providerStatus == 'approved' &&
              accountStatus == 'active') &&
          (location.startsWith('/admin') ||
              (location.startsWith('/provider') &&
               location != AppRouteNames.providerApplication &&
               location != AppRouteNames.providerProfile))) {
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
          final accountStatus = authNotifier.userModel?.accountStatus ?? 'suspended';

          String targetRoute = AppRouteNames.customerDashboard;

          if (role == 'admin') {
            targetRoute = AppRouteNames.adminDashboard;
          } else if (role == 'provider' &&
              providerStatus == 'approved' &&
              accountStatus == 'active') {
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
          final accountStatus = authNotifier.userModel?.accountStatus ?? 'suspended';

          String targetRoute = AppRouteNames.customerDashboard;

          if (role == 'admin') {
            targetRoute = AppRouteNames.adminDashboard;
          } else if (role == 'provider' &&
              providerStatus == 'approved' &&
              accountStatus == 'active') {
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
      builder: (context, state) => CustomerDashboardScreen(
        onNotificationTap: () => context.push(AppRouteNames.notifications),
        onEmergencyBookingTap: () => context.push(AppRouteNames.emergencyBooking),
        onFilterTap: () => context.push(AppRouteNames.filter),
        onProviderTap: (providerId) => context.push(
          AppRouteNames.providerProfile,
          extra: providerId,
        ),
      ),
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
            context.push(AppRouteNames.notifications);
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
        final providerId = state.extra as String?;
        if (providerId == null || providerId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Provider information is unavailable.')),
          );
        }
        return PublicProviderProfileScreen(
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
        final providerId = state.extra as String?;
        if (providerId == null || providerId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Provider information is unavailable.')),
          );
        }
        return PriceEstimateScreen(
          providerId: providerId,
          onProceedWithProvider: (provider) => context.push(
            AppRouteNames.bookingScheduling,
            extra: {
              'providerId': provider.id,
              'serviceId': provider.id,
              'serviceName': provider.serviceType,
              'price': ((provider.availability?['serviceCharge'] as num?)?.toDouble() ?? 0.0) +
                  ((provider.availability?['callOutFee'] as num?)?.toDouble() ?? 0.0),
            },
          ),
          onBack: () => context.pop(),
        );
      },
    ),

    // 6. Booking & Scheduling
    GoRoute(
      path: AppRouteNames.bookingScheduling,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        if (data == null) {
          return const Scaffold(body: Center(child: Text('Booking information is unavailable.')));
        }
        return BookingSchedulingScreen(
          providerId: data['providerId'] as String? ?? '',
          serviceId: data['serviceId'] as String? ?? '',
          serviceName: data['serviceName'] as String? ?? 'Service request',
          price: (data['price'] as num?)?.toDouble() ?? 0,
          onConfirmBooking: () {},
          onBookingCreated: (bookingId) => context.push(
            AppRouteNames.payment,
            extra: {
              'bookingId': bookingId,
              'serviceName': data['serviceName'],
              'amount': data['price'],
            },
          ),
          onBack: () => context.pop(),
        );
      },
    ),

    // 7. Payment
    GoRoute(
      path: AppRouteNames.payment,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        if (data == null) {
          return const Scaffold(body: Center(child: Text('Payment information is unavailable.')));
        }
        return PaymentScreen(
          bookingId: data['bookingId'] as String? ?? '',
          serviceName: data['serviceName'] as String? ?? 'Service request',
          amount: (data['amount'] as num?)?.toDouble() ?? 0,
          onPaymentSuccess: () => context.go(
            AppRouteNames.bookingTracking,
            extra: data['bookingId'],
          ),
          onBack: () => context.pop(),
        );
      },
    ),

    // 8. Booking Status Tracking
    GoRoute(
      path: AppRouteNames.bookingTracking,
      builder: (context, state) {
        final bookingId = state.extra as String?;
        if (bookingId == null || bookingId.isEmpty) {
          return const Scaffold(body: Center(child: Text('Booking information is unavailable.')));
        }
        return BookingTrackingScreen(
          bookingId: bookingId,
          onBack: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouteNames.customerDashboard);
            }
          },
          onReviewSelected: (data) => context.push(
            AppRouteNames.ratingReview,
            extra: data,
          ),
        );
      },
    ),

    // 9. Notifications
    GoRoute(
      path: AppRouteNames.notifications,
      builder: (context, state) => NotificationsScreen(
        onNotificationTap: (id) {
          context.push(AppRouteNames.bookingTracking, extra: id);
        },
        onBack: () => context.pop(),
      ),
    ),

    // 10. Emergency Booking
    GoRoute(
      path: AppRouteNames.emergencyBooking,
      builder: (context, state) => EmergencyBookingScreen(
        onRequestUrgentHelp: (bookingId) => context.go(
          AppRouteNames.bookingTracking,
          extra: bookingId,
        ),
        onBack: () => context.pop(),
      ),
    ),

    // 11. Service History
    GoRoute(
      path: AppRouteNames.serviceHistory,
      builder: (context, state) => ServiceHistoryScreen(
        onBookingSelected: (id) => context.push(
          AppRouteNames.bookingTracking,
          extra: id,
        ),
        onReviewSelected: (data) => context.push(
          AppRouteNames.ratingReview,
          extra: data,
        ),
        onBack: () => context.pop(),
      ),
    ),

    // 12. Post-Job Rating & Review
    GoRoute(
      path: AppRouteNames.ratingReview,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        if (data == null) {
          return const Scaffold(
            body: Center(child: Text('Review information is unavailable.')),
          );
        }
        return RatingReviewScreen(
          bookingId: data['bookingId'] as String? ?? '',
          providerId: data['providerId'] as String? ?? '',
          providerName: data['providerName'] as String? ?? 'Provider',
          onSubmitReview: () => context.go(AppRouteNames.customerDashboard),
          onSkip: () => context.go(AppRouteNames.customerDashboard),
        );
      },
    ),

    // 13. Provider â€” Booking Requests
    GoRoute(
      path: AppRouteNames.providerRequests,
      builder: (context, state) => ProviderBookingRequestsScreen(
        onNotificationTap: () => context.push(AppRouteNames.notifications),
        onProviderNavTap: (index) {
          if (index == 1) {
            context.go(AppRouteNames.providerAvailability);
          } else if (index == 2) {
            context.go(AppRouteNames.providerProfileEdit);
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
          } else if (index == 2) {
            context.go(AppRouteNames.providerProfileEdit);
          }
        },
        onBack: () => context.pop(),
      ),
    ),

    GoRoute(
      path: AppRouteNames.providerProfileEdit,
      builder: (context, state) => const ProviderProfileScreen(),
    ),

    // Provider Application Form (Customer → becomes provider)
    GoRoute(
      path: AppRouteNames.providerApplication,
      builder: (context, state) => ProviderApplicationScreen(
        onBack: () => context.pop(),
        onSubmitSuccess: () => context.pop(),
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
