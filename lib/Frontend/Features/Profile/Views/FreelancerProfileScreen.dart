import 'package:flutter/material.dart';
import '../../Auth/Repository/AuthRepo.dart';
import '../../Gigs/Model/GigModel.dart';
import '../../Gigs/Repository/GigRepo.dart';
import '../../../Theme/app_colors.dart';
import '../../../Utils/mongo_id.dart';

class FreelancerProfileScreen extends StatefulWidget {
  final String freelancerId;
  final GigModel? sourceGig;

  const FreelancerProfileScreen({
    super.key,
    required this.freelancerId,
    this.sourceGig,
  });

  @override
  State<FreelancerProfileScreen> createState() =>
      _FreelancerProfileScreenState();
}

class _FreelancerProfileScreenState extends State<FreelancerProfileScreen> {
  final _gigRepo = GigRepository();
  final _authRepo = AuthRepository();

  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var id = parseMongoId(widget.freelancerId);
      var gig = widget.sourceGig;

      if (id.isEmpty && gig?.id != null && gig!.id!.isNotEmpty) {
        final fullGig = await _gigRepo.getGigById(gig.id!);
        if (fullGig != null) {
          gig = fullGig;
          id = parseMongoId(fullGig.freelancerId);
        }
      }

      if (id.isEmpty) {
        setState(() {
          _error = 'Freelancer id missing for this gig';
          _loading = false;
        });
        return;
      }

      var profile = await _gigRepo.buildFreelancerProfile(
        freelancerId: id,
        sourceGig: gig,
      );

      try {
        final apiProfile = await _authRepo.getFreelancerProfile(id);
        if (apiProfile != null) {
          profile = {...profile, ...apiProfile};
        }
      } catch (_) {
        // Gigs-based profile is enough when API route is not deployed
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3E2723)),
        title: const Text(
          'Freelancer',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFF3E2723),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF3E2723)),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _ProfileBody(profile: _profile!),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final Map<String, dynamic> profile;

  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    final rating = (p['rating'] ?? 0.0).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFF4E342E),
            backgroundImage: p['profile_picture'] != null
                ? NetworkImage(p['profile_picture'])
                : null,
            child: p['profile_picture'] == null
                ? Text(
                    _initials(p['name'] ?? 'F'),
                    style: const TextStyle(color: Colors.white, fontSize: 28),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            p['name'] ?? 'Freelancer',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ..._starIcons(rating),
              const SizedBox(width: 8),
              Text(
                '${rating.toStringAsFixed(1)} (${p['review_count'] ?? 0} reviews)',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  Icons.work_outline,
                  '${p['gig_count'] ?? 0}',
                  'Gigs',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  Icons.check_circle_outline,
                  '${p['completed_orders'] ?? 0}',
                  'Completed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if ((p['profile_bio'] ?? '').toString().isNotEmpty) ...[
            _section('About', p['profile_bio'].toString()),
            const SizedBox(height: 16),
          ],
          if ((p['skills'] as List?)?.isNotEmpty == true) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Skills',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF3E2723),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (p['skills'] as List)
                  .map(
                    (s) => Chip(
                      label: Text(
                        s.toString(),
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: const Color(0xFFF3E5D8),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if ((p['email'] ?? '').toString().isNotEmpty)
            _infoTile(Icons.email_outlined, 'Email', p['email'].toString()),
          if ((p['phone_number'] ?? '').toString().isNotEmpty)
            _infoTile(
              Icons.phone_outlined,
              'Phone',
              p['phone_number'].toString(),
            ),
        ],
      ),
    );
  }

  String _initials(String name) {
    return name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();
  }

  List<Widget> _starIcons(double rating) {
    return List.generate(5, (i) {
      return Icon(
        i < rating.round() ? Icons.star : Icons.star_border,
        color: const Color(0xFFBCA073),
        size: 20,
      );
    });
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFBCA073)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFFBCA073)),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          color: Color(0xFF3E2723),
        ),
      ),
    );
  }
}
