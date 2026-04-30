import 'package:flutter/material.dart';
import 'package:locate_your_dentist/api/api.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/model/company_invoice_model.dart';
import 'package:locate_your_dentist/modules/plans/payment_pdf.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/utills/constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

String formatDate(String date) {
  if (date.isEmpty) return '';
  try {
    final parts = date.split('-');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);

    final dateTime = DateTime(year, month, day);
    return DateFormat('MMM d, yyyy').format(dateTime);
  } catch (e) {
    return date;
  }
}

 class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
 }
 class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isPaymentComplete = false;
  late Razorpay _razorpay;
  late final String userId;
  late final String planId;
  late final String startDate;
  late final String endDate;
  late final double amount;
  late final String name;
  late final String planName;
  late final String mobileNumber;
  late final String email;
  final PlanController planController=Get.put(PlanController());
  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
     amount = args['amount'] ?? '';
     name = args['name'] ?? '';
     planName = args['planName'] ?? '';
     mobileNumber = args['mobileNumber'] ?? '';
     email = args['email'] ?? '';
     startDate = args['startDate'] ?? '';
     endDate = args['endDate'] ?? '';
     userId = args['userId'] ?? '';
     planId = args['planId'] ?? '';
     print('name$name');
    loadData();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }
  void loadData()async{
   await planController.getCompanyDetails();
   await planController.getGstDetails(context);
  }
  void _openRazorpay() async {
    var options = {
      'key': AppConstants.razorPayKey,
      // 'order_id': orderId, ->
      'amount': amount*100,
      'name': 'Razorpay Inc.',
      'description': 'Thank you for shopping with us!',
      'prefill': {'contact':Api.userInfo.read('mobileNumber')??"" , 'email': Api.userInfo.read('email')??""},
      'theme': {
        'color': '#004958',
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if(name=='basePlan'){
      await planController.createUserPlans(userId,planId.toString(), planName.toString(),amount.toString(), startDate, endDate, context);

      await generateInvoice(
        amount: double.parse(amount.toString()),
        planName: planName.toString(),planType: name.toString(),startDate: startDate,endDate: endDate
      );
    }
    if(name=='addonsPlan'){
      await  generateInvoice(
        amount: double.parse(amount.toString()),
        planName: planName.toString(),planType: name.toString(),startDate: startDate,endDate: endDate
      );
      await  planController.createUserAddonsPlans(userId, planId.toString(), planName.toString(),amount.toString(),  startDate,endDate, context,);
      // await PdfGenerator.generatePriceSummary(
      //   userName:Api.userInfo.read('name') ?? "",
      //   planName: planName.toString(),
      //   finalAmount: amount,
      //   mobileNumber: Api.userInfo.read('mobileNumber') ?? "",
      //   email: Api.userInfo.read('email') ?? "",
      // );

    }
    if(name=='jobPlan'){
      await planController.createUserJobPlans(userId, planId.toString(), planName.toString(),amount.toString(),  startDate,endDate, context,);
      await generateInvoice(
        amount: double.parse(amount.toString()),
        planName: planName.toString(),planType: name,startDate:startDate,endDate: endDate
      );
    }
    if(name=='webinarPlan'){
      await planController.createUserWebinarPlans(userId, planId.toString(), planName.toString(),amount.toString(),  startDate,endDate, context,);
      await generateInvoice(
        amount: double.parse(amount.toString()),
        planName: planName.toString(),planType: name.toString(),startDate: startDate,endDate: endDate
      );
    }
    if(name=='postPlan'){
      await  planController.createUserPostImagePlans(userId, planId.toString(), planName.toString(),amount.toString(),  startDate,endDate, context,);
      await  generateInvoice(
        amount: double.parse(amount.toString()),
        planName: planName.toString(),planType: name.toString(),startDate: startDate,endDate: endDate
      );
    }
    showPaymentPopupMessage(context, true, 'Payment Successful!');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showPaymentPopupMessage(context, false, 'Payment Failed!');
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    print('You have chosen to pay via : ${response.walletName}. It will take some time to reflect your payment.');
  }
  void showPaymentPopupMessage(
      BuildContext ctx, bool isPaymentSuccess, String message) {
    showGeneralDialog(
      context: ctx,
      barrierDismissible: false,
      barrierLabel: "PaymentDialog",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(ctx).size.width * 0.85,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: isPaymentSuccess
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        isPaymentSuccess ? Icons.check_circle : Icons.cancel,
                        color: isPaymentSuccess ? Colors.green : Colors.red,
                        size: 45,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    isPaymentSuccess ? 'Payment Successful' : 'Payment Failed',
                    style: AppTextStyles.body(
                        context,
                        color: AppColors.black,fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(
                        context,
                        color: Colors.grey.shade700,fontWeight: FontWeight.normal
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        if (isPaymentSuccess) {
                          Get.offAllNamed('/viewPlanPage');
                        }
                        else{
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor:
                        isPaymentSuccess ? Colors.green : Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isPaymentSuccess ? 'CONTINUE' : 'TRY AGAIN',
                        style: AppTextStyles.body(
                            context,
                            color: AppColors.white,fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: Text('Payment',style: AppTextStyles.subtitle(context,color: AppColors.black),),
      ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Plan Summary",
                        style: AppTextStyles.body(
                          context,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [

                            /// Plan Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                planName,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            _modernRow("Start Date", formatDate(startDate)),
                            _modernRow("End Date", formatDate(endDate)),
                            _modernRow("User ID", userId),

                            const SizedBox(height: 30),

                            /// Amount Highlight
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.secondary
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Total Amount",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "₹ ${amount.toStringAsFixed(2)}",
                                      style:AppTextStyles.body(color: Colors.white,fontWeight: FontWeight.bold,context)
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:  [
                                const Icon(Icons.lock, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  "Secure payment via Razorpay",
                                  style:AppTextStyles.caption(color: Colors.grey,context)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _openRazorpay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.transparent,shadowColor: AppColors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child:  Text(
                      "Proceed to Checkout",
                      style: AppTextStyles.caption(
                        fontWeight: FontWeight.bold,context,color: AppColors.white
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
  Widget _modernRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> generateInvoice({
    required double amount,
    required String planName,
    required String planType,
    required String startDate,
    required String endDate,

  }) async {

    final apiCompany = await planController.getCompanyDetails();
    if (apiCompany == null) {
      print("Company details not found");
      return;
    }

    final pdfCompany = Company(
      companyName: apiCompany.companyName,
      gstin: apiCompany.gstin,
      address: apiCompany.address,
      email: apiCompany.email,
      phone: apiCompany.phone,
    );

    if (planController.getGstList.isNotEmpty) {

      final gstData = planController.getGstList.first;
      final double totalPaid = amount;

      final double cgstPercent = (gstData["cgst"] ?? 0).toDouble();
      final double sgstPercent = (gstData["sgst"] ?? 0).toDouble();
      final double igstPercent = (gstData["igst"] ?? 0).toDouble();

      final bool isShowGst = gstData["isShowGst"] == true;

      double baseAmount = totalPaid;
      double cgst = 0;
      double sgst = 0;
      double igst = 0;
      double totalAmount = totalPaid;

      if (isShowGst) {

        final double totalGstPercent =
            cgstPercent + sgstPercent + igstPercent;

        if (totalGstPercent > 0) {
          baseAmount = totalPaid / (1 + totalGstPercent / 100);

          cgst = baseAmount * cgstPercent / 100;
          sgst = baseAmount * sgstPercent / 100;
          igst = baseAmount * igstPercent / 100;

          totalAmount = baseAmount + cgst + sgst + igst;
        }
      }
      final TaxSummary finalTaxSummary = TaxSummary(
        baseAmount: baseAmount,
        cgst: cgst,
        sgst: sgst,
        igst: igst,
        cgstPercentage:cgstPercent ,
        sgstPercentage:sgstPercent ,
        igstPercentage: igstPercent,
        totalAmount: totalAmount,
      );
     await planController.saveInvoicePdf(
        userId: userId,
        planId: planId,
        planType:planType,
        planName: planName,
        startDate: startDate,
        endDate: endDate,
        amount: amount,
        taxSummary: finalTaxSummary,
        company: pdfCompany,
        context: context,
      );
      final invoiceId = (planController.invoiceId ?? "").isNotEmpty ? planController.invoiceId! : "";
      print('inv$invoiceId');
      String name = Api.userInfo.read('orgName') ?? "";
      print('org name$name');
      final pdfFile = await PdfGenerator.generateInvoicePdf(
        userName: name,
        planName: planName,
        planType:planType,startDate: startDate,
        endDate: endDate,
        taxSummary: finalTaxSummary,
        company: pdfCompany,
        invoiceId: invoiceId,
      );

   //   await OpenFilex.open(pdfFile.path);
    }
  }
 }