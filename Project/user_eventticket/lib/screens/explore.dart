import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';
import 'package:user_eventticket/screens/eventdetails.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Map<String, dynamic>> eventList = [];
  List<Map<String, dynamic>> filteredEvents = [];
  List<Map<String, dynamic>> eventTypeList = [];

  String selectedCategory = '';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;

  Future<void> fetchevent() async {
    try {
      final response = await supabase
          .from("tbl_event")
          .select("*, tbl_eventtype(*),tbl_place(*, tbl_district(*))");
      print(response);
      setState(() {
        eventList = List<Map<String, dynamic>>.from(response);
        filteredEvents = eventList;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchType() async {
    try {
      final response = await supabase.from('tbl_eventtype').select();
      setState(() {
        eventTypeList = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchevent();
    fetchType();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
      _showSuggestions = searchQuery.isNotEmpty;
      filterEvents();
    });
  }

  void filterEvents() {
    setState(() {
      filteredEvents = eventList.where((event) {
        print(event);
        final matchesSearch = event['event_name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        final matchesCategory = selectedCategory.isEmpty ||
            event['eventtype_id'].toString() == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  List<String> getSuggestions() {
    return eventList
        .where((event) => event['event_name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .map((event) => event['event_name'].toString())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: "Search events",
                  prefixIcon: const Icon(Icons.search),
                  // suffixIcon: IconButton(
                  //   icon: const Icon(Icons.filter_list),
                  //   onPressed: () {},
                  // ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              if (_showSuggestions)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: getSuggestions().length,
                        itemBuilder: (context, index) {
                          final suggestion = getSuggestions()[index];
                          return ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              _searchController.text = suggestion;
                              _showSuggestions = false;
                              _searchFocusNode.unfocus();
                              filterEvents();
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
          

          
          const SizedBox(height: 10),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text("Popular Events",
          //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          //     TextButton(
          //         onPressed: () {},
          //         child: const Text(
          //           "VIEW ALL",
          //           style: TextStyle(
          //               color: Color.fromARGB(255, 231, 128, 60), fontSize: 15),
          //         )),
          //   ],
          // ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ActionChip(
                    label: const Text('All'),
                    backgroundColor: selectedCategory.isEmpty
                        ? Color.fromARGB(255, 2, 0, 108)
                        : Colors.grey[300],
                    labelStyle: TextStyle(
                      color: selectedCategory.isEmpty
                          ? Colors.white
                          : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedCategory = '';
                        filterEvents();
                      });
                    },
                  ),
                ),
                ...eventTypeList.map((eventType) {
                  final isSelected =
                      selectedCategory == eventType['id'].toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ActionChip(
                      label: Text(eventType['eventtype_name'] ?? 'Unknown'),
                      backgroundColor: isSelected
                          ? Color.fromARGB(255, 2, 0, 108)
                          : Colors.grey[300],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedCategory = eventType['id'].toString();
                          filterEvents();
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEvents.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final data = filteredEvents[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetails(data: data),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(data['event_photo']),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      data['event_name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}