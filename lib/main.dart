import 'package:flutter/material.dart';
import 'package:music_player/Screen/AllMusic/all_music.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro Music Player',
      debugShowCheckedModeBanner: false,
      darkTheme:ThemeData.dark(),
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:const AllMusic(),
    );
  }
}

