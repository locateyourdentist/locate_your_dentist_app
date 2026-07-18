import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/modules/auth/login_screen/login_controller.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
import '../controllers/template_builder_controller.dart';
import '../controllers/whatsapp_template_controller.dart';
import '../models/whatsapp_template_model.dart';
import '../widgets/action_bar_widget.dart';
import '../widgets/template_builder_panel.dart';
import '../widgets/template_list_panel.dart';
import '../widgets/whatsapp_preview_panel.dart';

class WhatsappTemplateManagementPage extends StatefulWidget {
  const WhatsappTemplateManagementPage({super.key});

  @override
  State<WhatsappTemplateManagementPage> createState() =>
      _WhatsappTemplateManagementPageState();
}

class _WhatsappTemplateManagementPageState
    extends State<WhatsappTemplateManagementPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final listController = Get.put(WhatsappTemplateController());
  final builderController = Get.put(TemplateBuilderController());
  late final LoginController loginController;

  @override
  void initState() {
    super.initState();
    loginController = Get.put(LoginController());
    listController.fetchTemplates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      builderController.startAutoSave(context);
    });
  }

  @override
  void dispose() {
    builderController.stopAutoSave();
    Get.delete<TemplateBuilderController>();
    Get.delete<WhatsappTemplateController>();
    super.dispose();
  }

  void _selectTemplate(WhatsappTemplateModel template) {
    builderController.loadTemplate(template);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: listController,
      builder: (context, _) => _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isLoggedIn = Api.userInfo.read('token') != null;
    final bool isDesktop = width >= 1100;
    final bool isTablet = width >= 700 && width < 1100;
    final bool isMobile = width < 700;

    PreferredSizeWidget buildAppBar() {
      if (isLoggedIn) {
        return CommonWebAppBar(
          height: isMobile ? 60 : (isTablet ? 70 : 80),
          title: "WhatsApp Templates",
          onLogout: () {},
          onNotification: () {},
        );
      }
      return CommonHeader();
    }

    Widget body;
    if (isDesktop) {
      body = Row(
        children: [
          SizedBox(
            width: 300,
            child: TemplateListPanel(
              listController: listController,
              builderController: builderController,
              onSelectTemplate: _selectTemplate,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: TemplateBuilderPanel(controller: builderController),
          ),
          const VerticalDivider(width: 1),
          SizedBox(
            width: 340,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: WhatsappPreviewPanel(controller: builderController),
            ),
          ),
        ],
      );
    } else if (isTablet) {
      body = Row(
        children: [
          SizedBox(
            width: 260,
            child: TemplateListPanel(
              listController: listController,
              builderController: builderController,
              onSelectTemplate: _selectTemplate,
            ),
          ),
          Expanded(
            child: TemplateBuilderPanel(controller: builderController),
          ),
        ],
      );
    } else {
      body = DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Templates'),
                Tab(text: 'Builder'),
                Tab(text: 'Preview'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TemplateListPanel(
                    listController: listController,
                    builderController: builderController,
                    onSelectTemplate: _selectTemplate,
                  ),
                  TemplateBuilderPanel(controller: builderController),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: WhatsappPreviewPanel(controller: builderController),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldBg,
      appBar: buildAppBar(),
      drawer: (isLoggedIn && !isDesktop)
          ? const Drawer(width: 250, child: AdminSideBar())
          : null,
      body: Row(
        children: [
          if (isDesktop && isLoggedIn) const AdminSideBar(),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: ActionBarWidget(
        controller: builderController,
        existingTemplates: listController.templates,
        onSaved: listController.fetchTemplates,
      ),
    );
  }
}
