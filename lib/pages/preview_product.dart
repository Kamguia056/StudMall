import 'package:flutter/material.dart';
import 'dart:io';

class PreviewProductPage extends StatefulWidget {
  final String title;
  final String price;
  final String category;
  final String description;
  final List<File> images;

  const PreviewProductPage({
    super.key,
    required this.title,
    required this.price,
    required this.category,
    required this.description,
    required this.images,
  });

  @override
  State<PreviewProductPage> createState() => _PreviewProductPageState();
}

class _PreviewProductPageState extends State<PreviewProductPage> {
  int currentImage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aperçu du produit"), centerTitle: true),

      body: Column(
        children: [
          // Image principale
          Expanded(
            flex: 5,
            child: PageView.builder(
              onPageChanged: (i) => setState(() => currentImage = i),
              itemCount: widget.images.length,
              itemBuilder: (_, i) => Image.file(
                widget.images[i],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),

          // Miniatures
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.images.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => setState(() => currentImage = i),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: i == currentImage
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      widget.images[i],
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Infos produit
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "${widget.price} F",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Catégorie : ${widget.category}",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),

          // Button Commander
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () {},
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
          ),
        ],
      ),
    );
  }
}
