import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';
import 'package:user_eventticket/screens/changepassword.dart';
import 'package:user_eventticket/screens/complaints.dart';
import 'package:user_eventticket/screens/editprofile.dart';
import 'package:user_eventticket/screens/eventdetails.dart';
import 'package:user_eventticket/screens/explore.dart';
import 'package:user_eventticket/screens/favorite.dart';
import 'package:user_eventticket/screens/login.dart';
import 'package:user_eventticket/screens/mybookings.dart';
import 'package:user_eventticket/screens/mycomplaints.dart';
import 'package:user_eventticket/screens/myprofile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> pages = [
    HomeContent(),
    ExploreScreen(),
    Favorties(),
    MyBookings(),
    MyProfile(),
  ];

  int selectedIndex = 0;

  String name = '';
  String image = '';

  Future<void> fetchUser() async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('id', supabase.auth.currentUser!.id)
          .single();
      print(response);
      setState(() {
        name = response['user_name'];
        image = response['user_photo'];
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUser();
  }

  Future<void> confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await supabase.auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false, // Clears all previous routes
      ); // Redirect to login page
    }
  }

  String title = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: selectedIndex != 1
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: selectedIndex == 0
                  ? Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(image),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hellooo ",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                            Text(name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ],
                    )
                  : Text(title),
              actions: [
                selectedIndex == 4
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            color: Colors.black),
                        onSelected: (String result) {
                          switch (result) {
                            case 'edit_profile':
                              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfile(),));
                              break;
                            case 'change_password':
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePassword(),));
                              break;
                            case 'my_complaint':
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MyComplaintsPage(),));
                              break;
                            case 'log_out':
                              confirmLogout(context);
                              // Add your logout logic here (e.g., clear auth token, navigate to login screen)
                              break;
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'edit_profile',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20, color: Colors.black),
                                SizedBox(width: 10),
                                Text('Edit Profile'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'change_password',
                            child: Row(
                              children: [
                                Icon(Icons.lock, size: 20, color: Colors.black),
                                SizedBox(width: 10),
                                Text('Change Password'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'my_complaint',
                            child: Row(
                              children: [
                                Icon(Icons.report,
                                    size: 20, color: Colors.black),
                                SizedBox(width: 10),
                                Text('My Complaint'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'log_out',
                            child: Row(
                              children: [
                                Icon(Icons.logout,
                                    size: 20,
                                    color: Colors.black), // Logout icon
                                SizedBox(width: 10),
                                Text('Log Out'),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            )
          : null,
      body: SafeArea(child: pages[selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: (index) {
          print(index);
          setState(() {
            selectedIndex = index;
            if (index == 2) {
              title = "Favorites";
            } else if (index == 3) {
              title = "My Bookings";
            } else if (index == 4) {
              title = "My Profile";
            }
          });
        },
        selectedItemColor: Color.fromARGB(255, 2, 0, 108),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "Explore"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Favorites"),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number), label: "Tickets"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
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
          .select("*, tbl_eventtype(*),tbl_place(*, tbl_district(*))")
          .eq('event_status', '0');
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
              // TextField(
              //   controller: _searchController,
              //   focusNode: _searchFocusNode,
              //   decoration: InputDecoration(
              //     hintText: "Search events",
              //     prefixIcon: const Icon(Icons.search),
              //     suffixIcon: IconButton(
              //       icon: const Icon(Icons.filter_list),
              //       onPressed: () {},
              //     ),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //       borderSide: BorderSide.none,
              //     ),
              //     filled: true,
              //     fillColor: Colors.grey[200],
              //   ),
              // ),
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
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("New Events",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () {},
                  child: const Text(
                    "VIEW ALL",
                    style: TextStyle(
                        color: Color.fromARGB(255, 2, 0, 108), fontSize: 15),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: eventList.length,
              itemBuilder: (context, index) {
                final data = eventList[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                        image: DecorationImage(
                          image: NetworkImage(data['event_photo'] ?? ""),
                          fit: BoxFit.cover,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        data['event_name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Popular Events",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () {},
                  child: const Text(
                    "VIEW ALL",
                    style: TextStyle(
                        color: Color.fromARGB(255, 2, 0, 108), fontSize: 15),
                  )),
            ],
          ),
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
