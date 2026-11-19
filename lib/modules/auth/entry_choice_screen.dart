import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';

class EntryChoiceScreen extends StatelessWidget {
  const EntryChoiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned(
            bottom: -20,
            right: -20,
            child: Icon(
              Icons.local_hospital_outlined,
              size: size * 0.55,
              color: AppColors.primaryLight2.withOpacity(0.35),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, size),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: size * 0.06),
                    child: Column(
                      children: [
                        SizedBox(height: size * 0.08),
                        Icon(
                          Icons.local_hospital_outlined,
                          size: size * 0.13,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: size * 0.03),
                        Text(
                          "Welcome to LYD",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headline1(
                            context,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: size * 0.015),
                        Text(
                          "Find the right dental care, near you.",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(context, color: AppColors.grey,),
                        ),
                        SizedBox(height: size * 0.09),
                        _entryCard(
                          context,
                          size: size,
                          icon: Icons.groups_outlined,
                          title: "Public Entry",
                          description: "Find nearby clinics, book appointments and access dental services.",
                          onTap: () => Get.offAllNamed('/patientDashboard'),
                        ),
                        SizedBox(height: size * 0.05),
                        _entryCard(
                          context,
                          size: size,
                          icon: Icons.medical_services_outlined,
                          title: "Dental Professional Entry",
                          description:
                              "Login to manage your profile, clinic and services.",
                          onTap: () => Get.toNamed('/loginTypesPage'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double size) {
    return Container(
      padding: EdgeInsets.fromLTRB(size * 0.06, size * 0.05, size * 0.06, size * 0.06),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size * 0.14,
            height: size * 0.14,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logolyd.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_hospital,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(width: size * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LYD",
                  style: AppTextStyles.headline(
                    context,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  "Locate Your Dentist",
                  style: AppTextStyles.caption(
                    context,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Get.offAllNamed('/patientDashboard'),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                Icons.home_outlined,
                color: AppColors.white,
                size: size * 0.08,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryCard(
    BuildContext context, {
    required double size,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(size * 0.045),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryLight2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: size * 0.16,
                height: size * 0.16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                ),
                child: Icon(icon, color: AppColors.primary, size: size * 0.08),
              ),
              SizedBox(width: size * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.subtitle(
                        context,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.body(
                        context,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
