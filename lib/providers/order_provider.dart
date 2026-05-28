import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService(ref.watch(dioProvider));
});

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>(() {
  return OrdersNotifier();
});

class OrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    return ref.read(orderServiceProvider).getOrders();
  }

  Future<void> cancelOrder(int orderId) async {
    await ref.read(orderServiceProvider).cancelOrder(orderId);
    // Optimistically update local state or just refresh
    ref.invalidateSelf();
  }

  Future<void> placeOrder(Map<String, dynamic> payload) async {
    await ref.read(orderServiceProvider).placeOrder(payload);
    // Force a refresh of the order list to pick up the new order
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(orderServiceProvider).getOrders());
  }}
