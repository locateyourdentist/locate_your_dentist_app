import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class AboutUsWebPage extends StatelessWidget {
  const AboutUsWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    PreferredSizeWidget buildAppBar() {
      if (Api.userInfo.read('token') != null) {
        return CommonWebAppBar(
          height: width * 0.03,
          title: "LYD",
          onLogout: () {},
          onNotification: () {},
        );
      } else {
         return CommonHeader();
      }
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: buildAppBar(),
      body: Row(
        children: [
          if( Api.userInfo.read('token')!=null)
            const AdminSideBar(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary,AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child:  Column(
                      children: [
                        Text(
                          "LOCATE YOUR DENTIST",
                          style: AppTextStyles.subtitle(context,color: AppColors.white)
                        ),
                        const SizedBox(height: 15),
                         Text(
                          "Connecting Dental Clinics, Labs, Shops, Mechanics & Professionals",
                          textAlign: TextAlign.center,
                            style: AppTextStyles.body(context,color: AppColors.white)
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Column(
                        children: [

                          Text(
                            "About Our Platform",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 20),

                          Text(
                            "LOCATE YOUR DENTIST is a modern digital platform designed to connect the entire dental ecosystem. "
                                "Our app helps dental clinics, laboratories, suppliers, mechanics, and job seekers easily find each other and collaborate efficiently.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  Center(
                    child: Container(
                      constraints:  const BoxConstraints(maxWidth: 1100),
                      padding:  const EdgeInsets.symmetric(horizontal: 20),
                      child:  const Wrap(
                        spacing: 25,
                        runSpacing: 25,
                        children: [

                          FeatureCard(
                            icon: Icons.local_hospital,
                            title: "Dental Clinics",
                            description:
                            "Clinics can easily find nearby dental labs, shops, and technicians to support their work.",
                          ),

                          FeatureCard(
                            icon: Icons.science,
                            title: "Dental Labs",
                            description:
                            "Laboratories can connect with clinics and provide their dental services efficiently.",
                          ),

                          FeatureCard(
                            icon: Icons.store,
                            title: "Dental Shops",
                            description:
                            "Suppliers can showcase their dental products and reach more clinics and professionals.",
                          ),

                          FeatureCard(
                            icon: Icons.build,
                            title: "Dental Mechanics",
                            description:
                            "Technicians and mechanics can offer their expertise and services to clinics nearby.",
                          ),

                          FeatureCard(
                            icon: Icons.work,
                            title: "Job Opportunities",
                            description:
                            "Job seekers and employers can connect easily through our dental job portal.",
                          ),

                          FeatureCard(
                            icon: Icons.people,
                            title: "General Public",
                            description:
                            "Patients can discover trusted dental professionals and clinics near them.",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  /// VISION SECTION
                  Container(
                    width: double.infinity,
                    padding:  const EdgeInsets.symmetric(vertical: 60),
                    color: Colors.white,
                    child: Center(
                      child: Container(
                        constraints:  const BoxConstraints(maxWidth: 900),
                        child:  Column(
                          children: [

                            Text(
                              "Our Vision",
                              style: AppTextStyles.caption(context,fontWeight: FontWeight.bold)
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Our vision is to build a connected digital network for the dental industry "
                                  "where clinics, laboratories, suppliers, and professionals collaborate "
                                  "efficiently and grow together.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: width*0.009,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Container(
                  //   padding: const EdgeInsets.symmetric(vertical: 25),
                  //   color: Colors.black87,
                  //   child: const Center(
                  //     child: Text(
                  //       "© 2026 LOCATE YOUR DENTIST - All Rights Reserved",
                  //       style: TextStyle(color: Colors.white70),
                  //     ),
                  //   ),
                  // ),
                  if( Api.userInfo.read('token')==null)
                    const CommonFooter()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [

          Icon(icon, size: 45, color: const Color(0xff1C8ED6)),

          const SizedBox(height: 15),

          Text(
            title,
            style:  TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          )
        ],
      ),
    );
  }
}