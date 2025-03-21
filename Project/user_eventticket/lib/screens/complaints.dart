import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';

class ComplaintPage extends StatefulWidget {
  final int eventId;

  const ComplaintPage({super.key, required this.eventId});

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _complaintController = TextEditingController();

  Future<void> submitReviewAndComplaint() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to submit a complaint.')),
      );
      return;
    }

    if (_titleController.text.isEmpty && _complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a complaint.')),
      );
      return;
    }

    try {
      await supabase.from('tbl_complaint').insert({
        'complaint_title': _titleController.text,
        'complaint_content': _complaintController.text,
        'user_id': userId,
        'event_id': widget.eventId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your complaint has been submitted!')),
      );

      _titleController.clear();
      _complaintController.clear();
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complaint Title',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter complaint title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Complaint Details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _complaintController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe your complaint...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: submitReviewAndComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 0, 108),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Submit Complaint',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
