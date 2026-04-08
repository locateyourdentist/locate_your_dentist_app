import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_bottom_navigation.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/job_pages/view_webinar_page.dart';
import 'package:locate_your_dentist/modules/plans/payment_pdf.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

class InvoiceListPage extends StatefulWidget {
  // final List<Invoice> invoices;
  //
  // const InvoiceListPage({super.key, required this.invoices});
  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
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
      appBar: AppBar(
        backgroundColor: AppColors.white,centerTitle: true,
        title: Text(
          'My Purchases',
          style: AppTextStyles.subtitle(context, color: AppColors.black),
        ),
        automaticallyImplyLeading: true,iconTheme: IconThemeData(color: AppColors.black,size: size*0.05),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body:GetBuilder<PlanController>(
          builder: (controller) {
            return planController.invoiceList.isEmpty
              ? const Center(
            child: Text(
              "No invoices available",
              style: TextStyle(fontSize: 16),
            ),
          )
              : ListView.builder(
            padding:  const EdgeInsets.all(16),
            itemCount: planController.invoiceList.length,
            itemBuilder: (context, index) {
              final invoice = planController.invoiceList[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary,AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       "PlanType: ${invoice.planType}",
                        style:AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white)
                      ),
                      const SizedBox(height: 4),
                      Text(
                          "Plan Name: ${invoice.planName}",
                          style:AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Invoice: ${invoice.invoiceId}",
                          style:AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white)

                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Amount: ₹${invoice.amount.toStringAsFixed(2)}",
                              style:AppTextStyles.caption(context,fontWeight: FontWeight.bold,color: AppColors.white)

                          ),
                          Text("${formatDate(invoice.createdAt.toString())}",
                            //"${invoice.createdAt.day}-${invoice.createdAt.month}-${invoice.createdAt.year}",
                            style: AppTextStyles.caption(context,color: AppColors.white),
                          ),
                        ],
                      ),
                       const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: ()async {

                              String name = Api.userInfo.read('name') ?? "";
                              if (planController.invoiceList.isEmpty) {
                                Get.snackbar("No invoices", "Invoice list is empty");
                                return;
                              }

                              //final invoice = planController.invoiceList[0];
                              final invoice = planController.invoiceList.first;
                             await planController.getInvoiceById("${invoice.invoiceId.toString()}",context);
                              await planController.getInvoiceDetails(context);

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
                              //OpenFilex.open(pdfFile.path);
                            },
                            icon:  Icon(Icons.picture_as_pdf,color: AppColors.black,size: size*0.06,),
                            label:  Text("View PDF",style: AppTextStyles.caption(context,color: AppColors.black),),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
      bottomNavigationBar: const CommonBottomNavigation(currentIndex: 0),
    );
  }
}