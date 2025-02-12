import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout_screen.dart';
import 'home_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _removeOrder(String orderId) async {
    await _firestore.collection("orders").doc(orderId).delete();
  }

  void _goToHomeScreen() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  void _proceedToCheckout() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToHomeScreen();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.blue[900],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Orders", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goToHomeScreen,
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection("orders").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            var orders = snapshot.data!.docs;
            return orders.isEmpty
                ? const Center(child: Text("No orders yet", style: TextStyle(color: Colors.white)))
                : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var order = orders[index];
                      return ListTile(
                        title: Text(order["store"], style: TextStyle(color: Colors.white)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeOrder(order.id),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(onPressed: _proceedToCheckout, child: const Text("Proceed to Checkout"))
              ],
            );
          },
        ),
      ),
    );
  }
}
