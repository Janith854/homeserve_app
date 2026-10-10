// Customer Dashboard
// Provides navigation to: Home/Search, Bookings, Notifications, Profile

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/routes/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:homeserve_app/services/auth_notifier.dart';
import 'package:homeserve_app/services/notification_service.dart';
import 'package:homeserve_app/services/booking_service.dart';
import 'package:homeserve_app/services/provider_application_service.dart';
import 'package:homeserve_app/screens/home/home_search_screen.dart';
import 'package:homeserve_app/screens/notifications/notifications_screen.dart';
import 'package:homeserve_app/widgets/widgets.dart';

class CustomerDashboardScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onEmergencyBookingTap;
  final ValueChanged<String>? onProviderTap;
  final VoidCallback? onFilterTap;

  const CustomerDashboardScreen({
    super.key,
    this.onNotificationTap,
    this.onEmergencyBookingTap,
    this.onProviderTap,
    this.onFilterTap,
  });

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: _buildNotificationIcon(Icons.notifications_none_outlined),
            activeIcon: _buildNotificationIcon(Icons.notifications),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: _currentNavIndex,
      children: [
        // 0. Home/Search
        _buildHomeTab(),
        // 1. Bookings
        _buildBookingsTab(),
        // 2. Notifications
        _buildNotificationsTab(),
        // 3. Profile
        _buildProfileTab(),
      ],
    );
  }

  Widget _buildHomeTab() {
    return HomeSearchScreen(
      onNotificationTap: widget.onNotificationTap,
      onEmergencyBookingTap: widget.onEmergencyBookingTap,
      onProviderTap: widget.onProviderTap,
      onFilterTap: widget.onFilterTap,
      onNavTap: (index) {
        if (index == 1) {
          context.push(AppRouteNames.serviceHistory);
        } else if (index == 2) {
          context.push(AppRouteNames.notifications);
        }
      },
    );
  }

  Widget _buildBookingsTab() {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: BookingService.instance.watchCustomerBookings(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load bookings: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!.docs;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('My Bookings', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              if (bookings.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No bookings yet.')))
              else
                ...bookings.map((doc) {
                  final data = doc.data();
                  return Card(
                    child: ListTile(
                      title: Text(data['serviceName']?.toString() ?? 'Service'),
                      subtitle: Text('${data['providerName'] ?? 'Provider'}\n${data['date'] ?? ''} · ${data['time'] ?? ''}'),
                      isThreeLine: true,
                      trailing: StatusBadge(status: data['status']?.toString() ?? 'pending'),
                      onTap: () => context.push(AppRouteNames.bookingTracking, extra: doc.id),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return const NotificationsScreen();
  }

  Widget _buildProfileTab() {
    final userModel = authNotifier.userModel;
    return StreamBuilder<String>(
      stream: ProviderApplicationService.instance.watchProviderStatus(),
      builder: (context, snapshot) {
        final providerStatus = snapshot.data ?? userModel?.providerStatus ?? 'none';
        return SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'My Profile',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: const Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userModel?.fullName ?? 'User',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          userModel?.email ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Profile Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileInfoCard(label: 'Phone', value: userModel?.phone ?? 'N/A'),
                  const SizedBox(height: 12),
                  _buildProfileInfoCard(label: 'Email', value: userModel?.email ?? 'N/A'),
                  const SizedBox(height: 24),

                  // ── Become a Service Provider section ──────────────────
                  _buildProviderSection(providerStatus),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      await authNotifier.logout();
                      router.go(AppRouteNames.login);
                    },
                    child: const Text('Logout', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _confirmDeleteAccount(context),
                    child: const Text('Delete Account'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProviderSection(String providerStatus) {
    if (providerStatus == 'approved') {
      // Already an approved provider
      return Card(
        color: const Color(0xFFE8F5E9),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.verified, color: Color(0xFF2E7D32), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Provider Approved',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your provider account is active.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4CAF50)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (providerStatus == 'pending') {
      // Application pending review
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: AppColors.severityMedBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.accent, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_rounded, color: AppColors.accent, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Pending',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8A5A10),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your application is under review. We\'ll notify you soon.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF8A5A10)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            label: const Text(
              'Edit Application',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () => context.push(AppRouteNames.providerApplication),
          ),
        ],
      );
    }

    // 'none' or 'rejected' — show the apply button
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (providerStatus == 'rejected') ...[
          Card(
            color: const Color(0xFFFBEAEA),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.danger, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Your previous application was not approved. '
                      'You may apply again.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A2F2F)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.build_outlined, color: Colors.white),
          label: const Text(
            'Become a Service Provider',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => context.push(AppRouteNames.providerApplication),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard({required String label, required String value}) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(value, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
  }

  Future<void> logout() async {
    await authNotifier.logout();
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update Firestore first
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'accountStatus': 'deleted',
          'deletedAt': FieldValue.serverTimestamp(),
        });
        
        // Try to delete auth account (may require reauthentication)
        await user.delete();
      }
      
      await authNotifier.logout();
      if (context.mounted) {
        Navigator.pop(context); // close loading
        context.go(AppRouteNames.login);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not delete account. You may need to log in again first. Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildNotificationIcon(IconData icon) {
    return StreamBuilder<int>(
      stream: NotificationService.instance.watchUnreadCount(),
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon),
            if (unread > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
