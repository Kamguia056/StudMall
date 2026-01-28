import 'package:flutter/material.dart';
import 'package:studmall2/models/product.dart';
import 'package:studmall2/services/chat_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  // Since imageUrl is a String, we don't need a currentImage index for a PageView of multiple images unless we split a CSV string or similar.
  // Assuming single image URL for now based on model definition.

  void _commander() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Commander"),
        content: Text("Voulez-vous commander ${widget.product.name} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              try {
                final chatService = ChatService();
                await chatService.sendMessage(
                  receiverId: widget.product.sellerId,
                  receiverName: widget.product.sellerName,
                  receiverAvatar: widget.product.sellerAvatar,
                  message:
                      "Bonjour, je souhaite commander votre produit : ${widget.product.name}. Veuillez me contacter pour finaliser la transaction.",
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // 🔝 IMAGE + BACK + FAVORIS
          Stack(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),

              // Bouton retour
              Positioned(
                top: 40,
                left: 16,
                child: _circleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
              ),

              // Favoris
              Positioned(
                top: 40,
                right: 16,
                child: _circleButton(
                  icon: Icons.favorite_border,
                  color: Colors.red,
                  onTap: () {
                    // TODO: Implement toggle favorite
                  },
                ),
              ),
            ],
          ),

          // 📋 INFOS PRODUIT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${widget.product.price} Fcfa",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Catégorie
                  Row(
                    children: [
                      const Icon(Icons.category, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        widget.product.category,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  // Seller Info if available
                  if (widget.product.sellerName.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: NetworkImage(
                            widget.product.sellerAvatar,
                          ),
                          onBackgroundImageError: (_, __) {},
                          child: widget.product.sellerAvatar.isEmpty
                              ? const Icon(Icons.person, size: 14)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Vendeur: ${widget.product.sellerName}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.product.description,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🟪 BOUTON COMMANDER
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _commander,
                      child: const Text(
                        "Commander",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bouton circulaire
  Widget _circleButton({
    required IconData icon,
    Color color = Colors.black,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
