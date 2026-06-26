import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common-alertdialog.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/model/profile_model.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/service_locations.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/web_modules/common/filter_side_bar.dart';
import 'package:excel/excel.dart';

class ModernUserTable extends StatefulWidget {
  @override
  State<ModernUserTable> createState() => _ModernUserTableState();
}

class _ModernUserTableState extends State<ModernUserTable> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final loginController = Get.put(LoginController());
  String? userType;
  final TextEditingController searchController = TextEditingController();
  final ScrollController _horizontalScrollController = ScrollController();
  bool isExporting = false;

  @override
  void initState() {
    super.initState();
   // _refresh();
  }

  @override
  void dispose() {
    searchController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await loginController.getProfileDetails(
      Api.userInfo.read('sUserType1')??"",  loginController.selectedState,
      loginController.selectedDistrict,
      loginController.selectedTaluka,loginController.selectedVillages,Api.userInfo.read('token')==null? 'true':"", '', '', '', '', context,);
    await loginController.fetchStates();
    loginController.selectedState = null;
    loginController.selectedDistrict = null;
    loginController.selectedTaluka = null;
  }

  List<int>? generateExcel(List profiles) {
    final excel = Excel.createExcel();
    const sheetName = "Users";
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];
    final titleStyle = CellStyle(bold: true, fontSize: 16, horizontalAlign: HorizontalAlign.Center);
    final headerStyle = CellStyle(bold: true);

    sheet.appendRow([TextCellValue("User Report")]);
    sheet.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("F1"));
    sheet.cell(CellIndex.indexByString("A1")).cellStyle = titleStyle;
    sheet.appendRow([
      TextCellValue("S.No"), TextCellValue("Name"), TextCellValue("User ID"),
      TextCellValue("User Type"), TextCellValue("Mobile"), TextCellValue("Email Id"),
    ]);

    for (var col in ["A2", "B2", "C2", "D2", "E2", "F2"]) {
      sheet.cell(CellIndex.indexByString(col)).cellStyle = headerStyle;
    }

    for (int i = 0; i < profiles.length; i++) {
      final user = profiles[i];
      sheet.appendRow([
        TextCellValue("${i + 1}"), TextCellValue(user.name ?? ""), TextCellValue(user.userId ?? ""),
        TextCellValue(user.userType ?? ""), TextCellValue(user.mobileNumber ?? ""), TextCellValue(user.email ?? ""),
      ]);
    }
    return excel.encode();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final bool isDesktop = size >= 1100;
    final bool isTablet = size >= 700 && size < 1100;
    final bool isMobile = size < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    PreferredSizeWidget buildAppBar() {
      if (Api.userInfo.read('token') != null) {
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

    return WillPopScope(
      onWillPop: () async {
        Get.toNamed('/${pageUserTypeWeb(Api.userInfo.read('userType') ?? "")}');
        if (Api.userInfo.read('userType') == "superAdmin") {
          loginController.getProfileDetails('', '', '', '', [], '','', '', '', '', context);
        }
        if (Api.userInfo.read('userType') == "admin") {
          loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", '', '', [], '', '', '', '', '',context);
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer:( !isDesktop&&isLoggedIn) ? const Drawer(width: 250, child: AdminSideBar()) : null,
        endDrawer: isMobile ? const Drawer(width: 300, child: FilterSidebar()) : null,
        appBar: buildAppBar(),
        body: GetBuilder<LoginController>(
          builder: (controller) {
            final filteredProfiles = (userType == null || userType!.isEmpty)
                ? controller.profileList
                : controller.profileList.where((p) => p.userType.toLowerCase() == userType!.toLowerCase()).toList();
            return Row(
              children: [
                if (isDesktop && isLoggedIn) const AdminSideBar(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 15.0 : 40.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1300),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!isMobile)
                                SizedBox(width: isDesktop ? size * 0.15 : 250, child: const FilterSidebar()),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildHeaderActions(isDesktop, isMobile),
                                        const SizedBox(height: 20),
                                        _buildActiveFilters(isMobile),
                                        _buildExportButton(filteredProfiles),
                                        const SizedBox(height: 20),
                                        if (filteredProfiles.isEmpty)
                                          _buildEmptyState()
                                        else
                                          _buildUserTable(filteredProfiles, isMobile, isTablet),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderActions(bool isDesktop, bool isMobile) {
    return Row(
      children: [
        if (!isDesktop)
          IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) => _performSearch(),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: "Search...",
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        if (isMobile)
          IconButton(icon: const Icon(Icons.filter_list, color: AppColors.primary), onPressed: () => _scaffoldKey.currentState?.openEndDrawer()),
      ],
    );
  }

  Future<void> _performSearch() async {
    if (loginController.selectedDistance != null) {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        loginController.latitude = position.latitude;
        loginController.longitude = position.longitude;
      }
    }
    String distance = loginController.selectedDistance1.toString() ?? "0";
    if (distance != "0") {
      await getLocation();
    } else {
      loginController.latitude = null;
      loginController.longitude = null;
    }

    String safeLat =
    (distance != "0" && loginController.latitude != null)
        ? loginController.latitude.toString()
        : "";

    String safeLng =
    (distance != "0" && loginController.longitude != null)
        ? loginController.longitude.toString()
        : "";
    
    if (Api.userInfo.read('userType') == "superAdmin") {
      loginController.getProfileDetails('', '', '', '', [], '','', '', '', searchController.text.toString(), context);
    } else if (Api.userInfo.read('userType') == "admin") {
      loginController.getProfileDetails('',Api.userInfo.read('state') ?? "",  '', '', [], '','', '', '', searchController.text.toString(), context);
      // await loginController.getProfileDetails('', Api.userInfo.read('state') ?? "", loginController.selectedDistrict, loginController.selectedTaluka, loginController.selectedArea,'',safeLat, safeLng, distance,  searchController.text, context);
    } else {
      loginController.getProfileDetails(
          "Dental Clinic", '', '', '',[], 'true','', '', '', searchController.text.toString(), context);
      //await loginController.getProfileDetails(userType, loginController.selectedState, loginController.selectedDistrict, loginController.selectedTaluka,loginController.selectedArea, 'true',safeLat, safeLng, distance, searchController.text, context);
    }
  }
  Widget _buildActiveFilters(bool isMobile) {
    bool hasFilters = loginController.selectedDistance != null || loginController.selectedState != null || loginController.selectedDistrict != null || loginController.selectedTaluka != null || loginController.selectedJobType != null || loginController.selectedSalary != null || loginController.selectedCategories.isNotEmpty;
    if (!hasFilters) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: [
          if (loginController.selectedState != null) InputChip(label: Text(loginController.selectedState!), onDeleted: () { loginController.selectedState = null; loginController.update(); }),
          if (loginController.selectedDistrict != null) InputChip(label: Text(loginController.selectedDistrict!), onDeleted: () { loginController.selectedDistrict = null; loginController.update(); }),
          if (loginController.selectedTaluka != null) InputChip(label: Text(loginController.selectedTaluka!), onDeleted: () { loginController.selectedTaluka = null; loginController.update(); }),
          ...loginController.selectedVillages.map(
                (village) => InputChip(
              label: Text(village),
              onDeleted: () {
                loginController.selectedVillages.remove(village);
                loginController.update();
              },
            ),
          ),          TextButton(onPressed: () => _clearAllFilters(), child: const Text("Clear All", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _clearAllFilters() async {
    loginController.selectedCategories.clear();
    loginController.selectedState = loginController.selectedDistrict = loginController.selectedTaluka = loginController.selectedVillage = loginController.selectedUserType = loginController.selectedDistance = loginController.selectedJobType = loginController.selectedSalary = null;
    loginController.selectedVillages.clear();
    loginController.update();
    await loginController.getProfileDetails("", "", "", "",[] ,"", "", "", "", "", context);
  }

  Widget _buildExportButton(List filteredProfiles) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: isExporting ? null : () async {
          setState(() => isExporting = true);
          try { await generateExcel(filteredProfiles); } finally { setState(() => isExporting = false); }
        },
        icon: isExporting ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.download, size: 18),
        label: Text(isExporting ? "Exporting..." : "Export Excel"),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text('No data found', style: AppTextStyles.caption(context))));
  }
  Widget _buildUserTable(
      List<ProfileModel> profiles,
      bool isMobile,
      bool isTablet,
      ) {
    bool isBasePlanActive(ProfileModel profile) {
      final isActive =
      profile.details?["plan"]?["basePlan"]?["isActive"];
      return isActive == true || isActive == "true";
    }
    final firstProfile =
    profiles.isNotEmpty ? profiles.first : null;

    final planActive = firstProfile != null
        ? isBasePlanActive(firstProfile)
        : false;
    //final planActive = isBasePlanActive(clinic);
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    return Scrollbar(
      controller: _horizontalScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _horizontalScrollController,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: isMobile ? 900 : (isTablet ? 1100 : 1200),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    _headerCell("S.No", 1),
                    _headerCell("Name", 2),
                    _headerCell("User ID", 2),
                    _headerCell("User Type", 2),
                    // if ((planActive == true &&
                    //     firstProfile?.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
                    //     isAdminUser)
                    _headerCell("Mobile", 2),
                    _headerCell("View", 1),
                    if (Api.userInfo.read('userType') == "superAdmin")
                      _headerCell("Status", 1),
                    if (Api.userInfo.read('userType') == "superAdmin")
                      _headerCell("Actions", 1),

                  ],
                ),
              ),
              AnimationLimiter(
                child: Column(
                  children: List.generate(profiles.length, (index) {
                    final user = profiles[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: FadeInAnimation(
                        child: _buildDataRow(user, index),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _headerCell(String text, int flex) {
    return Expanded(flex: flex, child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))));
  }

  Widget _buildDataRow(ProfileModel user, int index) {
    final isEven = index % 2 == 0;
    bool isBasePlanActive(ProfileModel profile) {
      final isActive =
      profile.details?["plan"]?["basePlan"]?["isActive"];
      return isActive == true || isActive == "true";
    }
    final planActive = isBasePlanActive(user);
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isAdminUser = userType == 'admin' || userType == 'superAdmin';
    return Container(
      color: isEven ? Colors.grey[50] : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Row(
        children: [
          Expanded(flex: 1, child: Center(child: Text("${index + 1}", style: const TextStyle(fontSize: 12)))),
          Expanded(flex: 2, child: Center(child: Text(user.name, style: const TextStyle(fontSize: 12)))),
          Expanded(flex: 2, child: Center(child: Text(user.userId, style: const TextStyle(fontSize: 12)))),
          Expanded(flex: 2, child: Center(child: Text(user.userType, style: const TextStyle(fontSize: 12)))),

          Expanded(flex: 2, child: Center(child: Text((planActive == true &&
              user.details?["plan"]?["basePlan"]?["details"]?["mobileNumber"] == true) ||
              isAdminUser?user.mobileNumber:"-", style: const TextStyle(fontSize: 12)))),
          Expanded(flex: 1, child: Center(child: IconButton(icon: const Icon(Icons.remove_red_eye, color: Colors.grey, size: 18), onPressed: () async {
            Api.userInfo.write('selectUId', user.userId.toString());
            await loginController.getProfileByUserId(user.userId.toString(), context);
            Get.toNamed('/clinicProfileWebPage');
          }))),
          if (Api.userInfo.read('userType') == "superAdmin")
            Expanded(flex: 1, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: user.isActive ? Colors.green : Colors.red, borderRadius: BorderRadius.circular(12)), child: Text(user.isActive ? "Active" : "Inactive", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10)))),
          if (Api.userInfo.read('userType') == "superAdmin")
            Expanded(flex: 1, child: Center(child: IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 18), onPressed: () => _showDeleteDialog(user)))),
        ],
      ),
    );
  }
  void _showDeleteDialog(ProfileModel user) {
    showDeleteDialog(
      context: context, title: "Toggle User Status?", message: "Do you want to change this user's active status?",
      onConfirm: () async {
        await loginController.deactivateUserAdmin(user.userId, !user.isActive, context);
        await loginController.getProfileDetails('', '', '', '', [], '', '', '', '', '',context);
        loginController.update();
      },
    );
  }
}
