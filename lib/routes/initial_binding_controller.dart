import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';


class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => NotificationController());
    Get.lazyPut(() => PlanController());
    Get.lazyPut(() => JobController());
  }
}
