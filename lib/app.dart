import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/puzzle/ui/puzzle_page.dart';

class CalendarPuzzleApp extends StatelessWidget {
  const CalendarPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return MaterialApp(
      title: 'Wooden Calendar Puzzle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: textTheme,
        scaffoldBackgroundColor: const Color(0xFF101214),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFEEDCC3), // açık çerçeve tonu
          surface: Color(0xFF101214),
        ),
      ),
      home: const PuzzlePage(),
    );
  }
}
