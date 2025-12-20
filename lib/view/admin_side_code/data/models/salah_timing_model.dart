import 'package:cloud_firestore/cloud_firestore.dart';

class SalahTimings {
  final Map<String, SalahTime> timings;

  SalahTimings(this.timings);

  factory SalahTimings.fromSnapshots(List<QueryDocumentSnapshot> snapshots) {
    final Map<String, SalahTime> times = {};
    for (var doc in snapshots) {
      final data = doc.data() as Map<String, dynamic>;
      final id = doc.id;

      times[id] = SalahTime(
        azaanTime: (data['azaanTime'] ?? '').toString().trim(),
        jammatTime: (data['jammatTime'] ?? '').toString().trim(),
      );
    }
    return SalahTimings(times);
  }
}

class SalahTime {
  final String azaanTime;
  final String jammatTime;

  SalahTime({
    required this.azaanTime,
    required this.jammatTime,
  });
}
