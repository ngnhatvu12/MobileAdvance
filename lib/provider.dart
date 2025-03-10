import 'package:flutter/material.dart';

class AvatarProvider with ChangeNotifier {
  String _avatarText = 'NV';

  String get avatarText => _avatarText;

  void updateAvatarText(String newText) {
    _avatarText = newText;
    notifyListeners(); // Thông báo cho Consumer rebuild
  }
}