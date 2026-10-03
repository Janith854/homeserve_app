// Provider Dashboard
// Provides navigation to: Booking Requests, Availability, Provider Profile

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/routes/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:homeserve_app/services/auth_notifier.dart';
import 'package:homeserve_app/screens/provider/provider_booking_requests_screen.dart';
import 'package:homeserve_app/screens/provider/provider_availability_screen.dart';
import 'package:homeserve_app/screens/provider/provider_profile_screen.dart';

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Availability',
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
        ProviderBookingRequestsScreen(onProviderNavTap: _onNavTap),
        ProviderAvailabilityScreen(onProviderNavTap: _onNavTap),
        const ProviderProfileScreen(),
      ],
    );
  }

  Widget _buildAvailabilityTab() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Availability',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              _buildAvailabilityCard('Monday', '9:00 AM - 5:00 PM'),
              const SizedBox(height: 12),
              _buildAvailabilityCard('Tuesday', '9:00 AM - 5:00 PM'),
              const SizedBox(height: 12),
              _buildAvailabilityCard('Wednesday', '9:00 AM - 5:00 PM'),
              const SizedBox(height: 12),
              _buildAvailabilityCard('Thursday', '10:00 AM - 6:00 PM'),
              const SizedBox(height: 12),
              _buildAvailabilityCard('Friday', '9:00 AM - 4:00 PM'),
              const SizedBox(height: 12),
              _buildAvailabilityCard('Saturday', 'On-call'),
              const SizedBox(height: 12),
              _buildAvailabilityCard('Sunday', 'Closed'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.push(AppRouteNames.providerAvailability),
                child: const Text('Edit Availability'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard(String day, String hours) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(day, style: Theme.of(context).textTheme.titleSmall),
            Text(hours, style: Theme.of(context).textTheme.bodySmall),
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
                      userModel?.fullName ?? 'Provider',
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
              const SizedBox(height: 12),
              _buildProfileInfoCard(label: 'Status', value: userModel?.providerStatus ?? 'N/A'),
              const SizedBox(height: 12),
              _buildProfileInfoCard(label: 'Rating', value: '4.8 ⭐ (245 reviews)'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to edit profile
                },
                child: const Text('Edit Profile'),
              ),
              const SizedBox(height: 12),
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
