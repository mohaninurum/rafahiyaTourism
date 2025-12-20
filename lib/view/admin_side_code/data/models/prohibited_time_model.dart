class ProhibitedTime {
  final String time1From;
  final String time1To;
  final String time2From;
  final String time2To;
  final String time3From;
  final String time3To;
  final String time4From;
  final String time4To;
  final String imamId;

  ProhibitedTime({
    required this.time1From,
    required this.time1To,
    required this.time2From,
    required this.imamId,
    required this.time2To,
    required this.time3From,
    required this.time3To,
    required this.time4From,
    required this.time4To,
  });

  factory ProhibitedTime.fromMap(Map<String, dynamic> map) {
    return ProhibitedTime(
      time1From: map['time1From'] ?? '',
      time1To: map['time1To'] ?? '',
      time2From: map['time2From'] ?? '',
      time2To: map['time2To'] ?? '',
      time3From: map['time3From'] ?? '',
      time3To: map['time3To'] ?? '',
      time4From: map['time4From'] ?? '',
      time4To: map['time4To'] ?? '',
      imamId: map['imamId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'time1From': time1From,
      'time1To': time1To,
      'time2From': time2From,
      'time2To': time2To,
      'time3From': time3From,
      'time3To': time3To,
      'time4From': time4From,
      'time4To': time4To,
      'imamId': imamId,
    };
  }
}
