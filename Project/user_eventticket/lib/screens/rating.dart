import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';
import 'package:user_eventticket/screens/complaints.dart';

class RatingPage extends StatefulWidget {
  final String organizerId; // Pass organizer ID when navigating to this page
  final int eventId;

  const RatingPage(
      {super.key, required this.organizerId, required this.eventId});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  Future<void> submitReview() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a review.')),
      );
      return;
    }

    if (_rating == 0 || _reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please provide both a rating and a review.')),
      );
      return;
    }

    try {
      await supabase.from('tbl_rating').insert({
        'rating_value': _rating,
        'rating_content': _reviewController.text,
        'user_id': userId,
        'organiser_id': widget.organizerId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
      _reviewController.clear();
      setState(() => _rating = 0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget buildStar(int index) {
    return IconButton(
      icon: Icon(
        Icons.star,
        color: index < _rating ? Colors.amber : Colors.grey,
      ),
      onPressed: () => setState(() => _rating = index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Rate & Review',),backgroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rate the Organizer:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: List.generate(5, (index) => buildStar(index)),
            ),
            const SizedBox(height: 20),
            const Text('Write a Review:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _reviewController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color.fromARGB(255, 2, 0, 108), // Dark blue color
                foregroundColor: Colors.white, // Text color
                minimumSize:
                    const Size(double.infinity, 50), // Full-width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
              ),
              child: const Text(
                'Submit Review',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16, // Matching text size
                ),
              ),
            ),

            SizedBox(height: 20), // Add some space between the button and the text
            Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text("Have any Complaints? "),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplaintPage(
              eventId: widget.eventId,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color.fromARGB(255, 2, 0, 108)),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          "Report Here",
          style: TextStyle(
            color: Color.fromARGB(255, 2, 0, 108),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  ],
)

          ],
        ),
      ),
    );
  }
}
