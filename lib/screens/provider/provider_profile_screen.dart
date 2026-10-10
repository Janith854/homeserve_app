import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:homeserve_app/routes/app_router.dart';
import 'package:homeserve_app/services/auth_notifier.dart';
import 'package:homeserve_app/services/provider_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';

class ProviderProfileScreen extends StatefulWidget {
  final String providerId;
  final VoidCallback? onBookNow;
  final VoidCallback? onBack;

  const ProviderProfileScreen({
    super.key,
    this.providerId = '',
    this.onBookNow,
    this.onBack,
  });

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _service = TextEditingController();
  final _experience = TextEditingController();
  final _description = TextEditingController();
  final _areas = TextEditingController();
  final _price = TextEditingController();
  final _imageUrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  bool _isEditing = false;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _service, _experience, _description, _areas, _price, _imageUrl]) {
      controller.dispose();
    }
    super.dispose();
  }

  ImageProvider? _getProfileImage(String url) {
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

  Future<void> _pickImage() async {
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
        setState(() {
          _imageUrl.text = base64String;
        });
        if (_name.text.trim().isNotEmpty && _phone.text.trim().isNotEmpty && _service.text.trim().isNotEmpty) {
          await _save();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: ProviderService.instance.watchProviderProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Could not load profile: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          _load(snapshot.data!.data() ?? {});
          final hasImage = _imageUrl.text.trim().isNotEmpty;
          final imageProvider = _getProfileImage(_imageUrl.text);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: imageProvider,
                            child: !hasImage
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo_outlined, size: 28, color: AppColors.primary),
                                      SizedBox(height: 4),
                                      Text(
                                        'No Photo',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (_isEditing) ...[
                      if (hasImage)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _pickImage,
                              child: const Text('Change Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _imageUrl.text = '';
                                });
                              },
                              child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                            ),
                          ],
                        )
                      else
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text('Upload Photo', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _field(_name, 'Name'),
              _field(_phone, 'Phone', keyboardType: TextInputType.phone),
              _field(_service, 'Service type'),
              _field(_experience, 'Experience'),
              _field(_description, 'Description', maxLines: 4),
              _field(_areas, 'Available areas (comma separated)'),
              _field(_price, 'Price (Rs.)', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              if (_isEditing)
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving...' : 'Save profile'),
                )
              else
                FilledButton.icon(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                ),
              const SizedBox(height: 16),
              const Text('Role, verification status, and account status are managed by administrators.'),
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
                onPressed: () => _confirmDeleteAccount(context, widget.providerId),
                child: const Text('Delete Account'),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: !_isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !_isEditing,
          fillColor: _isEditing ? null : AppColors.surface,
        ),
      ),
    );
  }

  void _load(Map<String, dynamic> data) {
    if (_loaded) return;
    _name.text = data['name']?.toString() ?? '';
    _phone.text = data['phone']?.toString() ?? '';
    _service.text = data['serviceType']?.toString() ?? '';
    _experience.text = data['experience']?.toString() ?? '';
    _description.text = data['description']?.toString() ?? '';
    _areas.text = List<String>.from(data['availableAreas'] ?? const <String>[]).join(', ');
    _price.text = data['price']?.toString() ?? '';
    _imageUrl.text = data['profileImageUrl']?.toString() ?? '';
    _loaded = true;
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _phone.text.trim().isEmpty || _service.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name, phone, and service type are required.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ProviderService.instance.updateProfile(
        name: _name.text,
        phone: _phone.text,
        serviceType: _service.text,
        experience: _experience.text,
        description: _description.text,
        availableAreas: _areas.text.split(',').map((area) => area.trim()).where((area) => area.isNotEmpty).toList(),
        price: _price.text,
        profileImageUrl: _imageUrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved.')));
        setState(() => _isEditing = false);
      }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save profile: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, String providerId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account?'),
          content: const Text('Are you sure you want to permanently delete your provider account? This action cannot be undone.'),
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
      if (user == null) throw Exception('Not authenticated');

      // Check active bookings
      final bookingsSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: providerId)
          .where('status', whereIn: ['pending', 'confirmed', 'in_progress', 'in progress'])
          .get();

      if (bookingsSnap.docs.isNotEmpty) {
        if (context.mounted) {
          Navigator.pop(context); // close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have active bookings. Please resolve them before deleting your account.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Update Firestore documents
      await FirebaseFirestore.instance.collection('providers').doc(providerId).update({
        'accountStatus': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      });
      await FirebaseFirestore.instance.collection('users').doc(providerId).update({
        'accountStatus': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
      });
      
      // Delete auth account
      await user.delete();
      
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
}
