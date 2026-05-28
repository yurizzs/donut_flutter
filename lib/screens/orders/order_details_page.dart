import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';

class OrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(order.createdAt);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order Details', style: GoogleFonts.inter(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(order),
            const SizedBox(height: 24),
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 12),
            _buildOrderItems(),
            const SizedBox(height: 24),
            _buildSectionTitle('Payment Details'),
            const SizedBox(height: 12),
            _buildPaymentSummary(),
            const SizedBox(height: 24),
            _buildOrderInfo(dateStr),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(OrderModel order) {
    Color statusColor = AppColors.textSecondary;
    if (order.status.toLowerCase() == 'completed') statusColor = Colors.green;
    else if (order.status.toLowerCase() == 'cancelled') statusColor = Colors.red;
    else if (order.status.toLowerCase() == 'pending') statusColor = AppColors.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryText.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Order #${order.id}',
            style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            order.status.toUpperCase(),
            style: GoogleFonts.inter(
              color: statusColor,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Icons.check_circle_outline;
      case 'cancelled': return Icons.cancel_outlined;
      case 'pending': return Icons.access_time;
      default: return Icons.help_outline;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primaryText),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryText.withOpacity(0.05)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: order.items.length,
        separatorBuilder: (context, index) => Divider(color: AppColors.primaryText.withOpacity(0.05), height: 1),
        itemBuilder: (context, index) {
          final item = order.items[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.quantity}x',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.donutName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(item.categoryName, style: GoogleFonts.inter(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Text(
                  '₱${item.subtotal.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryText.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', order.total - 50), // Assuming 50 is delivery fee if not in model
          const SizedBox(height: 12),
          _buildSummaryRow('Delivery Fee', 50),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(
                '₱${order.total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        Text('₱${amount.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOrderInfo(String dateStr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Information', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today_outlined, 'Date placed', dateStr),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.payment_outlined, 'Payment Method', 'Cash on Delivery'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label:', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(width: 4),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
