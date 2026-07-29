import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/profiles/jobseeker_edit_profile.dart';
import 'package:locate_your_dentist/modules/profiles/pdf_path_view_page.dart';
import 'package:get/get.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Hover/lift affordance (desktop & web pointers) used purely for a modern,
/// tactile feel on tappable cards/tiles; does not intercept taps.
class _HoverLift extends StatefulWidget {
  final Widget child;
  final double liftScale;
  final BorderRadius? borderRadius;
  const _HoverLift({required this.child, this.liftScale = 1.02, this.borderRadius});

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _hovering ? -4.0 : 0.0)
          ..scale(_hovering ? widget.liftScale : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(_hovering ? 0.18 : 0.0),
              blurRadius: _hovering ? 20 : 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

/// Fades + slides a child in once on build, for a gentle section reveal.
class _RevealIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  const _RevealIn({required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class JobSeekerProfilePage extends StatefulWidget {
  const JobSeekerProfilePage({super.key});
  @override
  State<JobSeekerProfilePage> createState() => _JobSeekerProfilePageState();
}

class _JobSeekerProfilePageState extends State<JobSeekerProfilePage> {
  final loginController = Get.put(LoginController());
  final ScrollController _scrollController = ScrollController();
  late QuillController _controller;
  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];

      if (data == null) {
        delta = [
          {"insert": "\n"},
        ];
      } else if (data is List) {
        delta = List<Map<String, dynamic>>.from(data);
      } else if (data is String) {
        delta = List<Map<String, dynamic>>.from(jsonDecode(data));
      }

      _controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      print("Quill load error: $e");
      _controller = QuillController.basic();
    }
  }

  @override
  void initState() {
    super.initState();
    //loginController.getProfileByUserId(Api.userInfo.read('userId')??"", context);
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
      ),
    );
    _refresh();
  }

  Future<void> _refresh() async {
    print('sid${Api.userInfo.read('selectUId') ?? ""}');
    await loginController.getProfileByUserId(
      Api.userInfo.read('selectUId') ?? "",
      context,
    );
    print('sd${Api.userInfo.read('selectUId')??""}');
    await loginController.fetchStates();
    await loginController.getProfileByUserId(Api.userInfo.read('selectUId')??"", context);
    loadJobDescription(loginController.descriptionData);
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    String userType = Api.userInfo.read('userType') ?? "";
    final hasData = loginController.userData.isNotEmpty;
    final user = hasData ? loginController.userData.first : null;
    final collegeDetails = hasData
        ? (user?.details['collegeDetails'] ?? {})
        : {};
    final ug = collegeDetails['ugDegree'] ?? {};
    final pg = collegeDetails['pgDegree'] ?? {};
    final experiences = hasData
        ? (user?.details['experienceDetails'] ?? [])
        : [];
    final description = hasData
        ? user?.details["description"]?.toString() ?? ""
        : "";
    final categoryString = (hasData && user?.details['jobCategory'] is List)
        ? (user!.details['jobCategory'] as List).join(", ")
        : user?.details['jobCategory']?.toString() ?? "";
    final canEdit = userType == 'admin' ||
        userType == 'superAdmin' ||
        user?.userId == (Api.userInfo.read('userId') ?? "");
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    if (hasData) ...[

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 46),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                _HoverLift(
                                  liftScale: 1.08,
                                  borderRadius: BorderRadius.circular(50),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.18),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Profile',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.subtitle(context, color: Colors.white),
                                  ),
                                ),
                                if (canEdit)
                                  _HoverLift(
                                    liftScale: 1.08,
                                    borderRadius: BorderRadius.circular(50),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const EditProfilePage(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.18),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.edit_outlined,
                                            color: AppColors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox(width: 40),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: size * 0.16,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: size * 0.155,
                                  backgroundColor: const Color(0xFFF1F3F6),
                                  backgroundImage:
                                      (user!.images.isNotEmpty &&
                                          user.images[0].isNotEmpty)
                                      ? NetworkImage(user.images[0])
                                      : null,
                                  child:
                                      (user.images.isEmpty ||
                                          user.images[0].isEmpty)
                                      ? Icon(Icons.person, size: size * 0.14, color: AppColors.primary.withOpacity(0.5))
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              user.name ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: size * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if ((user.email ?? "").isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: size * 0.032,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _RevealIn(
                            child: _sectionCard(
                            size: size,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _sectionTitleInline(Icons.info_outline_rounded, "About", size),
                                    if (canEdit)
                                      _HoverLift(
                                        liftScale: 1.05,
                                        borderRadius: BorderRadius.circular(20),
                                        child: TextButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const EditProfilePage(),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.edit, size: size * 0.032, color: AppColors.primary),
                                          label: Text(
                                            "Edit Profile",
                                            style: TextStyle(
                                              fontSize: size * 0.032,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                IgnorePointer(
                                  child: QuillEditor(
                                    controller: _controller,
                                    scrollController: _scrollController,
                                    focusNode: FocusNode(),
                                    config: const QuillEditorConfig(
                                      showCursor: false,
                                      expands: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          _RevealIn(
                            delay: const Duration(milliseconds: 60),
                            child: _sectionCard(
                            size: size,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitleInline(Icons.description_outlined, "Resume", size),
                                const SizedBox(height: 10),
                                _HoverLift(
                                  liftScale: 1.015,
                                  borderRadius: BorderRadius.circular(14),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (user.certificates.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewPDFPage(
                                              pdfUrl: user.certificates[0],
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.file_open,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              (user.certificates.isNotEmpty &&
                                                      (user.certificates[0] ?? "")
                                                          .isNotEmpty)
                                                  ? "Resume.pdf"
                                                  : "Upload PDF",
                                              style: TextStyle(
                                                fontSize: size * 0.034,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(
                                              Icons.edit,
                                              size: size * 0.036,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          _RevealIn(
                            delay: const Duration(milliseconds: 120),
                            child: _sectionCard(
                            size: size,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitleInline(Icons.contact_page_outlined, "Contact Information", size),
                                const SizedBox(height: 6),
                                _contactTile(
                                  Icons.email_rounded,
                                  "Email",
                                  user.email,
                                  size,
                                ),
                                _contactTile(
                                  Icons.call,
                                  "Mobile",
                                  user.mobileNumber,
                                  size,
                                ),
                                _contactTile(
                                  Icons.cake,
                                  "Date of Birth",
                                  user.dob != null ? user.dob! : "",
                                  size,
                                ),
                                _contactTile(
                                  Icons.location_on,
                                  "Location",
                                  "${user.address['city'] ?? ''}, ${user.address['district'] ?? ''}, ${user.address['state'] ?? ''}",
                                  size,
                                ),
                              ],
                            ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          _RevealIn(
                            delay: const Duration(milliseconds: 160),
                            child: _sectionCard(
                            size: size,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitleInline(Icons.category_outlined, "Job Category", size),
                                const SizedBox(height: 6),
                                _contactTile(
                                  Icons.category,
                                  "Preferences",
                                  categoryString,
                                  size,
                                ),
                              ],
                            ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          _sectionTitle("Academic Details", size),
                          if (ug.isNotEmpty)
                            _infoPanel(
                              icon: Icons.school,
                              title: "UG Details",
                              desc:
                                  "College: ${ug['name'] ?? ""}\nDegree: ${ug['degree'] ?? ""}\nPercentage: ${ug['percentage'] ?? ""}",
                              size: size,
                              colors: const [AppColors.primary, AppColors.secondary],
                            ),
                          if (pg.isNotEmpty)
                            _infoPanel(
                              icon: Icons.school,
                              title: "PG Details",
                              desc:
                                  "College: ${pg['name'] ?? ""}\nDegree: ${pg['degree'] ?? ""}\nPercentage: ${pg['percentage'] ?? ""}",
                              size: size,
                              colors: const [Color(0xFF06B6D4), Color(0xFF67E8F9)],
                            ),

                          const SizedBox(height: 16),
                          _sectionTitle("Experience", size),
                          if (experiences.isNotEmpty)
                            Column(
                              children: experiences.map<Widget>((exp) {
                                return _infoPanel(
                                  icon: Icons.work_outline_rounded,
                                  title: "${exp['companyName'] ?? ""}",
                                  desc:
                                      "Duration: ${exp['experience'] ?? ""} \nDescription: ${exp['jobDescription'] ?? ""}",
                                  size: size,
                                  colors: const [Color(0xFFF59E0B), Color(0xFFFFC15E)],
                                );
                              }).toList(),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "No experience available",
                                style: TextStyle(
                                  fontSize: size * 0.038,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),

                          const SizedBox(height: 30),
                        ],
                        ),
                      ),
                    ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }

  Widget _sectionCard({required double size, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitleInline(IconData icon, String title, double size) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 15, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: size * 0.038,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: size * 0.04,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _contactTile(IconData icon, String label, String value, double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: size * 0.042, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: size * 0.033,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: size * 0.037,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPanel({
    required IconData icon,
    required String title,
    required String desc,
    required double size,
    List<Color> colors = const [AppColors.primary, AppColors.secondary],
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _HoverLift(
        liftScale: 1.012,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: size * 0.055, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: size * 0.038,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: size * 0.035,
                        height: 1.4,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
