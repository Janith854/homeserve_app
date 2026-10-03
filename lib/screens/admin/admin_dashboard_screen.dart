// Admin Dashboard
// Provides navigation to: Provider Verification, Customer Management, Provider Management, Reviews & Complaints, Admin Profile

import 'package:flutter/material.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/routes/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:homeserve_app/services/auth_notifier.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _buildContent(),
      bottomNavigationBar: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: BottomNavigationBar(
          currentIndex: _currentNavIndex,
          onTap: _onNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user),
              label: 'Verify',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Customers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.engineering_outlined),
              activeIcon: Icon(Icons.engineering),
              label: 'Providers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star),
              label: 'Reviews',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: _currentNavIndex,
      children: [
        // 0. Provider Verification
        _buildVerificationTab(),
        // 1. Customer Management
        _buildCustomerManagementTab(),
        // 2. Provider Management
        _buildProviderManagementTab(),
        // 3. Reviews & Complaints
        _buildReviewsTab(),
        // 4. Admin Profile
        _buildProfileTab(),
      ],
    );
  }

  Widget _buildVerificationTab() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Provider Verification',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              _buildStatCard('Total Providers', '340'),
              const SizedBox(height: 12),
              _buildStatCard('Pending Verification', '18'),
              const SizedBox(height: 24),
              Text(
                'Pending Applications',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildVerificationCard(
                name: 'Chamara Bandara',
                details: 'Electrical · NIC + Certificate uploaded',
              ),
              const SizedBox(height: 12),
              _buildVerificationCard(
                name: 'Priyanka Jayasuriya',
                details: 'Cleaning · Documents pending',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCard({
    required String name,
    required String details,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(details, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Review'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Approve', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerManagementTab() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Customer Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              _buildStatCard('Total Customers', '1,245'),
              const SizedBox(height: 12),
              _buildStatCard('Active Users', '980'),
              const SizedBox(height: 24),
              Text(
                'Recent Customers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildCustomerCard(
                name: 'Nimasha Perera',
                email: 'nimasha@email.com',
                bookings: 5,
              ),
              const SizedBox(height: 12),
              _buildCustomerCard(
                name: 'Suresh Kumara',
                email: 'suresh@email.com',
                bookings: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerCard({
    required String name,
    required String email,
    required int bookings,
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
            Text(name, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(email, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('Bookings: $bookings', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderManagementTab() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Provider Management',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              _buildStatCard('Total Providers', '340'),
              const SizedBox(height: 12),
              _buildStatCard('Approved Providers', '310'),
              const SizedBox(height: 24),
              Text(
                'Active Providers',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildProviderCard(
                name: 'Chamara Bandara',
                service: 'Electrical',
                status: 'Approved',
              ),
              const SizedBox(height: 12),
              _buildProviderCard(
                name: 'Priyanka Jayasuriya',
                service: 'Cleaning',
                status: 'Approved',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required String name,
    required String service,
    required String status,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleSmall),
                Text(service, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reviews & Complaints',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              _buildStatCard('Total Reviews', '2,145'),
              const SizedBox(height: 12),
              _buildStatCard('Pending Complaints', '8'),
              const SizedBox(height: 24),
              Text(
                'Recent Reviews',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildReviewCard(
                customer: 'Nimasha Perera',
                provider: 'Chamara Bandara',
                rating: 5,
                comment: 'Excellent service and very professional',
              ),
              const SizedBox(height: 12),
              _buildReviewCard(
                customer: 'Suresh Kumara',
                provider: 'Priyanka Jayasuriya',
                rating: 4,
                comment: 'Good work but a bit late',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String customer,
    required String provider,
    required int rating,
    required String comment,
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
            Text(customer, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('Provider: $provider', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('★' * rating, style: const TextStyle(color: Colors.orange, fontSize: 14)),
            const SizedBox(height: 4),
            Text(comment, style: Theme.of(context).textTheme.bodySmall),
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
                'Admin Profile',
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
                      child: const Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userModel?.fullName ?? 'Admin',
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
              _buildProfileInfoCard(label: 'Role', value: 'Administrator'),
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
