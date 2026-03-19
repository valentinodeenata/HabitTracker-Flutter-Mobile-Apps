import 'package:get/get.dart';
import 'package:habit_flow/features/stats/presentation/controllers/stats_controller.dart';

class StatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatsController>(() => StatsController());
  }
}
