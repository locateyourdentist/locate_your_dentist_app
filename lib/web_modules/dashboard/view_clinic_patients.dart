import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/common/filter_side_bar.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/platform_helper.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';

class ViewClinicPatients extends StatefulWidget {
  const ViewClinicPatients({super.key});

  @override
  State<ViewClinicPatients> createState() => _ViewClinicPatientsState();
}

class _ViewClinicPatientsState extends State<ViewClinicPatients> {
  final GlobalKey<ScaffoldState> _scaffoldKeyPatients = GlobalKey<ScaffoldState>();
  final loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 1100;
    final bool isTablet = screenWidth >= 700 && screenWidth < 1100;
    final bool isMobile = screenWidth < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    PreferredSizeWidget buildAppBar() {
      if (isLoggedIn) {
        return CommonWebAppBar(
          height: isMobile ? 60 : (isTablet ? 70 : 80),
          title: "LYD",
          onLogout: () {},
          onNotification: () {},
        );
      } else {
        return const CommonHeader();
      }
    }
    return Scaffold(
      key: _scaffoldKeyPatients,
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: (!isDesktop) ? const Drawer(width: 250, child: FilterSidebar()) : null,
      //endDrawer: isMobile ? const Drawer(width: 300, child: FilterSidebar()) : null,
      appBar: buildAppBar(),
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop && isLoggedIn) const AdminSideBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    "Total Profiles (${controller.profileList.length})",
                                    style: AppTextStyles.body(context, color: const Color(0xFF0F172A)).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // if (isMobile)
                                //   IconButton(
                                //     icon: const Icon(Icons.filter_list_rounded, color: AppColors.primary),
                                //     onPressed: () => _scaffoldKeyPatients.currentState?.openEndDrawer(),
                                //   ),
                                if (!isDesktop)
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    child: IconButton(
                                      icon:  Icon(Icons.filter_alt,color: AppColors.black,size: 17,),
                                      onPressed: () => _scaffoldKeyPatients.currentState?.openDrawer(),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMobile)
                                Container(
                                  width: isDesktop ? 280 : 240,
                                  margin: const EdgeInsets.only(right: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child:  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: FilterSidebar(),
                                  ),
                                ),



                                Expanded(
                                child: controller.profileList.isEmpty
                                    ? _buildEmptyState()
                                    : Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: buildActiveFilters(isMobile,context),
                                        ),
                                        ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: controller.profileList.length,
                                        itemBuilder: (context, index) {
                                        return _ClinicDashboardListCard(
                                          clinic: controller.profileList[index],
                                          loginController: controller,
                                        );
                                                                          },
                                                                        ),
                                      ],
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_search_rounded, size: 48, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          Text("No Profiles Found", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
          const SizedBox(height: 4),
          Text("Try adjusting your dashboard filter criteria options.", style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}

  class _ClinicDashboardListCard extends StatefulWidget {
  final ProfileModel clinic;
  final LoginController loginController;
  const _ClinicDashboardListCard({
    required this.clinic,
    required this.loginController,
  });
  @override
  State<_ClinicDashboardListCard> createState() => _ClinicDashboardListCardState();
  }
  class _ClinicDashboardListCardState extends State<_ClinicDashboardListCard> {
  bool _isHovered = false;

  bool get isBasePlanActive {
    final isActive = widget.clinic.details?["plan"]?["basePlan"]?["isActive"];
    return isActive == true || isActive == "true";
  }
  @override
  Widget build(BuildContext context) {
    final String userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    final bool showPrivateInfo = isBasePlanActive || isAdminUser;

    String firstImage = widget.clinic.logoImages.isNotEmpty
        ? widget.clinic.logoImages.first
        : (widget.clinic.images.isNotEmpty ? widget.clinic.images.first : "");

    return MouseRegion(
      onEnter: (_) => WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _isHovered = true)),
      onExit: (_) => WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _isHovered = false)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered ? AppColors.primary.withOpacity(0.4) : const Color(0xFFE2E8F0),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(_isHovered ? 0.05 : 0.01),
              blurRadius: _isHovered ? 16 : 8,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 2),
            )
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool compactMode = constraints.maxWidth < 620;

            final Widget imageNode = Container(
              width: compactMode ? 70 : 100,
              height: compactMode ? 70 : 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF1F5F9),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: firstImage.isNotEmpty
                    ? Image.network(firstImage, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_rounded, size: 32, color: Color(0xFF94A3B8)))
                    : const Icon(Icons.image_rounded, size: 32, color: Color(0xFF94A3B8)),
              ),
            );

            final Widget infoDetailsNode = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.clinic.details["name"] ?? "Clinic Center",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.location_on_rounded, size: 15, color: Color(0xFFEF4444)),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (widget.clinic.location.toString().isNotEmpty && (showPrivateInfo || (isBasePlanActive && widget.clinic.details["plan"]?["basePlan"]?["details"]?["location"] == true))) {
                            if (PlatformHelper.platform == 'Android' || PlatformHelper.platform == 'iOS') {
                              Get.toNamed('/webViewProfilePage', arguments: {
                                "url": widget.clinic.location.toString(),
                                "clinicName": widget.clinic.details["name"].toString()
                              });
                            }
                          }
                        },
                        child: Text(
                          "${widget.clinic.address['area'] ?? ''} ${widget.clinic.address['city'] ?? ''}, ${widget.clinic.address['district'] ?? ''}",
                          style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Dr. ${widget.clinic.name}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                if (showPrivateInfo && widget.clinic.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text("Mobile: ${widget.clinic.mobileNumber}", style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
                    ],
                  ),
                ],
              ],
            );

            final Widget actionButtonsNode = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: compactMode ? CrossAxisAlignment.stretch : CrossAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    Api.userInfo.write('selectUId', widget.clinic.userId);
                    await widget.loginController.getProfileByUserId(widget.clinic.userId, context);
                    Get.toNamed('/clinicProfileWebPage');
                  },
                  icon: const Icon(Icons.person_rounded,color:AppColors.primary, size: 16),
                  label: const Text("View Profile", style: TextStyle(fontSize: 13,color:AppColors.primary, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (showPrivateInfo && widget.clinic.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async => await launchUrl(Uri.parse("tel:${widget.clinic.mobileNumber}")),
                    icon: const Icon(Icons.call_rounded,color:Colors.green, size: 16),
                    label: const Text("Call Now", style: TextStyle(fontSize:13,color:AppColors.white,fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFFBBF7D0), width: 1.5),
                      backgroundColor: const Color(0xFFF0FDF4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ],
            );
            if (compactMode) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      imageNode,
                      const SizedBox(width: 14),
                      Expanded(child: infoDetailsNode),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFFF1F5F9))),
                  actionButtonsNode,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageNode,
                const SizedBox(width: 18),
                Expanded(child: infoDetailsNode),
                const SizedBox(width: 16),
                actionButtonsNode,
              ],
            );
          },
        ),
      ),
    );
  }
}