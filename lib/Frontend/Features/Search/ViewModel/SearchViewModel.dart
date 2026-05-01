import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import '../Model/NearbyGigModel.dart';
import '../Repository/SearchRepo.dart';

/// Holds the current search parameters and results.
class SearchState {
  final double radiusKm;
  final String searchQuery;
  final String category;
  final NearbyGigSearchResponse? response;
  final bool isLoading;
  final String? error;

  const SearchState({
    this.radiusKm = 10,
    this.searchQuery = '',
    this.category = '',
    this.response,
    this.isLoading = false,
    this.error,
  });

  /// Helper to get just the gig items.
  List<NearbyGigModel> get gigs => response?.items ?? [];

  /// Creates a copy with some fields changed.
  SearchState copyWith({
    double? radiusKm,
    String? searchQuery,
    String? category,
    NearbyGigSearchResponse? response,
    bool? isLoading,
    String? error,
  }) {
    return SearchState(
      radiusKm: radiusKm ?? this.radiusKm,
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      response: response ?? this.response,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Riverpod provider for the search screen.
final searchProvider = StateNotifierProvider<SearchViewModel, SearchState>((
  ref,
) {
  return SearchViewModel();
});

class SearchViewModel extends StateNotifier<SearchState> {
  final _repo = SearchRepository();
  Timer? _debounce;

  // Store the user's GPS coordinates so every search uses them
  double? _latitude;
  double? _longitude;

  SearchViewModel() : super(const SearchState());

  /// Saves the user's GPS coordinates and triggers a search.
  Future<void> initWithLocation(double latitude, double longitude) async {
    _latitude = latitude;
    _longitude = longitude;

    // Also save to backend in the background (for other features)
    // but don't wait for it or block on failure
    _repo.updateUserLocation(longitude: longitude, latitude: latitude);

    // Run the search with coordinates sent directly
    await search();
  }

  /// Runs a search with the current filters.
  /// Sends GPS coordinates directly in the query so the backend
  /// never needs to look up the user document for location.
  Future<void> search() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repo.searchNearbyGigs(
        radiusKm: state.radiusKm,
        search: state.searchQuery,
        category: state.category,
        latitude: _latitude,
        longitude: _longitude,
      );
      state = state.copyWith(response: response, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Updates the search radius and triggers a new search.
  void setRadius(double km) {
    state = state.copyWith(radiusKm: km);

    // Debounce so we don't spam the backend while the slider moves
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      search();
    });
  }

  /// Updates the text search query and triggers a new search.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      search();
    });
  }

  /// Updates the category filter and triggers a new search.
  void setCategory(String category) {
    state = state.copyWith(category: category);
    search();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
