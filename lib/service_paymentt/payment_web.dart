import 'dart:js' as js;
import 'package:locate_your_dentist/utills/constants.dart';

class PaymentService {
  void startPayment(
      double amount, {
        String? name,
        String? planType,
        String? planName,
        String? email,
        String? mobileNumber,
      }) {
    js.context.callMethod('eval', ["""
      var options = {
        "key": "${AppConstants.razorPayKey}",
        "amount": ${amount * 100},
        "name": "$name",
        "description": "$planName",
        "prefill": {"contact": "$mobileNumber", "email": "$email"},
        "theme": {"color": "#004958"},
        "handler": function(response) { alert("Payment Success: " + response.razorpay_payment_id); }
      };
      var rzp = new Razorpay(options);
      rzp.open();
    """]);
  }
}