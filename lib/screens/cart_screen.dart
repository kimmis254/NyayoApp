import 'package:flutter/material.dart';
import 'home_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = []; // Example cart items

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900], // Consistent Theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Go back
        ),
        title: const Text("My Cart", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartList(),
    );
  }

  // UI for Empty Cart
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/empty_cart.png", height: 150), // Placeholder Image
          const SizedBox(height: 20),
          const Text(
            "There's nothing here, wanna shop?",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
            },
            child: const Text(
              "Browse Our Products",
              style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // UI for Cart Items List
  Widget _buildCartList() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Image.asset("assets/product_placeholder.png", width: 50), // Example Product Image
              title: Text(item["name"], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              subtitle: Text("Price: \$${item["price"]}", style: TextStyle(color: Colors.grey[700])),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    cartItems.removeAt(index); // Remove item from cart
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
