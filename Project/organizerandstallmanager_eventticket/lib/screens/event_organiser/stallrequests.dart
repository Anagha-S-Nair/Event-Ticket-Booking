import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';

class StallRequets extends StatefulWidget {
  const StallRequets({super.key});

  @override
  State<StallRequets> createState() => _StallRequetsState();
}

class _StallRequetsState extends State<StallRequets> {
  List<Map<String, dynamic>> eventList = [];

  Future<void> acceptrequest(int rid) async {
    try {
      await supabase
          .from('tbl_stallrequest')
          .update({'request_status': 1}).eq('id', rid);
      fetchrequest();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request accepted.")),
      );
    } catch (e) {
      print("Error updating : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to accept.")),
      );
    }
  }

  Future<void> rejectrequest(int rid) async {
    try {
      await supabase
          .from('tbl_stallrequest')
          .update({'request_status': 2}).eq('id', rid);
      fetchrequest();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request rejected.")),
      );
    } catch (e) {
      print("Error updating : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to reject.")),
      );
    }
  }

  Future<void> fetchrequest() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from("tbl_stallrequest")
          .select(
              "*, tbl_event(*), tbl_stallmanager(*),tbl_stalltype(*)")
          .eq("tbl_event.organiser_id", uid);

      print(response);
      setState(() {
        eventList = (response);
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchrequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Stall Manager Requests',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey[300],
        centerTitle: true,
        foregroundColor: Colors.black87,
      ),
      body: eventList.isEmpty
          ? const Center(
              child: Text(
                'No pending requests',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: eventList.length,
                        itemBuilder: (context, index) {
                          var stall = eventList[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Manager Photo
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          stall['tbl_stallmanager']
                                              ['stallmanager_photo'],
                                        ),
                                        fit: BoxFit.cover,
                                        onError: (_, __) => const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stall['tbl_stallmanager']
                                                ['stallmanager_name'] ??
                                            'Unknown Manager',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.store,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            stall['tbl_stalltype']
                                                    ['stalltype_name'] ??
                                                'N/A',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.description,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              stall['request_message'] ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Action Buttons/Status
                                SizedBox(
                                  width: 120,
                                  child: stall['request_status'] == 0
                                      ? Column(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                acceptrequest(stall['id']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue[600],
                                                foregroundColor: Colors.white,
                                                minimumSize:
                                                    const Size(double.infinity, 36),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Approve',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            OutlinedButton(
                                              onPressed: () {
                                                rejectrequest(stall['id']);
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red[600],
                                                side: BorderSide(
                                                    color: Colors.red[600]!),
                                                minimumSize:
                                                    const Size(double.infinity, 36),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                'Reject',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: stall['request_status'] == 1
                                                ? Colors.green[50]
                                                : Colors.red[50],
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            stall['request_status'] == 1
                                                ? 'Approved'
                                                : 'Rejected',
                                            style: TextStyle(
                                              color: stall['request_status'] == 1
                                                  ? Colors.green[700]
                                                  : Colors.red[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}