import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String? _fullName, _email;
  String _deliveryMethod = "Delivery"; // Default to Delivery
  String _selectedPaymentMethod = "Mpesa"; // Default payment method
  LatLng? _pickupLocation;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _fetchUserDetails();
    _determinePickupLocation();
  }

  Future<void> _fetchUserDetails() async {
    if (_user == null) return;
    DocumentSnapshot userDoc = await _firestore.collection("users").doc(_user!.uid).get();
    setState(() {
      _fullName = userDoc["fullName"] ?? "Not Set";
      _email = userDoc["email"] ?? "Not Set";
    });
  }

  Future<void> _determinePickupLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _pickupLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _placeOrder() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Order placed successfully!"),
      backgroundColor: Colors.green,
    ));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrdersScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Checkout", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Text("Customer Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            _buildInfoTile("Full Name", _fullName ?? "Loading..."),
            _buildInfoTile("Email", _email ?? "Loading..."),

            const SizedBox(height: 15),

            // Delivery or Pickup
            Text("Delivery Method", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              children: [
                _buildDeliveryOption("Delivery"),
                const SizedBox(width: 10),
                _buildDeliveryOption("Pickup"),
              ],
            ),

            if (_deliveryMethod == "Pickup")
              Container(
                height: 200,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white)),
                child: _pickupLocation != null
                    ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _pickupLocation!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(markerId: const MarkerId("pickup"), position: _pickupLocation!),
                  },
                )
                    : const Center(child: CircularProgressIndicator(color: Colors.white)),
              ),

            const SizedBox(height: 15),

            // Order Summary
            Text("Order Summary", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            _buildInfoTile("Subtotal", "\$50"),
            _buildInfoTile("Delivery Fee", _deliveryMethod == "Delivery" ? "\$5" : "\$0"),
            _buildInfoTile("Total", _deliveryMethod == "Delivery" ? "\$55" : "\$50"),

            const SizedBox(height: 15),

            // Payment Methods
            Text("Payment Method", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                _buildPaymentOption("Mpesa"),
                const SizedBox(width: 10),
                _buildPaymentOption("Card"),
                const SizedBox(width: 10),
                _buildPaymentOption("PayPal"),
              ],
            ),

            const Spacer(),

            // Place Order Button
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Center(child: Text("Place Order", style: TextStyle(color: Colors.white, fontSize: 16))),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for user details
  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper function for delivery method selection
  Widget _buildDeliveryOption(String method) {
    return GestureDetector(
      onTap: () => setState(() => _deliveryMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: _deliveryMethod == method ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(method, style: TextStyle(color: _deliveryMethod == method ? Colors.white : Colors.black)),
      ),
    );
  }

  // Helper function for payment method selection
  Widget _buildPaymentOption(String method) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedPaymentMethod == method ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(method, style: TextStyle(color: _selectedPaymentMethod == method ? Colors.white : Colors.black)),
      ),
    );
  }
}
