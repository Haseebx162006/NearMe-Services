import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/Frontend/Admin/ViewModel/admin_providers.dart';
import 'package:near_me/Frontend/Features/Gigs/Model/GigModel.dart';

class AdminGigModerationScreen extends ConsumerWidget {
  const AdminGigModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gigsAsync = ref.watch(adminGigsProvider);
    final actionState = ref.watch(adminGigModerationControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gig Moderation',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: gigsAsync.when(
              loading: () => const Text(
                'Loading gigs…',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey),
              ),
              error: (e, _) => Text(
                'Failed to load gigs: $e',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.red),
              ),
              data: (gigs) => Text(
                '${gigs.length} gigs found',
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey),
              ),
            ),
          ),
          if (actionState.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Expanded(
            child: gigsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(height: 10),
                      Text(
                        'Could not load gigs.\n$e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(adminGigsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (gigs) {
                if (gigs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No gigs to show.',
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(adminGigsProvider.future),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: gigs.length,
                    itemBuilder: (context, index) {
                      final gig = gigs[index];
                      return _ModerationCard(
                        gig: gig,
                        onApprove: () async {
                          final controller =
                              ref.read(adminGigModerationControllerProvider.notifier);
                          try {
                            await controller.approveGig(gigId: gig.id ?? '');
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        onReject: () async {
                          final controller =
                              ref.read(adminGigModerationControllerProvider.notifier);
                          try {
                            await controller.rejectGig(gigId: gig.id ?? '');
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModerationCard extends StatelessWidget {
  final GigModel gig;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ModerationCard({
    required this.gig,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final title = gig.title ?? 'Untitled gig';
    final category = gig.category ?? '—';
    final price = gig.price != null ? '\$${gig.price}' : '—';
    final description = gig.description ?? '';
    final imageUrl = (gig.images != null && gig.images!.isNotEmpty) ? gig.images!.first : null;
    final status = gig.moderationStatus.isEmpty ? 'approved' : gig.moderationStatus;

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: imageUrl == null
                ? Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  )
                : Image.network(
                    imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E2723),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MetaColumn(label: 'Category', value: category),
                    _MetaColumn(label: 'Price', value: price),
                    _MetaColumn(label: 'Status', value: status),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F6F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Color(0xFF3E2723),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC7A76D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaColumn extends StatelessWidget {
  final String label;
  final String value;

  const _MetaColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }
}
