import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_music/features/music_player/model/music_model.dart';

class MusicPlayerPage extends StatefulWidget {
  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _player = AudioPlayer();
  List<MusicModel> musicList = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMusic();
    loadMusicList();
  }

  Future<void> _loadMusic() async {
    final list = await loadMusicList();
    setState(() {
      musicList = list;
    });
    await _loadTrack(0);
  }

  Future<List<MusicModel>> loadMusicList() async {
    final jsonString = await rootBundle.loadString('assets/music_list.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((item) => MusicModel.fromJson(item)).toList();
  }

  Future<void> _loadTrack(int index) async {
    currentIndex = index;
    await _player.setAsset(musicList[index].url);
    _player.play();
    setState(() {});
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMusic = musicList[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Playlist",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: musicList.length,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final music = musicList[index];
                  final isSelected = index == currentIndex;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              fit: BoxFit.cover,
                              music.image,
                              width: 60,
                              height: 60,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  music.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        isSelected ? Colors.blue : Colors.black,
                                  ),
                                ),
                                Text(
                                  music.artist,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.watch_later_outlined,
                                      size: 10,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      music.duration,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _loadTrack(index),
                            icon: Icon(Icons.play_arrow),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 100,
              child: StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing ?? false;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StreamBuilder<Duration>(
                        stream: _player.durationStream.map(
                          (d) => d ?? Duration.zero,
                        ),
                        builder: (context, durationSnapshot) {
                          final duration =
                              durationSnapshot.data ?? Duration.zero;

                          return StreamBuilder<Duration>(
                            stream: _player.positionStream,
                            builder: (context, positionSnapshot) {
                              final position =
                                  positionSnapshot.data ?? Duration.zero;

                              return Column(
                                children: [
                                  Slider(
                                    activeColor: Colors.blue,
                                    inactiveColor: Colors.grey,
                                    padding: EdgeInsets.all(0),
                                    min: 0.0,
                                    max: duration.inMilliseconds.toDouble(),
                                    value:
                                        position.inMilliseconds
                                            .clamp(0, duration.inMilliseconds)
                                            .toDouble(),
                                    onChanged: (value) {
                                      _player.seek(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                fit: BoxFit.cover,
                                currentMusic.image,
                                width: 60,
                                height: 60,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currentMusic.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    currentMusic.artist,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.watch_later_outlined,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        currentMusic.duration,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),
                            if (processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering)
                              const CircularProgressIndicator()
                            else if (!playing)
                              IconButton(
                                icon: const Icon(Icons.play_arrow),
                                iconSize: 34.0,
                                onPressed: _player.play,
                              )
                            else if (processingState !=
                                ProcessingState.completed)
                              IconButton(
                                icon: const Icon(Icons.pause),
                                iconSize: 34.0,
                                onPressed: _player.pause,
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.replay),
                                iconSize: 34.0,
                                onPressed: () => _player.seek(Duration.zero),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
