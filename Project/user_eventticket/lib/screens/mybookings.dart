import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyBookings extends StatefulWidget {
  const MyBookings({super.key});

  @override
  State<MyBookings> createState() => _MyBookingsState();
}

class _MyBookingsState extends State<MyBookings> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  void showTicketDialog(BuildContext context, Map<String, dynamic> booking) {
    final event = booking['tbl_event'];
    final place = event['tbl_place'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  event['event_name'],
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "${event['event_date']} · ${event['event_time']} (${event['event_duration']})",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  place['place_name'] ?? "Unknown Venue",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  "${booking['eventbooking_ticket']} Tickets",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking['eventbooking_status'] == 1
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking['eventbooking_status'] == 1
                        ? "Confirmed"
                        : "Pending",
                    style: TextStyle(
                      color: booking['eventbooking_status'] == 1
                          ? Colors.green
                          : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // QR Code
                QrImageView(
                  data: booking['eventbooking_id']
                      .toString(), // Use booking ID as QR code data
                  version: QrVersions.auto,
                  size: 150.0,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchBookings() async {
    try {
      final userId =
          supabase.auth.currentUser!.id; // Replace with dynamic user ID
      final response = await supabase
          .from('tbl_eventbooking')
          .select('*, tbl_event(*,tbl_place(*))')
          .eq('user_id', userId)
          .order('eventbooking_date', ascending: false);
      print(response);
      setState(() {
        bookings = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching bookings: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title:
              const Text("My Bookings", style: TextStyle(color: Colors.black)),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookings.isEmpty
                ? const Center(child: Text("No Bookings Found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      final event = booking['tbl_event'];
                      final place = booking['tbl_event']['tbl_place'];
                      print(booking);
                      return GestureDetector(
                        onTap: booking['eventbooking_status'] == 1 ? () {
                          showTicketDialog(context, booking);
                        } : null,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Event Image
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: NetworkImage(event['event_photo']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Event Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['event_name'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${event['event_date']} · ${event['event_time']} (${event['event_duration']})",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            place['place_name'] ??
                                                "Unknown Venue",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Ticket Info & Status
                                    Row(
                                      children: [
                                        Text(
                                          "${booking['eventbooking_ticket']} Tickets",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: booking[
                                                        'eventbooking_status'] ==
                                                    1
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            booking['eventbooking_status'] == 1
                                                ? "Confirmed"
                                                : "Pending",
                                            style: TextStyle(
                                              color:
                                                  booking['eventbooking_status'] ==
                                                          1
                                                      ? Colors.green
                                                      : Colors.red,
                                              fontSize: 10,
                                            ),
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
                      );
                    },
                  ),
      );
  }
}
