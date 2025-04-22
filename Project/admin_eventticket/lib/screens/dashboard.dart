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
      final now = DateTime.now();
      final year = now.year;
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31, 23, 59, 59);

      final response = await supabase
          .from('tbl_eventbooking')
          .select('eventbooking_date, eventbooking_ticket')
          .gte('eventbooking_date', startDate.toIso8601String())
          .lte('eventbooking_date', endDate.toIso8601String());

      final monthlyTickets = List<double>.filled(12, 0.0);
      for (var booking in response) {
        final bookingDateString = booking['eventbooking_date'] as String;
        final bookingDate = DateTime.parse(bookingDateString);
        if (bookingDate.year == year) {
          final monthIndex = bookingDate.month - 1; // Jan=0, Dec=11
          final tickets = (booking['eventbooking_ticket'] as num?)?.toDouble() ?? 0.0;
          monthlyTickets[monthIndex] += tickets;
        }
      }

      // Normalize for chart display (optional, or use raw values)
      final maxTickets = monthlyTickets.reduce((a, b) => a > b ? a : b);
      final normalizedTickets = maxTickets > 0
          ? monthlyTickets.map((tickets) => (tickets / maxTickets) * 5).toList()
          : monthlyTickets;

      return List.generate(
        12,
        (index) => FlSpot(index.toDouble(), normalizedTickets[index]),
      );
    } catch (e) {
      print('Error fetching ticket sales chart data: $e');
      return List.generate(12, (index) => FlSpot(index.toDouble(), 0.0));
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
                          List.generate(12, (index) => FlSpot(index.toDouble(), 0.0));

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
                                    'Jan',
                                    'Feb',
                                    'Mar',
                                    'Apr',
                                    'May',
                                    'Jun',
                                    'Jul',
                                    'Aug',
                                    'Sep',
                                    'Oct',
                                    'Nov',
                                    'Dec'
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
                          maxX: 11,
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