import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/product_service.dart';

class AdminProductsScreen extends StatelessWidget {
  AdminProductsScreen({super.key});

  final ProductService productService =
      ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Products',
        ),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ProductFormScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
        ),
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream: productService.getAllProducts(),

        builder: (context, snapshot) {
          // --------------------------------
          // LOADING
          // --------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // --------------------------------
          // ERROR
          // --------------------------------

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final products =
              snapshot.data ?? [];

          // --------------------------------
          // NO PRODUCTS
          // --------------------------------

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products found.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          // --------------------------------
          // PRODUCT LIST
          // --------------------------------

          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: products.length,

            itemBuilder: (context, index) {
              final product =
                  products[index];

              return AdminProductCard(
                product: product,
                productService:
                    productService,
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// ADMIN PRODUCT CARD
// ============================================================

class AdminProductCard extends StatelessWidget {
  final ProductModel product;
  final ProductService productService;

  const AdminProductCard({
    super.key,
    required this.product,
    required this.productService,
  });

  @override
  Widget build(BuildContext context) {
    final double finalPrice =
        product.price -
            (product.price *
                product.discount /
                100);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // --------------------------------
            // IMAGE
            // --------------------------------

            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color:
                    Colors.grey.shade200,

                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: product.imageUrl.isEmpty
                  ? const Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    )
                  : Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,

                      errorBuilder:
                          (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        );
                      },
                    ),
            ),

            const SizedBox(width: 12),

            // --------------------------------
            // PRODUCT INFORMATION
            // --------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    product.category,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Price: '
                    '${finalPrice.toStringAsFixed(2)}',
                  ),

                  const SizedBox(height: 5),

                  Text(
                    product.available
                        ? 'Available'
                        : 'Unavailable',

                    style: TextStyle(
                      color: product.available
                          ? Colors.green
                          : Colors.red,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // --------------------------------
                  // BUTTONS
                  // --------------------------------

                  Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProductFormScreen(
                                  product:
                                      product,
                                ),
                              ),
                            );
                          },

                          child: const Text(
                            'Edit',
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Expanded(
                        child:
                            OutlinedButton(
                          onPressed: () {
                            showDeleteDialog(
                              context,
                              product,
                            );
                          },

                          child: const Text(
                            'Delete',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DELETE CONFIRMATION
  // ==========================================================

  void showDeleteDialog(
    BuildContext context,
    ProductModel product,
  ) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Product',
          ),

          content: Text(
            'Are you sure you want to delete '
            '"${product.name}"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cancel',
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                await productService
                    .deleteProduct(
                  product.id,
                );

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(context);

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Product deleted',
                    ),
                  ),
                );
              },

              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// PRODUCT FORM SCREEN
// ============================================================

class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductFormScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState
    extends State<ProductFormScreen> {
  final ProductService productService =
      ProductService();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController discountController =
      TextEditingController();

  final TextEditingController categoryController =
      TextEditingController();

  final TextEditingController imageUrlController =
      TextEditingController();

  final TextEditingController storeIdController =
      TextEditingController();

  bool available = true;

  bool isSaving = false;

  bool get isEditing =>
      widget.product != null;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      final product = widget.product!;

      nameController.text =
          product.name;

      descriptionController.text =
          product.description;

      priceController.text =
          product.price.toString();

      discountController.text =
          product.discount.toString();

      categoryController.text =
          product.category;

      imageUrlController.text =
          product.imageUrl;

      storeIdController.text =
          product.storeId;

      available =
          product.available;
    }
  }

  // ==========================================================
  // SAVE PRODUCT
  // ==========================================================

  Future<void> saveProduct() async {
    // --------------------------------
    // VALIDATION
    // --------------------------------

    if (nameController.text.trim().isEmpty) {
      showMessage(
        'Please enter product name',
      );
      return;
    }

    if (descriptionController.text
        .trim()
        .isEmpty) {
      showMessage(
        'Please enter description',
      );
      return;
    }

    final double? price =
        double.tryParse(
      priceController.text.trim(),
    );

    if (price == null || price < 0) {
      showMessage(
        'Please enter a valid price',
      );
      return;
    }

    final double? discount =
        double.tryParse(
      discountController.text.trim(),
    );

    if (discount == null ||
        discount < 0 ||
        discount > 100) {
      showMessage(
        'Discount must be between 0 and 100',
      );
      return;
    }

    if (categoryController.text
        .trim()
        .isEmpty) {
      showMessage(
        'Please enter category',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final ProductModel product =
          ProductModel(
        id: widget.product?.id ?? '',

        name:
            nameController.text.trim(),

        description:
            descriptionController.text
                .trim(),

        price: price,

        discount: discount,

        category:
            categoryController.text
                .trim(),

        imageUrl:
            imageUrlController.text
                .trim(),

        storeId:
            storeIdController.text
                .trim(),

        available: available,
      );

      if (isEditing) {
        await productService
            .updateProduct(product);
      } else {
        await productService
            .addProduct(product);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Product updated'
                : 'Product added',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Error: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountController.dispose();
    categoryController.dispose();
    imageUrlController.dispose();
    storeIdController.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Product'
              : 'Add Product',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // NAME
            TextField(
              controller: nameController,

              decoration:
                  const InputDecoration(
                labelText: 'Product Name',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // DESCRIPTION
            TextField(
              controller:
                  descriptionController,

              maxLines: 3,

              decoration:
                  const InputDecoration(
                labelText: 'Description',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // PRICE
            TextField(
              controller: priceController,

              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),

              decoration:
                  const InputDecoration(
                labelText: 'Price',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // DISCOUNT
            TextField(
              controller:
                  discountController,

              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),

              decoration:
                  const InputDecoration(
                labelText: 'Discount (%)',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // CATEGORY
            TextField(
              controller:
                  categoryController,

              decoration:
                  const InputDecoration(
                labelText: 'Category',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // IMAGE URL
            TextField(
              controller:
                  imageUrlController,

              decoration:
                  const InputDecoration(
                labelText: 'Image URL',
                hintText:
                    'https://example.com/image.jpg',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // STORE ID
            TextField(
              controller:
                  storeIdController,

              decoration:
                  const InputDecoration(
                labelText: 'Store ID',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // AVAILABLE
            SwitchListTile(
              title: const Text(
                'Available',
              ),

              value: available,

              onChanged: (value) {
                setState(() {
                  available = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // SAVE
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed:
                    isSaving
                        ? null
                        : saveProduct,

                child: Padding(
                  padding:
                      const EdgeInsets.all(14),

                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing
                              ? 'Update Product'
                              : 'Add Product',

                          style:
                              const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}