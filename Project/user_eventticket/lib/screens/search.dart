import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Events'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar with Filter Icon
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list,color: Colors.blue,), // Filter Icon
                  onPressed: () {
                    // Add filter action here
                  },
                ),
                hintText: "Search",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[200],
                filled: true,
              ),
            ),
            const SizedBox(height: 10),

            // Filter Chips
            Row(
              children: [
                FilterChip(label: const Text("All"), onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text("Music"), onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text("Art"), onSelected: (_) {}),
                const SizedBox(width: 8),
                FilterChip(label: const Text("Workshop"), onSelected: (_) {}),
              ],
            ),
            const SizedBox(height: 10),

            // Outer Box
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Small Box for Image
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage("assets/concert1.jpg"), // Add your image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Event Details (Placeholder)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Event Title",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Date & Time",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: const [
                              Icon(Icons.location_on, size: 14, color: Colors.blue),
                              SizedBox(width: 4, height: 10),
                              Text("Event Location"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favorite Icon
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 10, bottom: 30), // Adjust padding for positioning
                      child: Icon(Icons.favorite_border),
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
}
