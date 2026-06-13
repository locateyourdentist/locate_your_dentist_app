import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/job_pages/view_webinar_page.dart';
import 'package:locate_your_dentist/modules/plans/payment_pdf.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:get/get.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';

class InvoiceListPageWeb extends StatefulWidget {
  @override
  State<InvoiceListPageWeb> createState() => _InvoiceListPageWebState();
}

class _InvoiceListPageWebState extends State<InvoiceListPageWeb> {
  final planController = Get.put(PlanController());
  final GlobalKey<ScaffoldState> _scaffoldKeyInvoice = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    planController.getInvoiceDetails(context);
  }

  String capitalizeFirst(String text) {
    if (text.isEmpty) return "";
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 1100;
    final bool isMobileLayout = width < 760;
    final bool isLoggedIn = Api.userInfo.read('token') != null;

    return Scaffold(
      key: _scaffoldKeyInvoice,
      drawer: (isLoggedIn && !isDesktop) ? const Drawer(width: 250, child: AdminSideBar()) : null,
      appBar: CommonWebAppBar(
        height: width * 0.03 > 60 ? width * 0.03 : 60,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body: GetBuilder<PlanController>(
        builder: (controller) {
          return Row(
            children: [
              if (isLoggedIn && isDesktop) const AdminSideBar(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (isLoggedIn && !isDesktop)
                            Padding(
                              padding: const EdgeInsets.only(top: 10, left: 10),
                              child: IconButton(
                                icon: const Icon(Icons.menu),
                                onPressed: () => _scaffoldKeyInvoice.currentState?.openDrawer(),
                              ),
                            ),

                          if (planController.invoiceList.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Center(
                                child: Text(
                                  "No invoices available",
                                  style: AppTextStyles.caption(context),
                                ),
                              ),
                            ),

                          if (planController.invoiceList.isNotEmpty)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(isMobileLayout ? 10.0 : 25.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: isMobileLayout ? 12 : 25,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          "My Invoices",
                                          style: AppTextStyles.subtitle(color: Colors.black, context),
                                        ),
                                      ),
                                      if (!isMobileLayout)
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(flex: 2, child: Center(child: Text("Plan Type", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold, context)))),
                                              Expanded(flex: 2, child: Center(child: Text("Plan Name", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold, context)))),
                                              Expanded(flex: 3, child: Center(child: Text("Invoice ID", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold, context)))), // 💡 More space allocated
                                              Expanded(flex: 2, child: Center(child: Text("Amount", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold, context)))),
                                              Expanded(flex: 2, child: Center(child: Text("Date", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold, context)))),
                                              Expanded(flex: 2, child: Center(child: Text("Action", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold, context)))),        ],
                                          ),
                                        ),

                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: planController.invoiceList.length,
                                          itemBuilder: (context, index) {
                                            final invoice = planController.invoiceList[index];
                                            final isEven = index % 2 == 0;
                                            final rowColor = isEven ? Colors.grey.shade100 : Colors.white;

                                            Future<void> onDownloadPressed() async {
                                              String name = Api.userInfo.read('name') ?? "";
                                            //  await planController.getInvoiceById("${invoice.invoiceId}", context);
                                              //final invoiceId = planController.invoiceDetails[0];
                                              // final selectedInvoice = planController.invoiceList[index];
                                              //
                                              // await planController.getInvoiceById(
                                              //     "${selectedInvoice.invoiceId}", context);
                                              // final invoiceId = planController.invoiceDetails[0];
                                              //
                                              // await PdfGenerator.generateInvoicePdf(
                                              //   userName: name,
                                              //   planName: invoiceId.planName,
                                              //   planType: invoiceId.planType,
                                              //   startDate: invoiceId.startDate,
                                              //   endDate: invoiceId.endDate,
                                              //   taxSummary: invoiceId.taxSummary,
                                              //   company: invoiceId.company,
                                              //   invoiceId: invoiceId.invoiceId,
                                              //
                                              // );
                                              await planController.getInvoiceById("${invoice.invoiceId.toString()}",context);
                                              await planController.getInvoiceDetails(context);

                                              final invoiceId = planController.invoiceDetails[index];
                                              final pdfFile = await PdfGenerator.generateInvoicePdf(
                                                userName: name,
                                                planName: invoiceId.planName,
                                                planType: invoiceId.planType,
                                                startDate: invoiceId.startDate,
                                                endDate: invoiceId.endDate,
                                                taxSummary: invoiceId.taxSummary,
                                                company: invoiceId.company,
                                                invoiceId: invoiceId.invoiceId,
                                              );
                                            }
                                            if (isMobileLayout) {
                                              return Card(
                                                margin: const EdgeInsets.only(bottom: 12),
                                                color: rowColor,
                                                elevation: 1,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      _buildMobileRow("Plan Type:", capitalizeFirst(invoice.planType ?? "")),
                                                      _buildMobileRow("Plan Name:", invoice.planName ?? "", isBold: true),
                                                      _buildMobileRow("Invoice ID:", invoice.invoiceId.toString()),
                                                      _buildMobileRow("Amount:", "₹${invoice.amount.toStringAsFixed(2)}", customColor: Colors.green, isBold: true),
                                                      _buildMobileRow("Date:", formatDate(invoice.createdAt.toString())),
                                                      const Divider(height: 20),

                                                      // Responsive Button spans full horizontal space comfortably
                                                      SizedBox(
                                                        width: double.infinity,
                                                        child: ElevatedButton.icon(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: AppColors.primary,
                                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                                          ),
                                                          onPressed: onDownloadPressed,
                                                          icon: const Icon(Icons.cloud_download_outlined, color: Colors.white),
                                                          label: const Text(
                                                            "Download Invoice",
                                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }

                                            return Container(
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(flex:2,child: Text(capitalizeFirst(invoice.planType ?? ""), style: AppTextStyles.caption(color: AppColors.black, context))),
                                                  Expanded(flex:2,child: Text(invoice.planName ?? "", style: AppTextStyles.caption(color: AppColors.black, fontWeight: FontWeight.bold, context))),
                                                  Expanded(flex:3,child: Text(invoice.invoiceId.toString(), style: AppTextStyles.caption(color: AppColors.black, context))),
                                                  Expanded(flex:2,child: Text("₹${invoice.amount.toStringAsFixed(2)}", style: AppTextStyles.caption(color: Colors.green, fontWeight: FontWeight.bold, context))),
                                                  Expanded(flex:2,child: Text(formatDate(invoice.createdAt.toString()), style: AppTextStyles.caption(color: AppColors.black, context))),
                                                  Expanded(flex:2,
                                                    child: Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: ElevatedButton.icon(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: AppColors.white,
                                                          elevation: 1,
                                                        ),
                                                        onPressed: onDownloadPressed,
                                                        icon: Icon(Icons.cloud_download_outlined, color: AppColors.black, size: 16),
                                                        label: Text("Download", style: AppTextStyles.caption(context, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
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
  Widget _buildMobileRow(String label, String value, {Color? customColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: customColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}