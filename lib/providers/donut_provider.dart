import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/donut_model.dart';
import '../services/donut_service.dart';

final donutServiceProvider = Provider<DonutService>((ref) {
  return DonutService(ref.watch(dioProvider));
});

final donutsProvider = AsyncNotifierProvider<DonutsNotifier, List<DonutModel>>(() {
  return DonutsNotifier();
});

class DonutsNotifier extends AsyncNotifier<List<DonutModel>> {
  @override
  Future<List<DonutModel>> build() async {
    return ref.read(donutServiceProvider).getDonuts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(donutServiceProvider).getDonuts());
  }
}
