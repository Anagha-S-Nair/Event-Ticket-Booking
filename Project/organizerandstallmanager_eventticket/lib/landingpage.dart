import 'package:flutter/material.dart';
import 'package:organizerandstallmanager_eventticket/homepage.dart';
import 'package:organizerandstallmanager_eventticket/login.dart';
import 'package:organizerandstallmanager_eventticket/organsierregistration.dart';
import 'package:organizerandstallmanager_eventticket/screens/event_organiser/homepage.dart';
import 'package:organizerandstallmanager_eventticket/stallregistration.dart';

class Landingpage extends StatelessWidget {
  const Landingpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/l6.jpg'),
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
                                builder: (context) => Stallregistration(),
                              ));
                        },
                        child: Text(
                          "SIGNUP",
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
                                builder: (context) => LoginPage(),
                              ));
                        },
                        child: Text(
                          "LOGIN",
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
              height: 220,
            ),
            Center(
              child: Text(
                "Book Smart. Experience More.",
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(3.0, 3.0), // Position of the shadow
                      blurRadius: 2.0, // Softness of the shadow
                      color: const Color.fromARGB(255, 66, 66, 66)
                          .withOpacity(0.8), // Shadow color with opacity
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                "Book today, experience tomorrow.",
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
                        builder: (context) => OrganiserHomePage(),
                      ));
                },
                child: Text(
                  "GET STARTED",
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
