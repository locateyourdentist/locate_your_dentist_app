// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:locate_your_dentist/api/api.dart';
// import 'package:locate_your_dentist/common_widgets/color_code.dart';
// import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
// import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
// import 'common-alertdialog.dart';
//
//
// class CommonBottomNavigation extends StatefulWidget {
//   final int currentIndex;
//
//   const CommonBottomNavigation({Key? key, this.currentIndex = 0}) : super(key: key);
//
//   @override
//   _CommonBottomNavigationState createState() => _CommonBottomNavigationState();
// }
//
// class _CommonBottomNavigationState extends State<CommonBottomNavigation> {
//   late int selectedIndex;
//   final loginController = Get.put(LoginController());
//
//   final List<_NavigationItem> items = [
//     _NavigationItem(icon: Icons.home, label: 'Home'),
//     if ((Api.userInfo.read('userType')!='superAdmin')||Api.userInfo.read('userId')!='admin')
//
//       if (Api.userInfo.read('userType') != 'superAdmin')  _NavigationItem(icon: Icons.person, label:Api.userInfo.read('token') != null?'Profile':'Register'),
//     if (Api.userInfo.read('token') != null)
//       _NavigationItem(icon: Icons.settings, label: 'Menu'),
//     Api.userInfo.read('token') != null
//         ? _NavigationItem(icon: Icons.logout, label: 'LogOut')
//         : _NavigationItem(icon: Icons.login, label: 'LogIn'),
//   ];
//   @override
//   void initState() {
//     super.initState();
//     selectedIndex = widget.currentIndex;
//     // loginController.getProfileByUserId(Api.userInfo.read('userId') ?? "", context);
//   }
//   void _handleTap(BuildContext context, int index) async {
//     setState(() {
//       selectedIndex = index;
//     });
//     final item = items[index];
//     if (item.label == 'Login' || item.label == 'LogIn') {
//       Get.offAllNamed('/loginPage');
//       return;
//     }
//     if (item.label == 'Home') {
//       // return;
//       if (Api.userInfo.read('token') != null) {
//         Get.offAllNamed('/${pageUserType(Api.userInfo.read('userType') ?? "")}');
//       } else {
//         Get.offAllNamed('/patientDashboard');
//       }
//     }
//     if (item.label == 'LogOut') {
//       showLogoutDialog(context);
//       return;
//     }
//     if (item.label == 'Menu') {
//       if (Api.userInfo.read('token') != null)
//         Get.toNamed('/settingPage');
//       return;
//     }
//
//     if (item.label == 'Profile') {
//        await loginController.getProfileByUserId(Api.userInfo.read('userId') ?? "", context);
//        if (Api.userInfo.read('token') != null) {
//         Get.offAllNamed('/${profilePage(Api.userInfo.read('userType') ?? "")}');
//       } else {
//         Get.offAllNamed('/registerPage');
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
//         child: Container(
//           height: 70,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 20,
//                 spreadRadius: 2,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: BottomNavigationBar(
//               type: BottomNavigationBarType.fixed,
//               elevation: 0,
//               backgroundColor: Colors.transparent,
//               currentIndex: selectedIndex,
//               selectedItemColor: AppColors.primary,
//               unselectedItemColor: Colors.grey.shade400,
//               selectedFontSize: 12,
//               unselectedFontSize: 11,
//               onTap: (index) => _handleTap(context, index),
//               items: items.map((item) {
//                 return BottomNavigationBarItem(
//                   icon: Icon(
//                     item.icon,
//                     size: selectedIndex == items.indexOf(item) ? 26 : 22,
//                   ),
//                   label: item.label,
//                 );
//               }).toList(),
//                           ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//   class _NavigationItem {
//   final IconData icon;
//   final String label;
//
//   _NavigationItem({
//     required this.icon,
//     required this.label,
//   });
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
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

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;
  }

  void _handleTap(BuildContext context, int index, List<_NavigationItem> items) async {
    if (index >= items.length) return;

    setState(() {
      selectedIndex = index;
    });

    final item = items[index];

    final token = Api.userInfo.read('token');
    final userType = Api.userInfo.read('userType') ?? '';
    final userId = Api.userInfo.read('userId') ?? '';

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

    if (item.label == 'Profile') {
      Api.userInfo.write('selectUId',userId);
      if (token != null) {
        Get.offAllNamed('/${profilePage(userType)}');
      } else {
        Get.offAllNamed('/registerPage');
      }
      return;
    }
    if (item.label == 'Register') {
      Api.userInfo.write('selectUId',userId);
      if (token != null) {
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

    final List<_NavigationItem> items = [
      _NavigationItem(icon: Icons.home, label: 'Home'),

      if (userType != 'superAdmin' && userId != 'admin')
        _NavigationItem(
          icon: Icons.person,
          label: token != null ? 'Profile' : 'Register',
        ),

      if (token != null)
        _NavigationItem(icon: Icons.settings, label: 'Menu'),

      token != null
          ? _NavigationItem(icon: Icons.logout, label: 'LogOut')
          : _NavigationItem(icon: Icons.login, label: 'LogIn'),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              backgroundColor: Colors.transparent,
              currentIndex:
              selectedIndex < items.length ? selectedIndex : 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey.shade400,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              onTap: (index) => _handleTap(context, index, items),
              items: items.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(
                    item.icon,
                    size: selectedIndex == items.indexOf(item) ? 26 : 22,
                  ),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;

  _NavigationItem({
    required this.icon,
    required this.label,
  });
}