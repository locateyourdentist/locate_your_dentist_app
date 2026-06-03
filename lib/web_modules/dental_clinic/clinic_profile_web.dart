import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/common_widgets/watsapp_utils.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/product_services/service_controller.dart';
import 'package:locate_your_dentist/modules/profiles/view_profileImages.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../../api/api.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:url_launcher/url_launcher.dart';

class ClinicProfileWeb extends StatefulWidget {
  const ClinicProfileWeb({super.key});
  @override
  State<ClinicProfileWeb> createState() => _ClinicProfileWebState();
}

class _ClinicProfileWebState extends State<ClinicProfileWeb> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loginController = Get.put(LoginController());
  final serviceController = Get.put(ServiceController());
  final ScrollController _scrollController = ScrollController();
  late QuillController _controller;
  Future<void> setProfileData(user) async {

    loginController.selectedState = user.address["state"] ?? "";
    loginController.selectedDistrict = user.address["district"] ?? "";
    loginController.selectedTaluka = user.address["city"] ?? "";
    loginController.selectedVillage = user.address["area"] ?? "";
    print('fgf${user.address["district"] ?? ""}');
    await loginController.fetchStates();
    if (loginController.selectedState != null && loginController.selectedState!.isNotEmpty) {
      await loginController.fetchDistricts(loginController.selectedState!);
    }
    if (loginController.selectedDistrict != null && loginController.selectedDistrict!.isNotEmpty) {
      await loginController.fetchTalukas(loginController.selectedDistrict!);
    }
    if (loginController.selectedTaluka != null && loginController.selectedTaluka!.isNotEmpty) {
      await loginController.fetchVillages(loginController.selectedTaluka!);
    }

    loginController.update();
  }

  void loadJobDescription(dynamic data) {
    try {
      List<Map<String, dynamic>> delta = [];
      if (data == null) {
        delta = [{"insert": "\n"}];
      } else if (data is List) {
        delta = List<Map<String, dynamic>>.from(data);
      } else if (data is String) {
        delta = List<Map<String, dynamic>>.from(jsonDecode(data));
      }
      _controller = QuillController(
        document: Document.fromJson(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
      if (mounted) setState(() {});
    } catch (e) {
      _controller = QuillController.basic();
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    _controller = QuillController.basic();
    _refresh();
    super.initState();
  }

  Future<void> _refresh() async {
    await serviceController.getServiceListAdmin(Api.userInfo.read('selectUId') ?? "", context);
    await loginController.getProfileByUserId(Api.userInfo.read('selectUId') ?? "", context);
    if (loginController.userData.isNotEmpty) {
      await setProfileData(loginController.userData.first);
    }
    if (!mounted) return;
    final data = loginController.userData.isNotEmpty ? loginController.userData.first.details["description"] : null;
    loadJobDescription(data);
  }

  bool getPlanActive() {
    final userData = loginController.userData;
    if (userData.isEmpty) return false;
    final raw = userData.first.details["plan"]?["basePlan"]?["isActive"] ?? "";
    return raw == true || raw == "true";
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
      appBar: isLoggedIn ? CommonWebAppBar(height: isMobile ? 60 : 80, title: "LYD") : const CommonHeader(),
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      body: GetBuilder<LoginController>(
        builder: (controller) {
          return Row(
            children: [
              if (isLoggedIn && isDesktop) const AdminSideBar(),
              Expanded(
                child: controller.isLoading 
                  ? _buildShimmerProfile(width, isDesktop) 
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: _buildProfileContent(width, isDesktop, isMobile, isLoggedIn, controller),
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(double width, bool isDesktop, bool isMobile, bool isLoggedIn, LoginController controller) {
    final user = controller.userData.isNotEmpty ? controller.userData.first : null;
    final bool isAdminUser = Api.userInfo.read('userType') == 'admin' || Api.userInfo.read('userType') == 'superAdmin';
    final isSameUser = isLoggedIn && user != null && user.userId.toString() == (Api.userInfo.read('userId')?.toString() ?? "");
    final planActive = getPlanActive();

    return Stack(
      children: [
        if (isLoggedIn && !isDesktop)
          Positioned(
            top: 10, left: 10,
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(isMobile ? 10 : 30, isLoggedIn && !isDesktop ? 60 : 30, isMobile ? 10 : 30, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeaderCard(width, isMobile, user, planActive, isAdminUser, isSameUser, controller),
                  const SizedBox(height: 24),
                  _buildTabsSection(width, isMobile, isAdminUser, user, planActive, isSameUser),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeaderCard(double width, bool isMobile, dynamic user, bool planActive, bool isAdminUser, bool isSameUser, LoginController controller) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey, width: 0.3),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: isMobile 
        ? Column(
            children: [
              _buildMobileHeaderInfo(width, user, controller),
              const SizedBox(height: 15),
              _buildProfileActions(width, user, planActive, isAdminUser, isSameUser, context),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLogo(width, controller),
              const SizedBox(width: 20),
              Expanded(
                child: _buildProfileInfo(width, user, Api.userInfo.read('userType')??"", Api.userInfo.read('userId')??"", user?.userId?.toString()??"", isAdminUser, planActive, isSameUser, context),
              )
            ],
          ),
    );
  }

  Widget _buildTabsSection(double width, bool isMobile, bool isAdminUser, dynamic user, bool planActive, bool isSameUser) {
    return DefaultTabController(
      length: isAdminUser ? 4 : 3,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: TabBar(
              isScrollable: isMobile,
              tabAlignment: isMobile ? TabAlignment.start : null,
              indicator: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              labelColor: AppColors.black,
              unselectedLabelColor: Colors.black87,
              labelStyle: AppTextStyles.caption(fontWeight: FontWeight.bold, context),
              tabs: [
                const Tab(text: 'Description'),
                const Tab(text: 'Services'),
                const Tab(text: 'Images'),
                if (isAdminUser) const Tab(text: 'Certificates'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 800,
            child: TabBarView(
              children: [
                _buildDescriptionTab(),
                _buildServicesTab(width, isMobile, planActive, isAdminUser, user, Api.userInfo.read('userId')??""),
                _buildImagesTab(),
                if (isAdminUser) _buildCertificatesTab(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Description", style: AppTextStyles.body(fontWeight: FontWeight.bold, context)),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IgnorePointer(
                child: QuillEditor(
                  controller: _controller,
                  scrollController: ScrollController(),
                  focusNode: FocusNode(),
                  config: const QuillEditorConfig(
                    showCursor: false, expands: false, padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesTab(double width, bool isMobile, bool planActive, bool isAdminUser, dynamic user, String currentUserId) {
    String editUserId = user?.userId?.toString() ?? "";
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (serviceController.serviceList.isEmpty)
              Center(child: Text('No data found', style: AppTextStyles.caption(context, fontWeight: FontWeight.normal))),
            if (serviceController.isLoading)
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            if (serviceController.serviceList.isNotEmpty && (planActive && user?.details["plan"]?["basePlan"]?["details"]["services"] == true || isAdminUser || currentUserId == editUserId))
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: serviceController.serviceList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 2,
                  crossAxisSpacing: 16, mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 3 : 4,
                ),
                itemBuilder: (_, index) {
                  final service = serviceController.serviceList[index];
                  return GestureDetector(
                    onTap: () async {
                      await serviceController.getServiceDetailAdmin(service.serviceId.toString(), context);
                      Get.toNamed('/serviceDetailPageWeb', arguments: {"serviceId": service.serviceId.toString()});
                    },
                    child: Container(
                      decoration: _cardDecoration(),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              service.image?.isNotEmpty == true ? service.image!.first : "",
                              width: 60, height: 60, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(service.serviceTitle ?? "", style: AppTextStyles.caption(fontWeight: FontWeight.bold, context), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 5),
                                Text("₹ ${service.serviceCost}", style: AppTextStyles.caption(fontWeight: FontWeight.normal, context)),
                              ],
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
      ),
    );
  }

  Widget _buildImagesTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Center(
        child: MediaCarousel(
          images: loginController.editImages.isNotEmpty
              ? loginController.editImages.where((img) => img.url != null && img.url!.startsWith('http') && !img.url!.contains('undefined')).toList()
              : [],
        ),
      ),
    );
  }

  Widget _buildCertificatesTab(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: loginController.editCertificates.isEmpty 
        ? Center(child: Text('No data found', style: AppTextStyles.caption(context)))
        : ListView.builder(
            itemCount: loginController.editCertificates.length,
            itemBuilder: (context, index) {
              final cert = loginController.editCertificates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text("${user?.userType} Certificate", style: AppTextStyles.caption(context, fontWeight: FontWeight.bold)),
                    ),
                    if (cert.url?.toLowerCase().endsWith(".pdf") ?? false)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        label: const Text("Open PDF"),
                        onPressed: () => launchUrl(Uri.parse(cert.url!)),
                      )
                    else if (cert.url != null)
                      Image.network(cert.url!, height: 200, fit: BoxFit.contain),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
    );
  }

  Widget _buildLogo(double width, LoginController controller) {
    final double logoSize = width < 700 ? 80 : 120;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        controller.logoImage.isNotEmpty ? controller.logoImage.first ?? "" : "",
        height: logoSize, width: logoSize, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: logoSize, width: logoSize, color: Colors.grey.shade200,
          child: Icon(Icons.image, size: logoSize * 0.4, color: AppColors.grey),
        ),
      ),
    );
  }

  Widget _buildMobileHeaderInfo(double width, dynamic user, LoginController controller) {
    return Row(
      children: [
        _buildLogo(width, controller),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.details["name"] ?? "", style: AppTextStyles.body(context, fontWeight: FontWeight.bold)),
              Text("${user?.address['city'] ?? ''}, ${user?.address['district'] ?? ''}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(double width, dynamic user, String userType, String userId, String editUserId, bool isAdminUser, bool planActive, bool isSameUser, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(user?.details["name"] ?? "", style: AppTextStyles.body(context, fontWeight: FontWeight.bold))),
            if (isAdminUser || userId == editUserId)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  loginController.getProfileByUserId(user?.userId ?? "", context);
                  Get.toNamed('/registerPageWeb');
                },
              ),
          ],
        ),
        if (isAdminUser)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text(user?.userType ?? "", style: AppTextStyles.caption(context, color: Colors.grey)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: user?.isActive == true ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(user?.isActive == true ? "Active" : "Inactive", style: const TextStyle(color: Colors.white, fontSize: 10)),
                )
              ],
            ),
          ),
        _buildProfileActions(width, user, planActive, isAdminUser, isSameUser, context),
      ],
    );
  }

  Widget _buildProfileActions(double width, dynamic user, bool planActive, bool isAdminUser, bool isSameUser, BuildContext context) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: [
        _actionButton(Icons.call, "Call", () async {
          if ((planActive && user?.details["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) || isAdminUser) {
            await launchCall(user?.mobileNumber.toString() ?? "");
          }
        }, context),
        _actionButton(Icons.language, "Website", () {
          if ((planActive && user?.details["plan"]?["basePlan"]?["details"]?["location"] == true) || isAdminUser) {
            Get.toNamed('/webViewProfilePage', arguments: {"url": user?.details["website"] ?? "", "clinicName": user?.details["name"] ?? ""});
          }
        }, context),
        _actionButton(Icons.chat, "WhatsApp", () async {
          if (planActive || isAdminUser) {
            await WhatsAppUtils.openWhatsApp(phoneNumber: user?.mobileNumber?.toString() ?? '', message: "Hi Message From ${user?.details?["name"] ?? ''}");
          }
        }, context),
        if (Api.userInfo.read('token') != null && user != null && !isSameUser)
          _actionButton(Icons.contact_page_outlined, "Contact", () {
            Get.toNamed('/createContactPageWeb', arguments: {
              "senderUserId": Api.userInfo.read('userId') ?? "",
              "receiverUserId": user.userId.toString(),
              "clinicName": user.details["name"]?.toString() ?? "",
              "mobileNumber": user.mobileNumber?.toString() ?? "",
              "email": user.email?.toString() ?? "",
              "address": user.address,
            });
          }, context),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap, BuildContext context) {
    return IntrinsicWidth(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 2),
              Flexible(child: Text(label, style: AppTextStyles.caption(context, fontWeight: FontWeight.bold, color: AppColors.primary))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerProfile(double width, bool isDesktop) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
      child: Row(
        children: [
          if (isDesktop) Container(width: 250, height: double.infinity, color: Colors.white),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Container(height: 150, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                  const SizedBox(height: 20),
                  Container(height: 50, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 20),
                  Expanded(child: Container(width: double.infinity, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
