import 'package:flutter/material.dart';

class AdminOrdersPaymentsScreen extends StatelessWidget {
  const AdminOrdersPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Orders & Payments',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  _buildSummaryBox(
                    label: 'Total in Escrow',
                    value: '\$45,890',
                    icon: Icons.attach_money,
                    color: const Color(0xFFC7A76D),
                  ),
                  const SizedBox(width: 15),
                  _buildSummaryBox(
                    label: 'Disputed Orders',
                    value: '3',
                    icon: Icons.error_outline,
                    color: const Color(0xFFD32F2F),
                    isAlert: true,
                  ),
                ],
              ),
            ),

            // Orders List
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPaymentCard(
                  orderId: 'ORD-1234',
                  service: 'House Cleaning',
                  customer: 'John D.',
                  freelancer: 'Sarah Johnson',
                  amount: '\$47.25',
                  status: 'completed',
                  escrowStatus: 'Escrow: held',
                  date: 'Apr 23, 2026',
                  actionButton: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.attach_money, size: 18),
                    label: const Text('Release Payment to Freelancer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC7A76D),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                _buildPaymentCard(
                  orderId: 'ORD-1235',
                  service: 'Laptop Repair',
                  customer: 'Lisa M.',
                  freelancer: 'Mike Chen',
                  amount: '\$62.25',
                  status: 'in-progress',
                  escrowStatus: 'Escrow: held',
                  date: 'Apr 23, 2026',
                ),
                _buildPaymentCard(
                  orderId: 'ORD-1236',
                  service: 'Hair Styling',
                  customer: 'Robert K.',
                  freelancer: 'Emma Rodriguez',
                  amount: '\$37.00',
                  status: 'completed',
                  escrowStatus: 'Escrow: released',
                  date: 'Apr 22, 2026',
                  isSuccess: true,
                ),
                _buildPaymentCard(
                  orderId: 'ORD-1237',
                  service: 'Plumbing',
                  customer: 'Anna S.',
                  freelancer: 'David Williams',
                  amount: '\$82.50',
                  status: 'disputed',
                  escrowStatus: 'Escrow: disputed',
                  date: 'Apr 21, 2026',
                  isDisputed: true,
                  disputeBox: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Payment dispute requires resolution',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ),
                  multiActions: Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton('Refund Customer', onPressed: () {}),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPrimaryButton('Release to Freelancer', onPressed: () {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ],
        ),
      ),
    );
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
