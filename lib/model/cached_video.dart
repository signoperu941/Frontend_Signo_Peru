class CachedVideo {
  final String palabra;
  final String originalUrl;
  final String localPath;
  final DateTime downloadedAt;

  const CachedVideo({
    required this.palabra,
    required this.originalUrl,
    required this.localPath,
    required this.downloadedAt,
  });

  Map<String, dynamic> toJson() => {
        'palabra': palabra,
        'originalUrl': originalUrl,
        'localPath': localPath,
        'downloadedAt': downloadedAt.toIso8601String(),
      };

  factory CachedVideo.fromJson(Map<String, dynamic> json) => CachedVideo(
        palabra: json['palabra'] as String,
        originalUrl: json['originalUrl'] as String,
        localPath: json['localPath'] as String,
        downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      );
}
