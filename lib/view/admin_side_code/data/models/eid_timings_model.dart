class EidTiming {
  final String jammat1;
  final String jammat2;

  EidTiming({required this.jammat1, required this.jammat2});

  factory EidTiming.fromMap(Map<String, dynamic> map) {
    return EidTiming(
      jammat1: map['jammat1'] ?? '',
      jammat2: map['jammat2'] ?? '',
    );
  }
}
