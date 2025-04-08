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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "User Complaints",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 2,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.blue[800],
              ),
            )
          : _complaints.isEmpty
              ? Center(
                  child: Text(
                    "No complaints found",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchComplaints,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = _complaints[index];
                      return _buildComplaintCard(complaint);
                    },
                  ),
                ),
    );
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    String statusText;
    Color statusColor;

    switch (complaint['complaint_status'].toString()) {
      case '0':
        statusText = 'New';
        statusColor = Colors.red[700]!;
        break;
      case '1':
        statusText = 'Resolved';
        statusColor = Colors.green[700]!;
        break;
      default:
        statusText = 'Unknown';
        statusColor = Colors.grey[700]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(complaint['tbl_user']['user_photo']),
              radius: 24,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint['complaint_title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "By: ${complaint['tbl_user']['user_name']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Icon(Icons.event, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Event: ${complaint['tbl_event']['event_name']}",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                complaint['complaint_date'].toString().split('T')[0],
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        children: [
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 16),
          Text(
            "Details:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            complaint['complaint_content'] ?? 'No Content Available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                "Contact: ${complaint['tbl_user']['user_contact']}",
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: complaint['complaint_status'] == 0
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              complaint['complaint_status'] == 0
                  ? ElevatedButton.icon(
                      onPressed: () {
                        replyBox(context, complaint['id']);
                      },
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text("Reply"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        complaint['complaint_reply'] ?? 'No Reply',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  void replyBox(BuildContext context, id) {
    TextEditingController replyController = TextEditingController();
    final _replyForm = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Reply to Complaint',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          content: Form(
            key: _replyForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your reply below:',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: replyController,
                  decoration: InputDecoration(
                    hintText: 'Type your response here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  maxLines: 4,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter a reply' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_replyForm.currentState!.validate()) {
                  _updateComplaintStatus(id, replyController.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Submit Reply'),
            ),
          ],
        );
      },
    );
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