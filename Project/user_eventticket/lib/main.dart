import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:user_eventticket/screens/login.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://kwagmrhiuvqqvdlozppd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt3YWdtcmhpdXZxcXZkbG96cHBkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzcxMDQyMDgsImV4cCI6MjA1MjY4MDIwOH0.woNmIIe58VjkauHL0VFWQCrvBuMaCOKtqM3CRGzm9aE',
  );
  runApp(const MainApp());
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage()
    );
  }
}