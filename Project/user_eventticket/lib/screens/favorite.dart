import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: 10, // Example count
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.favorite, color: Colors.red),
              title: Text('Favorite Item ${index + 1}'),
              subtitle: Text('Description of item ${index + 1}'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Add navigation or actions if needed
              },
            ),
          );
        },
      ),
    );
  }
}