import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../modules/auth/login_screen/login_controller.dart';

class GumDiseaseCard extends StatelessWidget {
  // const GumDiseaseCard({super.key});
  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 768;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: isDesktop
            ? IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: _buildImageSection(isDesktop: true)),
              Expanded(flex: 6, child: _buildDetailsSection(context)),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 260, child: _buildImageSection(isDesktop: false)),
            _buildDetailsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection({required bool isDesktop}) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?auto=format&fit=crop&w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade50,
                child: const Icon(Icons.health_and_safety_outlined, size: 50, color: Colors.redAccent),
              );
            },
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '02 . HIGH RISK',
                style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
              ),
              SizedBox(height: 8),
              Text(
                'Understanding Gum Disease & Bleeding',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final loginController = Get.put(LoginController());
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Periodontitis',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gum Disease (Gingivitis)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          const Text(
            'An inflammatory condition affecting the tissues surrounding and supporting the teeth. It is mostly caused by a buildup of bacterial plaque, leading to infections that destroy the support structures of your natural teeth.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text('Common Symptoms', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          _buildBulletItem('Gums that bleed easily during brushing or flossing routines.'),
          _buildBulletItem('Swollen, tender, or bright red/dusky purple gums.'),
          _buildBulletItem('Persistent bad breath or a foul taste that will not leave.'),
          const SizedBox(height: 20),
          const Text('Available Treatments', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 12),
          _buildTreatmentChipRow([
            'Scaling & Root Planing',
            'Antimicrobial Rinses',
            'Laser Gum Therapy',
            'Flap Surgery'
          ]),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 250,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: ()async {
                  await loginController.getProfileDetails(
                    "Dental Clinic",
                    loginController.selectedState,
                    loginController.selectedDistricts,
                    loginController.selectedTalukas,loginController.selectedVillages,
                    "true",
                    '',
                    '',
                    loginController.selectedDistance.toString(),
                    '',
                    context,
                  );
                  Get.toNamed('/userTypeListWeb');
                },
                child: const Text('Find Nearby Dental Clinics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: Icon(Icons.circle, size: 6, color: Colors.amber),
          ),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildTreatmentChipRow(List<String> treatments) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: treatments.map((treatment) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Text(treatment, style: TextStyle(color: Colors.grey.shade800, fontSize: 12, fontWeight: FontWeight.w500)),
        );
      }).toList(),
    );
  }
}




class DentalServiceCard extends StatefulWidget {
  final String title;
  final String description;
  final String image;
  final String url;

  const DentalServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.url,
  });

  @override
  State<DentalServiceCard> createState() => _DentalServiceCardState();
}

class _DentalServiceCardState extends State<DentalServiceCard> {

  bool hover = false;

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(widget.url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception("Could not launch");
    }
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return MouseRegion(

      onEnter: (_) {
        setState(() => hover = true);
      },

      onExit: (_) {
        setState(() => hover = false);
      },

      child: GestureDetector(

        onTap: _launchUrl,

        child: AnimatedContainer(

          duration: const Duration(milliseconds: 250),

          width: width > 700 ? 220 : 220,

          decoration: BoxDecoration(

            color: Colors.white,

            borderRadius: BorderRadius.circular(25),

            boxShadow: [

              BoxShadow(
                color: hover
                    ? Colors.blue.withOpacity(.25)
                    : Colors.black12,
                blurRadius: hover ? 18 : 10,
                offset: const Offset(0, 6),
              )

            ],
          ),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// IMAGE
              ClipRRect(

                borderRadius: const BorderRadius.only(

                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),

                ),

                child: Stack(

                  children: [

                    Image.asset(
                      widget.image,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(.65),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(

                      left: 20,
                      bottom: 18,

                      child: Text(

                        widget.title,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Padding(

                padding: const EdgeInsets.all(20),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(

                      widget.description,

                      style: TextStyle(
                        color: Colors.grey.shade700,
                        height: 1.5,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Align(

                      alignment: Alignment.center,

                      child: AnimatedContainer(

                        duration: const Duration(milliseconds: 250),

                        height: 50,
                        width: 50,

                        decoration: BoxDecoration(

                          shape: BoxShape.circle,

                          color: hover
                              ? const Color(0xff0A3D72)
                              : Colors.blue.shade50,

                        ),

                        child: Icon(

                          Icons.arrow_forward,

                          color: hover
                              ? Colors.white
                              : Colors.blue.shade900,

                        ),
                      ),
                    )

                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}

class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  @override
  Widget build(BuildContext context) {

    final isMobile =
        MediaQuery.of(context).size.width < 900;

    return isMobile
        ?  Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      decoration:  BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _image(),
              const SizedBox(height: 30),
              _content(context),
            ],
          ),
        ),
      ),
    )
        :  Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        constraints: const BoxConstraints(maxWidth: 1500),
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(flex: 5, child: _image()),
            const SizedBox(width: 60),
            Expanded(flex: 5, child: _content(context)),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    return Stack(
      clipBehavior: Clip.none,
      children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            height: 300,
            "assets/images/welcomePage.png",
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _content(context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Text(
          "WHY CHOOSE US",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 15),

        Text(
            "Committed To Excellent Dental Care",
            style: AppTextStyles.subtitle(context,color: AppColors.white)
        ),

        SizedBox(height: 20),

        Text(
          "Connect with trusted dentists, dental clinics, and specialists. Book appointments, compare services, and receive quality dental care effortlessly.",
          style: TextStyle(
            height: 1.8,
            color: Colors.white,
          ),
        ),

        SizedBox(height: 30),

        buildFeature(
            Icons.verified,
            "Verified Dentists",context
        ),

        buildFeature(
            Icons.local_hospital,
            "Emergency Dental Care",context
        ),

        buildFeature(
            Icons.support_agent,
            "24/7 Support",context
        ),
      ],
    );
  }

  Widget buildFeature(
      IconData icon,
      String title,dynamic context
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
            Colors.white.withOpacity(.1),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 15),

          Text(
              title,
              style: AppTextStyles.caption(context,  color: Colors.white,)
          ),
        ],
      ),
    );
  }
}







