import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:locate_your_dentist/utills/constants.dart';

class PaymentService {
  Razorpay? _razorpay;

  void initRazorpay({
    required void Function(PaymentSuccessResponse) onSuccess,
    required void Function(PaymentFailureResponse) onError,
    required void Function(ExternalWalletResponse) onWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onWallet);
  }

  void startPayment(
      double amount, {
        String? name,
        String? planType,
        String? planName,
        String? email,
        String? mobileNumber,
      }) {
    var options = {
      'key': AppConstants.razorPayKey,
      'amount': amount * 100,
      'name': name,
      'description': '$planType - $planName',
      'prefill': {'contact': mobileNumber, 'email': email},
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void dispose() {
    _razorpay?.clear();
  }
}