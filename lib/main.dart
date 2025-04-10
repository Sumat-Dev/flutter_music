import 'package:flutter/material.dart';

import 'features/music_player/view/music_player_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter music',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MusicPlayerPage(),
    );
  }
}
