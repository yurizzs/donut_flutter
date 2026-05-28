import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../models/donut_model.dart';

class DonutService {
  final Dio _dio;

  DonutService(this._dio);

  Future<List<DonutModel>> getDonuts() async {
    try {
      final response = await _dio.get(ApiConstants.donuts);
      
      // Detailed logging to debug the structure
      if (response.data == null || response.data['donuts'] == null) {
        debugPrint('Unexpected API response structure: ${response.data}');
        return [];
      }

      final List data = response.data['donuts']['data'];
      return data.map((json) => DonutModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      debugPrint('Error in DonutService.getDonuts: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }
}
