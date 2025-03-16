import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';

class ComplaintsPage extends StatefulWidget {
  final int id;
  const ComplaintsPage({super.key, required this.id});

  @override
  State<ComplaintsPage> createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  List<Map<String, dynamic>> _complaints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final response = await supabase
          .from('tbl_complaint')
          .select("*,tbl_event(*),tbl_user(*)")
          .eq('event_id', widget.id);

      setState(() {
        _complaints = response;
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching complaints: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 250),
      appBar: AppBar(
        title: const Text("Customer Complaints"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? const Center(child: Text("No complaints found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = _complaints[index];
                    return _buildComplaintCard(complaint);
                  },
                ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    String statusText;
    Color statusColor;

    switch (complaint['complaint_status'].toString()) {
      case '0':
        statusText = 'New';
        statusColor = Colors.red;
        break;
      case '1':
        statusText = 'Resolved';
        statusColor = Colors.green;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        childrenPadding: const EdgeInsets.all(20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(complaint['tbl_user']['user_photo']),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint['complaint_title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "By: ${complaint['tbl_user']['user_name']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              const Icon(Icons.event, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                "Event: ${complaint['tbl_event']['event_name']}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                complaint['complaint_date'].toString().split('T')[0],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        children: [
          const Divider(),
          const Text(
            "Details:",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            complaint['complaint_content'] ?? 'No Content Available',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            "Contact: ${complaint['tbl_user']['user_contact']}",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: complaint['complaint_status'] == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              
              complaint['complaint_status'] == 0 ?  ElevatedButton.icon(
                  onPressed: (){
                    replyBox(context, complaint['id']);
                  },
                  icon: const Icon(Icons.check_circle, size: 16),
                  label: const Text("Reply"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 8),
                  ),
                ) : Text(complaint['complaint_reply'] ?? 'No Reply' , style: const TextStyle(fontSize: 14, color: Colors.grey),),
            ],
          ),
        ],
      ),
    );
  }

  void replyBox(BuildContext context, id){
    TextEditingController replyController = TextEditingController();
    final _replyForm = GlobalKey<FormState>();
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Reply to Complaint'),
        content: Form(
          key: _replyForm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your reply below:'),
              const SizedBox(height: 10),
              TextFormField(
                controller: replyController,
                decoration: const InputDecoration(
                  hintText: 'Reply',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add your reply logic here
              if(_replyForm.currentState!.validate()){
                _updateComplaintStatus(id, replyController.text);
                
              }
            },
            child: const Text('Reply'),
          ),
        ],
      );
    },);
  }

  void _updateComplaintStatus(int id, String reply) async {
    try {
      await supabase
          .from('tbl_complaint')
          .update({'complaint_status': 1, 'complaint_reply': reply})
          .eq('id', id);

      
      fetchComplaints();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint status updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }
}
