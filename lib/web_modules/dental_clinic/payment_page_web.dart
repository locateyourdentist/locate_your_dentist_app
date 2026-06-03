import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:locate_your_dentist/common_widgets/color_code.dart';
import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
import 'package:locate_your_dentist/service_paymentt/payment_stub.dart';
import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';



class CheckoutScreenWeb extends StatefulWidget {
  @override
  _CheckoutScreenWebState createState() => _CheckoutScreenWebState();
}

class _CheckoutScreenWebState extends State<CheckoutScreenWeb> {
  final PlanController planController = Get.put(PlanController());
  final paymentService = PaymentService();

  late final double amount;
  late final String name, planName,planType, mobileNumber, email, startDate, endDate, userId, planId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>;
    amount = (args['amount'] ?? 0).toDouble();
    name = args['name'] ?? '';
    planName = args['planName'] ?? '';
    planType = args['planType'] ?? '';
    mobileNumber = args['mobileNumber'] ?? '';
    email = args['email'] ?? '';
    startDate = args['startDate'] ?? '';
    endDate = args['endDate'] ?? '';
    userId = args['userId'] ?? '';
    planId = args['planId'] ?? '';

    if (!kIsWeb && paymentService is dynamic) {
      // Mobile only: initialize Razorpay callbacks
      (paymentService as dynamic).initRazorpay(
        onSuccess: _handlePaymentSuccess,
        onError: _handlePaymentError,
        onWallet: _handleExternalWallet,
      );
    }

    loadData();
  }

  void loadData() async {
    await planController.getCompanyDetails();
    await planController.getGstDetails(context);
  }

  @override
  void dispose() {
    if (!kIsWeb && paymentService is dynamic) {
      (paymentService as dynamic).dispose();
    }
    super.dispose();
  }

  void startPayment() {
    paymentService.startPayment(
      amount,
      name: name,
      planName: planName,
      planType:planType,
      email: email,
      mobileNumber: mobileNumber,
    );
  }

  void _handlePaymentSuccess(response) {
    print("SUCCESS: ${response.paymentId}");
  }

  void _handlePaymentError(response) {
    print("ERROR: ${response.message}");
  }

  void _handleExternalWallet(response) {
    print("WALLET: ${response.walletName}");
  }

  String formatDate(String date) {
    if (date.isEmpty) return '';
    try {
      final parts = date.split('-');
      final dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: CommonWebAppBar(
        height: size * 0.03,
        title: "LYD",
        onLogout: () {},
        onNotification: () {},
      ),
      body: Row(
        children: [
          const AdminSideBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Order Summary",
                              style: AppTextStyles.caption(
                                context,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),
                            _infoTile("PlanType", planType),
                            _infoTile("Plan", planName),
                            _infoTile("Start Date", formatDate(startDate)),
                            _infoTile("End Date", formatDate(endDate)),
                            _infoTile("User ID", userId),
                            _infoTile("Mobile", mobileNumber),
                            _infoTile("Email", email),

                            const Divider(height: 40),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Amount",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "₹ ${amount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20,),
                            Center(
                              child: Container(
                                width: size*0.3,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [

                                    const Icon(Icons.payment,
                                        size: 60, color: AppColors.primary),

                                    const SizedBox(height: 20),

                                    Text(
                                      "Secure Payment",
                                      style: AppTextStyles.subtitle(
                                        context,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    const Text(
                                      "You will be redirected to a secure payment gateway.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),

                                    const SizedBox(height: 30),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: startPayment,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          "Pay Now",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}