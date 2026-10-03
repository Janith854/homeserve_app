// Customer Dashboard
// Provides navigation to: Home/Search, Bookings, Notifications, Profile

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/routes/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:homeserve_app/services/auth_notifier.dart';
import 'package:homeserve_app/services/notification_service.dart';
import 'package:homeserve_app/services/booking_service.dart';

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
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
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.bolt,
                      label: 'Emergency',
                      onTap: () {
                        context.push(AppRouteNames.emergencyBooking);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.search,
                      label: 'Search',
                      onTap: () {
                        context.push(AppRouteNames.filter);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Browse Services
              Text(
                'Browse Services',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildServiceGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    final services = ['Plumbing', 'Electrical', 'Cleaning', 'Carpentry'];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: services
          .map((service) => Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(service, style: Theme.of(context).textTheme.labelMedium),
                ),
              ))
          .toList(),
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
                      subtitle: Text('${data['date'] ?? ''} · ${data['time'] ?? ''}'),
                      trailing: Text(data['status']?.toString() ?? 'pending'),
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
    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: NotificationService.instance.watchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load notifications: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = [...snapshot.data!.docs]
            ..sort((a, b) => _notificationDate(b).compareTo(_notificationDate(a)));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: Text('Notifications', style: Theme.of(context).textTheme.headlineMedium)),
                  TextButton(
                    onPressed: () => NotificationService.instance.markAllAsRead(snapshot.data!),
                    child: const Text('Read all'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No notifications yet.')))
              else
                ...items.map((doc) {
                  final data = doc.data();
                  final unread = data['isRead'] != true;
                  return Card(
                    child: ListTile(
                      title: Text(data['title']?.toString() ?? 'Notification', style: unread ? const TextStyle(fontWeight: FontWeight.bold) : null),
                      subtitle: Text(data['message']?.toString() ?? ''),
                      onTap: () => NotificationService.instance.markAsRead(doc.id),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  DateTime _notificationDate(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final value = doc.data()['createdAt'];
    return value is Timestamp ? value.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required String time,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(message, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    final userModel = authNotifier.userModel;
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  await authNotifier.logout();
                  if (context.mounted) {
                    context.go(AppRouteNames.login);
                  }
                },
                child: const Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
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
}
