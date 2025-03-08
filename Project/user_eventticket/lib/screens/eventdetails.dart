import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:user_eventticket/main.dart';
import 'package:user_eventticket/screens/payment.dart';

class EventDetails extends StatefulWidget {
  final Map<String, dynamic> data;

  const EventDetails({super.key, required this.data});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  String btn = "Book Event";
  int? remTocket;
  Future<void> insertFavorite() async {
    try {
      await supabase.from('tbl_favorite').insert({
        'event_id': widget.data['id'],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event added to favorites!'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to favorites: $e'),
        ),
      );
    }
  }

  Future<void> checkTicket() async {
    try {
      int availableTickets = widget.data['event_count'] ?? 0;
      final ticketSum = await supabase
          .from('tbl_eventbooking')
          .select('eventbooking_ticket')
          .eq('event_id', widget.data['id'])
          .eq('eventbooking_status', 1);

      final totalTickets = ticketSum.fold<int>(
          0, (sum, row) => sum + (row['eventbooking_ticket'] as int));

      setState(() {
        remTocket = availableTickets - totalTickets; // Safe subtraction
      });

      if (totalTickets >= availableTickets) {
        setState(() {
          btn = "Sold Out";
        });
      }

      print('Total tickets booked: $totalTickets');
    } catch (e) {
      print("Error checking tickets: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    checkTicket();
  }

  void _showTicketBookingDialog() {
    int ticketCount = 0;
    double ticketPrice =
        double.parse(widget.data['event_ticketprice'].toString());
    double totalAmount = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Book Tickets'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How many tickets would you like?'),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: ticketCount > 0
                            ? () {
                                setStateDialog(() {
                                  ticketCount--;
                                  totalAmount = ticketCount * ticketPrice;
                                });
                              }
                            : null,
                      ),
                      Text(
                        '$ticketCount',
                        style: TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: ticketCount < remTocket!
                            ? () {
                                setStateDialog(() {
                                  ticketCount++;
                                  totalAmount = ticketCount * ticketPrice;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Total Amount: ₹ ${totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: ticketCount > 0
                      ? () async {
                          try {
                            // Here you would typically add the booking to your database
                            final data = await supabase
                                .from('tbl_eventbooking')
                                .insert({
                                  'event_id': widget.data['id'],
                                  'eventbooking_ticket': ticketCount,
                                  'eventbooking_amount': totalAmount,
                                })
                                .select('id')
                                .single();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Tickets booked successfully!')),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentPage(
                                  id: data['id'],
                                ),
                              ),
                            );
                            checkTicket(); // Update button state
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error booking tickets: $e')),
                            );
                          }
                        }
                      : null,
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = "Invalid Date";
    try {
      DateTime eventDate = DateTime.parse(widget.data['event_date']);
      formattedDate = DateFormat('EEEE, MMMM d, y').format(eventDate);
    } catch (e) {
      print("Error parsing date: $e");
    }

    String formattedTime = "Invalid Time";
    try {
      DateTime eventTime =
          DateTime.parse("1970-01-01 ${widget.data['event_time']}");
      formattedTime = DateFormat('HH:mm:ss').format(eventTime);
    } catch (e) {
      print("Error parsing time: $e");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.black),
            onPressed: insertFavorite,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(widget.data['event_photo']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                widget.data['event_name'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.calendar_today, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Text(formattedDate),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.access_time, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Text("Time: $formattedTime"),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "${widget.data['tbl_place']['place_name']}, ${widget.data['tbl_place']['tbl_district']['district_name']}",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.attach_money, color: Colors.blue),
                  ),
                  SizedBox(width: 16),
                  Text("\₹ ${widget.data['event_ticketprice'].toString()}"),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "About Event",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                widget.data['event_details'],
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: btn == "Sold Out"
                ? null
                : () {
                    _showTicketBookingDialog();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: btn == "Sold Out" ? Colors.grey : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
            ),
            child: Text(
              btn,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
