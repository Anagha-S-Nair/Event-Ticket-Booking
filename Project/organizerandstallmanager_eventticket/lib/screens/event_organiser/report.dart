import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({super.key});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _salesDataFuture;
  DateTime _startDate = DateTime(2025, 1, 1);
  DateTime _endDate = DateTime(2025, 6, 30);
  String? _errorMessage;
  bool _isDataFetched = false;

  Future<List<Map<String, dynamic>>> fetchSalesData() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'User not authenticated. Please log in.';
        });
        return [];
      }

      final response = await supabase
          .from('tbl_eventbooking')
          .select(
              'id, eventbooking_amount, eventbooking_date, eventbooking_ticket, '
              'tbl_event(id, event_name, organiser_id, eventtype_id, '
              'tbl_eventtype(id, eventtype_name))')
          .eq('eventbooking_status', 1)
          .eq('tbl_event.organiser_id', user.id)
          .gte('eventbooking_date', _startDate.toIso8601String())
          .lte('eventbooking_date', _endDate.toIso8601String())
          .order('eventbooking_date', ascending: false);

      if (response is! List) {
        setState(() {
          _errorMessage = 'Unexpected response from server.';
        });
        return [];
      }

      final salesData = response.map((booking) {
        double totalAmount =
            double.tryParse(booking['eventbooking_amount'].toString()) ?? 0.0;
        DateTime? bookingDate =
            DateTime.tryParse(booking['eventbooking_date'].toString());

        return {
          'booking_id': booking['id'].toString(),
          'date': bookingDate ?? _startDate,
          'total_amount': totalAmount,
          'event_name':
              booking['tbl_event']['event_name']?.toString() ?? 'Unknown Event',
          'ticket_count': booking['eventbooking_ticket'] ?? 0,
          'type': booking['tbl_event']['tbl_eventtype']['eventtype_name']
                  ?.toString() ??
              'Unknown Type',
        };
      }).toList();

      setState(() {
        _errorMessage = null;
      });
      return salesData;
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching sales data: $e';
      });
      return [];
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2025, 12, 31),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _fetchData() {
    setState(() {
      _isDataFetched = true;
      _salesDataFuture = fetchSalesData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sales Report",
              style: GoogleFonts.sanchez(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Start Date",
                      style: GoogleFonts.sanchez(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () => _selectStartDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd-MM-yyyy').format(_startDate),
                              style: GoogleFonts.sanchez(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "End Date",
                      style: GoogleFonts.sanchez(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () => _selectEndDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('dd-MM-yyyy').format(_endDate),
                              style: GoogleFonts.sanchez(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text("View Results"),
            ),
            const SizedBox(height: 20),
            if (_isDataFetched) ...[
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.sanchez(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _salesDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        _errorMessage ?? "No sales data available for this period",
                        style: GoogleFonts.sanchez(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  }

                  final salesData = snapshot.data!;
                  final totalSales = salesData.fold<double>(
                      0.0, (sum, sale) => sum + sale['total_amount']);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total Sales: \₹ ${totalSales.toStringAsFixed(2)}",
                        style: GoogleFonts.sanchez(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - 16,
                          ),
                          child: DataTable(
                            columnSpacing: 20,
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.grey.shade100),
                            border: TableBorder(
                              horizontalInside:
                                  BorderSide(color: Colors.grey.shade300),
                              verticalInside:
                                  BorderSide(color: Colors.grey.shade300),
                              top: BorderSide(color: Colors.grey.shade300),
                              bottom: BorderSide(color: Colors.grey.shade300),
                              left: BorderSide(color: Colors.grey.shade300),
                              right: BorderSide(color: Colors.grey.shade300),
                            ),
                            columns: [
                              DataColumn(
                                label: Text(
                                  "SlNo",
                                  style: GoogleFonts.sanchez(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Event name",
                                  style: GoogleFonts.sanchez(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Ticket Count",
                                  style: GoogleFonts.sanchez(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Event Type",
                                  style: GoogleFonts.sanchez(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Amount",
                                  style: GoogleFonts.sanchez(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  "Date",
                                  style: GoogleFonts.sanchez(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              
                            ],
                            rows: salesData.asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final sale = entry.value;
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    index.toString(),
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    sale['event_name'],
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    sale['ticket_count'].toString(),
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    sale['type'],
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                
                                DataCell(
                                  Text(
                                    "\₹ ${sale['total_amount'].toStringAsFixed(2)}",
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    DateFormat('dd-MM-yyyy')
                                        .format(sale['date']),
                                    style: GoogleFonts.sanchez(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
