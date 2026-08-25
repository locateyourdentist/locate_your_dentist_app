import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'register_page.dart';

class DentalProfessionalRegisterPage extends StatefulWidget {
  const DentalProfessionalRegisterPage({super.key});

  @override
  State<DentalProfessionalRegisterPage> createState() =>
      _DentalProfessionalRegisterPageState();
}

class _DentalProfessionalRegisterPageState
    extends State<DentalProfessionalRegisterPage> {
  static const Color primaryBlue = Color(0xFF0759C9);
  static const Color darkText = Color(0xFF101828);
  static const Color secondaryText = Color(0xFF667085);
  static const Color lightBlue = Color(0xFFF4F8FF);
  static const Color borderColor = Color(0xFFE5E7EB);
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
        return Icons.event_seat_outlined;

      case "dentalLab":
        return Icons.biotech_outlined;

      case "dentalShop":
        return Icons.shopping_cart_outlined;

      case "dentalMechanic":
        return Icons.build_outlined;

      case "Dental jobSeekers":
        return Icons.person_search_outlined;

      case "Dental Professionals":
        return Icons.person_outline;

      default:
        return Icons.medical_services_outlined;
    }
  }

  // ============================================================
  // GET SUBTITLE
  // ============================================================

  String _getCategorySubtitle(String key) {
    switch (key) {
      case "dentist":
        return "General Dentist, Specialist, etc.";

      case "dentalLab":
        return "Dental Laboratory / Technician";

      case "dentalShop":
        return "Dental Products & Materials";

      case "dentalMechanic":
        return "Chair, Equipment Repair & Service";

      case "Dental jobSeekers":
        return "Dental Jobs / Employment";

      case "Dental Professionals":
        return "Consultant / Advisor";

      default:
        return "";
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

                    // PROGRESS
                    _buildProgressIndicator(),

                    const SizedBox(height: 40),

                    // TITLE
                    _buildTitleSection(),

                    const SizedBox(height: 30),

                    // CATEGORY LIST
                    _buildCategoryList(),

                    const SizedBox(height: 18),

                    // LOGIN
                    _buildLoginLink(),

                    const SizedBox(height: 12),
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
      height: 62,
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

          // TITLE
          const Text(
            "Dental Professional\nRegister",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: darkText,
              letterSpacing: -0.25,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROGRESS BAR
  // ============================================================

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressLine(true),
        const SizedBox(width: 7),
        _buildProgressLine(false),
        const SizedBox(width: 7),
        _buildProgressLine(false),
        const SizedBox(width: 7),
        _buildProgressLine(false),
      ],
    );
  }

  Widget _buildProgressLine(bool active) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 5,
        decoration: BoxDecoration(
          color: active ? primaryBlue : const Color(0xFFD9DEE5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return const Column(
      children: [
        Text(
          "Select Your Category",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),

        SizedBox(height: 8),

        Text(
          "Choose the option that best describes you",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: secondaryText,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY LIST
  // ============================================================

  Widget _buildCategoryList() {
    return Column(
      children: registrationItems.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCategoryCard(item),
        );
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

          height: 96,

          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF4F8FF) : Colors.white,

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

          child: Row(
            children: [
              const SizedBox(width: 16),

              // ICON
              Container(
                width: 58,
                height: 58,

                decoration: const BoxDecoration(
                  color: lightBlue,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  _getCategoryIcon(key),
                  size: 31,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(width: 17),

              // TEXT
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      value,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _getCategorySubtitle(key),

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.2,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // ARROW / LOADING
              if (isLoading && isSelected)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryBlue,
                  ),
                )
              else
                const Icon(Icons.chevron_right, size: 28, color: darkText),

              const SizedBox(width: 12),
            ],
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
