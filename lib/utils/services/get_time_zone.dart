
import 'package:flutter_timezone/flutter_timezone.dart';
class GetTimeZone {
  static Future<String> setupTimezone() async {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    String currentTimeZone = timezoneInfo.identifier;
    print("Current timezone: $currentTimeZone");
    return currentTimeZone;
  }
}