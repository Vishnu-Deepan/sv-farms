import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentLogic {
  final Razorpay _razorpay = Razorpay();

  // Callback functions for Razorpay events
  final Function(String) onPaymentSuccess;
  final Function(String) onPaymentFailure;

  PaymentLogic({required this.onPaymentSuccess, required this.onPaymentFailure}) {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    onPaymentSuccess("Payment Successful!");
  }

  // Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    onPaymentFailure("Payment Failed!");
  }

  // Handle external wallet response
  void _handleExternalWallet(ExternalWalletResponse response) {
    onPaymentFailure("External Wallet Selected");
  }


  // Open the Razorpay checkout
  void openCheckout({
    required String userName,
    required String userEmail,
    required String userPhone,
    required String planName,
    required int totalAmount,
    required String fullAddress,
  }) {
    var options = {
      'key': 'rzp_test_xxtkgKXuHLnKRr', // Replace with your Razorpay key
      'amount': (totalAmount * 100).toInt(), // Amount in paise
      'name': userName,
      'description': planName,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
      },
      'notes': {
        'address': 'Delivery at: $fullAddress',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay checkout: $e');
    }
  }

  // Dispose Razorpay instance
  void dispose() {
    _razorpay.clear();
  }
}
