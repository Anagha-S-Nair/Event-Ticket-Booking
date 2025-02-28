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
      allowMultiple: false, // Only single file upload
    );
    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
      });
    }
  }

  Future<String?> photoUpload(String uid) async {
    try {
      final bucketName = 'organisers'; // Replace with your bucket name
      final filePath = "$uid-event-${pickedImage!.name}";
      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            pickedImage!.bytes!, // Use file.bytes for Flutter Web
          );
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(filePath);
      // await updateImage(uid, publicUrl);
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
        selectedPlace = null; // Reset the selected place when district changes
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
        // Reset the selected place when district changes
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
    // fetchplace();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
              minHeight: 500,
              maxHeight: 1000,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 700,
                    height: 200,
                    decoration: BoxDecoration(color: Color(0xFF1E1E2E)),
                    child: pickedImage == null
                        ? GestureDetector(
                            onTap: handleImagePick,
                            child: Icon(
                              Icons.image_outlined,
                              color: Color(0xFF0277BD),
                              size: 50,
                            ),
                          )
                        : GestureDetector(
                            onTap: handleImagePick,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: pickedImage!.bytes != null
                                  ? Image.memory(
                                      Uint8List.fromList(
                                          pickedImage!.bytes!), // For web
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(pickedImage!
                                          .path!), // For mobile/desktop
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Event Name',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            fillColor: const Color(0xFF2E2E3E),
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E2E3E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade600),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              items: eventtypeList.map((eventtype) {
                                return DropdownMenuItem(
                                  value: eventtype["id"].toString(),
                                  child: Text(eventtype["eventtype_name"]),
                                );
                              }).toList(),
                              value: selectedEventtype,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedEventtype = newValue;
                                  // fetchplace(newValue!);  // Fetch places when district changes
                                });
                              },
                              dropdownColor: const Color(0xFF2E2E3E),
                              style: const TextStyle(color: Colors.white),
                              hint: const Text(' Type',
                                  style: TextStyle(color: Colors.white70)),
                              // items: const [],
                              // onChanged: (value) {},
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintStyle: const TextStyle(color: Colors.white70),
                            labelStyle: const TextStyle(color: Colors.white),
                            suffixIcon: const Icon(Icons.calendar_today,
                                color: Colors.white70),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2E2E3E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _timeController,
                          readOnly: true,
                          onTap: () => _selectTime(context),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Time',
                            hintStyle: const TextStyle(color: Colors.white70),
                            labelStyle: const TextStyle(color: Colors.white),
                            suffixIcon: const Icon(Icons.access_time,
                                color: Colors.white70),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2E2E3E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedDuration,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDuration = newValue;
                            });
                          },
                          items: [
                            '30 min',
                            '1 hour',
                            '2 hours',
                            '3 hours',
                            'Half-day',
                            'Full-day'
                          ]
                              .map((duration) => DropdownMenuItem<String>(
                                    value: duration,
                                    child: Text(duration,
                                        style: TextStyle(color: Colors.white)),
                                  ))
                              .toList(),
                          decoration: InputDecoration(
                            labelText: 'Duration',
                            labelStyle: const TextStyle(color: Colors.white),
                            suffixIcon:
                                const Icon(Icons.timer, color: Colors.white70),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2E2E3E),
                          ),
                          dropdownColor: const Color(0xFF2E2E3E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          items: districtList.map((district) {
                            return DropdownMenuItem(
                              value: district["id"].toString(),
                              child: Text(district["district_name"]),
                            );
                          }).toList(),
                          value: selectedDistrict,
                          onChanged: (newValue) {
                            setState(() {
                              selectedDistrict = newValue;
                              // Fetch places when district changes
                            });
                            fetchplace(newValue!);
                          },
                          decoration: InputDecoration(
                            // labelText: 'District',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: const Color(0xFF2E2E3E),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          dropdownColor: const Color(0xFF2E2E3E),
                          style: const TextStyle(color: Colors.white),
                          hint: const Text(' District',
                              style: TextStyle(color: Colors.white70)),
                          // items: const [],
                          // onChanged: (value) {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          items: placeList.map((place) {
                            return DropdownMenuItem(
                              value: place["id"].toString(),
                              child: Text(place["place_name"]),
                            );
                          }).toList(),
                          value: selectedPlace,
                          onChanged: (newValue) {
                            setState(() {
                              selectedPlace = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            // labelText: 'Place',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: const Color(0xFF2E2E3E),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          dropdownColor: const Color(0xFF2E2E3E),
                          style: const TextStyle(color: Colors.white),
                          hint: const Text(' Place',
                              style: TextStyle(color: Colors.white70)),
                          // items: const [],
                          // onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _detailsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Details',
                      labelStyle: const TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade600),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF2E2E3E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: _countController,
                          decoration: InputDecoration(
                            labelText: 'Count',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2E2E3E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          controller: _ticketpriceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            labelStyle: const TextStyle(color: Colors.white),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey.shade600),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF2E2E3E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          insertEvent();
                        },
                        child: const Text(
                          'CREATE EVENT',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
