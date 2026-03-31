import 'package:flutter/material.dart';

class NavController extends ChangeNotifier {
  int _adminIndex = 0;
  int _maestroIndex = 0;
  int _alumnoIndex = 0;

  int get adminIndex => _adminIndex;
  int get maestroIndex => _maestroIndex;
  int get alumnoIndex => _alumnoIndex;

  void setAdminIndex(int index) {
    _adminIndex = index;
    notifyListeners();
  }

  void setMaestroIndex(int index) {
    _maestroIndex = index;
    notifyListeners();
  }

  void setAlumnoIndex(int index) {
    _alumnoIndex = index;
    notifyListeners();
  }

  /// Reset all indexes (useful on logout)
  void reset() {
    _adminIndex = 0;
    _maestroIndex = 0;
    _alumnoIndex = 0;
    notifyListeners();
  }
}
