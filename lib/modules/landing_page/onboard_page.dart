import 'dart:async';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({super.key});

  @override
  State<OnBoardPage> createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  int selectIndex = 0;
  late PageController _pageController;
  Timer? _timer;

  final List<Map<String, dynamic>> onBoardPages = [
    {
      "title": "Dental Problems?",
      "description":
      "Find the best dentist in your area to solve your dental related problems.",
      "image": "assets/images/lp1.jpg"
    },
    {
      "title": "Buy/Sell Dental Equipments",
      "description":
      "Our app helps you buy dental equipment directly from sellers. You can also sell your own.",
      "image": "assets/images/lp2.jpg"
    },
    {
      "title": "Wants Training/Jobs/Webinar?",
      "description":
      "Find latest jobs & training posted by clinics, plus webinars from top organizations.",
      "image": "assets/images/lp3.jpg"
    },
  ];
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (selectIndex < onBoardPages.length - 1) {
        selectIndex++;
      } else {
        selectIndex = 0;
      }
      _pageController.animateToPage(
        selectIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    selectIndex = index;
                  });
                },
                itemCount: onBoardPages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0,bottom: 20,left: 10,right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            onBoardPages[index]['image'],
                            height: size * 1.2,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          onBoardPages[index]['title'],
                          style: AppTextStyles.subtitle(
                              context, color: AppColors.black),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            onBoardPages[index]['description'],
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption(
                                context, color: AppColors.grey),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(onBoardPages.length, (index) {
                bool isActive = index == selectIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: size * 0.03,
                  width: isActive ? size * 0.08 : size * 0.03,
                  decoration: BoxDecoration(
                    color:
                    isActive ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
        
            const SizedBox(height: 30),
        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: size*0.11,
                    width: size*0.35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        addBoolToSF() async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool('isShowOnboard', true);
                          print("value ${prefs.getBool('isShowOnboard')}");
                        }
                        addBoolToSF();
                        Get.toNamed('/loginPage');
                      },
                      child: Text(
                        'Login',
                        style: AppTextStyles.body(context,
                            color: AppColors.black,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size*0.11,
                    width: size*0.37,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        addBoolToSF() async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool('isShowOnboard', true);
                          print("value ${prefs.getBool('isShowOnboard')}");
                        }
                        addBoolToSF();
                        Get.toNamed('/patientDashboard');
                      },
                      child: Center(
                        child: Text(
                          'Skip To Home',
                          style: AppTextStyles.caption(context,
                              color: AppColors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
