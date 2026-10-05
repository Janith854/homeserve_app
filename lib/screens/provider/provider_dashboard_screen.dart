// Provider Dashboard
// Provides navigation to: Booking Requests, Availability, Provider Profile

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/screens/provider/provider_booking_requests_screen.dart';
import 'package:homeserve_app/screens/provider/provider_availability_screen.dart';
import 'package:homeserve_app/screens/provider/provider_profile_screen.dart';

import 'package:homeserve_app/screens/notifications/notifications_screen.dart';
import 'package:homeserve_app/services/notification_service.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
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
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Requests',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Availability',
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
        ProviderBookingRequestsScreen(onProviderNavTap: _onNavTap),
        ProviderAvailabilityScreen(onProviderNavTap: _onNavTap),
        const NotificationsScreen(),
        const ProviderProfileScreen(),
      ],
    );
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
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
