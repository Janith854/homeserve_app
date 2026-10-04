// Admin Dashboard
// Provides navigation to: Provider Verification, Customer Management, Provider Management, Reviews & Complaints, Admin Profile

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/routes/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:homeserve_app/services/auth_notifier.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homeserve_app/services/admin_user_service.dart';
import 'package:homeserve_app/screens/admin/admin_verification_screen.dart';
import 'package:homeserve_app/screens/admin/admin_reviews_screen.dart';

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

      // FIX:
      // BottomNavigationBar must NOT be inside
      // SingleChildScrollView because it causes
      // unbounded width constraints.
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }

  Widget _buildContent() {
    return IndexedStack(
      index: _currentNavIndex,
      children: [
        // 0. Provider Verification
        AdminVerificationScreen(
          onAdminNavTap: (index) {
            if (index == 3) {
              setState(() => _currentNavIndex = 3);
            }
          },
        ),

        // 1. Customer Management
        _buildCustomerManagementTab(),

        // 2. Provider Management
        _buildProviderManagementTab(),

        // 3. Reviews & Complaints
        AdminReviewsScreen(
          onAdminNavTap: (index) {
            if (index == 0) {
              setState(() => _currentNavIndex = 0);
            }
          },
        ),

        // 4. Admin Profile
        _buildProfileTab(),
      ],
    );
  }

  Widget _buildCustomerManagementTab() {
    return _UserManagementTab(
      title: 'Customer Management',
      stream: AdminUserService.instance.watchCustomers(),
      isProvider: false,
      onEdit: (data) => _editCustomer(data),
    );
  }

  Widget _buildProviderManagementTab() {
    return _UserManagementTab(
      title: 'Provider Management',
      stream: AdminUserService.instance.watchApprovedProviders(),
      isProvider: true,
      onEdit: (data) => _editProvider(data),
    );
  }

  Future<void> _editCustomer(Map<String, dynamic> data) async {
    final name = TextEditingController(
      text: data['fullName']?.toString() ?? '',
    );

    final phone = TextEditingController(text: data['phone']?.toString() ?? '');

    var status = data['accountStatus']?.toString() ?? 'active';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Customer profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(data['email']?.toString() ?? ''),
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              TextField(
                controller: phone,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              DropdownButton<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(
                    value: 'suspended',
                    child: Text('Suspended'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => status = value ?? status);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await AdminUserService.instance.updateCustomer(
                  userId: data['id']?.toString() ?? '',
                  fullName: name.text,
                  phone: phone.text,
                  accountStatus: status,
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    name.dispose();
    phone.dispose();
  }

  Future<void> _editProvider(Map<String, dynamic> data) async {
    final name = TextEditingController(text: data['name']?.toString() ?? '');
    final phone = TextEditingController(text: data['phone']?.toString() ?? '');
    final service = TextEditingController(
      text: data['serviceType']?.toString() ?? '',
    );
    final experience = TextEditingController(
      text: data['experience']?.toString() ?? '',
    );
    final description = TextEditingController(
      text: data['description']?.toString() ?? '',
    );
    final price = TextEditingController(
      text: data['price']?.toString() ?? '',
    );
    final imageUrl = TextEditingController(
      text: data['profileImageUrl']?.toString() ?? '',
    );

    var status = data['accountStatus']?.toString() ?? 'active';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          ImageProvider? getProfileImage(String url) {
            final trimmed = url.trim();
            if (trimmed.isEmpty) return null;
            if (trimmed.startsWith('data:image')) {
              try {
                final base64Data = trimmed.split(',').last;
                return MemoryImage(base64Decode(base64Data));
              } catch (_) {
                return null;
              }
            }
            return NetworkImage(trimmed);
          }

          Future<void> pickImage() async {
            try {
              final picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
                maxWidth: 600,
                maxHeight: 600,
                imageQuality: 80,
              );
              if (image != null) {
                final bytes = await image.readAsBytes();
                final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                setDialogState(() {
                  imageUrl.text = base64String;
                });
              }
            } catch (e) {
              if (dialogContext.mounted) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Could not pick image: $e')),
                );
              }
            }
          }

          final hasImage = imageUrl.text.trim().isNotEmpty;
          final imageProvider = getProfileImage(imageUrl.text);

          return AlertDialog(
            title: const Text('Provider profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: imageProvider,
                      child: !hasImage
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_a_photo_outlined, size: 22, color: AppColors.primary),
                                SizedBox(height: 2),
                                Text(
                                  'Upload Photo',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  if (hasImage)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: pickImage,
                          child: const Text('Change Photo'),
                        ),
                        TextButton(
                          onPressed: () {
                            setDialogState(() {
                              imageUrl.text = '';
                            });
                          },
                          child: const Text('Remove', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    )
                  else
                    TextButton(
                      onPressed: pickImage,
                      child: const Text('Upload Photo'),
                    ),
                  Text(data['email']?.toString() ?? ''),
                  Text(
                    'Verification: ${data['verificationStatus'] ?? 'approved'}',
                  ),
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  TextField(
                    controller: service,
                    decoration: const InputDecoration(labelText: 'Service type'),
                  ),
                  TextField(
                    controller: experience,
                    decoration: const InputDecoration(labelText: 'Experience'),
                  ),
                  TextField(
                    controller: description,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: price,
                    decoration: const InputDecoration(labelText: 'Price / Rate'),
                  ),
                  DropdownButton<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'suspended',
                        child: Text('Suspended'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() => status = value ?? status);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  await AdminUserService.instance.updateProvider(
                    providerId: data['id']?.toString() ?? '',
                    name: name.text,
                    phone: phone.text,
                    serviceType: service.text,
                    experience: experience.text,
                    description: description.text,
                    availableAreas: List<String>.from(
                      data['availableAreas'] ?? const [],
                    ),
                    accountStatus: status,
                    price: price.text,
                    profileImageUrl: imageUrl.text,
                  );

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    for (final controller in [name, phone, service, experience, description, price, imageUrl]) {
      controller.dispose();
    }
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
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 40,
                        color: Colors.white,
                      ),
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

              _buildProfileInfoCard(
                label: 'Phone',
                value: userModel?.phone ?? 'N/A',
              ),

              const SizedBox(height: 12),

              _buildProfileInfoCard(
                label: 'Email',
                value: userModel?.email ?? 'N/A',
              ),

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

                  if (mounted) {
                    context.go(AppRouteNames.login);
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
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

class _UserManagementTab extends StatefulWidget {
  final String title;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final bool isProvider;
  final ValueChanged<Map<String, dynamic>> onEdit;

  const _UserManagementTab({
    required this.title,
    required this.stream,
    required this.isProvider,
    required this.onEdit,
  });

  @override
  State<_UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<_UserManagementTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: widget.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Could not load users: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data!.docs
              .map((doc) {
                return <String, dynamic>{'id': doc.id, ...doc.data()};
              })
              .where((data) {
                final query = _query.trim().toLowerCase();

                if (query.isEmpty) {
                  return true;
                }

                return [
                  data['fullName'],
                  data['name'],
                  data['email'],
                  data['serviceType'],
                  data['phone'],
                ].any(
                  (value) =>
                      value?.toString().toLowerCase().contains(query) == true,
                );
              })
              .toList();

          final activeCount = records
              .where((data) => data['accountStatus'] != 'suspended')
              .length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name, email, phone, or service',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total: ${snapshot.data!.docs.length}'),
                    Text('Active: $activeCount'),
                  ],
                ),
              ),

              Expanded(
                child: records.isEmpty
                    ? const Center(child: Text('No matching users.'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: records.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final data = records[index];

                          final name =
                              (data['fullName'] ??
                                      data['name'] ??
                                      'Unnamed user')
                                  .toString();

                          final status = (data['accountStatus'] ?? 'active')
                              .toString();

                          return Card(
                            child: ListTile(
                              title: Text(name),
                              subtitle: Text(
                                widget.isProvider
                                    ? '${data['serviceType'] ?? 'Service'} · ${data['email'] ?? ''}'
                                    : '${data['email'] ?? ''}\n${data['phone'] ?? ''}',
                              ),
                              isThreeLine: !widget.isProvider,
                              trailing: Chip(
                                label: Text(status),
                                backgroundColor: status == 'suspended'
                                    ? Colors.red.shade100
                                    : Colors.green.shade100,
                              ),
                              onTap: () => widget.onEdit(data),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
