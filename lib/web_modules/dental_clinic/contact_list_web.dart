import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/date_filter_drawer.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/dental_clinic/viewContact_detail_web.dart';

class ViewContactListWeb extends StatefulWidget {
  const ViewContactListWeb({super.key});

  @override
  State<ViewContactListWeb> createState() => _ViewContactListWebState();
}

class _ViewContactListWebState extends State<ViewContactListWeb> {
  final contactController = Get.put(ContactController());
  final loginController = Get.put(LoginController());
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeyContact = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final userId = Api.userInfo.read('userId') ?? "";
    contactController.getSenderContactFormLists(userId, '', '', '', context);
  }

  Future<void> _refresh() async {
    final userId = Api.userInfo.read('userId') ?? "";
    await contactController.getSenderContactFormLists(userId, '', '', '', context);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;
    final bool isDesktop = width >= 1100;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    return Scaffold(
    key: _scaffoldKeyContact,
      backgroundColor: AppColors.scaffoldBg,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: width * 0.03 > 60 ? width * 0.03 : 60,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<ContactController>(
        builder: (controller) {
          return Row(
            children: [
              if (isLoggedIn && isDesktop) const AdminSideBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: Stack(
                    children: [
                      if (!isDesktop)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(Icons.menu,color: AppColors.black,),
                            onPressed: () => _scaffoldKeyContact.currentState?.openDrawer(),
                          ),
                        ),
                      SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(isMobile ? 15 : 30, isDesktop ? 30 : 60, isMobile ? 15 : 30, 30),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(context, width, isMobile),
                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      if (controller.isLoading)
                                        _buildShimmer(context)
                                      else if (controller.senderContactLists.isEmpty)
                                        _buildEmptyState(context)
                                      else
                                        _buildContactTable(context, controller.senderContactLists, width, isMobile, isTablet),
                                    ],
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
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double width, bool isMobile) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 20,
      children: [
        Text(
          "Contact Submissions",
          style: AppTextStyles.subtitle(context, color: Colors.black),
        ),
        Container(
          height: 45,
          width: isMobile ? double.infinity : 400,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
          ),
          child: Row(
            children: [
              const SizedBox(width: 15),
              Icon(Icons.search, color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Search by name or org...",
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (value) => _refresh(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                onPressed: () => showDateFilterPopup(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: List.generate(
            6,
            (index) => Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.contact_mail_outlined, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 15),
              Text('No contacts found', style: AppTextStyles.caption(context, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTable(BuildContext context, List contacts, double width, bool isMobile, bool isTablet) {
    return Column(
      children: [
        if (!isMobile)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _headerCell("Org Name", 2),
                _headerCell("User Type", 1.5),
                _headerCell("Name", 1.5),
                if (!isTablet) _headerCell("Mobile", 1.5),
                if (!isTablet) _headerCell("Date", 1.5),
                _headerCell("Action", 1),
              ],
            ),
          ),
        AnimationLimiter(
          child: ListView.separated(
            itemCount: contacts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final contact = contacts[index];
              final formattedDate = DateFormat('MMM dd, yyyy').format(
                DateTime.tryParse(contact.createdAt.toString()) ?? DateTime.now(),
              );

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: FadeInAnimation(
                  child: isMobile 
                    ? _buildMobileCard(context, contact, formattedDate)
                    : _buildDataRow(context, contact, formattedDate, isTablet),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String text, double flex) {
    return Expanded(
      flex: (flex * 10).toInt(),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDataRow(BuildContext context, dynamic contact, String date, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          Expanded(flex: 20, child: Text(contact.orgName ?? "-", style: AppTextStyles.caption(context))),
          Expanded(flex: 15, child: Text(contact.userType ?? "-", style: AppTextStyles.caption(context))),
          Expanded(flex: 15, child: Text(contact.Name ?? "-", style: AppTextStyles.caption(context))),
          if (!isTablet) Expanded(flex: 15, child: Text(contact.mobileNumber ?? "-", style: AppTextStyles.caption(context))),
          if (!isTablet) Expanded(flex: 15, child: Text(date, style: AppTextStyles.caption(context))),
          Expanded(
            flex: 10,
            child: TextButton(
              onPressed: () {
                Api.userInfo.write('contactId1', contact.id);
                showContactDetailsDialog(context);
              },
              child: const Text("View", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, dynamic contact, String date) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(contact.orgName ?? "-", style: AppTextStyles.body(context, fontWeight: FontWeight.bold))),
              Text(date, style: AppTextStyles.caption(context, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Text(contact.Name ?? "-", style: AppTextStyles.caption(context)),
          const SizedBox(height: 10),
          Text(contact.mobileNumber ?? "-", style: AppTextStyles.caption(context, color: Colors.grey)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                Api.userInfo.write('contactId1', contact.id);
                showContactDetailsDialog(context);
              },
              child:  Text("View Details",style: AppTextStyles.caption(context,color: AppColors.primary),),
            ),
          ),
        ],
      ),
    );
  }
}
