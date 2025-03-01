import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';
import 'package:user_eventticket/screens/eventdetails.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> eventList = [];

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

  Future<void> fetchevent() async {
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase.from("tbl_event").select();
      print(response);
      setState(() {
        eventList = response;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  List<Map<String, dynamic>> eventTypeList = [];
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
    // TODO: implement initState
    super.initState();
    fetchevent();
    fetchUser();
    fetchType();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(image),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hellooo ",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(name,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar with Filter Icon
            TextField(
              decoration: InputDecoration(
                hintText: "Search events",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: Implement filter functionality
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),

            // Featured Events
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("New Events",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                    onPressed: () {},
                    child: const Text(
                      "VIEW ALL",
                      style: TextStyle(
                          color: Color.fromARGB(255, 231, 128, 60),
                          fontSize: 15),
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
                            image: NetworkImage(data['event_photo']),
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

            // Category Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Popular Events ",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                    onPressed: () {},
                    child: const Text(
                      "VIEW ALL",
                      style: TextStyle(
                          color: Color.fromARGB(255, 231, 128, 60),
                          fontSize: 15),
                    )),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: eventTypeList.map((eventType) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Chip(
                      label: Text(eventType['eventtype_name'] ?? 'Unknown'),
                      backgroundColor: Color.fromARGB(255, 231, 128, 60),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Popular Events Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: eventList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final data = eventList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetails(data: data),));
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
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color.fromARGB(255, 231, 128, 60),
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
