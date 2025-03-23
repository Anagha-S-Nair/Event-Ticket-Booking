import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<int> _userCountFuture;
  late Future<int> _organizerCountFuture;
  late Future<int> _stallManagerCountFuture;
  late Future<int> _ticketsSoldFuture;
  late Future<List<FlSpot>> _ticketSalesChartDataFuture;

  @override
  void initState() {
    super.initState();
    _userCountFuture = fetchUserCount();
    _organizerCountFuture = fetchOrganizerCount();
    _stallManagerCountFuture = fetchStallManagerCount();
    _ticketsSoldFuture = fetchTicketsSold();
    _ticketSalesChartDataFuture = fetchTicketSalesChartData();
  }

  Future<int> fetchUserCount() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select('id')
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      print('Error fetching user count: $e');
      return 0;
    }
  }

  Future<int> fetchOrganizerCount() async {
    try {
      final response = await supabase
          .from('tbl_eventorganisers')
          .select('id')
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      print('Error fetching organizer count: $e');
      return 0;
    }
  }

  Future<int> fetchStallManagerCount() async {
    try {
      final response = await supabase
          .from('tbl_stallmanager')
          .select('id')
          .count(CountOption.exact);
      return response.count;
    } catch (e) {
      print('Error fetching stall manager count: $e');
      return 0;
    }
  }

  Future<int> fetchTicketsSold() async {
    try {
      final response = await supabase
          .from('tbl_eventbooking')
          .select('eventbooking_ticket')
          .eq('eventbooking_status', 1);

      int totalTickets = 0;
      for (var booking in response) {
        totalTickets += (booking['eventbooking_ticket'] as num?)?.toInt() ?? 0;
      }
      print('Total tickets sold: $totalTickets');
      return totalTickets;
    } catch (e) {
      print('Error fetching tickets sold: $e');
      return 0;
    }
  }

  Future<List<FlSpot>> fetchTicketSalesChartData() async {
    try {
      final response = await supabase
          .from('tbl_eventbooking')
          .select('eventbooking_date, eventbooking_ticket')
          .eq('eventbooking_status', 1)
          .gte('eventbooking_date', '2024-10-01T00:00:00+00')
          .lte('eventbooking_date', '2025-03-31T23:59:59+00');

      print('Raw response from tbl_eventbooking: $response');

      final monthlyTickets = List<double>.filled(6, 0.0);
      for (var booking in response) {
        final bookingDateString = booking['eventbooking_date'] as String;
        print('Processing booking: $booking');
        print('Booking date string: $bookingDateString');

        final bookingDate = DateTime.parse(bookingDateString);
        print('Parsed booking date: $bookingDate');

        // Adjust monthIndex to map Oct 2024 (month 10) to index 0, Mar 2025 (month 3) to index 5
        final year = bookingDate.year;
        final month = bookingDate.month;
        int monthIndex;

        if (year == 2024) {
          monthIndex = month - 10; // Oct 2024 = 0, Nov 2024 = 1, Dec 2024 = 2
        } else if (year == 2025) {
          monthIndex = month + 2; // Jan 2025 = 3, Feb 2025 = 4, Mar 2025 = 5
        } else {
          continue; // Skip dates outside our range
        }

        print('Calculated monthIndex: $monthIndex');

        if (monthIndex < 0 || monthIndex > 5) continue;

        final tickets = (booking['eventbooking_ticket'] as num?)?.toDouble() ?? 0.0;
        print('Tickets for this booking: $tickets');
        monthlyTickets[monthIndex] += tickets;
      }

      print('Monthly tickets array: $monthlyTickets');

      // Normalize to a 0-5 scale for the chart
      final maxTickets = monthlyTickets.reduce((a, b) => a > b ? a : b);
      print('Max tickets: $maxTickets');
      final normalizedTickets = maxTickets > 0
          ? monthlyTickets.map((tickets) => (tickets / maxTickets) * 5).toList()
          : monthlyTickets;

      print('Normalized tickets: $normalizedTickets');

      final spots = List.generate(
          6, (index) => FlSpot(index.toDouble(), normalizedTickets[index]));
      print('FlSpots for chart: $spots');

      return spots;
    } catch (e) {
      print('Error fetching ticket sales chart data: $e');
      return List.generate(6, (index) => FlSpot(index.toDouble(), 0.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Admin Dashboard",
            style: GoogleFonts.sanchez(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<int>(
                  future: _userCountFuture,
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Total Users",
                      value: snapshot.data?.toString() ?? '0',
                      icon: Icons.person,
                      color: Colors.blue,
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FutureBuilder<int>(
                  future: _organizerCountFuture,
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Event Organizers",
                      value: snapshot.data?.toString() ?? '0',
                      icon: Icons.event,
                      color: Colors.purple,
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FutureBuilder<int>(
                  future: _stallManagerCountFuture,
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Stall Managers",
                      value: snapshot.data?.toString() ?? '0',
                      icon: Icons.storefront,
                      color: Colors.orange,
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FutureBuilder<int>(
                  future: _ticketsSoldFuture,
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      title: "Tickets Sold",
                      value: snapshot.data?.toString() ?? '0',
                      icon: Icons.confirmation_number,
                      color: Colors.green,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ticket Sales Overview",
                  style: GoogleFonts.sanchez(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<FlSpot>>(
                    future: _ticketSalesChartDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error loading chart"));
                      }
                      final spots = snapshot.data ??
                          List.generate(6, (index) => FlSpot(index.toDouble(), 0.0));

                      return LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1, // Ensure one label per month
                                getTitlesWidget: (value, meta) {
                                  const titles = [
                                    'Oct',
                                    'Nov',
                                    'Dec',
                                    'Jan',
                                    'Feb',
                                    'Mar'
                                  ];
                                  final index = value.toInt();
                                  if (index < 0 || index >= titles.length) {
                                    return const Text('');
                                  }
                                  return Text(
                                    titles[index],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                          minX: 0,
                          maxX: 5,
                          minY: 0,
                          maxY: 5,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.sanchez(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.sanchez(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}