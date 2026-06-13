import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/modules/contact_form/contact_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../web_modules/common/common_widgets_web.dart';

class ViewFeedbackForms extends StatefulWidget {
  const ViewFeedbackForms({super.key});

  @override
  State<ViewFeedbackForms> createState() => _ViewFeedbackFormsState();
}

class _ViewFeedbackFormsState extends State<ViewFeedbackForms> {
  final controller = Get.put(ContactController());
  DateTime? appliedFromDate;
  DateTime? appliedToDate;

  @override
  void initState() {
    super.initState();
    controller.getFeedbackFormLists('', '', '', context);
  }

  // 🎨 Modern Filter Bottom Sheet Dialog UI
  void showFilterSheet(BuildContext context) {
    DateTime? tempFrom = appliedFromDate;
    DateTime? tempTo = appliedToDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter Requests",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        if (tempFrom != null || tempTo != null)
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                tempFrom = null;
                                tempTo = null;
                              });
                            },
                            child: const Text("Clear All", style: TextStyle(color: Colors.redAccent)),
                          )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Date Pickers Grid Row Layout
                    Row(
                      children: [
                        Expanded(
                          child: _datePickerTile(
                            label: "From Date",
                            value: tempFrom,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempFrom ?? DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setSheetState(() => tempFrom = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _datePickerTile(
                            label: "To Date",
                            value: tempTo,
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: tempTo ?? DateTime.now(),
                                firstDate: DateTime(2024),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setSheetState(() => tempTo = picked);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Primary Apply Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          setState(() {
                            appliedFromDate = tempFrom;
                            appliedToDate = tempTo;
                          });
                          controller.getFeedbackFormLists(
                            appliedFromDate?.toString() ?? '',
                            appliedToDate?.toString() ?? '',
                            '',
                            context,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Apply Filters",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _datePickerTile({required String label, required DateTime? value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  value == null ? "Select Date" : DateFormat("dd MMM yyyy").format(value),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            ),
            Icon(Icons.calendar_today_rounded, color: Colors.indigo.shade400, size: 18),
          ],
        ),
      ),
    );
  }

  String formatDate(dynamic date) {
    try {
      return DateFormat("dd MMM yyyy • hh:mm a").format(DateTime.parse(date.toString()).toLocal());
    } catch (_) {
      return "-";
    }
  }

  // 📱 Complete Modern Card Component (Used for Grid/List entries dynamically)
  Widget feedbackCard(dynamic item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.indigo.shade50,
                child: Text(
                  item.name.toString().isNotEmpty ? item.name[0].toUpperCase() : "?",
                  style: TextStyle(color: Colors.indigo.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name ?? "Anonymous",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDate(item.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14.0),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F7)),
          ),

          // Contact Metadata Blocks
          _contactIconRow(Icons.email_outlined, item.email ?? "No Email"),
          const SizedBox(height: 8),
          _contactIconRow(Icons.phone_outlined, item.mobile ?? "No Mobile"),

          const SizedBox(height: 14),

          // User Message Body Block
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: SingleChildScrollView(
                child: Text(
                  item.message ?? "No message contents written.",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Split Row Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: "Call",
                  icon: Icons.call_rounded,
                  color: Colors.grey,
                  onTap: () => launchUrl(Uri.parse("tel:${item.mobile}")),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(
                  label: "Email",
                  icon: Icons.mail_rounded,
                  color: Colors.indigo.shade600,
                  onTap: () => launchUrl(Uri.parse("mailto:${item.email}")),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _contactIconRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  final GlobalKey<ScaffoldState> _scaffoldKeyService = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    final bool isDesktop = width >= 1100;
    final userType = Api.userInfo.read('userType')?.toString() ?? "";
    final bool isMobile = width < 700;
    // Calculate ideal grid column sizing counts reactively
    int crossAxisCount = 4;
    if (width < 650) {
      crossAxisCount = 1;
    } else if (width < 950) {
      crossAxisCount = 2;
    } else if (width < 1350) {
      crossAxisCount = 3;
    }

    return Scaffold(
      key: _scaffoldKeyService,
      backgroundColor: AppColors.scaffoldBg,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: isMobile ? 60 : 80,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
     // backgroundColor: const Color(0xFFFAFBFC),
      body: GetBuilder<ContactController>(
        builder: (controller) {
          final double width = MediaQuery.of(context).size.width;
          final bool isDesktop = width >= 1100;
          final bool isLoggedIn = Api.userInfo.read('token') != null;

          return Row(
            children: [
              if (isLoggedIn && isDesktop) const AdminSideBar(),

              Expanded(
                child: Stack(
              children: [
                if (isLoggedIn && !isDesktop)

                  Padding(
                        padding: const EdgeInsets.only(top: 10, left: 10),
                        child: IconButton(
                          icon: const Icon(Icons.menu,color: AppColors.black,),
                          onPressed: () => _scaffoldKeyService.currentState?.openDrawer(),
                        ),
                      ),

                if (controller.isLoading)
                 const Center(child: CircularProgressIndicator(strokeWidth: 3)),


                if (controller.publicContactFormLists.isEmpty)
                 Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                "No Requests Found",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                ),
                ],
                ),
                ),
                    Center(
                      child: Text(
                        "View Feedback Forms",
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                      ),
                    ),
                   // showFilterSheet(context)
                    if (controller.publicContactFormLists.isNotEmpty)

                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: GridView.builder(
                                shrinkWrap: true,
                              //  physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.publicContactFormLists.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 310,
                                ),
                                itemBuilder: (context, index) {
                                  return feedbackCard(
                                    controller.publicContactFormLists[index],
                                  );
                                },
                              )
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}