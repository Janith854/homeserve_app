import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homeserve_app/models/provider_model.dart';

/// Thin wrapper around Firestore reads for the "providers" collection.
///
/// All queries are real-time streams so the UI auto-updates whenever
/// a document changes in Firestore.
class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  /// Returns a real-time stream of all providers, ordered by rating desc.
  Stream<List<ProviderModel>> watchProviders() {
    return _db
        .collection('providers')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ProviderModel.fromDoc).toList());
  }

  /// Returns a real-time stream filtered by [category].
  /// Pass null or empty string to get all providers.
  Stream<List<ProviderModel>> watchProvidersByCategory(String? category) {
    if (category == null || category.isEmpty) return watchProviders();

    return _db
        .collection('providers')
        .where('category', isEqualTo: category)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ProviderModel.fromDoc).toList());
  }

  /// Returns a one-time fetch of providers whose name contains [query]
  /// (case-sensitive prefix match — extend with Algolia for full-text).
  Future<List<ProviderModel>> searchProviders(String query) async {
    if (query.isEmpty) {
      final snap = await _db
          .collection('providers')
          .orderBy('rating', descending: true)
          .get();
      return snap.docs.map(ProviderModel.fromDoc).toList();
    }

    // Firestore prefix query trick: name >= query AND name < query + \uf8ff
    final snap = await _db
        .collection('providers')
        .orderBy('name')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .get();
    return snap.docs.map(ProviderModel.fromDoc).toList();
  }
}
