import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_drawer.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import '../../common_widgets/color_code.dart';
import '../auth/login_screen/login_controller.dart';


class WebinarCard extends StatefulWidget {
  @override
  State<WebinarCard> createState() => _WebinarCardState();
}

class _WebinarCardState extends State<WebinarCard> {
  final jobController=Get.put(JobController());
  final loginController=Get.put(LoginController());
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKeyWebinar = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    jobController.getWebinarListJobSeekers('','',context);
  }
  Future<void> _refresh() async {
    jobController.getWebinarListJobSeekers('','',context);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKeyWebinar,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        toolbarHeight: size * 0.16,
        automaticallyImplyLeading: false,
        title: Container(
          height: size * 0.12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: AppTextStyles.caption(
                    context,
                    color: AppColors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search webinar by name, area...",
                    hintStyle: AppTextStyles.caption(
                      context,
                      color: AppColors.grey,
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.grey,
                      size: size * 0.05,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (value) {
                    void showDateFilterPopup(BuildContext context) {
                      double width = MediaQuery.of(context).size.width;
                      DateTime? fromDate;
                      DateTime? toDate;

                      Get.dialog(
                        Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                width: width * 0.15,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "Filter by Date",
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 20),

                                    // From Date
                                    ListTile(
                                      title: Text(
                                        fromDate == null
                                            ? "From Date"
                                            : "From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}",
                                      ),
                                      trailing: const Icon(Icons.calendar_today),
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: fromDate ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            fromDate = picked; // rebuild dialog with new date
                                          });
                                        }
                                      },
                                    ),

                                    // To Date
                                    ListTile(
                                      title: Text(
                                        toDate == null
                                            ? "To Date"
                                            : "To: ${DateFormat('yyyy-MM-dd').format(toDate!)}",
                                      ),
                                      trailing: const Icon(Icons.calendar_today),
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: toDate ?? DateTime.now(),
                                          firstDate: fromDate ?? DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            toDate = picked; // rebuild dialog
                                          });
                                        }
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    ElevatedButton(
                                      onPressed: () async {
                                        if (fromDate == null || toDate == null) return;

                                        final from = DateFormat('yyyy-MM-dd').format(fromDate!);
                                        final to = DateFormat('yyyy-MM-dd').format(toDate!);

                                        Get.back();
                                        await  jobController.getWebinarListJobSeekers(from,to,context);
                                      },
                                      child:  Text("Apply Filter",style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        barrierDismissible: true,
                      );
                    }
                  },
                ),
              ),
              Container(
                height: size * 0.06,
                width: 1,
                color: Colors.grey.shade300,
              ),

              IconButton(
                icon: Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: size * 0.06,
                ),
                onPressed: () {
                  void showDateFilterPopup(BuildContext context) {
                    double width = MediaQuery.of(context).size.width;
                    DateTime? fromDate;
                    DateTime? toDate;

                    Get.dialog(
                      Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              width: width * 0.15,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Filter by Date",
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 20),

                                  // From Date
                                  ListTile(
                                    title: Text(
                                      fromDate == null
                                          ? "From Date"
                                          : "From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}",
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: fromDate ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          fromDate = picked; // rebuild dialog with new date
                                        });
                                      }
                                    },
                                  ),

                                  // To Date
                                  ListTile(
                                    title: Text(
                                      toDate == null
                                          ? "To Date"
                                          : "To: ${DateFormat('yyyy-MM-dd').format(toDate!)}",
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: () async {
                                      // final picked = await showDatePicker(
                                      //   context: context,
                                      //   initialDate: toDate ?? DateTime.now(),
                                      //   firstDate: fromDate ?? DateTime(2000),
                                      //   lastDate: DateTime(2100),
                                      // );
                                      // if (picked != null) {
                                      //   setState(() {
                                      //     toDate = picked;
                                      //   });
                                      // }
                                      final first = fromDate ?? DateTime(2000);

                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: toDate ?? first,
                                        firstDate: first,
                                        lastDate: DateTime(2100),
                                      );

                                      if (picked != null) {
                                        setState(() {
                                          toDate = picked;
                                        });
                                      }
                                    },
                                  ),

                                  const SizedBox(height: 20),

                                  ElevatedButton(
                                    onPressed: () async {
                                      if (fromDate == null || toDate == null) return;

                                      final from = DateFormat('yyyy-MM-dd').format(fromDate!);
                                      final to = DateFormat('yyyy-MM-dd').format(toDate!);

                                      Get.back();
                                      await  jobController.getWebinarListJobSeekers(from,to,context);
                                    },
                                    child:  Text("Apply Filter",style: AppTextStyles.caption(context,color: AppColors.black,fontWeight: FontWeight.bold),),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      barrierDismissible: true,
                    );
                  }
                  showDateFilterPopup(context);
                  },
              ),
            ],
          ),
        ),
      ),
      body: GetBuilder<JobController>(
          builder: (controller) {
            return RefreshIndicator(
            onRefresh:_refresh ,
            child: Column(
              children: [
                if(jobController.webinarListJobSeekers.isEmpty)
                  Center(child: Center(child: Text('No Job found',style: AppTextStyles.caption(context),)),),
                if(jobController.isLoading==true)
              //  const CircularProgressIndicator(color: AppColors.primary,),
                buildShimmerEmptyWidget(size),

                if(jobController.webinarListJobSeekers.isNotEmpty)
            Expanded(
              child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: jobController.webinarListJobSeekers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final webinar = jobController.webinarListJobSeekers[index];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            SizedBox(
                              height: 190,
                              width: double.infinity,
                              child: Image.network(
                                webinar.webinarImage ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.grey),
                                ),
                              ),
                            ),

                            /// Location Chip
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        webinar.place ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: size * 0.03),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                webinar.webinarTitle ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size * 0.045,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 6),
                              Text(
                                webinar.orgName ?? "",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size * 0.035,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                webinar.createdDate.toString()?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),

                              const SizedBox(height: 16),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () {
                                    jobController.getWebinarById(webinar.webinarId.toString(), 'true', context);
                                    Get.toNamed('/viewWebinarPage');
                                  },
                                  child:  Text(
                                    "View Webinar",
                                    style: AppTextStyles.caption(context,color: AppColors.white)
                                    ),
                                  ),
                                ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
                  ),
            )

                ],
            ),
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}
