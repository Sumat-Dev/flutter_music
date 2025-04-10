class MusicModel {
  final String title;
  final String artist;
  final String image;
  final String duration;
  final String url;

  MusicModel({
    required this.title,
    required this.artist,
    required this.image,
    required this.duration,
    required this.url,
  });

  factory MusicModel.fromJson(Map<String, dynamic> json) {
    return MusicModel(
      title: json['title'] as String,
      artist: json['artist'] as String,
      image: json['image'] as String,
      duration: json['duration'] as String,
      url: json['url'] as String,
    );
  }
}
