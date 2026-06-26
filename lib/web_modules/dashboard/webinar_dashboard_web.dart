import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import '../../modules/dashboard/jobController.dart';



class WebinarDashboardGrid extends StatelessWidget {
  final List<dynamic> webinarList;
  final JobController controller;

  const WebinarDashboardGrid({
    super.key,
    required this.webinarList,
    required this.controller,
  });
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
              child: const Icon(Icons.web, size: 40, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            const Text(
              "No Webinars Found",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            // const SizedBox(height: 4),
            // const Text(
            //   "Check back soon for freshly updated career options.",
            //   style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            // ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return  GetBuilder<JobController>(
        builder: (jController) {
          if (webinarList.isEmpty) {
            return _buildEmptyState();
          }
          return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1500),
              padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.all(15),
                        physics: const BouncingScrollPhysics(),
                        itemCount: webinarList.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                          childAspectRatio: MediaQuery.of(context).size.width > 1000
                              ? 0.70 : 0.9,
                        ),
                        itemBuilder: (context, index) {
                          final webinar = webinarList[index];
                          return WebinarDashboardCard(
                            webinar: webinar,
                            controller: controller,
                          );
                        },
                      ),
                      if(webinarList.length>3)
                      Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              Get.toNamed('/webinarListWebPage');
                            },
                            child: Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          const Text(
                            "View All Webinars",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff334155),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
      }
    );
  }
}

class WebinarDashboardCard extends StatefulWidget {
  final dynamic webinar;
  final JobController controller;

  const WebinarDashboardCard({
    super.key,
    required this.webinar,
    required this.controller,
  });

  @override
  State<WebinarDashboardCard> createState() =>
      _WebinarDashboardCardState();
}

class _WebinarDashboardCardState
    extends State<WebinarDashboardCard> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    final webinar = widget.webinar;

    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isHover
                ? AppColors.primary.withOpacity(.3)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  isHover ? .08 : .04),
              blurRadius: isHover ? 20 : 12,
              offset:
              isHover ? const Offset(0, 10) : const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            widget.controller.getWebinarById(
              webinar.webinarId.toString(),
              "true",
              context,
            );
            Get.toNamed('/webLoginPage');
            //Get.toNamed('/viewWebinarDetailWebPage');
          },
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              /// IMAGE
              ClipRRect(
                borderRadius:
                const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Image.network(
                    webinar.webinarImage ?? "",
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Container(
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding:
                  const EdgeInsets.all(7),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withOpacity(.08),
                          borderRadius:
                          BorderRadius.circular(
                              8),
                        ),
                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color:
                              AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                webinar.place ??
                                    "Online",
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        webinar.webinarTitle ?? "Webinar",
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style:AppTextStyles.body(context,fontWeight: FontWeight.bold)
                      ),

                      const SizedBox(height: 8),

                      Text(
                        webinar.orgName ?? "",
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 15,
                            color:
                            Color(0xff64748B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              webinar.createdDate !=
                                  null
                                  ? DateFormat(
                                  'dd MMM yyyy')
                                  .format(
                                  DateTime.parse(
                                      webinar
                                          .createdDate
                                          .toString()))
                                  : "Upcoming",
                              style:
                              const TextStyle(
                                fontSize: 12,
                                color: Color(
                                    0xff64748B),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.play_circle_fill,
                            size: 18,
                          ),
                          label:
                           Text("View Webinar",style: AppTextStyles.caption(context,color: AppColors.white),),
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            AppColors.primary,
                            foregroundColor:
                            Colors.white,
                            elevation: 0,
                            shape:
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                          ),
                          onPressed: ()async {
                           await widget.controller.getWebinarById(
                              webinar.webinarId.toString(), "true", context,);
                           Get.toNamed('/webLoginPage');
                          // Get.toNamed('/viewWebinarDetailWebPage');
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}



