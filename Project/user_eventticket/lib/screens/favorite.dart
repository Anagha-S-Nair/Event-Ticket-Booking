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
      await supabase
          .from('tbl_favorite')
          .delete()
          .eq('id', id); // Corrected line

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
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      shrinkWrap: true,
      itemCount: favorites.length, // Placeholder for now
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
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        event['event_photo'] ?? "",
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        event['event_name'] ?? "Event Name",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  child: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      deleteFavorite(id);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
