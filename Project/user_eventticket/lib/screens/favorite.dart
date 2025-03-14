import 'package:flutter/material.dart';
import 'package:user_eventticket/main.dart';
import 'package:user_eventticket/screens/eventdetails.dart';

class Favorties extends StatefulWidget {
  const Favorties({super.key});

  @override
  State<Favorties> createState() => _FavortiesState();
}

class _FavortiesState extends State<Favorties> {
  List<Map<String, dynamic>> favorites = [];

  Future<void> fetchFavorite() async {
    print("Fetching favorite events");
    try {
      String uid = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('tbl_favorite')
          .select(
              " *, tbl_event(*,tbl_eventtype(*),tbl_place(*, tbl_district(*)))")
          .eq('user_id', uid);
      print(response);
      setState(() {
        favorites = response;
      });
    } catch (e) {
      print("Error fetching favorite events: $e");
    }
  }

  Future<void> deleteFavorite(int id) async {
    try {
      await supabase.from('tbl_favorite').delete().eq('id', id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event deleted from favorites!'),
        ),
      );

      fetchFavorite();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting favorites: $e'),
        ),
      );
    }
  }

  @override
  void initState() {
    fetchFavorite();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.90, // Adjust this value
        ),
        shrinkWrap: true,
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final event = favorites[index]['tbl_event'];
          int id = favorites[index]['id'];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EventDetails(data: event)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(event['event_photo'] ?? ""),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
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
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        deleteFavorite(id);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Text(
                      event['event_name'] ?? "Event Name",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
