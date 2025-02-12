import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class ShopScreen extends StatefulWidget {
  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _selectedIndex = 1;

  final List<String> shops = [
    "Supermarket", "Water Dispensers", "Top Crust", "Pharmacy", "Electronics", "Fashion Store"
  ];

  final List<String> categories = [
    "Groceries", "Drinks", "Clothing", "Pharmacy", "Electronics", "Beauty"
  ];

  String searchQuery = "";
  List<String> filteredShops = [];
  bool _isSearchFocused = false;
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    filteredShops = List.from(shops);

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() => _isSearchFocused = false);
      }
    });
  }

  void _filterShops(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredShops = List.from(shops);
      } else {
        filteredShops = shops
            .where((shop) => shop.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _goToHomeScreen() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
          title: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isSearchFocused = true),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      focusNode: _searchFocusNode,
                      onChanged: _filterShops,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Search shop or item...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
                },
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _goToHomeScreen,
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Text(
                            categories[index][0],
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(categories[index], style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: AnimationLimiter(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredShops.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      columnCount: 2,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.white,
                            child: Text(
                              filteredShops[index][0],
                              style: GoogleFonts.lato(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
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
    );
  }
}
