// Add this new provider file: lib/provider/app_state_provider.dart
import 'package:flutter/foundation.dart';

class AppStateProvider with ChangeNotifier {
  bool _showRestartDialog = false;

  bool get showRestartDialog => _showRestartDialog;

  void setShowRestartDialog(bool value) {
    _showRestartDialog = value;
    notifyListeners();
  }
}
