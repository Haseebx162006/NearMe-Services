import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../../Theme/app_colors.dart';
import '../ViewModel/SearchViewModel.dart';
import '../Model/NearbyGigModel.dart';

class CustomerSearchScreen extends ConsumerStatefulWidget {
  const CustomerSearchScreen({super.key});

  @override
  ConsumerState<CustomerSearchScreen> createState() =>
      _CustomerSearchScreenState();
}

class _CustomerSearchScreenState extends ConsumerState<CustomerSearchScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // User's current position (default to Lahore until GPS is loaded)
  LatLng _userPosition = const LatLng(31.5204, 74.3587);
  bool _locationLoaded = false;
  bool _isLocating = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Gets the user's real GPS coordinates from the device hardware.
  Future<void> _initLocation() async {
    try {
      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('️ Please enable GPS/Location services!'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          setState(() => _isLocating = false);
        }
        _searchWithCurrentPosition();
        return;
      }

      // 2. Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('️ Location permission denied'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLocating = false);
          _searchWithCurrentPosition();
          return;
        }
      }
      if (!mounted) return;
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Location permission permanently denied. Enable in Settings.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        setState(() => _isLocating = false);
        _searchWithCurrentPosition();
        return;
      }

      // 3. Try to get CURRENT position from GPS hardware
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 20),
          ),
        );
        debugPrint('[GPS] getCurrentPosition: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        debugPrint('[GPS] getCurrentPosition failed: $e');
        // 4. Fallback: try last known position
        try {
          position = await Geolocator.getLastKnownPosition();
          debugPrint('[GPS] getLastKnownPosition: ${position?.latitude}, ${position?.longitude}');
        } catch (e2) {
          debugPrint('[GPS] getLastKnownPosition also failed: $e2');
        }
      }

      if (!mounted) return;

      if (position != null) {
        setState(() {
          _userPosition = LatLng(position!.latitude, position.longitude);
          _locationLoaded = true;
          _isLocating = false;
        });

        // Move map to the REAL position
        _mapController.move(_userPosition, 14.0);
        debugPrint('[GPS]  Using real GPS: ${position.latitude}, ${position.longitude}');
      } else {
        // GPS completely failed — show warning and use default
        setState(() => _isLocating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('️ Could not detect GPS. Showing default location.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        debugPrint('[GPS]  All GPS methods failed, using default Lahore coords');
      }

      // Search with whatever position we have
      _searchWithCurrentPosition();
    } catch (e) {
      debugPrint('[GPS] Unexpected error: $e');
      if (!mounted) return;
      setState(() => _isLocating = false);
      _searchWithCurrentPosition();
    }
  }

  void _searchWithCurrentPosition() {
    if (!mounted) return;
    ref.read(searchProvider.notifier).initWithLocation(
          _userPosition.latitude,
          _userPosition.longitude,
        );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      body: Stack(
        children: [
          // ─── 1. REAL MAP ───────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _userPosition,
                initialZoom: 14.0,
              ),
              children: [
                // OpenStreetMap tile layer (FREE, no API key)
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nearme.app',
                ),

                // Search radius circle
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _userPosition,
                      radius: searchState.radiusKm * 1000, // meters
                      useRadiusInMeter: true,
                      color: const Color(0xFF4E342E).withOpacity(0.08),
                      borderColor: const Color(0xFF4E342E).withOpacity(0.4),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),

                // Markers layer
                MarkerLayer(
                  markers: [
                    // User's blue dot
                    Marker(
                      point: _userPosition,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A49E2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF4A49E2).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Freelancer gig markers from search results
                    ...searchState.gigs.map((gig) {
                      // We don't have individual freelancer coordinates
                      // from the search response, so we place markers in
                      // a circle around the user based on distance_km.
                      // This is a visual approximation.
                      final markerPos = _estimateGigPosition(gig);
                      final initials = _getInitials(gig.title);

                      return Marker(
                        point: markerPos,
                        width: 50,
                        height: 50,
                        child: GestureDetector(
                          onTap: () => _showGigDetails(gig),
                          child: _buildMapMarker(
                            initials,
                            const Color(0xFF8B5E3C),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),

          // GPS loading overlay
          if (_isLocating)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF4A49E2),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Detecting your location...',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Color(0xFF3E2723),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ─── 2. TOP SEARCH BAR ─────────────────────────────────────
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        ref
                            .read(searchProvider.notifier)
                            .setSearchQuery(value);
                      },
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search,
                            color: AppColors.textHint, size: 20),
                        hintText: 'Search freelancers or skills...',
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _showFilterSheet(),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── 3. RE-CENTER BUTTON ───────────────────────────────────
          Positioned(
            right: 20,
            bottom: 220,
            child: GestureDetector(
              onTap: () {
                setState(() => _isLocating = true);
                _initLocation();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),

          // ─── 4. LOADING INDICATOR ──────────────────────────────────
          if (searchState.isLoading)
            Positioned(
              top: 130,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFBCA073),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Searching nearby...',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ─── 5. ERROR BANNER ────────────────────────────────────────
          if (searchState.error != null)
            Positioned(
              top: 130,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade400, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        searchState.error!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ─── 6. BOTTOM RADIUS SLIDER + RESULTS COUNT ───────────────
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Search Radius',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${searchState.radiusKm.toInt()} km',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFBCA073),
                      inactiveTrackColor: const Color(0xFFF3E5D8),
                      thumbColor: const Color(0xFFBCA073),
                      overlayColor:
                          const Color(0xFFBCA073).withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: searchState.radiusKm,
                      min: 1,
                      max: 1000,
                      onChanged: (val) {
                        ref.read(searchProvider.notifier).setRadius(val);
                        
                        // Automatically adjust map zoom so the circle stays in view
                        // Formula: Zoom level drops by 1 every time radius doubles
                        double targetZoom = 14.5 - (log(val) / ln2);
                        // Clamp between min and max zoom
                        targetZoom = targetZoom.clamp(4.0, 18.0);
                        
                        _mapController.move(_userPosition, targetZoom);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '1km',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.circle,
                              size: 8, color: Color(0xFFBCA073)),
                          const SizedBox(width: 4),
                          Text(
                            '${searchState.response?.uniqueFreelancers ?? 0} freelancers found',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF4E342E),
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        '1000km',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────

  /// Estimates a map position for a gig based on its distance_km.
  /// Since the backend doesn't return individual freelancer coordinates,
  /// we place markers around the user at the correct distance, spread
  /// evenly around a circle.
  LatLng _estimateGigPosition(NearbyGigModel gig) {
    final index = ref.read(searchProvider).gigs.indexOf(gig);
    final totalGigs = ref.read(searchProvider).gigs.length;

    // Spread markers evenly in a circle
    final angle = (index / totalGigs) * 2 * 3.14159;
    final distanceDeg =
        gig.distanceKm / 111.0; // rough km-to-degree conversion

    return LatLng(
      _userPosition.latitude + distanceDeg * sin(angle),
      _userPosition.longitude + distanceDeg * cos(angle),
    );
  }

  /// Gets first letters of each word for marker initials.
  String _getInitials(String title) {
    final words = title.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return title.substring(0, title.length >= 2 ? 2 : title.length).toUpperCase();
  }

  /// Shows a bottom sheet with gig details when a marker is tapped.
  void _showGigDetails(NearbyGigModel gig) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title + Distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    gig.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBCA073).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${gig.distanceKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5E3C),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Category
            Text(
              gig.category,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              gig.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Price + Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${gig.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4E342E),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to gig detail or booking screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E342E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// Shows a filter sheet for category selection.
  void _showFilterSheet() {
    final categories = [
      'All',
      'Cleaning',
      'Repair',
      'Plumbing',
      'Electrical',
      'Tutoring',
      'Design',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Filter by Category',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E2723),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((cat) {
                final isSelected =
                    ref.read(searchProvider).category == cat ||
                        (cat == 'All' &&
                            ref.read(searchProvider).category.isEmpty);
                return GestureDetector(
                  onTap: () {
                    ref.read(searchProvider.notifier).setCategory(
                          cat == 'All' ? '' : cat,
                        );
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4E342E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Builds a styled marker bubble for a freelancer/gig on the map.
  Widget _buildMapMarker(String initials, Color color) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
