// Provider Application Form Screen
// Allows a customer to apply to become a service provider.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:homeserve_app/services/provider_application_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';

class ProviderApplicationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSubmitSuccess;

  const ProviderApplicationScreen({
    super.key,
    this.onBack,
    this.onSubmitSuccess,
  });

  @override
  State<ProviderApplicationScreen> createState() =>
      _ProviderApplicationScreenState();
}

class _ProviderApplicationScreenState
    extends State<ProviderApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areasController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _selectedServiceType;

  bool _isSubmitting = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingApplication();
  }

  Future<void> _loadExistingApplication() async {
    try {
      final existing = await ProviderApplicationService.instance.getPendingApplication();
      if (existing != null && mounted) {
        setState(() {
          _fullNameController.text = existing['name']?.toString() ?? '';
          _phoneController.text = existing['phone']?.toString() ?? '';
          _selectedServiceType = existing['serviceType']?.toString();
          _experienceController.text = existing['experience']?.toString() ?? '';
          _descriptionController.text = existing['description']?.toString() ?? '';
          _areasController.text = (existing['availableAreas'] as List<dynamic>?)?.join(', ') ?? '';
          _priceController.text = existing['price']?.toString() ?? '';
          _imageUrlController.text = existing['profileImageUrl']?.toString() ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading existing application: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          _imageUrlController.text = base64String;
        });
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
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    _areasController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final areas = _areasController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (areas.isEmpty) {
      _showError('Please enter at least one available area.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ProviderApplicationService.instance.submitApplication(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        serviceType: _selectedServiceType ?? '',
        experience: _experienceController.text.trim(),
        description: _descriptionController.text.trim(),
        availableAreas: areas,
        price: _priceController.text.trim(),
        profileImageUrl: _imageUrlController.text.trim(),
      );

      if (mounted) {
        _showSuccess();
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Application Submitted!'),
          ],
        ),
        content: const Text(
          'Your provider application has been submitted successfully. '
          'You will be notified once it has been reviewed.',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onSubmitSuccess?.call();
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Become a Service Provider',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header card
              Card(
                color: AppColors.primaryLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.build, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Provider Application',
                              style: AppTextStyles.h1.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Fill in your details to apply as a service provider.',
                              style: AppTextStyles.field,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Photo
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: _getProfileImage(_imageUrlController.text),
                            child: _imageUrlController.text.trim().isEmpty
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.add_a_photo_outlined, size: 28, color: AppColors.primary),
                                      SizedBox(height: 4),
                                      Text(
                                        'Upload Photo',
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
                    if (_imageUrlController.text.trim().isNotEmpty)
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
                                _imageUrlController.text = '';
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
                ),
              ),
              const SizedBox(height: 20),

              // Full Name
              _buildFieldLabel('Full Name *'),
              _buildTextField(
                controller: _fullNameController,
                hint: 'Enter your full name',
                icon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
              ),
              const SizedBox(height: 16),

              // Phone Number
              _buildFieldLabel('Phone Number *'),
              _buildTextField(
                controller: _phoneController,
                hint: 'e.g. 0771234567',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),

              // Service Type
              _buildFieldLabel('Service Type *'),
              DropdownButtonFormField<String>(
                initialValue: _selectedServiceType,
                hint: Text('Select service type', style: AppTextStyles.field),
                items: ['Plumbing', 'Electrical', 'Cleaning'].map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: AppTextStyles.fieldFilled),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() => _selectedServiceType = v);
                },
                validator: (v) => v == null ? 'Service type is required' : null,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.muted),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.home_repair_service_outlined,
                      color: AppColors.muted, size: 20),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.btn),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.btn),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.btn),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Experience
              _buildFieldLabel('Years of Experience *'),
              _buildTextField(
                controller: _experienceController,
                hint: 'e.g. 3 years',
                icon: Icons.workspace_premium_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Experience is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              _buildFieldLabel('Description *'),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Describe your skills and services...',
                icon: Icons.description_outlined,
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Available Areas
              _buildFieldLabel('Available Areas *'),
              _buildTextField(
                controller: _areasController,
                hint: 'e.g. Colombo, Kandy, Galle (comma-separated)',
                icon: Icons.location_on_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'At least one area is required' : null,
              ),
              const SizedBox(height: 8),
              Text(
                'Separate multiple areas with commas.',
                style: AppTextStyles.meta,
              ),
              const SizedBox(height: 16),

              // Price
              _buildFieldLabel('Price (Rs.) *'),
              _buildTextField(
                controller: _priceController,
                hint: 'e.g. 2500',
                keyboardType: TextInputType.number,
                icon: Icons.payments_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Price is required' : null,
              ),
              const SizedBox(height: 28),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.btn),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save / Update Application',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: AppTextStyles.name),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: AppTextStyles.fieldFilled,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.field,
        prefixIcon: maxLines == 1
            ? Icon(icon, color: AppColors.muted, size: 20)
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: maxLines > 1 ? 14 : 0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.btn),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.btn),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.btn),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.btn),
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.btn),
          borderSide: BorderSide(color: AppColors.danger, width: 1.5),
        ),
      ),
    );
  }
}
