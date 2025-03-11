import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';

class OrganizerRatingsPage extends StatefulWidget {
  final String organizerId;

  const OrganizerRatingsPage({super.key, required this.organizerId});

  @override
  State<OrganizerRatingsPage> createState() => _OrganizerRatingsPageState();
}

class _OrganizerRatingsPageState extends State<OrganizerRatingsPage> {
  List<Map<String, dynamic>> ratings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRatings();
  }

  Future<void> fetchRatings() async {
    try {
      final response = await supabase
          .from('tbl_rating')
          .select('rating_value, rating_content, tbl_user(user_name)')
          .eq('organiser_id', widget.organizerId);

      setState(() {
        ratings = response;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching ratings: $e')),
      );
    }
  }

  Widget buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Ratings'),
        backgroundColor: const Color.fromARGB(255, 2, 0, 108),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ratings.isEmpty
              ? const Center(child: Text('No ratings available'))
              : Center(
                child: SizedBox(
                  width: 800,
                  child: ListView.builder(
                      itemCount: ratings.length,
                      itemBuilder: (context, index) {
                        final rating = ratings[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 30, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      rating['tbl_user']['user_name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                buildStarRating(rating['rating_value']),
                                const SizedBox(height: 8),
                                Text(
                                  rating['rating_content'] ?? 'No comment',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ),
              ),
    );
  }
}
