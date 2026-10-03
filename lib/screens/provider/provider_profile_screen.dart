import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/services/provider_service.dart';

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
  final _imageUrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [_name, _phone, _service, _experience, _description, _areas, _imageUrl]) {
      controller.dispose();
    }
    super.dispose();
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_imageUrl.text.isNotEmpty)
                Center(child: CircleAvatar(radius: 42, backgroundImage: NetworkImage(_imageUrl.text))),
              _field(_name, 'Name'),
              _field(_phone, 'Phone', keyboardType: TextInputType.phone),
              _field(_service, 'Service type'),
              _field(_experience, 'Experience'),
              _field(_description, 'Description', maxLines: 4),
              _field(_areas, 'Available areas (comma separated)'),
              _field(_imageUrl, 'Profile image URL'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save profile'),
              ),
              const SizedBox(height: 16),
              const Text('Role, verification status, and account status are managed by administrators.'),
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
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
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
        profileImageUrl: _imageUrl.text,
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save profile: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
