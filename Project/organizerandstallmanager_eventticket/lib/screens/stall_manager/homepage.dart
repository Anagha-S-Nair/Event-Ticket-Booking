import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/createevent.dart';
import 'package:organizerandstallmanager_eventticket/screens/stall_manager/event.dart';
import 'package:organizerandstallmanager_eventticket/screens/stall_manager/myprofile.dart';
import 'package:organizerandstallmanager_eventticket/screens/stall_manager/viewrequests.dart';

class StallHomePage extends StatelessWidget {
  const StallHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/l10.jpg'), // Replace with your image path
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
                                builder: (context) => StallProfile(),
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
                                builder: (context) => StallEvents(),
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyRequests(),
                              ));
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
          ],
        ),
      ),
    );
  }
}
