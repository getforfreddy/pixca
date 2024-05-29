import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../controller/RazorPayCredentials.dart';



class PaymentPage extends StatefulWidget {
  final String orderId;
  final String image1;
  final String brand;
  final double totalAmount;
  final String userId;

  const PaymentPage({
    Key? key,
    required this.orderId,
    required this.image1,
    required this.brand,
    required this.totalAmount,
    required this.userId,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? userEmail;
  String? userPhone;

  Future<void> fetchUserDetails() async {
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      setState(() {
        userEmail = userSnapshot['email'];
        userPhone = userSnapshot['phoneNumber'];
      });
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    fetchUserDetails();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckOut() async {
    const double usdToInrRate = 75.0;

    int amountInPaise = (widget.totalAmount * usdToInrRate * 100).toInt();

    var options = {
      'key': RazorPayCredentials.keyId,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'Jim Mathew',
      'description': 'Description for order',
      'timeout': 60,
      'prefill': {
        'contact': userPhone ?? '',
        'email': userEmail ?? '',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: 'Payment Success: ' + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: 'Payment Error: ' + response.message!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: 'External Wallet: ' + response.walletName!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(widget.image1, height: 200, width: double.infinity, fit: BoxFit.cover),
              SizedBox(height: 8),
              Text('Brand: ${widget.brand}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Total Amount: \$${widget.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      openCheckOut();
                    }
                  },
                  child: Text('Pay Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}