import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:intl/intl.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Map<String, dynamic>> bookingList = [];
  bool isLoading = true;

  Future<void> fetchbooking() async {
    try {
      setState(() {
        isLoading = true;
      });

      String uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from("tbl_eventbooking")
          .select("*, tbl_event(*), tbl_user(*)")
          .eq("tbl_event.organiser_id", uid)
          .eq("eventbooking_status", 1);

      // Convert response to List and sort by eventbooking_date in descending order
      List<Map<String, dynamic>> sortedList =
          List<Map<String, dynamic>>.from(response);
      sortedList.sort((a, b) {
        DateTime? dateA = a['eventbooking_date'] != null
            ? DateTime.tryParse(a['eventbooking_date'])
            : null;
        DateTime? dateB = b['eventbooking_date'] != null
            ? DateTime.tryParse(b['eventbooking_date'])
            : null;

        // Handle null dates (put them at the end)
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;

        return dateB.compareTo(dateA); // Descending order (latest first)
      });

      setState(() {
        bookingList = sortedList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchbooking();
  }

  // Helper method to format date
  String formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dateTime = DateTime.parse(date);
      return DateFormat('dd-MM-yy').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          'User Booking',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.2,
            color: Color(0xFF1A1F36),
          ),
        ),
        centerTitle: false,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
            onPressed: fetchbooking,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: Color(0xFF3B82F6),
                  strokeWidth: 3,
                ),
              ),
            )
          : bookingList.isEmpty
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_busy_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Active Bookings',
                          style: TextStyle(
                            fontSize: 22,
                            color: Color(0xFF1A1F36),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Current bookings will be displayed here',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchbooking,
                  color: const Color(0xFF3B82F6),
                  child: ListView.builder(
                    itemCount: bookingList.length,
                    padding: const EdgeInsets.all(24),
                    itemBuilder: (context, index) {
                      final booking = bookingList[index];
                      String image = booking['tbl_user']['user_photo'] ?? "";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // View booking details
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // User image
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: image != ''
                                        ? Image.network(
                                            image,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              color: Colors.grey[100],
                                              child: Icon(
                                                Icons.person_outline,
                                                size: 28,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[100],
                                            child: Icon(
                                              Icons.person_outline,
                                              size: 28,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Booking details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        booking['tbl_user']['user_name'] ??
                                            'Unknown User',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1F36),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.event_outlined,
                                            size: 18,
                                            color: Color(0xFF6B7280),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              booking['tbl_event']
                                                      ['event_name'] ??
                                                  'N/A',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF6B7280),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 18,
                                            color: Color(0xFF6B7280),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Date: ${formatDate(booking['eventbooking_date'])}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF6B7280),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.confirmation_number_outlined,
                                            size: 18,
                                            color: Color(0xFF6B7280),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Tickets: ${booking['eventbooking_ticket'] ?? 'N/A'}",
                                            style: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF6B7280),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
