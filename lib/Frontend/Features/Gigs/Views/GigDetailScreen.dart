import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../Auth/ViewModel/authViewModel.dart';
import '../Model/GigModel.dart';
import '../../Orders/ViewModel/customer_order_provider.dart';
import '../../Orders/ViewModel/customer_order_history_provider.dart';
import '../../Orders/Repository/PaymentRepository.dart';
import '../../../Theme/app_colors.dart';
import '../../Chat/ViewModel/chatProvider.dart';
import '../../Chat/Views/ChatScreen.dart';
import '../../Profile/Views/FreelancerProfileScreen.dart';
import '../Repository/GigRepo.dart';
import '../../../Utils/mongo_id.dart';

class GigDetailScreen extends ConsumerStatefulWidget {
  final GigModel gig;

  const GigDetailScreen({super.key, required this.gig});

  @override
  ConsumerState<GigDetailScreen> createState() => _GigDetailScreenState();
}

class _GigDetailScreenState extends ConsumerState<GigDetailScreen> {
  final TextEditingController _requirementsController = TextEditingController();
  final _gigRepo = GigRepository();
  final _paymentRepo = PaymentRepository();
  bool _isSubmitting = false;
  late GigModel _gig;

  @override
  void initState() {
    super.initState();
    _gig = widget.gig;
    _refreshGigIfNeeded();
  }

  Future<void> _refreshGigIfNeeded() async {
    if (_gig.id == null || _gig.id!.isEmpty) return;
    if (parseMongoId(_gig.freelancerId).isNotEmpty &&
        _gig.freelancerName != null) {
      return;
    }
    final full = await _gigRepo.getGigById(_gig.id!);
    if (full != null && mounted) {
      setState(() => _gig = full);
    }
  }

  @override
  void dispose() {
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final user = ref.read(authprovider).value;
    final customerId = user?.id;

    if (customerId == null || customerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to place an order.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final hasPending = await ref.read(pendingReviewProvider.future);
      if (hasPending) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please review your completed order before placing a new one. '
              'Go to Profile > Order History.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // Step 1: Create the order
      final orderId = await ref.read(customerOrderProvider.notifier).placeOrder(
            gigId: _gig.id ?? '',
            freelancerId: _gig.freelancerId,
            customerId: customerId,
            amount: _gig.price,
            requirements: _requirementsController.text.trim(),
          );

      if (orderId.isEmpty) {
        throw Exception('Failed to create order');
      }

      // Step 2: Create PaymentIntent and get client_secret
      if (!mounted) return;
      final clientSecret = await _paymentRepo.createPaymentIntent(orderId);

      // Step 3: Present Stripe Payment Sheet
      await _paymentRepo.presentPaymentSheet(clientSecret);

      // Verify and confirm payment on the backend immediately
      await _paymentRepo.confirmPayment(orderId);

      // Step 4: Payment succeeded — show success dialog
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
              const SizedBox(width: 8),
              const Text('Payment Successful!'),
            ],
          ),
          content: const Text(
            'Your order has been placed and payment is held securely. '
            'The freelancer will be notified to start working on your order.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to home
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on StripeException catch (e) {
      // User cancelled the payment sheet or payment failed
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final message = e.error.localizedMessage ?? 'Payment was cancelled.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final hasImage = _gig.images.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF4E342E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: hasImage
                  ? Image.network(
                      _gig.images.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: const Color(0xFF4E342E),
                      child: const Icon(Icons.image, size: 100, color: Colors.white24),
                    ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _gig.title,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3E2723),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E5D8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _gig.category,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4E342E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${_gig.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4E342E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      final fid = parseMongoId(_gig.freelancerId);
                      if (fid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Freelancer info not available yet'),
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FreelancerProfileScreen(
                            freelancerId: fid,
                            sourceGig: _gig,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF8F6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFF4E342E),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Freelancer',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _gig.freelancerName ?? 'View profile and ratings',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF3E2723),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Color(0xFFBCA073),
                                    ),
                                    Text(
                                      ' ${(_gig.freelancerRating ?? _gig.rating).toStringAsFixed(1)} rating',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'About this Gig',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _gig.description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Requirements Section
                  const Text(
                    'Order Requirements',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell the freelancer exactly what you need to get started.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _requirementsController,
                    maxLines: 5,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: 'e.g. Please clean the living room and kitchen...',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      filled: true,
                      fillColor: const Color(0xFFFBF8F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final user = ref.read(authprovider).value;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please sign in to chat')),
                          );
                          return;
                        }
                        
                        try {
                          final chatRepo = ref.read(chatRepositoryProvider);
                          final conversation = await chatRepo.startConversation(
                            _gig.freelancerId,
                            _gig.id ?? '',
                          );
                          
                          // Set the active chat ID
                          ref.read(selectedChatIdProvider.notifier).state = conversation.id;
                          
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(conversation: conversation),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to start chat: $e')),
                          );
                        }
                      },
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('Chat with Freelancer'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        foregroundColor: const Color(0xFF4E342E),
                        side: const BorderSide(color: Color(0xFF4E342E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120), // Extra space
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E342E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Confirm and Place Order',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
