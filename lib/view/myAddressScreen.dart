import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAddressSample extends StatefulWidget {
  const MyAddressSample({Key? key});

  @override
  State<MyAddressSample> createState() => _MyAddressSampleState();
}

class _MyAddressSampleState extends State<MyAddressSample> {
  late User _currentUser;
  bool _isLoading = true;
  List<DocumentSnapshot> _addressList = [];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    _currentUser = FirebaseAuth.instance.currentUser!;
    try {
      final QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .where('userId', isEqualTo: _currentUser.uid)
          .get();
      setState(() {
        _isLoading = false;
        _addressList = addressSnapshot.docs;
      });
    } catch (error) {
      print('Error fetching addresses: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Address'),
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                  width: 500,
                  height: 100,
                  child: Card(
                    child:
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : _addressList.isEmpty
                        ? Center(child: Text('No addresses found'))
                        : ListView.builder(
                      itemCount: _addressList.length,
                      itemBuilder: (context, index) {
                        final addressData = _addressList[index].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(addressData['name']),
                          subtitle: Text('${addressData['houseNo']}, ${addressData['roadName']}, ${addressData['city']}, ${addressData['state']}, ${addressData['pincode']}'),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      )
    );
  }
}
