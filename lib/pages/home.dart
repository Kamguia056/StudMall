import 'package:flutter/material.dart';

import '../services/product_service.dart';
import '../models/product.dart';
import '../services/chat_service.dart';
import 'package:studmall2/pages/product_detail.dart'; // Added import

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController searchController;
  bool showSearchHistory = false;
  final ProductService _productService = ProductService();
  Stream<List<Product>>? _productsStream;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _productsStream = _productService.getProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAE6E6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ★★★★★ HEADER ★★★★★
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF4A00E0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage("assets/images/logo.png"),
                        ),
                      ),
                      const Text(
                        "StudMall",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 100),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showSearchHistory = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: searchController,
                              onTap: () {
                                setState(() {
                                  showSearchHistory = true;
                                });
                              },
                              decoration: const InputDecoration(
                                icon: Icon(Icons.search),
                                hintText: "Rechercher...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ★★★★★ MEILLEURES OFFRES ★★★★★
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ★★★★★ CATEGORIES ★★★★★
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Catégories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Tout",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _categoryCircle(
                        Icons.fastfood,
                        Colors.orange,
                        "Nourriture",
                      ),
                      _categoryCircle(
                        Icons.phone_android,
                        Colors.blue,
                        "Digital",
                      ),
                      _categoryCircle(
                        Icons.fitness_center,
                        Colors.green,
                        "Sports",
                      ),
                      _categoryCircle(Icons.chair, Colors.red, "Mobilier"),
                      _categoryCircle(Icons.book, Colors.purple, "Livres"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ★★★★★ TOUS LES PRODUITS ★★★★★
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Tous les produits",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Tout",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ✅ Grille dynamique des produits
                  StreamBuilder<List<Product>>(
                    stream: _productsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }
                      final products = snapshot.data ?? [];
                      if (products.isEmpty) {
                        return const Center(
                          child: Text('Aucun produit disponible.'),
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 0.7,
                            ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _productCard(context, product);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ███ Widgets réutilisables ███

Widget _categoryCircle(IconData icon, Color bgColor, String label) {
  return Column(
    children: [
      CircleAvatar(
        radius: 30,
        backgroundColor: bgColor,
        child: Icon(icon, size: 30, color: Colors.white),
      ),
      const SizedBox(height: 5),
      Text(label),
    ],
  );
}

Widget _productCard(BuildContext context, Product product) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "${product.price} Fcfa",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Commander"),
                          content: Text(
                            "Voulez-vous commander ${product.name} ?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Logique de commande ici
                                try {
                                  final chatService = ChatService();
                                  await chatService.sendMessage(
                                    receiverId: product.sellerId,
                                    receiverName: product.sellerName,
                                    receiverAvatar: product.sellerAvatar,
                                    message:
                                        "Bonjour, je souhaite commander votre produit : ${product.name}. Veuillez me contacter pour finaliser la transaction.",
                                  );
                                  Navigator.pop(context); // Close dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Commande envoyée ! Le vendeur a reçu votre message.",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.pop(context); // Close dialog
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Erreur lors de la commande : ${e.toString()}",
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: const Text("Confirmer"),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 72, 4, 219),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Commander",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
