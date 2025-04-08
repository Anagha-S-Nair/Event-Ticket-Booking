import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/main.dart';
import 'package:file_picker/file_picker.dart';

class Createevent extends StatefulWidget {
  const Createevent({super.key});

  @override
  State<Createevent> createState() => _CreateeventState();
}

class _CreateeventState extends State<Createevent> {
  List<Map<String, dynamic>> createeventList = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _ticketpriceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? _selectedDuration;
  String? selectedDistrict;
  String? selectedEventtype;
  String? selectedPlace;

  final formkey = GlobalKey<FormState>();

  List<Map<String, dynamic>> districtList = [];
  List<Map<String, dynamic>> eventtypeList = [];
  List<Map<String, dynamic>> placeList = [];

  PlatformFile? pickedImage;

  Future<void> handleImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<String?> photoUpload(String uid) async {
    try {
      final bucketName = 'organisers';
      final filePath = "$uid-event-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!,
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print("Error photo upload: $e");
      return null;
    }
  }

  Future<void> fetchdistrict() async {
    try {
      final response = await supabase.from("tbl_district").select();
      setState(() {
        districtList = response;
      });
    } catch (e) {
      print("Error fetching districts: $e");
    }
  }

  Future<void> fetchplace(String id) async {
    try {
      final response =
          await supabase.from("tbl_place").select().eq("district_id", id);
      setState(() {
        placeList = response;
        selectedPlace = null;
      });
    } catch (e) {
      print("Error fetching places: $e");
    }
  }

  Future<void> fetcheventtype() async {
    try {
      final response = await supabase.from("tbl_eventtype").select();
      setState(() {
        eventtypeList = response;
      });
    } catch (e) {
      print("Error fetching eventtype: $e");
    }
  }

  Future<void> insertEvent() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      String? photoUrl = await photoUpload(uid);
      String name = _nameController.text;
      String details = _detailsController.text;
      String date = _dateController.text;
      String count = _countController.text;
      String duration = _selectedDuration!;
      String ticketprice = _ticketpriceController.text;
      String time = _timeController.text;

      await supabase.from('tbl_event').insert({
        'organiser_id': uid,
        'event_name': name,
        'eventtype_id': selectedEventtype,
        'place_id': selectedPlace,
        'event_details': details,
        'event_date': date,
        'event_count': count,
        'event_duration': duration,
        'event_ticketprice': ticketprice,
        'event_photo': photoUrl,
        'event_time': time
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Successfully Inserted",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      _nameController.clear();
      _detailsController.clear();
      _dateController.clear();
      _countController.clear();
      _ticketpriceController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          "Failed. Please Try Again!!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      print("ERROR ADDING EVENT: $e");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdistrict();
    fetcheventtype();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromARGB(255, 19, 37, 82);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        
        elevation: 0,
        title: Text(
          'Create New Event',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload Section
                      Container(
                        width: double.infinity,
                        height: 220,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: pickedImage == null
                            ? GestureDetector(
                                onTap: handleImagePick,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      color: primaryColor,
                                      size: 48,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Upload Event Image',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Supports JPG, PNG (Max 5MB)',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: handleImagePick,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: pickedImage!.bytes != null
                                      ? Image.memory(
                                          Uint8List.fromList(pickedImage!.bytes!),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Image.file(
                                          File(pickedImage!.path!),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                ),
                              ),
                      ),
                      SizedBox(height: 32),

                      // Event Name and Type
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _nameController,
                              label: 'Event Name',
                              primaryColor: primaryColor,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 1,
                            child: _buildDropdown(
                              value: selectedEventtype,
                              items: eventtypeList.map((eventtype) {
                                return DropdownMenuItem(
                                  value: eventtype["id"].toString(),
                                  child: Text(eventtype["eventtype_name"]),
                                );
                              }).toList(),
                              hint: 'Event Type',
                              onChanged: (newValue) {
                                setState(() {
                                  selectedEventtype = newValue;
                                });
                              },
                              primaryColor: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28),

                      // Date, Time, Duration
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _dateController,
                              label: 'Date',
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              suffixIcon: Icons.calendar_today,
                              primaryColor: primaryColor,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _buildTextField(
                              controller: _timeController,
                              label: 'Time',
                              readOnly: true,
                              onTap: () => _selectTime(context),
                              suffixIcon: Icons.access_time,
                              primaryColor: primaryColor,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _buildDropdown(
                              value: _selectedDuration,
                              items: [
                                '30 min',
                                '1 hour',
                                '2 hours',
                                '3 hours',
                                'Half-day',
                                'Full-day'
                              ].map((duration) => DropdownMenuItem<String>(
                                    value: duration,
                                    child: Text(duration),
                                  )).toList(),
                              hint: 'Duration',
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedDuration = newValue;
                                });
                              },
                              primaryColor: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28),

                      // District and Place
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              value: selectedDistrict,
                              items: districtList.map((district) {
                                return DropdownMenuItem(
                                  value: district["id"].toString(),
                                  child: Text(district["district_name"]),
                                );
                              }).toList(),
                              hint: 'District',
                              onChanged: (newValue) {
                                setState(() {
                                  selectedDistrict = newValue;
                                });
                                fetchplace(newValue!);
                              },
                              primaryColor: primaryColor,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _buildDropdown(
                              value: selectedPlace,
                              items: placeList.map((place) {
                                return DropdownMenuItem(
                                  value: place["id"].toString(),
                                  child: Text(place["place_name"]),
                                );
                              }).toList(),
                              hint: 'Place',
                              onChanged: (newValue) {
                                setState(() {
                                  selectedPlace = newValue;
                                });
                              },
                              primaryColor: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 28),

                      // Details
                      _buildTextField(
                        controller: _detailsController,
                        label: 'Event Details',
                        maxLines: 4,
                        primaryColor: primaryColor,
                      ),
                      SizedBox(height: 28),

                      // Count and Price
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _countController,
                              label: 'Ticket Count',
                              primaryColor: primaryColor,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: _buildTextField(
                              controller: _ticketpriceController,
                              label: 'Ticket Price (₹)',
                              primaryColor: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),

                      // Submit Button
                      Center(
                        child: SizedBox(
                          width: 320,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: insertEvent,
                            child: Text(
                              'Create Event',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    required Color primaryColor,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: primaryColor, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    required Color primaryColor,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: TextStyle(color: Colors.black87, fontSize: 16),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      dropdownColor: Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: primaryColor),
    );
  }
}