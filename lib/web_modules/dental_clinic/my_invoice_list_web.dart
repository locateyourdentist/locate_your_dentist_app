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
  // final List<Invoice> invoices;
  //
  // const InvoiceListPage({super.key, required this.invoices});
  @override
  State<InvoiceListPageWeb> createState() => _InvoiceListPageWebState();
}

class _InvoiceListPageWebState extends State<InvoiceListPageWeb> {
  final planController=Get.put(PlanController());
  @override
  void initState() {
    super.initState();
    planController.getInvoiceDetails(context);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CommonWebAppBar(
        height: size * 0.08,
        title: "LOCATE YOUR DENTIST",
        onLogout: () {},
        onNotification: () {},
      ),
      body:GetBuilder<PlanController>(
          builder: (controller) {
                return Row(
                  children: [
                    const AdminSideBar(),

                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1100),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                               if( planController.invoiceList.isEmpty)

                                 Padding(
                                   padding: const EdgeInsets.all(15.0),
                                   child: Center(child: Text("No invoices available",
                                        style:AppTextStyles.caption(context)),),
                                 ),
                                if( planController.invoiceList.isNotEmpty)

                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(25.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          children: [

                                            Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Text("My Invoices", style: AppTextStyles.subtitle(color: Colors.black,context)),
                                            ),

                                            Container(
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(2),
                                                boxShadow: const [
                                                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                                                ],
                                              ),
                                              child:  Row(
                                                children: [
                                                  Expanded(child: Text("Plan Type", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold,context))),
                                                  Expanded(child: Text("Plan Name", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold,context))),
                                                  Expanded(child: Text("Invoice ID", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold,context))),
                                                  Expanded(child: Text("Amount", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold,context))),
                                                  Expanded(child: Text("Date", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold,context))),
                                                  Expanded(child: Text("Action", style: AppTextStyles.caption(color: Colors.white, fontWeight: FontWeight.bold,context))),
                                                ],
                                              ),
                                            ),

                                            // Table Rows
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: planController.invoiceList.length,
                                                itemBuilder: (context, index) {
                                                  final invoice = planController.invoiceList[index];
                                                  String capitalizeFirst(String text) {
                                                    if (text.isEmpty) return "";
                                                    return text[0].toUpperCase() + text.substring(1);
                                                  }
                                                  final isEven = index % 2 == 0;
                                                  final rowColor = isEven ? Colors.grey.shade100 : Colors.white;

                                                  return Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      color: rowColor,
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            capitalizeFirst(invoice.planType ?? ""),
                                                            style: AppTextStyles.caption(
                                                              color: AppColors.black,
                                                              fontWeight: FontWeight.normal,
                                                              context,
                                                            ),
                                                          ),
                                                        ),                                                        Expanded(child: Text(invoice.planName ?? "",style: AppTextStyles.caption(color: AppColors.black, fontWeight: FontWeight.bold,context))),
                                                        Expanded(child: Text(invoice.invoiceId.toString(),style: AppTextStyles.caption(color: AppColors.black, fontWeight: FontWeight.normal,context))),
                                                        Expanded(child: Text("₹${invoice.amount.toStringAsFixed(2)}",style: AppTextStyles.caption(color: Colors.green, fontWeight: FontWeight.bold,context))),
                                                        Expanded(child: Text(formatDate(invoice.createdAt.toString()),style: AppTextStyles.caption(color: AppColors.black, fontWeight: FontWeight.normal,context))),

                                                        Expanded(
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: ElevatedButton.icon(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: AppColors.white,
                                                              ),
                                                              onPressed: () async {
                                                                String name = Api.userInfo.read('name') ?? "";

                                                                final selectedInvoice = planController.invoiceList[index];

                                                                await planController.getInvoiceById(
                                                                    "${selectedInvoice.invoiceId}", context);

                                                                final invoiceId = planController.invoiceDetails[0];

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

                                                                // if (kIsWeb) {
                                                                //   final bytes = await pdfFile.readAsBytes();
                                                                //
                                                                //   final blob = html.Blob([bytes], 'application/pdf');
                                                                //   final url = html.Url.createObjectUrlFromBlob(blob);
                                                                //
                                                                //   final anchor = html.AnchorElement(href: url)
                                                                //     ..setAttribute("download", "invoice.pdf")
                                                                //     ..click();
                                                                //
                                                                //   html.Url.revokeObjectUrl(url);
                                                                // } else {
                                                                //   OpenFilex.open(pdfFile.path);
                                                                // }
                                                              },
                                                              icon:  Icon(Icons.cloud_download_outlined,color: AppColors.grey,size: size*0.01,),

                                                              label:  Text("Download",style: AppTextStyles.caption(context,color: AppColors.primary,fontWeight: FontWeight.bold),),
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
                                  ),
                                )

                                        ]
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
          }
      ),
    );
  }
}