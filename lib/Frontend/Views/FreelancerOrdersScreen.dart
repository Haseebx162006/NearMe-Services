import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Features/Orders/ViewModel/freelancer_orders_provider.dart';

class FreelancerOrdersScreen extends ConsumerStatefulWidget {
  const FreelancerOrdersScreen({super.key});

  @override
  ConsumerState<FreelancerOrdersScreen> createState() =>
      _FreelancerOrdersScreenState();
}

class _FreelancerOrdersScreenState
    extends ConsumerState<FreelancerOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(freelancerOrdersProvider.notifier).refreshOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(freelancerOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const Text(
                    'Manage your bookings',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref
                          .read(freelancerOrdersProvider.notifier)
                          .refreshOrders();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E342E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Orders List
            Expanded(
              child: ordersState.when(
                data: (orders) {
                  if (orders.isEmpty) {
                    return const Center(
                      child: Text(
                        'No orders yet',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final isPending = order.status == 'pending';
                      final isAccepted = order.status == 'accepted';
                      final isPaid = order.paymentStatus == 'held';

                      return _buildOrderCard(
                        clientName: order.customerName ?? 'New Customer',
                        service: order.gigTitle ?? 'Service Request',
                        dateTime: "${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} ${order.createdAt.hour}:${order.createdAt.minute}",
                        amount: '\$${order.price.toStringAsFixed(2)}',
                        requirements:
                            order.description ?? 'No details provided',
                        status: order.status.toUpperCase(),
                        paymentStatus: order.paymentStatus,
                        statusColor: isPending
                            ? const Color(0xFFF3E5D8)
                            : isAccepted
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFF5E6D3),
                        statusTextColor: isPending
                            ? const Color(0xFFC7A76D)
                            : isAccepted
                            ? Colors.green
                            : const Color(0xFF3E2723),
                        actions: isPending
                            ? Column(
                                children: [
                                  if (!isPaid)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFF3E0),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.orange, size: 18),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Waiting for customer payment before you can accept.',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () async {
                                            try {
                                              await ref
                                                  .read(
                                                    freelancerOrdersProvider
                                                        .notifier,
                                                  )
                                                  .updateOrderStatus(
                                                    order.id ?? '',
                                                    'declined',
                                                  );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Order declined'),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error: $e'),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.close, size: 18),
                                          label: const Text('Decline'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFD32F2F,
                                            ),
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: isPaid
                                              ? () async {
                                                  try {
                                                    await ref
                                                        .read(
                                                          freelancerOrdersProvider
                                                              .notifier,
                                                        )
                                                        .updateOrderStatus(
                                                          order.id ?? '',
                                                          'accepted',
                                                        );
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text('Order accepted'),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text('Error: $e'),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              : null,
                                          icon: const Icon(Icons.check, size: 18),
                                          label: const Text('Accept'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isPaid
                                                ? const Color(0xFFC7A76D)
                                                : Colors.grey[400],
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : isAccepted
                            ? SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(
                                            freelancerOrdersProvider.notifier,
                                          )
                                          .updateOrderStatus(
                                            order.id ?? '',
                                            'completed',
                                          );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Order marked as completed',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text('Error: $e')),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4E342E),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text(
                                    'Mark as Completed',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4E342E)),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Error loading orders\n$err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String clientName,
    required String service,
    required String dateTime,
    required String amount,
    required String requirements,
    required String status,
    required String paymentStatus,
    required Color statusColor,
    required Color statusTextColor,
    Widget? actions,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  Text(
                    service,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: statusTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Payment status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: paymentStatus == 'held'
                  ? const Color(0xFFE8F5E9)
                  : paymentStatus == 'released'
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  paymentStatus == 'held'
                      ? Icons.account_balance_wallet
                      : paymentStatus == 'released'
                      ? Icons.check_circle
                      : Icons.hourglass_empty,
                  size: 14,
                  color: paymentStatus == 'held'
                      ? Colors.green[700]
                      : paymentStatus == 'released'
                      ? Colors.blue[700]
                      : Colors.orange[700],
                ),
                const SizedBox(width: 4),
                Text(
                  paymentStatus == 'held'
                      ? '💰 Payment Held'
                      : paymentStatus == 'released'
                      ? '✅ Payment Released'
                      : '⏳ Awaiting Payment',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: paymentStatus == 'held'
                        ? Colors.green[700]
                        : paymentStatus == 'released'
                        ? Colors.blue[700]
                        : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Date & Time', dateTime),
          const SizedBox(height: 8),
          _buildInfoRow('Amount', amount, isPrice: true),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requirements:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  requirements,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
          ),
          if (actions != null) ...[const SizedBox(height: 20), actions],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
            color: isPrice ? const Color(0xFFC7A76D) : const Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }
}
