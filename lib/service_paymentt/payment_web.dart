import 'dart:js' as js;
import 'payment_stub.dart';

class PaymentServiceWeb extends PaymentService {
  @override
  void startPayment(
      double amount, {
        String? name,
        String? planName,
        String? email,
        String? mobileNumber,
      }) {
    js.context.callMethod('eval', ["""
      var options = {
        "key": "YOUR_RAZORPAY_KEY",
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