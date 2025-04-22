import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'package:universal_io/io.dart';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _reportDataFuture;
  DateTime _startDate = DateTime(2025, 1, 1);
  DateTime _endDate = DateTime(2025, 6, 30);
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _reportDataFuture = fetchReportData();
  }

  Future<List<Map<String, dynamic>>> fetchReportData() async {
    try {
      final response = await supabase
          .from('tbl_eventbooking')
          .select(
            'id, eventbooking_date, eventbooking_amount, eventbooking_ticket, '
            'tbl_event(id, event_name, event_date, event_ticketprice, eventtype_id, id, '
            'tbl_eventtype(id, eventtype_name), '
            'tbl_eventorganisers(id, organisers_name))'
          )
          .gte('eventbooking_date', _startDate.toIso8601String())
          .lte('eventbooking_date', _endDate.toIso8601String())
          .order('eventbooking_date', ascending: false);

      final data = response.map((booking) {
        return {
          'booking_id': booking['id'].toString(),
          'event_name': booking['tbl_event']['event_name']?.toString() ?? 'Unknown Event',
          'event_date': DateTime.parse(booking['tbl_event']['event_date'].toString()),
          'booking_date': DateTime.parse(booking['eventbooking_date'].toString()),
          'ticket_price': double.tryParse(booking['tbl_event']['event_ticketprice'].toString()) ?? 0.0,
          'ticket_count': booking['eventbooking_ticket'] ?? 0,
          'amount': double.tryParse(booking['eventbooking_amount'].toString()) ?? 0.0,
          'type': booking['tbl_event']['tbl_eventtype']['eventtype_name']?.toString() ?? 'Unknown Type',
          'organisers_name': booking['tbl_event']['tbl_eventorganisers']['organisers_name']?.toString() ?? 'Unknown Organizer',
        };
      }).toList();

      if (data.isEmpty) {
        setState(() {
          _errorMessage = 'No data found for the selected date range.';
        });
      } else {
        setState(() {
          _errorMessage = null;
        });
      }

      return data;
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching report data: $e';
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
        _reportDataFuture = fetchReportData();
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
        _reportDataFuture = fetchReportData();
      });
    }
  }

  Future<void> generatePDF(List<Map<String, dynamic>> reportData) async {
    final pdf = pw.Document();

    final totalAmount = reportData.fold<double>(0.0, (sum, item) => sum + item['amount']);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Event and Booking Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Date Range: ${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Total Amount: Rs. ${totalAmount.toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 16, color: PdfColors.green, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: pw.EdgeInsets.all(8),
              headers: [
                'Sl. No.',
                'Type',
                'Event Name',
                'Event Date',
                'Booking Date',
                'Ticket Price',
                'Ticket Count',
                'Amount',
                'Organiser',
              ],
              data: reportData.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final item = entry.value;
                return [
                  index.toString(),
                  item['type'],
                  item['event_name'],
                  DateFormat('MMM dd, yyyy').format(item['event_date']),
                  DateFormat('MMM dd, yyyy').format(item['booking_date']),
                  'Rs. ${item['ticket_price'].toStringAsFixed(2)}',
                  item['ticket_count'].toString(),
                  'Rs. ${item['amount'].toStringAsFixed(2)}',
                  item['organisers_name'],
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'Event_Booking_Report.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
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
              "Event and Booking Report",
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_startDate),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM dd, yyyy').format(_endDate),
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
              future: _reportDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      _errorMessage ?? "No report data available for this period",
                      style: GoogleFonts.sanchez(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }

                final reportData = snapshot.data!;
                final totalAmount = reportData.fold<double>(0.0, (sum, item) => sum + item['amount']);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Amount: Rs. ${totalAmount.toStringAsFixed(2)}",
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
                            horizontalInside: BorderSide(color: Colors.grey.shade300),
                            verticalInside: BorderSide(color: Colors.grey.shade300),
                            top: BorderSide(color: Colors.grey.shade300),
                            bottom: BorderSide(color: Colors.grey.shade300),
                            left: BorderSide(color: Colors.grey.shade300),
                            right: BorderSide(color: Colors.grey.shade300),
                          ),
                          columns: [
                            DataColumn(label: Text('Sl. No.', style: GoogleFonts.sanchez(fontWeight: FontWeight.bold, color: Colors.black87))),
                            DataColumn(label: Text('Type', style: GoogleFonts.sanchez(fontWeight: FontWeight.bold, color: Colors.black87))),
                            DataColumn(label: Text('Event Name', style: GoogleFonts.sanchez(fontWeight: FontWeight.bold, color: Colors.black87))),
                            DataColumn(label: Text('Event Date', style: GoogleFonts.sanchez(fontWeight: FontWeight.bold, color: Colors.black87))),
                            DataColumn(label: Text('Booking Date', style: GoogleFonts.sanchez(fontWeight: FontWeight.bold, color: Colors.black87))),
                            DataColumn(label: Text('Ticket Price', style: GoogleFonts.sanchez(fontWeight: FontWeight.bold, color: Colors.black87))),
                            DataColumn(label: Text('Ticket Count', style: GoogleFonts.sanchez(fontWeight: FontWeight.bold, color: Colors.black87))),
                            DataColumn(label: Text('Amount', style: GoogleFonts.sanchez(fontWeight: FontWeight.bold, color: Colors.black87))),
                            DataColumn(label: Text('Organizer', style: GoogleFonts.sanchez(fontWeight: FontWeight.bold, color: Colors.black87))),
                          ],
                          rows: reportData.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final item = entry.value;
                            return DataRow(cells: [
                              DataCell(Text(index.toString(), style: GoogleFonts.sanchez(fontSize: 14, color: Colors.black87))),
                              DataCell(Text(item['type'], style: GoogleFonts.sanchez(fontSize: 14, color: Colors.black87))),
                              DataCell(Text(item['event_name'], style: GoogleFonts.sanchez(fontSize: 14, color: Colors.black87))),
                              DataCell(Text(DateFormat('MMM dd, yyyy').format(item['event_date']), style: GoogleFonts.sanchez(fontSize: 14, color: Colors.black87))),
                              DataCell(Text(DateFormat('MMM dd, yyyy').format(item['booking_date']), style: GoogleFonts.sanchez(fontSize: 14, color: Colors.black87))),
                              DataCell(Text('Rs. ${item['ticket_price'].toStringAsFixed(2)}', style: GoogleFonts.sanchez(fontSize: 14, color: Colors.black87))),
                              DataCell(Text(item['ticket_count'].toString(), style: GoogleFonts.sanchez(fontSize: 14, color: Colors.black87))),
                              DataCell(Text('Rs. ${item['amount'].toStringAsFixed(2)}', style: GoogleFonts.sanchez(fontSize: 14, color: Colors.black87))),
                              DataCell(Text(item['organisers_name'], style: GoogleFonts.sanchez(fontSize: 14, color: Colors.black87))),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await generatePDF(reportData);
                      },
                      child: Text('Download PDF', style: GoogleFonts.sanchez(fontSize: 16)),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}