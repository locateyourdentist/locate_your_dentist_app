import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../../../api/api.dart';
import '../../../common_widgets/color_code.dart';
import '../../../common_widgets/common_textstyles.dart';
import 'register_page.dart';

class DentalProfessionalRegisterPage extends StatefulWidget {
  const DentalProfessionalRegisterPage({super.key});

  @override
  State<DentalProfessionalRegisterPage> createState() =>
      _DentalProfessionalRegisterPageState();
}

class _DentalProfessionalRegisterPageState
    extends State<DentalProfessionalRegisterPage> {
  static const Color primaryBlue = AppColors.primary;
  static const Color darkText = AppColors.black;
  static const Color secondaryText = AppColors.grey;
  static const Color lightBlue = AppColors.primaryLight;
  static const Color borderColor = AppColors.primaryLight2;
  static const String professionalKeyStorage = 'professional_key';

  static const String professionalTypeStorage = 'professional_type';

  // ============================================================
  // YOUR CATEGORY DATA
  // ============================================================

  final List<Map<String, String>> allItems = [
    {"key": "admin", "value": "Admin"},
    {"key": "superAdmin", "value": "Super Admin"},
    {"key": "dentist", "value": "Dental Clinic"},
    {"key": "dentalLab", "value": "Dental Lab"},
    {"key": "dentalShop", "value": "Dental Shop"},
    {"key": "dentalMechanic", "value": "Dental Mechanic"},
    {"key": "Dental jobSeekers", "value": "Job Seekers"},
    {"key": "Dental Professionals", "value": "Dental Consultant"},
  ];

  bool isLoading = false;

  String? selectedKey;
  String? selectedValue;
  List<Map<String, String>> get registrationItems {
    return allItems.where((item) {
      final key = item["key"];

      return key == "dentist" ||
          key == "dentalLab" ||
          key == "dentalShop" ||
          key == "dentalMechanic" ||
          key == "Job Seekers" ||
          key == "Dental Consultant";
    }).toList();
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadSelectedCategory();
  }

  Future<void> _loadSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();

    final savedKey = prefs.getString(professionalKeyStorage);

    final savedValue = prefs.getString(professionalTypeStorage);

    if (!mounted) return;

    setState(() {
      selectedKey = savedKey;
      selectedValue = savedValue;
    });
  }

  // ============================================================
  // SAVE CATEGORY
  // ============================================================

  Future<void> _selectCategory(Map<String, String> item) async {
    if (isLoading) return;

    final String key = item["key"] ?? "";
    final String value = item["value"] ?? "";

    if (key.isEmpty || value.isEmpty) {
      _showError("Invalid category selected.");
      return;
    }

    setState(() {
      isLoading = true;
      selectedKey = key;
      selectedValue = value;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      Api.userInfo.write('userType',key);
      // Store KEY
      await prefs.setString(professionalKeyStorage, key);

      // Store VALUE
      await prefs.setString(professionalTypeStorage, value);

      debugPrint("====================================");

      debugPrint("Professional Key   : $key");

      debugPrint("Professional Type  : $value");

      debugPrint("====================================");

      if (!mounted) return;

      // --------------------------------------------------------
      // Navigate to next page
      // --------------------------------------------------------

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegisterPage()),
      );
    } catch (e) {
      debugPrint("Error saving professional category: $e");

      if (mounted) {
        _showError("Unable to save category. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ============================================================
  // GET ICON
  // ============================================================

  IconData _getCategoryIcon(String key) {
    switch (key) {
      case "dentist":
        return Icons.medical_services_outlined;

      case "dentalLab":
        return Icons.biotech_outlined;

      case "dentalShop":
        return Icons.storefront_outlined;

      case "dentalMechanic":
        return Icons.event_seat_outlined;

      case "Dental jobSeekers":
        return Icons.person_search_outlined;

      case "Dental Professionals":
        return Icons.person_outline;

      default:
        return Icons.medical_services_outlined;
    }
  }

  // Short label shown on the category card. Kept separate from the
  // stored "value" (e.g. "Dental Shop") so saved/registered data stays
  // unchanged while the card text matches the reference design.
  String _getDisplayLabel(String key, String fallbackValue) {
    switch (key) {
      case "dentist":
        return "Dentist";

      case "dentalShop":
        return "Shop Owners";

      case "dentalLab":
        return "Dental Lab";

      case "dentalMechanic":
        return "Chair & Instrument\nMechanic";

      default:
        return fallbackValue;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(),

            // BODY
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // LOGO
                    _buildLogoBlock(),

                    const SizedBox(height: 24),

                    // TITLE
                    _buildTitleSection(),

                    const SizedBox(height: 30),

                    // CATEGORY LIST
                    _buildCategoryList(),

                    const SizedBox(height: 18),

                    // LOGIN
                    _buildLoginLink(),

                    const SizedBox(height: 12),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Get.toNamed('/patientDashboard');
                        },
                        child: Text(
                          "Back To Home",
                          style: AppTextStyles.body(
                            context,
                            color: primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return SizedBox(
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // BACK BUTTON
          Positioned(
            left: 14,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(30),
              child: const Padding(
                padding: EdgeInsets.all(9),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 21,
                  color: darkText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogoBlock() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryBlue, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logolyd.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.local_hospital,
                color: primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "LYD",
          style: AppTextStyles.headline1(context, color: darkText),
        ),
        Text(
          "Locate Your Dentist",
          style: AppTextStyles.caption(
            context,
            color: primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        const Text(
          "Dental Professional Entry",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Choose your professional category",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: secondaryText,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: primaryBlue,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY GRID
  // ============================================================

  Widget _buildCategoryList() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.95,
      children: registrationItems.map((item) {
        return _buildCategoryCard(item);
      }).toList(),
    );
  }

  // ============================================================
  // CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard(Map<String, String> item) {
    final String key = item["key"] ?? "";
    final String value = item["value"] ?? "";

    final bool isSelected = selectedKey == key;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                _selectCategory(item);
              },

        borderRadius: BorderRadius.circular(16),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),

          decoration: BoxDecoration(
            color: isSelected ? lightBlue : Colors.white,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: isSelected ? primaryBlue : borderColor,
              width: isSelected ? 1.4 : 1,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ICON / LOADING
                if (isLoading && isSelected)
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryBlue,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: lightBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(key),
                      size: 29,
                      color: primaryBlue,
                    ),
                  ),

                const SizedBox(height: 10),

                Text(
                  _getDisplayLabel(key, value),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(fontSize: 14, color: secondaryText),
        ),

        GestureDetector(
          onTap: () {
            Get.toNamed('/loginPage');
          },

          child: const Text(
            "Login",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryBlue,
            ),
          ),
        ),
      ],
    );
  }
}
