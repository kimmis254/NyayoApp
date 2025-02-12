import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'shop_screen.dart';
import 'orders_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<String> categories = [
    "Groceries", "Electronics", "Clothing", "Beauty", "Furniture"
  ];

  final List<Map<String, dynamic>> stores = [
    {"name": "SuperMart", "image": "assets/store1.png"},
    {"name": "Tech Haven", "image": "assets/store2.png"},
    {"name": "Fashion Hub", "image": "assets/store3.png"},
    {"name": "Cosmetics Store", "image": "assets/store4.png"},
    {"name": "Furniture World", "image": "assets/store5.png"}
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() => _selectedIndex = index);
      switch (index) {
        case 0:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
          break;
        case 1:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ShopScreen()));
          break;
        case 2:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OrdersScreen()));
          break;
        case 3:
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.blue[900],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      hintText: "Search products...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen())),
              ),
            ],
          ),
        ),

        // Main Body Content
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Categories Section (Circular Icons)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      categories[index][0], // First letter of category
                                      style: TextStyle(
                                          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(categories[index], style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Stores Grid (Better UI with Cards)
              Expanded(
                child: AnimationLimiter(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: stores.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        columnCount: 2,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () {
                                // Add navigation to store details
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                      ),
                                      child: Image.asset(
                                        stores[index]["image"],
                                        height: 100,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      stores[index]["name"],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[900],
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      onPressed: () {},
                                      child: const Text("Explore", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue[900],
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shop"),
            BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
