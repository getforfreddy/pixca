import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../controller/RazorPayCredentials.dart';

class RazorPayPage extends StatefulWidget {
  const RazorPayPage({Key? key}) : super(key: key);

  @override
  State<RazorPayPage> createState() => _RazorPayPageState();
}

class _RazorPayPageState extends State<RazorPayPage> {
  late Razorpay _razorpay;
  TextEditingController amtController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int grandTotal = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    fetchGrandTotal();
  }

  Future<void> fetchGrandTotal() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .where('orderStatus', isEqualTo: 'Processing')
            .get();

        int total = 0;

        for (var orderDoc in orderSnapshot.docs) {
          // Log the document data to debug
          print('Document data: ${orderDoc.data()}');

          // Get the price string and remove non-numeric characters
          String priceStr = orderDoc['price'] ?? '0';
          priceStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');

          // Convert the cleaned price string to an integer
          int price = int.tryParse(priceStr) ?? 0;

          // Log the converted price
          print('Converted price: $price');

          total += price;
        }

        // Log the total amount
        print('Total amount: $total');

        setState(() {
          grandTotal = total;
          amtController.text = grandTotal.toString();
        });
      } catch (e) {
        // Handle potential errors
        print('Error fetching orders: $e');
        Fluttertoast.showToast(
            msg: 'Error fetching orders',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckOut(int amount) async {
    var options = {
      'key': RazorPayCredentials.keyId,
      'amount': amount * 100,
      'currency': 'INR',
      'name': 'Freddy Nixal',
      'description': 'Description for order',
      'timeout': 60,
      'prefill': {
        'contact': '8157848503',
        'email': 'freddynixal1999@gmail.com'
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

  // Future<void> _updateOrderStatus() async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     try {
  //       QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
  //           .collection('orders')
  //           .where('userId', isEqualTo: user.uid)
  //           .get();
  //
  //       for (var orderDoc in orderSnapshot.docs) {
  //         await orderDoc.reference.update({'orderStatus': 'Success'});
  //       }
  //     } catch (e) {
  //       print('Error updating order status: $e');
  //       Fluttertoast.showToast(
  //           msg: 'Error updating order status',
  //           toastLength: Toast.LENGTH_SHORT,
  //           gravity: ToastGravity.BOTTOM);
  //     }
  //   }
  // }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(
        msg: 'Payment Success: ' + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM);

    await _updateOrderStatus(response.paymentId!);
  }

  Future<void> _updateOrderStatus(String paymentId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .get();

        for (var orderDoc in orderSnapshot.docs) {
          await orderDoc.reference.update({
            'orderStatus': 'Success',
            'paymentId': paymentId,
          });
        }
      } catch (e) {
        print('Error updating order status: $e');
        Fluttertoast.showToast(
            msg: 'Error updating order status',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM);
      }
    }
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
        title: Text('RazorPay Integration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(amtController.text),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    int amount = int.tryParse(amtController.text) ?? 0;
                    openCheckOut(amount);
                  }
                },
                child: Text('Pay Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
