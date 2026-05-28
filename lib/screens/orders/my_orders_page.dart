import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_modal.dart';
import 'order_details_page.dart';

class MyOrdersPage extends ConsumerWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Orders', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.primaryText)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return _buildLoginRequired(context);
          return ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) return _buildEmptyState();
              return RefreshIndicator(
                onRefresh: () => ref.refresh(ordersProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildOrderCard(context, ref, orders[index]),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            error: (err, stack) => _buildErrorView(ref, err.toString()),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => _buildErrorView(ref, err.toString()),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, OrderModel order) {
    final dateStr = DateFormat('MMM dd, yyyy').format(order.createdAt);
    final isPending = order.status.toLowerCase() == 'pending';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OrderDetailPage(order: order)),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryText.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text('Order #${order.id}', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppColors.accent, fontSize: 12)),
                ),
                Text(dateStr, style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 20),
            ...order.items.take(2).map((item) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 32, height: 32, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(16)), child: Text('${item.quantity}x', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.donutName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(item.categoryName, style: GoogleFonts.inter(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                  Text('₱${item.subtotal.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14)),
                ],
              ),
            )).toList(),
            if (order.items.length > 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('+ ${order.items.length - 2} more items', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Bill', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
                Text('₱${order.total.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.primaryText)),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusBadge(order.status),
            if (isPending) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleCancel(context, ref, order.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppColors.textSecondary;
    if (status.toLowerCase() == 'completed') color = Colors.green;
    else if (status.toLowerCase() == 'cancelled') color = Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: GoogleFonts.inter(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
  
  Widget _buildLoginRequired(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Please Sign In', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('You need to be logged in to view your order history.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const LoginModal(),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(WidgetRef ref, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Unable to load orders', style: GoogleFonts.inter()),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(ordersProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍩', style: TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text('No orders yet!', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your donut journey hasn\'t started.'),
        ],
      ),
    );
  }

  void _handleCancel(BuildContext context, WidgetRef ref, int orderId) async {
     final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Cancel')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ref.read(ordersProvider.notifier).cancelOrder(orderId);
      } catch (e) {
        // Handle error
      }
    }
  }
}
