import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio;

  OrderService(this._dio);

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _dio.get(ApiConstants.orders);
      debugPrint('Orders API Response Structure: ${response.data.runtimeType}');

      // Access the nested structure: response.data['orders']['data']
      final Map<String, dynamic> responseData = response.data;
      final List data = responseData['orders']?['data'] ?? [];
      
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      debugPrint('Error in OrderService.getOrders: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> cancelOrder(int id) async {
    try {
      await _dio.patch(ApiConstants.cancelOrder(id));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> placeOrder(Map<String, dynamic> payload) async {
    try {
      await _dio.post(ApiConstants.orders, data: payload);
    } catch (e) {
      rethrow;
    }
  }
}
