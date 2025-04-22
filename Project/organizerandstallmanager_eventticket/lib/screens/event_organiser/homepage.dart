import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/booking.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/createevent.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/myevents.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/myprofile.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/report.dart';


class OrganiserHomePage extends StatelessWidget {
  const OrganiserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/l12.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.darken,
            ),
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "QUICKTICK",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      _buildNavButton(
                        context,
                        "Account",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrganiserProfile()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildNavButton(
                        context,
                        "Event",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EventsPage()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildNavButton(
                        context,
                        "Booking",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookingPage()),
                        ),
                      ),
                      // const SizedBox(width: 10),
                      // _buildNavButton(
                      //   context,
                      //   "Rating",
                      //   () {
                      //     // Navigator.push(context, MaterialPageRoute(builder: (context) => OrganizerRatingsPage(
                      //     //             organizerId: widget.data['organiser_id']
                      //     // ),));
                      //   },
                      // ),
                      const SizedBox(width: 10),
                      _buildNavButton(
                        context,
                        "Report",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SalesReportPage()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 200),
            Center(
              child: Column(
                children: [
                  Text(
                    "Organize with Confidence, Sell with Ease.",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Plan smarter, sell quicker, succeed easier",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Createevent()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      "CREATE EVENT",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, String title, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white70,
        ),
      ),
    );
  }
}