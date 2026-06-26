import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/notification_page/notificationController.dart';
import 'common-alertdialog.dart';

class CommonBottomNavigation extends StatefulWidget {
  final int currentIndex;

  const CommonBottomNavigation({Key? key, this.currentIndex = 0})
      : super(key: key);

  @override
  _CommonBottomNavigationState createState() =>
      _CommonBottomNavigationState();
}

class _CommonBottomNavigationState extends State<CommonBottomNavigation> {
  late int selectedIndex;
  final loginController = Get.put(LoginController());
  final notificationController=Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    final String userId = Api.userInfo.read('userId') ?? "";
    //Api.userInfo.write('selectUId',userId);
    selectedIndex = widget.currentIndex;
  }

  void _handleTap(BuildContext context, int index, List<NavigationItem> items) async {
    if (index >= items.length) return;

    setState(() {
      selectedIndex = index;
    });

    final item = items[index];

    final token = Api.userInfo.read('token');
    final userType = Api.userInfo.read('userType') ?? '';
    final userId = Api.userInfo.read('userId') ?? '';
    //Api.userInfo.write('selectUId', userId);

    if (item.label == 'LogIn') {
      Get.offAllNamed('/loginPage');
      return;
    }

    if (item.label == 'Home') {
      if (token != null) {
        Get.offAllNamed('/${pageUserType(userType)}');
      } else {
        Get.offAllNamed('/patientDashboard');
      }
      return;
    }

    if (item.label == 'LogOut') {
      showLogoutDialog(context);
      return;
    }

    if (item.label == 'Menu') {
      Get.toNamed('/settingPageMobile');
      return;
    }
    if (item.label == 'Notification') {
      await  notificationController.getNotificationListAdmin(context);
      Get.toNamed('/notificationPage');
      return;
    }
    if (item.label == 'Profile' || item.label == 'Register') {
      if (token != null) {
        Api.userInfo.write('selectUId', userId);
        Get.offAllNamed('/${profilePage(userType)}');
      } else {
        Get.offAllNamed('/registerPage');
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userType = Api.userInfo.read('userType') ?? '';
    final userId = Api.userInfo.read('userId') ?? '';
    final token = Api.userInfo.read('token');

    final List<NavigationItem> items = [
      NavigationItem(icon: Icons.home, label: 'Home'),

      if (userType != 'superAdmin' && userId != 'admin')
        NavigationItem(
          icon: Icons.person,
          label: token != null ? 'Profile' : 'Register',
        ),
      if (token != null)
      NavigationItem(icon: Icons.notifications, label: 'Notification'),

      if (token != null)
        NavigationItem(icon: Icons.settings, label: 'Menu'),

      token != null
          ? NavigationItem(icon: Icons.logout, label: 'LogOut')
          : NavigationItem(icon: Icons.login, label: 'LogIn'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: AnimatedBottomNavigation(
          currentIndex: selectedIndex,
          items: items,
          onTap: (index) => _handleTap(context, index, items),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}

class AnimatedBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<NavigationItem> items;
  final ValueChanged<int> onTap;

  const AnimatedBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = currentIndex == index;
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey,
                    size: isSelected ? 30 : 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
