import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:get/get.dart';
import '../../common_widgets/color_code.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: Text('About Us',style: AppTextStyles.subtitle(context,color: AppColors.white),),
        iconTheme: const IconThemeData(color: AppColors.white), flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary,AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [
                         AppColors.primary,AppColors.secondary
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: Icon(Icons.medical_services_rounded,
                        size: size * 0.25, color: AppColors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "About LYD",
                    style: TextStyle(
                      fontSize: size * 0.06,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your Digital Dental Ecosystem",
                    style: TextStyle(
                      fontSize: size * 0.045,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _title("Our Vision"),
            _desc(
                "To modernize the dental industry by enabling fast communication, trusted collaboration, and seamless workflows across India."),
            const SizedBox(height: 20),

            _title("What We Offer"),
            _bullet("Dental Clinics", "Find labs, post jobs, hire professionals."),
            _bullet("Dental Labs", "Connect with clinics & manage orders."),
            _bullet("Dental Shops", "Showcase dental materials & products."),
            _bullet("Dental Mechanics", "Provide support and build connections."),
            _bullet("Consultants", "Share expertise and guide professionals."),
            _bullet("Job Seekers", "Find jobs, apply instantly, build profiles."),
            _bullet("State Admin", "Manage users and verify data."),
            _bullet("Super Admin", "Full system analytics and control."),
            const SizedBox(height: 20),

            _title("Why Choose Us?"),
            _desc(
                "• Unified platform for all dental needs\n• Modern & simple UI\n• Verified professionals\n• Pan-India availability\n• Smart search & instant connections"),
            const SizedBox(height: 25),

            _title("Our Mission"),
            _desc(
                "To empower every dental professional with digital tools that save time, boost growth, and improve patient care."),
            const SizedBox(height: 30),

            Center(
              child: Text(
                "© 2025 Dental Connect — All Rights Reserved",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
            ),
            CommonListTile(
              title: 'Help',
              onTap: () => Get.toNamed('/'),
            ),
            CommonListTile(
              title: 'Privacy Policy',
              onTap: () => Get.toNamed('/'),
            ),
            CommonListTile(
              title: 'Terms & Conditions',
              onTap: () => Get.toNamed('/'),
            ),
            Text('follow us on',
                style: TextStyle(
    fontSize: size*0.03,
    fontWeight: FontWeight.bold,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primary,
    decorationThickness: 2,
    ),),
            SizedBox(height: size * 0.02),

            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CommonSettingContainer(images: "assets/images/facebook.png"),
                  SizedBox(width: 10),
                  CommonSettingContainer(images: "assets/images/instagram.png"),
                  SizedBox(width: 10),
                  CommonSettingContainer(images: "assets/images/youtube.png"),
                  SizedBox(width: 10),
                  CommonSettingContainer(images: "assets/images/linkein.png"),
                ],
              ),
            ),

            SizedBox(height: size * 0.01),
            Text('App Version',
                style: AppTextStyles.subtitle(context, color: AppColors.black)),
            SizedBox(height: size * 0.01),
            Text('v0.0.1',
                style: AppTextStyles.caption(context, color: AppColors.grey)),
          ],
        ),
      ),
      bottomNavigationBar: CommonBottomNavigation(currentIndex: 0),

    );
  }


  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _desc(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _bullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle,color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87, fontSize: 15),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
