// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:locate_your_dentist/common_widgets/color_code.dart';
// import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
// import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
// import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
// import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:intl/intl.dart';
//
// class CheckoutScreenWeb extends StatefulWidget {
//   @override
//   _CheckoutScreenWebState createState() => _CheckoutScreenWebState();
// }
//
// class _CheckoutScreenWebState extends State<CheckoutScreenWeb> {
//   late Razorpay _razorpay;
//   final PlanController planController = Get.put(PlanController());
//
//   late final double amount;
//   late final String name, planName, mobileNumber, email, startDate, endDate, userId, planId;
//
//   @override
//   void initState() {
//     super.initState();
//     final args = Get.arguments as Map<String, dynamic>;
//     amount = (args['amount'] ?? 0).toDouble();
//     name = args['name'] ?? '';
//     planName = args['planName'] ?? '';
//     mobileNumber = args['mobileNumber'] ?? '';
//     email = args['email'] ?? '';
//     startDate = args['startDate'] ?? '';
//     endDate = args['endDate'] ?? '';
//     userId = args['userId'] ?? '';
//     planId = args['planId'] ?? '';
//
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//
//     loadData();
//   }
//
//   void loadData() async {
//     await planController.getCompanyDetails();
//     await planController.getGstDetails(context);
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   void _openRazorpay() {
//     final options = {
//       'key': 'YOUR_RAZORPAY_KEY',
//       'amount': amount * 100,
//       'name': 'Razorpay Inc.',
//       'description': 'Thank you for shopping with us!',
//       'prefill': {'contact': mobileNumber, 'email': email},
//       'theme': {'color': '#004958'}
//     };
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print(e.toString());
//     }
//   }
//
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     // Implement your payment success logic
//     print('Payment Success: ${response.paymentId}');
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     print('Payment Error: ${response.code} - ${response.message}');
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print('External Wallet: ${response.walletName}');
//   }
//
//   String formatDate(String date) {
//     if (date.isEmpty) return '';
//     try {
//       final parts = date.split('-');
//       final dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
//       return DateFormat('MMM d, yyyy').format(dt);
//     } catch (e) {
//       return date;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isWeb = MediaQuery.of(context).size.width > 600;
//     double size=MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       appBar: CommonWebAppBar(
//         height: size * 0.08,
//         title: "LYD",
//         onLogout: () {
//         },
//         onNotification: () {
//         },
//       ),
//       body: Row(
//         children: [
//           const AdminSideBar(),
//           Expanded(
//             child: Center(
//               child: Container(
//                 constraints: const BoxConstraints(maxWidth: 900),
//                 padding: EdgeInsets.symmetric(horizontal: isWeb ? 40 : 20, vertical: 20),
//                 child: Column(
//                   children: [
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Plan Summary',
//                               style: AppTextStyles.caption(context, fontWeight: FontWeight.bold, color: AppColors.primary),
//                             ),
//                             const SizedBox(height: 20),
//                             Card(
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                               elevation: 4,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(24),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     /// Plan Badge
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                                       decoration: BoxDecoration(
//                                         color: AppColors.secondary.withOpacity(0.15),
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       child: Text(
//                                         planName,
//                                         style: const TextStyle(
//                                           color: AppColors.secondary,
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 16,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 24),
//                                     _modernRow('Start Date', formatDate(startDate)),
//                                     _modernRow('End Date', formatDate(endDate)),
//                                     _modernRow('User ID', userId),
//                                     const SizedBox(height: 30),
//
//                                     /// Amount Highlight
//                                     Center(
//                                       child: Container(
//                                         padding: const EdgeInsets.all(20),
//                                         decoration: BoxDecoration(
//                                           gradient: const LinearGradient(
//                                             colors: [AppColors.primary, AppColors.secondary],
//                                           ),
//                                           borderRadius: BorderRadius.circular(16),
//                                         ),
//                                         child: Column(
//                                           children: [
//                                             Text(
//                                               'Total Amount',
//                                               style: TextStyle(color: Colors.white.withOpacity(0.8)),
//                                             ),
//                                             const SizedBox(height: 6),
//                                             Text(
//                                               '₹ ${amount.toStringAsFixed(2)}',
//                                               style: AppTextStyles.caption(context, fontWeight: FontWeight.bold, color: Colors.white),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 20),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: const [
//                                         Icon(Icons.lock, size: 16, color: Colors.grey),
//                                         SizedBox(width: 6),
//                                         Text('Secure payment via Razorpay', style: TextStyle(color: Colors.grey)),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     /// Checkout Button
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 1),
//                       child: SizedBox(
//                         width: size*0.24,
//                         child: ElevatedButton(
//                           onPressed: _openRazorpay,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             elevation: 5,
//                             backgroundColor: AppColors.primary,
//                           ),
//                           child: Text(
//                             'Proceed to Checkout',
//                             style: AppTextStyles.subtitle(context, color: AppColors.white),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _modernRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: const TextStyle(color: Colors.grey, fontSize: 15)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
//
// import 'package:locate_your_dentist/common_widgets/color_code.dart';
// import 'package:locate_your_dentist/common_widgets/common_textstyles.dart';
// import 'package:locate_your_dentist/modules/plans/plan_controller.dart';
// import 'package:locate_your_dentist/web_modules/common/common_side_bar.dart';
// import 'package:locate_your_dentist/web_modules/common/common_widgets_web.dart';
//
// import '../../service_paymentt/payment_stub.dart';
//
// class CheckoutScreenWeb extends StatefulWidget {
//   @override
//   _CheckoutScreenWebState createState() => _CheckoutScreenWebState();
// }
//
// class _CheckoutScreenWebState extends State<CheckoutScreenWeb> {
//
//   Razorpay? _razorpay;
//   final PlanController planController = Get.put(PlanController());
//
//   late final double amount;
//   late final String name, planName, mobileNumber, email, startDate, endDate, userId, planId;
//   final paymentService = PaymentService();
//   @override
//   void initState() {
//     super.initState();
//
//     final args = Get.arguments as Map<String, dynamic>;
//
//     amount = (args['amount'] ?? 0).toDouble();
//     name = args['name'] ?? '';
//     planName = args['planName'] ?? '';
//     mobileNumber = args['mobileNumber'] ?? '';
//     email = args['email'] ?? '';
//     startDate = args['startDate'] ?? '';
//     endDate = args['endDate'] ?? '';
//     userId = args['userId'] ?? '';
//     planId = args['planId'] ?? '';
//
//     /// ✅ Only initialize Razorpay for mobile
//     if (!kIsWeb) {
//       _razorpay = Razorpay();
//       _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//       _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//       _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     }
//
//     loadData();
//   }
//
//   void loadData() async {
//     await planController.getCompanyDetails();
//     await planController.getGstDetails(context);
//   }
//
//   @override
//   void dispose() {
//     if (!kIsWeb) {
//       _razorpay?.clear();
//     }
//     super.dispose();
//   }
//
//   // ================= MOBILE PAYMENT =================
//   void _openRazorpayMobile() {
//     var options = {
//       'key': 'YOUR_RAZORPAY_KEY',
//       'amount': amount * 100,
//       'name': name,
//       'description': planName,
//       'prefill': {
//         'contact': mobileNumber,
//         'email': email,
//       }
//     };
//
//     try {
//       _razorpay?.open(options);
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
//
//   // ================= WEB PAYMENT =================
//   void _openRazorpayWeb() {
//     js.context.callMethod('eval', ["""
//       var options = {
//         "key": "YOUR_RAZORPAY_KEY",
//         "amount": ${amount * 100},
//         "name": "$name",
//         "description": "$planName",
//         "prefill": {
//           "contact": "$mobileNumber",
//           "email": "$email"
//         },
//         "theme": {
//           "color": "#004958"
//         },
//         "handler": function (response) {
//           alert("Payment Success: " + response.razorpay_payment_id);
//         }
//       };
//       var rzp = new Razorpay(options);
//       rzp.open();
//     """]);
//   }
//
//   // ================= COMMON HANDLER =================
//   void startPayment() {
//     if (kIsWeb) {
//       _openRazorpayWeb();
//     } else {
//       _openRazorpayMobile();
//     }
//   }
//
//   // ================= CALLBACKS =================
//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     print("SUCCESS: ${response.paymentId}");
//   }
//
//   void _handlePaymentError(PaymentFailureResponse response) {
//     print("ERROR: ${response.message}");
//   }
//
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print("WALLET: ${response.walletName}");
//   }
//
//   String formatDate(String date) {
//     if (date.isEmpty) return '';
//     try {
//       final parts = date.split('-');
//       final dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
//       return DateFormat('MMM d, yyyy').format(dt);
//     } catch (e) {
//       return date;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     double size = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBg,
//       appBar: CommonWebAppBar(
//         height: size * 0.08,
//         title: "LYD",
//         onLogout: () {},
//         onNotification: () {},
//       ),
//       body: Row(
//         children: [
//           const AdminSideBar(),
//
//           Expanded(
//             child: Center(
//               child: Container(
//                 constraints: const BoxConstraints(maxWidth: 900),
//                 padding: const EdgeInsets.all(20),
//
//                 child: Column(
//                   children: [
//
//                     /// ================= CONTENT =================
//                     Expanded(
//                       child: SingleChildScrollView(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//
//                             Text(
//                               'Plan Summary',
//                               style: AppTextStyles.caption(
//                                 context,
//                                 fontWeight: FontWeight.bold,
//                                 color: AppColors.primary,
//                               ),
//                             ),
//
//                             const SizedBox(height: 20),
//
//                             Card(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               elevation: 4,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(24),
//
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//
//                                     /// PLAN NAME
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                                       decoration: BoxDecoration(
//                                         color: AppColors.secondary.withOpacity(0.15),
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       child: Text(
//                                         planName,
//                                         style: const TextStyle(
//                                           color: AppColors.secondary,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//
//                                     const SizedBox(height: 20),
//
//                                     _row("Start Date", formatDate(startDate)),
//                                     _row("End Date", formatDate(endDate)),
//                                     _row("User ID", userId),
//
//                                     const SizedBox(height: 30),
//
//                                     /// AMOUNT BOX
//                                     Center(
//                                       child: Container(
//                                         padding: const EdgeInsets.all(20),
//                                         decoration: BoxDecoration(
//                                           gradient: const LinearGradient(
//                                             colors: [AppColors.primary, AppColors.secondary],
//                                           ),
//                                           borderRadius: BorderRadius.circular(16),
//                                         ),
//                                         child: Column(
//                                           children: [
//                                             Text("Total Amount", style: TextStyle(color: Colors.white70)),
//                                             Text(
//                                               "₹ ${amount.toStringAsFixed(2)}",
//                                               style: AppTextStyles.subtitle(context, color: Colors.white),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     /// ================= BUTTON =================
//                     SizedBox(
//                       width: size * 0.25,
//                       child: ElevatedButton(
//                         onPressed: startPayment,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           backgroundColor: AppColors.primary,
//                         ),
//                         child: Text(
//                           "Proceed to Checkout",
//                           style: AppTextStyles.subtitle(context, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _row(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: const TextStyle(color: Colors.grey)),
//           Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//}

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
  late final String name, planName, mobileNumber, email, startDate, endDate, userId, planId;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>;
    amount = (args['amount'] ?? 0).toDouble();
    name = args['name'] ?? '';
    planName = args['planName'] ?? '';
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