import 'dart:async';

import 'package:flutter/material.dart';
import 'package:homeserve_app/models/provider_model.dart';
import 'package:homeserve_app/services/firestore_service.dart';
import 'package:homeserve_app/theme/app_theme.dart';
import 'package:homeserve_app/widgets/widgets.dart';

class HomeSearchScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onEmergencyBookingTap;
  final ValueChanged<String>? onProviderTap;
  final VoidCallback? onFilterTap;
  final ValueChanged<int>? onNavTap;

  const HomeSearchScreen({
    super.key,
    this.onNotificationTap,
    this.onEmergencyBookingTap,
    this.onProviderTap,
    this.onFilterTap,
    this.onNavTap,
  });

  @override
  State<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends State<HomeSearchScreen> {
  // ── Navigation ──────────────────────────────────────────────
  int _selectedCategoryIndex = 0; // 0 = "All"

  // ── Search ───────────────────────────────────────────────────
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  // ── Category chips (index 0 = "All", maps to null filter) ───
  final List<String> _categories = [
    'All',
    'Plumbing',
    'Electrical',
    'Cleaning',
  ];

  // ── Firestore stream ─────────────────────────────────────────
  // The stream is kept in state and rebuilt when the active
  // category changes so we minimise unnecessary Firestore reads.
  late Stream<List<ProviderModel>> _providersStream;

  @override
  void initState() {
    super.initState();
    _providersStream = _buildStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────

  String? get _activeCategory {
    final cat = _categories[_selectedCategoryIndex];
    return cat == 'All' ? null : cat;
  }

  Stream<List<ProviderModel>> _buildStream() {
    return FirestoreService.instance
        .watchProvidersByCategory(_activeCategory);
  }

  void _onCategoryTap(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _searchQuery = '';
      _searchController.clear();
      _providersStream = _buildStream();
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _searchQuery = value.trim());
    });
  }

  /// Client-side filter on the stream snapshot so we can combine
  /// a category filter (server-side) with a search query (client-side)
  /// without needing a composite Firestore index.
  List<ProviderModel> _applySearch(List<ProviderModel> providers) {
    if (_searchQuery.isEmpty) return providers;
    final q = _searchQuery.toLowerCase();
    return providers
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q))
        .toList();
  }

  // ── Icon mapping for category (no photoUrl yet) ──────────────
  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'electrical':
        return Icons.bolt_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'plumbing':
      default:
        return Icons.build_rounded;
    }
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl + 2, // 14 px
                  vertical: AppSpacing.xxl + 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Top App Bar ─────────────────────────────
                    AppBarWithIcon(
                      title: 'HomeServe',
                      leadingIcon: Icons.menu_rounded,
                      trailingIcon: Icons.notifications_none_rounded,
                      showBadge: true,
                      onLeadingPressed: () {},
                      onTrailingPressed: widget.onNotificationTap ?? () {},
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Search Bar ──────────────────────────────
                    SearchBarWidget(
                      controller: _searchController,
                      hintText: 'Search service or area...',
                      onTap: widget.onFilterTap ?? () {},
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Category Chips ──────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_categories.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.md),
                            child: ChipFilter(
                              label: _categories[index],
                              isActive: _selectedCategoryIndex == index,
                              onTap: () => _onCategoryTap(index),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Emergency Booking ───────────────────────
                    DangerButton(
                      label: 'Emergency Booking',
                      icon: Icons.warning_amber_rounded,
                      isOutline: true,
                      onPressed: widget.onEmergencyBookingTap ?? () {},
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Section Title ───────────────────────────
                    Text(
                      'Nearby Providers',
                      style: AppTextStyles.meta.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Live Provider List ──────────────────────
                    StreamBuilder<List<ProviderModel>>(
                      stream: _providersStream,
                      builder: (context, snapshot) {
                        // ── Loading state ───────────────────────
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const _ProviderListLoading();
                        }

                        // ── Error state ─────────────────────────
                        if (snapshot.hasError) {
                          return _ErrorState(
                            message: snapshot.error.toString(),
                          );
                        }

                        final allProviders = snapshot.data ?? [];
                        final providers = _applySearch(allProviders);

                        // ── Empty state ─────────────────────────
                        if (providers.isEmpty) {
                          return _EmptyState(
                            searchQuery: _searchQuery,
                            category: _activeCategory,
                          );
                        }

                        // ── Provider cards ──────────────────────
                        return Column(
                          children: providers.map((provider) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.xl),
                              child: _ProviderCard(
                                provider: provider,
                                icon: _iconForCategory(provider.category),
                                onTap: () {
                                  widget.onProviderTap?.call(provider.id);
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE HELPER WIDGETS
// (Scoped to this file — no UI layout change, same card design as before)
// ─────────────────────────────────────────────────────────────────────────────

/// Individual provider card — replaces the inline anonymous Container.
/// Uses the same decoration/layout as the original placeholder cards.
class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  final IconData icon;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.provider,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            // Photo: use network image if photoUrl present, else placeholder
            _ProviderPhoto(
              photoUrl: provider.photoUrl,
              fallbackIcon: icon,
            ),
            const SizedBox(width: AppSpacing.xxl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + verified badge on same row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          style: AppTextStyles.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (provider.verified) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const _VerifiedBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  RatingStars(
                    rating: provider.rating,
                    size: AppIconSize.star,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    provider.formattedPrice.isNotEmpty
                        ? '${provider.formattedPrice} · ${provider.category}'
                        : provider.category,
                    style: AppTextStyles.price,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    provider.location,
                    style: AppTextStyles.meta,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a network image when [photoUrl] is available, falls back to the
/// same gradient PhotoPlaceholder that was used with the old placeholder data.
class _ProviderPhoto extends StatelessWidget {
  final String? photoUrl;
  final IconData fallbackIcon;

  const _ProviderPhoto({this.photoUrl, required this.fallbackIcon});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.btnSmall),
        child: Image.network(
          photoUrl!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() => PhotoPlaceholder(
        width: 48,
        height: 48,
        icon: fallbackIcon,
      );
}

/// Small "Verified" chip — shown only when provider.verified == true.
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: AppIconSize.badgeVerified,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 2),
          Text('Verified', style: AppTextStyles.badgeVerified),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING  /  EMPTY  /  ERROR  STATES
// ─────────────────────────────────────────────────────────────────────────────

/// Three shimmer-like skeleton cards while the first snapshot loads.
class _ProviderListLoading extends StatelessWidget {
  const _ProviderListLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => const _SkeletonCard()),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          children: [
            _shimmerBox(width: 48, height: 48, radius: AppRadius.btnSmall),
            const SizedBox(width: AppSpacing.xxl),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _shimmerBox(height: 11, width: 120),
                  _shimmerBox(height: 9, width: 80),
                  _shimmerBox(height: 9, width: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(
      {required double height, required double width, double radius = 4}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Shown when Firestore returns 0 documents (or the search yields no matches).
class _EmptyState extends StatelessWidget {
  final String searchQuery;
  final String? category;

  const _EmptyState({required this.searchQuery, this.category});

  @override
  Widget build(BuildContext context) {
    final isSearch = searchQuery.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x7l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearch ? Icons.search_off_rounded : Icons.handyman_outlined,
            size: 48,
            color: AppColors.muted,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            isSearch
                ? 'No providers found for "$searchQuery"'
                : category != null
                    ? 'No $category providers available yet'
                    : 'No providers available yet',
            style: AppTextStyles.meta.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isSearch
                ? 'Try a different keyword or clear the search.'
                : 'Check back soon — providers are being added.',
            style: AppTextStyles.meta,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Shown when the Firestore stream emits an error.
class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x7l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.danger),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Could not load providers',
            style: AppTextStyles.meta.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Check your connection and try again.',
            style: AppTextStyles.meta,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
