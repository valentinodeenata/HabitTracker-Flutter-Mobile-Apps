import 'package:get/get.dart';
import 'package:habit_flow/features/habit/presentation/controllers/habit_controller.dart';

class HabitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HabitController>(() => HabitController());
  }
}
