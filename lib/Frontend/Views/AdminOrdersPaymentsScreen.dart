import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/Frontend/Admin/ViewModel/admin_providers.dart';
import 'package:near_me/Frontend/Admin/Models/admin_order_model.dart';

class AdminOrdersPaymentsScreen extends ConsumerWidget {
  const AdminOrdersPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(adminPaymentsSummaryProvider);
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Orders & Payments',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminPaymentsSummaryProvider);
          ref.invalidate(adminOrdersProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            summaryAsync.when(
              loading: () => Row(
                children: [
                  _buildSummaryBox(
                    label: 'Total in Escrow',
                    value: 'Loading…',
                    icon: Icons.attach_money,
                    color: const Color(0xFFC7A76D),
                  ),
                  const SizedBox(width: 15),
                  _buildSummaryBox(
                    label: 'Disputed Orders',
                    value: 'Loading…',
                    icon: Icons.error_outline,
                    color: const Color(0xFFD32F2F),
                    isAlert: true,
                  ),
                ],
              ),
              error: (e, _) => Row(
                children: [
                  _buildSummaryBox(
                    label: 'Total in Escrow',
                    value: 'Error',
                    icon: Icons.attach_money,
                    color: const Color(0xFFC7A76D),
                  ),
                  const SizedBox(width: 15),
                  _buildSummaryBox(
                    label: 'Disputed Orders',
                    value: 'Error',
                    icon: Icons.error_outline,
                    color: const Color(0xFFD32F2F),
                    isAlert: true,
                  ),
                ],
              ),
              data: (s) => Row(
                children: [
                  _buildSummaryBox(
                    label: 'Total in Escrow',
                    value: '\$${s.totalInEscrow.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: const Color(0xFFC7A76D),
                  ),
                  const SizedBox(width: 15),
                  _buildSummaryBox(
                    label: 'Disputed Orders',
                    value: '${s.disputedOrders}',
                    icon: Icons.error_outline,
                    color: const Color(0xFFD32F2F),
                    isAlert: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ordersAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => _ErrorBox(
                message: e.toString(),
                onRetry: () => ref.invalidate(adminOrdersProvider),
              ),
              data: (orders) {
                if (orders.isEmpty) {
                  return const _EmptyBox(
                    title: 'No orders yet',
                    subtitle: 'When users place orders, they will appear here.',
                  );
                }
                return Column(
                  children: [
                    for (final o in orders) ...[
                      _buildOrderCard(o),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(AdminOrderModel o) {
    final created = o.createdAt == null ? '—' : _formatDate(o.createdAt!);
    return Container(
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
              Text(
                'Order ${o.id}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E2723),
                ),
              ),
              Text(
                '\$${o.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDCC196),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatusBadge(o.status),
              const SizedBox(width: 10),
              _buildEscrowBadge('Payment: ${o.paymentStatus}', o.paymentStatus == 'released', false),
              const Spacer(),
              Text(
                created,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Gig: ${o.gigId}',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Widget _buildSummaryBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isAlert = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAlert ? const Color(0xFFFFEBEE) : color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isAlert ? const Color(0xFFD32F2F) : Colors.white.withOpacity(0.8), size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isAlert ? const Color(0xFFD32F2F) : Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: isAlert ? const Color(0xFFD32F2F).withOpacity(0.8) : Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required String orderId,
    required String service,
    required String customer,
    required String freelancer,
    required String amount,
    required String status,
    required String escrowStatus,
    required String date,
    Widget? actionButton,
    Widget? multiActions,
    Widget? disputeBox,
    bool isSuccess = false,
    bool isDisputed = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
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
                    orderId,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E2723)),
                  ),
                  Text(
                    service,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                amount,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDCC196)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildUserDetail('Customer', customer),
              const Spacer(),
              _buildUserDetail('Freelancer', freelancer),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               _buildStatusBadge(status),
               _buildEscrowBadge(escrowStatus, isSuccess, isDisputed),
               Text(date, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
            ],
          ),
          if (disputeBox != null) disputeBox,
          if (actionButton != null) ...[
            const SizedBox(height: 15),
            SizedBox(width: double.infinity, child: actionButton),
          ],
          if (multiActions != null) ...[
            const SizedBox(height: 5),
            multiActions,
          ],
        ],
      ),
    );
  }

  Widget _buildUserDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF3E2723))),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'completed') color = Colors.green;
    if (status == 'in-progress') color = Colors.orange;
    if (status == 'disputed') color = const Color(0xFFD32F2F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEscrowBadge(String text, bool isSuccess, bool isDisputed) {
    Color color = const Color(0xFFC7A76D);
    if (isSuccess) color = Colors.green;
    if (isDisputed) color = const Color(0xFFD32F2F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF3E5D8),
        foregroundColor: const Color(0xFF3E2723),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildPrimaryButton(String text, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFC7A76D),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyBox({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Failed to load orders',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3E2723),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
