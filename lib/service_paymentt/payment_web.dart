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
    void Function(String paymentId)? onSuccess,
    void Function(String reason)? onDismiss,
  }) {
    js.context['razorpaySuccessHandler'] = js.JsFunction.withThis((
      thisArg,
      String paymentId,
    ) {
      onSuccess?.call(paymentId);
    });
    js.context['razorpayDismissHandler'] = js.JsFunction.withThis((thisArg) {
      onDismiss?.call('Payment cancelled');
    });

    js.context.callMethod('eval', [
      """
      var options = {
        "key": "${AppConstants.razorPayKey}",
        "amount": ${amount * 100},
        "name": "$name",
        "description": "$planName",
        "prefill": {"contact": "$mobileNumber", "email": "$email"},
        "theme": {"color": "#004958"},
        "handler": function(response) { razorpaySuccessHandler(response.razorpay_payment_id); },
        "modal": { "ondismiss": function() { razorpayDismissHandler(); } }
      };
      var rzp = new Razorpay(options);
      rzp.open();
    """,
    ]);
  }
}
