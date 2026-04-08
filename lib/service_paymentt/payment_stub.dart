class PaymentService {
  /// Unified method for both web and mobile
  void startPayment(
      double amount, {
        String? name,
        String? planName,
        String? email,
        String? mobileNumber,
      }) {
    print("Payment not supported on this platform");
  }
}