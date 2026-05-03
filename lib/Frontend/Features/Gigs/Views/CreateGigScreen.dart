import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../Components/custom_textfield.dart';
import '../../../Components/custom_button.dart';
import '../../../Theme/app_colors.dart';
import '../../Auth/ViewModel/authViewModel.dart';
import '../Repository/GigRepo.dart';
import '../viewModel/viewModel.dart';

class CreateGigScreen extends ConsumerStatefulWidget {
  const CreateGigScreen({super.key});

  @override
  ConsumerState<CreateGigScreen> createState() => _CreateGigScreenState();
}

class _CreateGigScreenState extends ConsumerState<CreateGigScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _repo = GigRepository();

  String _selectedCategory = '';
  bool _isSubmitting = false;
  String? _locationStatus;
  double? _latitude;
  double? _longitude;

  final _categories = [
    'Cleaning',
    'Repair',
    'Plumbing',
    'Electrical',
    'Tutoring',
    'Design',
    'Photography',
    'Delivery',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Detects the freelancer's GPS location when the screen opens.
  Future<void> _detectLocation() async {
    setState(() => _locationStatus = 'Detecting your location...');

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        setState(
            () => _locationStatus = '️ Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
        if (permission == LocationPermission.denied) {
          setState(() => _locationStatus = '️ Location permission denied');
          return;
        }
      }
      if (!mounted) return;
      if (permission == LocationPermission.deniedForever) {
        setState(
            () => _locationStatus = '️ Location permission permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationStatus =
            ' Location detected (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _locationStatus = '️ Could not detect location');
    }
  }

  /// Creates the gig and saves the freelancer's location.
  Future<void> _submitGig() async {
    // Validate inputs
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final priceText = _priceController.text.trim();

    if (title.isEmpty) {
      _showError('Please enter a gig title');
      return;
    }
    if (description.isEmpty) {
      _showError('Please enter a description');
      return;
    }
    if (priceText.isEmpty) {
      _showError('Please enter a price');
      return;
    }
    if (_selectedCategory.isEmpty) {
      _showError('Please select a category');
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      _showError('Please enter a valid price');
      return;
    }

    if (_latitude == null || _longitude == null) {
      _showError(
          'Location not detected. Please enable GPS and tap the location button.');
      return;
    }

    // Get the current user's ID
    final authState = ref.read(authprovider);
    final user = authState.value;
    if (user == null) {
      _showError('Not logged in. Please sign in again.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 1. Save the freelancer's GPS location to their user profile
      //    This is CRITICAL for the $geoNear search to find them
      await _repo.updateFreelancerLocation(
        longitude: _longitude!,
        latitude: _latitude!,
      );

      // 2. Create the gig
      await _repo.createGig(
        title: title,
        description: description,
        price: price,
        category: _selectedCategory,
        freelancerId: user.id ?? '',
      );

      if (!mounted) return;

      // 3. Refresh the gig list
      ref.read(gigprovider.notifier).refreshGigs();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gig created successfully! '),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to create gig: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create New Gig',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step Progress Indicator
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildStepHeader('Basic Info', true),
                _buildStepHeader('Pricing', true),
                _buildStepHeader('Location', true),
                _buildStepHeader('Submit', true),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  CustomTextField(
                    label: 'Gig Title',
                    hintText: 'e.g., Professional House Cleaning',
                    prefixIcon: Icons.title,
                    controller: _titleController,
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Describe your service in detail...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price
                  CustomTextField(
                    label: 'Price (\$)',
                    hintText: 'e.g., 50',
                    prefixIcon: Icons.attach_money,
                    controller: _priceController,
                  ),
                  const SizedBox(height: 24),

                  // Category
                  const Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory.isEmpty
                            ? null
                            : _selectedCategory,
                        hint: const Text(
                          'Select category',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.textHint,
                          ),
                        ),
                        items: _categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(
                                    cat,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── LOCATION STATUS ───────────────────────────────
                  const Text(
                    'Your Location',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _latitude != null
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _latitude != null
                            ? const Color(0xFF81C784)
                            : const Color(0xFFFFCC02),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _latitude != null
                              ? Icons.check_circle
                              : Icons.info_outline,
                          color: _latitude != null
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFE65100),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _locationStatus ?? 'Detecting location...',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: _latitude != null
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                        ),
                        if (_latitude == null)
                          GestureDetector(
                            onTap: _detectLocation,
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFFE65100),
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your location is saved so customers nearby can find your gig.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Submit Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isSubmitting
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFBCA073),
                    ),
                  )
                : CustomPrimaryButton(
                    label: 'Create Gig',
                    onPressed: _submitGig,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFC7A76D)
                  : const Color(0xFFF3E5D8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFF3E2723) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
