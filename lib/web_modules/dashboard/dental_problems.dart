import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../modules/auth/login_screen/login_controller.dart';

class GumDiseaseCard extends StatelessWidget {
  final loginController = Get.put(LoginController());

  GumDiseaseCard({super.key});

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
              color: Colors.black.withValues(alpha: 0.04),
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
                    Expanded(
                      flex: 5,
                      child: _buildImageSection(isDesktop: true),
                    ),
                    Expanded(flex: 6, child: _buildDetailsSection(context)),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 260,
                    child: _buildImageSection(isDesktop: false),
                  ),
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
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  size: 50,
                  color: Colors.redAccent,
                ),
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
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
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
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Understanding Gum Disease & Bleeding',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
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
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Periodontitis',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gum Disease (Gingivitis)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'An inflammatory condition affecting the tissues surrounding and supporting the teeth. It is mostly caused by a buildup of bacterial plaque, leading to infections that destroy the support structures of your natural teeth.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Common Symptoms',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletItem(
            'Gums that bleed easily during brushing or flossing routines.',
          ),
          _buildBulletItem('Swollen, tender, or bright red/dusky purple gums.'),
          _buildBulletItem(
            'Persistent bad breath or a foul taste that will not leave.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Treatments',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildTreatmentChipRow([
            'Scaling & Root Planing',
            'Antimicrobial Rinses',
            'Laser Gum Therapy',
            'Flap Surgery',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await loginController.getProfileDetails(
                    "Dental Clinic",
                    loginController.selectedState,
                    loginController.selectedDistrict,
                    loginController.selectedTaluka,
                    loginController.selectedVillages,
                    "true",
                    '',
                    '',
                    loginController.selectedDistance.toString(),
                    '',
                    context,
                  );
                  Get.toNamed('/userTypeListWeb');
                },
                child: const Text(
                  'Find Nearby Dental Clinics',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ),
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
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
          child: Text(
            treatment,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class DentalServiceCard extends StatelessWidget {
  final String title;
  final String image;
  final String url;

  const DentalServiceCard({
    super.key,
    required this.title,
    required this.image,
    required this.url,
  });

  Future<void> _launchUrl() async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _launchUrl,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(image, height: 120, width: 90),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class BruxismCard extends StatelessWidget {
  const BruxismCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 768;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                    Expanded(
                      flex: 5,
                      child: _buildImageSection(isDesktop: true),
                    ),
                    Expanded(flex: 6, child: _buildDetailsSection(context)),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 260,
                    child: _buildImageSection(isDesktop: false),
                  ),
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
            'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade50,
                child: const Icon(
                  Icons.gavel_rounded,
                  size: 50,
                  color: Colors.purple,
                ),
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
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
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
                '03 . STRESS RELATED',
                style: TextStyle(
                  color: Colors.purpleAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bruxism & Jaw Tension Damage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final loginController = Get.put(LoginController());
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Occlusal Trauma',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Teeth Grinding (Bruxism)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'A condition in which you unconsciously grind, gnash, or clench your teeth. This frequently happens during sleep (sleep bruxism) and can lead to severe structural wear on tooth enamel, micro-fractures, and joint complications.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Common Symptoms',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletItem(
            'Teeth that are flattened, fractured, chipped, or loose.',
          ),
          _buildBulletItem(
            'Worn tooth enamel, exposing deeper layers of yellow dentin.',
          ),
          _buildBulletItem(
            'Increased tooth pain, jaw soreness, or dull morning headaches.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Treatments',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildTreatmentChipRow([
            'Custom Night Guards',
            'Occlusal Adjustment',
            'Stress Management',
            'Muscle Relaxants',
          ]),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 260,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await loginController.getProfileDetails(
                    "Dental Clinic",
                    loginController.selectedState,
                    loginController.selectedDistrict,
                    loginController.selectedTaluka,
                    loginController.selectedVillages,
                    "true",
                    '',
                    '',
                    loginController.selectedDistance.toString(),
                    '',
                    context,
                  );
                  Get.toNamed('/userTypeListWeb');
                },
                icon: Icon(Icons.search, color: AppColors.white, size: 16),
                label: const Text(
                  "Find Nearby Dental Clinics",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
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
          child: Text(
            treatment,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SensitivityCard extends StatelessWidget {
  const SensitivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 768;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                    Expanded(
                      flex: 5,
                      child: _buildImageSection(isDesktop: true),
                    ),
                    Expanded(flex: 6, child: _buildDetailsSection(context)),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 260,
                    child: _buildImageSection(isDesktop: false),
                  ),
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
            'https://images.unsplash.com/photo-1598256989800-fe5f95da9787?auto=format&fit=crop&w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade50,
                child: const Icon(
                  Icons.ac_unit_rounded,
                  size: 50,
                  color: Colors.teal,
                ),
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
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
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
                '04 . NERVE ROOT SENSITIVE',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Managing Sharp Temperature Sensitivity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final loginController = Get.put(LoginController());
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Dentin Hypersensitivity',
              style: TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tooth Sensitivity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'The discomfort or sharp pain in teeth as a response to certain stimuli, such as hot or cold temperatures. It occurs when the underlying protective tooth layer (dentin) is exposed due to receding gums or worn enamel.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Common Symptoms',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletItem(
            'Sharp, sudden pain when consuming hot or cold foods/liquids.',
          ),
          _buildBulletItem(
            'Discomfort when breathing in cold ambient air through the mouth.',
          ),
          _buildBulletItem(
            'Pain when eating highly sweet or acidic foods and citrus.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Treatments',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildTreatmentChipRow([
            'Desensitizing Toothpaste',
            'Fluoride Varnish Gels',
            'Surgical Gum Grafts',
            'Bonding Resin Seals',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await loginController.getProfileDetails(
                    "Dental Clinic",
                    loginController.selectedState,
                    loginController.selectedDistrict,
                    loginController.selectedTaluka,
                    loginController.selectedVillages,
                    "true",
                    '',
                    '',
                    loginController.selectedDistance.toString(),
                    '',
                    context,
                  );
                  Get.toNamed('/userTypeListWeb');
                },
                child: const Text(
                  'Find Nearby Dental Clinics',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ),
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
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
          child: Text(
            treatment,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class WisdomTeethCard extends StatelessWidget {
  const WisdomTeethCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 768;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                    Expanded(
                      flex: 5,
                      child: _buildImageSection(isDesktop: true),
                    ),
                    Expanded(flex: 6, child: _buildDetailsSection(context)),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 260,
                    child: _buildImageSection(isDesktop: false),
                  ),
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
            'https://images.unsplash.com/photo-1579684389782-64d84b5e901a?auto=format&fit=crop&w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade50,
                child: const Icon(
                  Icons.masks_rounded,
                  size: 50,
                  color: Colors.orange,
                ),
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
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
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
                '05 . ORAL SURGERY',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Managing Third Molar Crowding & Pain',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final loginController = Get.put(LoginController());
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Molar Impaction',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Impacted Wisdom Teeth',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Third molars at the back of the mouth that do not have enough room to emerge or develop normally. They can grow at wrong angles, pressuring adjacent healthy teeth, causing structural alignment shifting, cysts, or deep infections.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Common Symptoms',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletItem(
            'Red, swollen, or tender gums situated right behind your back molars.',
          ),
          _buildBulletItem(
            'Jaw pain, facial swelling, or severe difficulty fully opening your mouth.',
          ),
          _buildBulletItem(
            'Persistent bad breath or a strange, unpleasant taste when chewing nearby.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Treatments',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildTreatmentChipRow([
            'Surgical Extraction',
            'Diagnostic 3D Imaging',
            'Antibiotic Therapy',
            'Operculectomy',
          ]),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 260,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await loginController.getProfileDetails(
                    "Dental Clinic",
                    loginController.selectedState,
                    loginController.selectedDistrict,
                    loginController.selectedTaluka,
                    loginController.selectedVillages,
                    "true",
                    '',
                    '',
                    loginController.selectedDistance.toString(),
                    '',
                    context,
                  );
                  Get.toNamed('/userTypeListWeb');
                },
                icon: Icon(Icons.search, color: AppColors.white, size: 16),
                label: const Text(
                  "Find Nearby Dental Clinics",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
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
          child: Text(
            treatment,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class AbscessCard extends StatelessWidget {
  const AbscessCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 768;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(60),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                    Expanded(
                      flex: 5,
                      child: _buildImageSection(isDesktop: true),
                    ),
                    Expanded(flex: 6, child: _buildDetailsSection(context)),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 260,
                    child: _buildImageSection(isDesktop: false),
                  ),
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
            'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade50,
                child: const Icon(
                  Icons.report_problem_outlined,
                  size: 50,
                  color: Colors.red,
                ),
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
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
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
                '06 . CRITICAL EMERGENCY',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Urgent Care for Deep Bacterial Infestations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final loginController = Get.put(LoginController());
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Periapical Abscess',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dental Abscess (Infection)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'A localized collection of pus caused by a bacterial infection spreading down into the innermost pulp chamber of a tooth. This is an urgent condition that requires immediate treatment to prevent the infection from spreading into the jawbone.',
            style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Common Symptoms',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletItem(
            'Severe, throbbing toothache that radiates to the jawbone, neck, or ear.',
          ),
          _buildBulletItem(
            'Fever, facial swelling, or tender, swollen lymph nodes under your jaw.',
          ),
          _buildBulletItem(
            'A pimple-like bump on your gums that may rupture and leak fluid.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Available Treatments',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildTreatmentChipRow([
            'Incision & Drainage',
            'Root Canal Therapy',
            'Emergency Extraction',
            'Systemic Antibiotics',
          ]),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 260,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await loginController.getProfileDetails(
                    "Dental Clinic",
                    loginController.selectedState,
                    loginController.selectedDistrict,
                    loginController.selectedTaluka,
                    loginController.selectedVillages,
                    "true",
                    '',
                    '',
                    loginController.selectedDistance.toString(),
                    '',
                    context,
                  );
                  Get.toNamed('/userTypeListWeb');
                },
                icon: Icon(Icons.search, color: AppColors.white, size: 16),
                label: const Text(
                  "Find Nearby Dental Clinics",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
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
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
          ),
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
          child: Text(
            treatment,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class WhyChooseUsSection extends StatelessWidget {
  const WhyChooseUsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return isMobile
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
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
        : Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              constraints: const BoxConstraints(maxWidth: 1500),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
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
        // Container(
        //   height: 450,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(250),
        //     image: const DecorationImage(
        //       image: Image.asset(
        //         "assets/images/7p.jpg",
        //       ),
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "WHY CHOOSE US",
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 15),

        Text(
          "Committed To Excellent Dental Care",
          style: AppTextStyles.subtitle(context, color: AppColors.white),
        ),

        SizedBox(height: 20),

        Text(
          "Connect with trusted dentists, dental clinics, and specialists. Book appointments, compare services, and receive quality dental care effortlessly.",
          style: TextStyle(height: 1.8, color: Colors.white),
        ),

        SizedBox(height: 30),

        buildFeature(Icons.verified, "Verified Dentists", context),

        buildFeature(Icons.local_hospital, "Emergency Dental Care", context),

        buildFeature(Icons.support_agent, "24/7 Support", context),

        // buildFeature(
        //   Icons.calendar_month,
        //   "People's can search nearby Clinic location",
        // ),
      ],
    );
  }

  Widget buildFeature(IconData icon, String title, dynamic context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: .1),
            child: Icon(icon, color: Colors.white),
          ),

          const SizedBox(width: 15),

          Text(
            title,
            style: AppTextStyles.caption(context, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

Widget stepCard(String number, String title, IconData icon) {
  return Container(
    width: 180,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
    ),
    child: Column(
      children: [
        CircleAvatar(radius: 28, child: Icon(icon)),
        const SizedBox(height: 10),
        Text(
          "Step $number",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(title, textAlign: TextAlign.center),
      ],
    ),
  );
}

class BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> points;

  const BenefitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xff14B8A6).withValues(alpha: .1),
            child: Icon(icon, color: const Color(0xff14B8A6), size: 30),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          ...points.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget dentalTreatmentWidget() {
  final treatments = [
    {
      "title": "Root Canal",
      "icon": Icons.medical_services,
      "color": Colors.red,
    },
    {
      "title": "Dental Implant",
      "icon": Icons.health_and_safety,
      "color": Colors.blue,
    },
    {
      "title": "Aligners",
      "icon": Icons.align_horizontal_left,
      "color": Colors.green,
    },
    {
      "title": "Orthodonics Appliances",
      "icon": Icons.architecture,
      "color": Colors.orange,
    },
    {"title": "Gum Treatment", "icon": Icons.healing, "color": Colors.purple},
    {
      "title": "Brushing Technique",
      "icon": Icons.clean_hands,
      "color": Colors.teal,
    },
  ];

  return Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Popular Dental Treatments",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        Text(
          "Find dental clinics based on your treatment needs",
          style: TextStyle(color: Colors.grey.shade600),
        ),

        const SizedBox(height: 25),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: treatments.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 2.3,
          ),
          itemBuilder: (context, index) {
            final item = treatments[index];

            return InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: (item["color"] as Color).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (item["color"] as Color),
                      child: Icon(
                        item["icon"] as IconData,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item["title"] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget clinicSearchWidget() {
  return Container(
    padding: const EdgeInsets.all(25),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Find Dental Clinics",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 20),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "State",
            border: OutlineInputBorder(),
          ),
          items: [
            "Tamil Nadu",
            "Kerala",
            "Karnataka",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) {},
        ),

        const SizedBox(height: 15),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: "District",
            border: OutlineInputBorder(),
          ),
          items: [
            "Madurai",
            "Chennai",
            "Coimbatore",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) {},
        ),

        const SizedBox(height: 15),

        TextFormField(
          decoration: const InputDecoration(
            labelText: "Area / City",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search),
            label: const Text("Search Clinics"),
          ),
        ),
      ],
    ),
  );
}

class BrushingTechniqueCard extends StatelessWidget {
  const BrushingTechniqueCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final loginController = Get.put(LoginController());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      // decoration: const BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [
      //       AppColors.primary,
      //       AppColors.secondary,
      //     ],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      // ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: isDesktop
              ? Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                        child: Image.asset(
                          "assets/images/tooth_brush.jpg",
                          height: 500,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(flex: 6, child: _content(context)),
                  ],
                )
              : Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      child: Image.asset(
                        "assets/images/tooth_brush.jpg",
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    _content(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _content(dynamic context) {
    final loginController = Get.put(LoginController());
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Dental Awareness",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Proper Brushing Technique",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          const Text(
            "Brushing correctly removes plaque, prevents cavities, reduces gum disease risk, and keeps your breath fresh. Dentists recommend brushing twice daily for at least two minutes.",
            style: TextStyle(height: 1.6, color: Colors.black54),
          ),

          const SizedBox(height: 25),

          const Text(
            "Steps to Brush Properly",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          _step("1", "Hold toothbrush at 45° angle to gums"),
          _step("2", "Use gentle circular motions"),
          _step("3", "Clean outer and inner tooth surfaces"),
          _step("4", "Brush chewing surfaces thoroughly"),
          _step("5", "Brush tongue to remove bacteria"),
          _step("6", "Brush for at least 2 minutes"),

          const SizedBox(height: 25),

          const Text(
            "Benefits",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip("Fresh Breath"),
              _chip("Healthy Gums"),
              _chip("Prevents Cavities"),
              _chip("Whiter Teeth"),
              _chip("Removes Plaque"),
            ],
          ),

          const SizedBox(height: 25),

          Center(
            child: SizedBox(
              width: 260,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await loginController.getProfileDetails(
                    "Dental Clinic",
                    loginController.selectedState,
                    loginController.selectedDistrict,
                    loginController.selectedTaluka,
                    loginController.selectedVillages,
                    "true",
                    '',
                    '',
                    loginController.selectedDistance.toString(),
                    '',
                    context,
                  );
                  Get.toNamed('/userTypeListWeb');
                },
                icon: Icon(Icons.search, color: AppColors.white, size: 16),
                label: const Text(
                  "Find Nearby Dental Clinics",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(String no, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blue,
            child: Text(
              no,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _chip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.green.shade800,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

final treatments = [
  {
    "title": "Root Canal Treatment",
    "image": "assets/images/rootcanal.jpg",
    "category": "Endodontics",
    "description":
        "Root canal treatment removes infected pulp and saves the natural tooth from extraction.",
    "symptoms": [
      "Severe tooth pain",
      "Sensitivity to hot & cold",
      "Swollen gums",
      "Darkened tooth",
    ],
    "treatments": ["Root Canal Therapy", "Crown Placement", "Pain Management"],
    "color": AppColors.primary,
  },

  {
    "title": "Dental Implants",
    "image": "assets/images/dental_implant.jpg",
    "category": "Tooth Replacement",
    "description":
        "Dental implants provide a permanent solution for missing teeth.",
    "symptoms": [
      "Missing tooth",
      "Difficulty chewing",
      "Jaw bone loss",
      "Speech issues",
    ],
    "treatments": ["Titanium Implant", "Bone Grafting", "Implant Crown"],
    "color": AppColors.primary,
  },

  {
    "title": "Clear Aligners",
    "image": "assets/images/aligners.jpg",
    "category": "Orthodontics",
    "description": "Invisible aligners gradually straighten teeth comfortably.",
    "symptoms": ["Crooked teeth", "Spacing", "Crowding", "Misaligned bite"],
    "treatments": ["Clear Aligners", "Digital Smile Planning", "Retention"],
    "color": AppColors.primary,
  },

  {
    "title": "Orthodontic Appliances",
    "image": "assets/images/orthodontic_appliances.jpg",
    "category": "Braces",
    "description":
        "Braces and orthodontic appliances correct alignment and bite issues.",
    "symptoms": [
      "Overbite",
      "Underbite",
      "Crowded teeth",
      "Jaw alignment issues",
    ],
    "treatments": ["Metal Braces", "Ceramic Braces", "Retainers"],
    "color": AppColors.primary,
  },

  {
    "title": "Gum Treatment",
    "image": "assets/images/gum_treat.jpg",
    "category": "Periodontics",
    "description":
        "Professional gum care helps prevent tooth loss and infections.",
    "symptoms": ["Bleeding gums", "Bad breath", "Swollen gums", "Loose teeth"],
    "treatments": ["Scaling", "Root Planing", "Laser Therapy"],
    "color": AppColors.primary,
  },

  {
    "title": "General Dental Checkup",
    "image": "assets/images/tooth_brush.jpg",
    "category": "Preventive Care",
    "description":
        "Regular dental checkups help identify problems before they become serious.",
    "symptoms": [
      "Routine care",
      "Tooth pain",
      "Sensitivity",
      "Oral health assessment",
    ],
    "treatments": ["Oral Examination", "X-Ray", "Professional Cleaning"],
    "color": AppColors.primary,
  },
];

class TreatmentCard extends StatelessWidget {
  final Map treatment;
  final bool reverse;

  const TreatmentCard({
    super.key,
    required this.treatment,
    required this.reverse,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      // decoration: const BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: [
      //       AppColors.primary,
      //       AppColors.secondary,
      //     ],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      // ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1500),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: isDesktop
              ? IntrinsicHeight(
                  child: Row(
                    children: reverse
                        ? [
                            Expanded(
                              flex: 6,
                              child: _buildDetailsSection(context),
                            ),
                            Expanded(flex: 5, child: _buildImageSection()),
                          ]
                        : [
                            Expanded(flex: 5, child: _buildImageSection()),
                            Expanded(
                              flex: 6,
                              child: _buildDetailsSection(context),
                            ),
                          ],
                  ),
                )
              : Column(
                  children: [
                    SizedBox(height: 280, child: _buildImageSection()),
                    _buildDetailsSection(context),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(treatment["image"] ?? "", fit: BoxFit.cover),
          ),
        ),

        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .1),
                  Colors.black.withValues(alpha: .6),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          left: 25,
          right: 25,
          bottom: 25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                treatment["category"] ?? "",
                style: TextStyle(
                  color: treatment["color"] ?? "",
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                treatment["title"] ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    final loginController = Get.put(LoginController());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: (treatment["color"] as Color).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              treatment["category"] ?? "",
              style: TextStyle(
                color: treatment["color"] ?? "",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            treatment["title"] ?? "",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            treatment["description"] ?? "",
            style: const TextStyle(
              height: 1.6,
              color: Colors.black54,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 15),

          const Divider(),

          const SizedBox(height: 18),

          const Text(
            "Common Symptoms",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),

          const SizedBox(height: 12),

          ...(treatment["symptoms"] ?? "" as List)
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: treatment["color"] ?? "",
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          e,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          const SizedBox(height: 25),

          const Text(
            "Available Treatments",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (treatment["treatments"] as List)
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: (treatment["color"] as Color).withValues(
                        alpha: .08,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      e,
                      style: TextStyle(
                        color: treatment["color"] ?? "",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 25),

          Center(
            child: SizedBox(
              width: 260,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: treatment["color"] ?? "",
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await loginController.getProfileDetails(
                    "Dental Clinic",
                    loginController.selectedState,
                    loginController.selectedDistrict,
                    loginController.selectedTaluka,
                    loginController.selectedVillages,
                    "true",
                    '',
                    '',
                    loginController.selectedDistance.toString(),
                    '',
                    context,
                  );
                  Get.toNamed('/userTypeListWeb');
                },
                icon: const Icon(Icons.search, color: AppColors.white),
                label: const Text(
                  "Find Nearby Dental Clinics",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
