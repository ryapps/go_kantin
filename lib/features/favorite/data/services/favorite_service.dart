import 'package:hive_flutter/hive_flutter.dart';
import 'package:kantin_app/features/favorite/data/models/favorite_stan_model.dart';

class FavoriteService {
  static const String _boxName = 'favorites';
  Box<FavoriteStanModel>? _box;

  /// Initialize Hive and open box
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FavoriteStanModelAdapter());
    }

    _box = await Hive.openBox<FavoriteStanModel>(_boxName);
  }

  /// Get all favorites
  List<FavoriteStanModel> getAllFavorites() {
    if (_box == null) throw Exception('Hive box not initialized');
    return _box!.values.toList();
  }

  /// Add to favorites
  Future<void> addFavorite(FavoriteStanModel favorite) async {
    if (_box == null) throw Exception('Hive box not initialized');
    await _box!.put(favorite.id, favorite);
  }

  /// Remove from favorites
  Future<void> removeFavorite(String stanId) async {
    if (_box == null) throw Exception('Hive box not initialized');
    await _box!.delete(stanId);
  }

  /// Check if stan is favorite
  bool isFavorite(String stanId) {
    if (_box == null) throw Exception('Hive box not initialized');
    return _box!.containsKey(stanId);
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(FavoriteStanModel favorite) async {
    if (_box == null) throw Exception('Hive box not initialized');

    if (isFavorite(favorite.id)) {
      await removeFavorite(favorite.id);
      return false; // removed
    } else {
      await addFavorite(favorite);
      return true; // added
    }
  }

  /// Clear all favorites
  Future<void> clearAll() async {
    if (_box == null) throw Exception('Hive box not initialized');
    await _box!.clear();
  }

  /// Get favorite count
  int getFavoriteCount() {
    if (_box == null) throw Exception('Hive box not initialized');
    return _box!.length;
  }

  /// Close box
  Future<void> close() async {
    await _box?.close();
  }
}
