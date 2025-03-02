import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/createevent.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/myevents.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/myprofile.dart';

class OrganiserHomePage extends StatelessWidget {
  const OrganiserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/l12.jpg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    "EVENT",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrganiserProfile(),
                              ));
                        },
                        child: Text(
                          "Account",
                          style: TextStyle(
                            decorationColor: Colors.white,
                            fontSize: 18,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventsPage(),
                              ));
                        },
                        child: Text(
                          "Event",
                          style: TextStyle(
                            decorationColor: Colors.white,
                            fontSize: 18,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => (),));
                        },
                        child: Text(
                          "Booking",
                          style: TextStyle(
                            decorationColor: Colors.white,
                            fontSize: 18,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => (),));
                        },
                        child: Text(
                          "StallRequests",
                          style: TextStyle(
                            decorationColor: Colors.white,
                            fontSize: 18,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              height: 200,
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                "Organize with Confidence, Sell with Ease.",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                "Plan smarter, sell quicker, succeed easier",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Createevent(),
                      ));
                },
                child: Text(
                  "CREATE EVENT",
                  style: TextStyle(
                    fontSize: 15,
                    color: const Color.fromARGB(255, 43, 40, 40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
