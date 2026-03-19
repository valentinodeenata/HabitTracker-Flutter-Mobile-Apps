import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/services/storage_service.dart';
import 'package:habit_flow/main.dart';

void main() {
  setUpAll(() async {
    Get.testMode = true;
    await Get.putAsync(() => StorageService().init());
  });

  tearDownAll(Get.reset);

  testWidgets('App starts and shows HabitFlow title', (WidgetTester tester) async {
    await tester.pumpWidget(const HabitFlowApp());
    await tester.pumpAndSettle();
    expect(find.text('HabitFlow'), findsOneWidget);
  });
}
