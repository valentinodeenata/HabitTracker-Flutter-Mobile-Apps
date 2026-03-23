import 'package:get/get.dart';
import 'package:habit_flow/features/focus_session/presentation/controllers/focus_session_controller.dart';
import 'package:habit_flow/features/habit/presentation/controllers/habit_controller.dart';

class FocusSessionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HabitController>()) {
      Get.put(HabitController(), permanent: true);
    }
    if (!Get.isRegistered<FocusSessionController>()) {
      Get.put(FocusSessionController(), permanent: true);
    }
    Get.find<FocusSessionController>().syncRouteArguments(Get.arguments);
  }
}
