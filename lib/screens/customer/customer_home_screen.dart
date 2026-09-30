import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';
import 'customer_orders_screen.dart';

import '../../screens/customer/wishlist_screen.dart';

import 'notifications_screen.dart';

import 'profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState
    extends State<CustomerHomeScreen> {
  int selectedIndex = 0;

  final ProductService productService =
      ProductService();

  final TextEditingController searchController =
      TextEditingController();

  String selectedCategory = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // ============================================================
  // FILTER PRODUCTS
  // ============================================================

  List<ProductModel> filterProducts(
    List<ProductModel> products,
  ) {
    final searchText =
        searchController.text
            .trim()
            .toLowerCase();

    return products.where((product) {
      // --------------------------------
      // SEARCH FILTER
      // --------------------------------

      final matchesSearch =
          searchText.isEmpty ||
          product.name
              .toLowerCase()
              .contains(searchText) ||
          product.description
              .toLowerCase()
              .contains(searchText) ||
          product.category
              .toLowerCase()
              .contains(searchText);

      // --------------------------------
      // CATEGORY FILTER
      // --------------------------------

      final matchesCategory =
          selectedCategory == 'All' ||
          product.category
                  .toLowerCase() ==
              selectedCategory
                  .toLowerCase();

      return matchesSearch &&
          matchesCategory;
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery Companion',
        ),

        actions: [
          IconButton(
            onPressed: logout,

            icon: const Icon(
              Icons.logout,
            ),
          ),

          IconButton(
    icon: const Icon(Icons.favorite),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const WishlistScreen(),
        ),
      );
    },
  ),
             IconButton(
    icon: const Icon(
      Icons.notifications,
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const NotificationsScreen(),
        ),
      );
    },
  ),
      IconButton(
  icon: const Icon(Icons.person),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ProfileScreen(),
      ),
    );
  },
),

        ],

        
      ),

      body: _buildBody(),

      bottomNavigationBar:
          BottomNavigationBar(
        currentIndex:
            selectedIndex,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        selectedItemColor:
            Colors.deepPurple,

        unselectedItemColor:
            Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
            ),
            label: 'Search',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_cart,
            ),
            label: 'Cart',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long,
            ),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (selectedIndex == 1) {
      return _buildSearchPage();
    }

    if (selectedIndex == 2) {
      return CartScreen();
    }

    if (selectedIndex == 3) {
      return CustomerOrdersScreen();
    }

    return _buildHome();
  }

  // ============================================================
  // HOME
  // ============================================================

  Widget _buildHome() {
    return StreamBuilder<List<ProductModel>>(
      stream: productService.getProducts(),

      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        }

        final products =
            snapshot.data ?? [];

        final filteredProducts =
            filterProducts(products);

        return SingleChildScrollView(
          padding:
              const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // --------------------------------
              // GREETING
              // --------------------------------

              const Text(
                'Hello 👋',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'What would you like to order?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // --------------------------------
              // SEARCH
              // --------------------------------

              _buildSearchField(),

              const SizedBox(height: 25),

              // --------------------------------
              // CATEGORIES
              // --------------------------------

              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              _buildCategories(),

              const SizedBox(height: 25),

              // --------------------------------
              // SPECIAL OFFER
              // --------------------------------

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(20),

                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),

                  color: Colors
                      .deepPurple
                      .shade100,
                ),

                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Special Offer',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Schedule your delivery and save on delivery fees!',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --------------------------------
              // PRODUCTS TITLE
              // --------------------------------

              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  if (selectedCategory !=
                      'All')
                    Text(
                      selectedCategory,
                      style:
                          const TextStyle(
                        color:
                            Colors.deepPurple,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 15),

              // --------------------------------
              // PRODUCTS
              // --------------------------------

              if (filteredProducts
                  .isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.all(30),

                  child: Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(
                        fontSize: 17,
                      ),
                    ),
                  ),
                )
              else
                _buildProductGrid(
                  filteredProducts,
                ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SEARCH PAGE
  // ============================================================

  Widget _buildSearchPage() {
    return StreamBuilder<List<ProductModel>>(
      stream:
          productService.getProducts(),

      builder: (
        context,
        snapshot,
      ) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        }

        final products =
            snapshot.data ?? [];

        final filteredProducts =
            filterProducts(products);

        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.all(16),

              child:
                  _buildSearchField(),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: _buildCategories(),
            ),

            const SizedBox(height: 10),

            Expanded(
              child:
                  filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            'No products found.',
                            style:
                                TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding:
                              const EdgeInsets
                                  .all(
                            16,
                          ),

                          itemCount:
                              filteredProducts
                                  .length,

                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                2,

                            crossAxisSpacing:
                                12,

                            mainAxisSpacing:
                                12,

                            childAspectRatio:
                                0.72,
                          ),

                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            return ProductCard(
                              product:
                                  filteredProducts[
                                      index],
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField() {
    return TextField(
      controller:
          searchController,

      onChanged: (value) {
        setState(() {});
      },

      decoration:
          InputDecoration(
        hintText:
            'Search products...',

        prefixIcon:
            const Icon(
          Icons.search,
        ),

        suffixIcon:
            searchController
                    .text
                    .isNotEmpty
                ? IconButton(
                    onPressed: () {
                      searchController
                          .clear();

                      setState(() {});
                    },

                    icon:
                        const Icon(
                      Icons.clear,
                    ),
                  )
                : null,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    const categories = [
      'All',
      'Grocery',
      'Food',
      'Drinks',
      'Medicine',
      'Others',
    ];

    return SizedBox(
      height: 45,

      child: ListView.builder(
        scrollDirection:
            Axis.horizontal,

        itemCount:
            categories.length,

        itemBuilder:
            (context, index) {
          final category =
              categories[index];

          final isSelected =
              selectedCategory ==
                  category;

          return Padding(
            padding:
                const EdgeInsets.only(
              right: 10,
            ),

            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCategory =
                      category;
                });
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected
                        ? Colors
                            .deepPurple
                        : Colors
                            .grey
                            .shade200,

                foregroundColor:
                    isSelected
                        ? Colors.white
                        : Colors.black,
              ),

              child: Text(
                category,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // PRODUCT GRID
  // ============================================================

  Widget _buildProductGrid(
    List<ProductModel> products,
  ) {
    return GridView.builder(
      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      itemCount:
          products.length,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,

        crossAxisSpacing: 12,

        mainAxisSpacing: 12,

        childAspectRatio: 0.72,
      ),

      itemBuilder:
          (context, index) {
        return ProductCard(
          product: products[index],
        );
      },
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final double finalPrice =
        product.price -
            (
              product.price *
              product.discount /
              100
            );

    return Card(
      clipBehavior:
          Clip.antiAlias,

      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ProductDetailsScreen(
                product: product,
              ),
            ),
          );
        },

        child: Padding(
          padding:
              const EdgeInsets.all(10),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // --------------------------------
              // IMAGE
              // --------------------------------

              Expanded(
                child: Container(
                  width:
                      double.infinity,

                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),

                    color: Colors
                        .grey
                        .shade200,
                  ),

                  child: product
                          .imageUrl
                          .isEmpty
                      ? const Icon(
                          Icons.image,
                          size: 50,
                          color:
                              Colors.grey,
                        )
                      : Image.network(
                          product
                              .imageUrl,

                          fit:
                              BoxFit.cover,

                          errorBuilder:
                              (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.image,
                              size: 50,
                              color:
                                  Colors.grey,
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              // --------------------------------
              // NAME
              // --------------------------------

              Text(
                product.name,

                maxLines: 2,

                overflow:
                    TextOverflow
                        .ellipsis,

                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              // --------------------------------
              // CATEGORY
              // --------------------------------

              Text(
                product.category,

                style:
                    const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              // --------------------------------
              // PRICE
              // --------------------------------

              Text(
                finalPrice
                    .toStringAsFixed(
                  2,
                ),

                style:
                    const TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}