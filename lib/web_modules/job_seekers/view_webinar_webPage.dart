import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/common_widgets/common_widget_all.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/modules/dashboard/jobController.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import 'package:locate_your_dentist/web_modules/dashboard/view_profile_web.dart';
import 'package:locate_your_dentist/common_widgets/webinar_share_utils.dart';
import 'package:flutter_quill/flutter_quill.dart';

class WebinarViewWebPage extends StatefulWidget {
  const WebinarViewWebPage({super.key});

  @override
  State<WebinarViewWebPage> createState() => _WebinarViewWebPageState();
}

class _WebinarViewWebPageState extends State<WebinarViewWebPage> {
  final GlobalKey<ScaffoldState> _scaffoldKeyWebinar =
      GlobalKey<ScaffoldState>();
  final jobController = Get.put(JobController());
  final loginController = Get.put(LoginController());
  final ScrollController _scrollController = ScrollController();
  final ScrollController _quillScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
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

      setState(() {});
    } catch (e) {
      print("Quill load error: $e");

      _controller = QuillController.basic();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
      ),
    );
    _refresh();
  }

  Future<void> _refresh() async {
    final webinarId = Get.parameters['id'] ?? Api.userInfo.read('webinarId') ?? "";
    await jobController.getWebinarById(
      webinarId,
      Api.userInfo.read('activeStatus1') ?? "",
      context,
    );
    await jobController.getAppliedWebinarsAdmin(webinarId, context);
    loadJobDescription(jobController.webDescriptionData);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobile = width < 700;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    return Scaffold(
      key: _scaffoldKeyWebinar,
      backgroundColor: AppColors.scaffoldBg,
      drawer: !isDesktop
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      appBar: buildAppBar(context),
      body: GetBuilder<JobController>(
        builder: (controller) {
          if (controller.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (controller.webinar.isEmpty)
            return Center(
              child: Text(
                "No data found",
                style: AppTextStyles.caption(context),
              ),
            );
          final webinar = controller.webinar.first;
          return Row(
            children: [
              if (isLoggedIn && isDesktop) const AdminSideBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverToBoxAdapter(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1000,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    isMobile ? 10 : 30.0,
                                    isMobile ? 10 : 30.0,
                                    isMobile ? 10 : 30.0,
                                    0,
                                  ),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        if (!isDesktop)
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: IconButton(
                                              icon: const Icon(Icons.menu),
                                              onPressed: () =>
                                                  _scaffoldKeyWebinar
                                                      .currentState
                                                      ?.openDrawer(),
                                            ),
                                          ),
                                        SizedBox(
                                          height: isMobile
                                              ? 200
                                              : (width > 900 ? 350 : 220),
                                          width: double.infinity,
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  if (loginController
                                                      .webinarFileImages
                                                      .isNotEmpty) {
                                                    Get.toNamed(
                                                      '/viewImagePage',
                                                      arguments: {
                                                        'url': loginController
                                                            .webinarFileImages
                                                            .first
                                                            .url
                                                            .toString(),
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Image.network(
                                                  loginController
                                                          .webinarFileImages
                                                          .isNotEmpty
                                                      ? loginController
                                                            .webinarFileImages
                                                            .first
                                                            .url
                                                            .toString()
                                                      : '',
                                                  width: double.infinity,
                                                  height: isMobile
                                                      ? 200
                                                      : (width > 900
                                                            ? 350
                                                            : 220),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Container(
                                                        color: Colors
                                                            .grey
                                                            .shade200,
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Icon(
                                                          Icons.image,
                                                          color: AppColors.grey,
                                                          size: 40,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black.withValues(
                                                        alpha: 0.6,
                                                      ),
                                                      Colors.transparent,
                                                    ],
                                                    begin:
                                                        Alignment.bottomCenter,
                                                    end: Alignment.topCenter,
                                                  ),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    20,
                                                  ),
                                                  child: Text(
                                                    webinar.webinarTitle ?? "",
                                                    style: AppTextStyles.body(
                                                      context,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TabBar(
                                          indicatorColor: AppColors.primary,
                                          indicatorWeight: 3,
                                          labelColor: AppColors.black,
                                          unselectedLabelColor: AppColors.black,
                                          tabs: [
                                            const Tab(
                                              text: 'Webinar Description',
                                            ),
                                            Tab(
                                              text:
                                                  Api.userInfo.read(
                                                            'userType',
                                                          ) !=
                                                          null &&
                                                      Api.userInfo
                                                              .read('userType')
                                                              .toString() ==
                                                          'Job Seekers'
                                                  ? 'Clinic Description'
                                                  : "Applicants List",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ];
                      },
                      body: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isMobile ? 10 : 30.0,
                              0,
                              isMobile ? 10 : 30.0,
                              isMobile ? 10 : 30.0,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TabBarView(
                                children: [
                                  SingleChildScrollView(
                                    padding: EdgeInsets.all(isMobile ? 15 : 24),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _leftSection(webinar, isMobile),
                                        const SizedBox(height: 20),
                                        _rightSection(webinar, isMobile),
                                      ],
                                    ),
                                  ),
                                  Api.userInfo.read('token') != null &&
                                          Api.userInfo.read('userType') !=
                                              'Job Seekers'
                                      ? _buildApplicationsTab(
                                          jobController.appliedWebinarList,
                                          width,
                                          context,
                                        )
                                      : (webinar.description != null &&
                                            webinar.description
                                                .toString()
                                                .isNotEmpty)
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: IgnorePointer(
                                            child: QuillEditor(
                                              controller: _controller,
                                              scrollController:
                                                  _quillScrollController,
                                              focusNode: _focusNode,
                                              config: const QuillEditorConfig(
                                                showCursor: false,
                                                expands: false,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            "No Description",
                                            style: AppTextStyles.caption(
                                              context,
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _quillScrollController.dispose();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _leftSection(var webinar, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconText(Icons.business, webinar.orgName ?? "N/A", context, isMobile),
        _iconText(Icons.location_on, webinar.place ?? "N/A", context, isMobile),
        _iconText(
          Icons.calendar_today,
          formatDate(webinar.createdDate.toString()),
          context,
          isMobile,
        ),
        _iconText(
          Icons.access_time,
          "${webinar.startTime} - ${webinar.endTime}",
          context,
          isMobile,
        ),
      ],
    );
  }

  Widget _rightSection(var webinar, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "About Webinar",
                style: AppTextStyles.body(context, fontWeight: FontWeight.bold),
              ),
            ),
            InkWell(
              onTap: () => shareWebinarPost(
                webinarTitle: webinar.webinarTitle ?? '',
                orgName: webinar.orgName ?? '',
                place: webinar.place,
                date: formatDate(webinar.createdDate?.toString()),
                startTime: webinar.startTime,
                endTime: webinar.endTime,
                description: plainTextFromDelta(webinar.webinarDescription),
                imageUrl: loginController.webinarFileImages.isNotEmpty
                    ? loginController.webinarFileImages.first.url.toString()
                    : null,
                webinarId: webinar.webinarId?.toString(),
              ),
              child: Icon(
                Icons.share_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ],
        ),
        // const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: IgnorePointer(
            child: QuillEditor(
              controller: _controller,
              scrollController: _quillScrollController,
              focusNode: _focusNode,
              config: const QuillEditorConfig(
                showCursor: false,
                expands: false,
              ),
            ),
          ),
        ),
        //Text(webinar.webinarDescription ?? "", style:  AppTextStyles.body(context, color: Colors.black87)),
        const SizedBox(height: 10),
        Text(
          "Webinar Link",
          style: AppTextStyles.caption(context, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () {
            Get.toNamed(
              '/webViewProfilePage',
              arguments: {
                "url": webinar.webinarLink ?? "",
                "clinicName": webinar.webinarTitle ?? "",
              },
            );
          },
          child: Text(
            webinar.webinarLink ?? "",
            style: AppTextStyles.caption(
              context,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconText(IconData icon, String text, dynamic context, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.body(context))),
        ],
      ),
    );
  }
}

String formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return "N/A";
  try {
    final date = DateTime.parse(isoDate).toLocal();
    return DateFormat('MMM dd, yyyy').format(date);
  } catch (_) {
    return "N/A";
  }
}

Widget _buildApplicationsTab(
  List applicants,
  double width,
  BuildContext context,
) {
  if (applicants.isEmpty) {
    return Center(
      child: Text(
        'No data found',
        style: AppTextStyles.caption(
          context,
          color: AppColors.black,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width > 900 ? width * 0.1 : 16,
        vertical: 20,
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: applicants.map<Widget>((applier) {
          return _applicationCard(applier, width, context);
        }).toList(),
      ),
    ),
  );
}

Widget _applicationCard(dynamic applier, double width, BuildContext context) {
  double cardWidth = width > 1200 ? 400 : width * 0.45;
  final loginController = Get.find<LoginController>();
  final screenWidth = MediaQuery.of(context).size.width;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () async {
        await loginController.getProfileByUserId(
          applier.jobSeekerId ?? "",
          context,
        );
        Get.to(() => const ViewWebProfilePage());
      },
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.14,
                  backgroundColor: AppColors.primary,
                  child: ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/doctor1.jpg',
                      image: "${AppConstants.baseUrl}${applier.image}",
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_outlined,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applier.name ?? "",
                        style: AppTextStyles.caption(
                          context,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Text(
                        "Email: ${applier.email ?? ""}",
                        style: AppTextStyles.caption(
                          context,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      // Text("JobId: ${applier.webinarId ?? ""}",
                      //     style: AppTextStyles.caption(context,fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.call,
                    color: Colors.green,
                    size: screenWidth * 0.012,
                  ),
                  onPressed: () {
                    launchCall(applier.mobileNumber ?? "");
                  },
                ),
                Text(
                  applier.mobileNumber ?? "",
                  style: AppTextStyles.caption(
                    context,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    color: AppColors.grey,
                    size: screenWidth * 0.012,
                  ),
                  onPressed: () async {
                    await loginController.getProfileByUserId(
                      applier.jobSeekerId ?? "",
                      context,
                    );
                    Get.toNamed('/viewProfilePageWeb');
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (_) => const JobSeekerProfilePage()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
