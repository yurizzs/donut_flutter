import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._(); // prevent instantiation

  static final String domain = dotenv.maybeGet('API_URL') ?? 'http://localhost:8000';
  static final String baseUrl = '$domain/api';
  static final String storageUrl = '$domain/storage';

  // Authenticaton
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String user = '/auth/me';

  // Donut Endpoints
  static const String donuts = '/donuts';
  
  // Order Endpoints
  static const String orders = '/orders';
  static String cancelOrder(int id) => '/orders/$id/cancel';

  // User Endpoints
  static const String users = '/users';
  static String userShow(String slug) => '/users/$slug';
  static String userUpdate(int id) => '/users/$id';
  static String userDelete(int id) => '/users/$id';
  static String userRestore(int id) => '/users/$id/restore';

  // timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}