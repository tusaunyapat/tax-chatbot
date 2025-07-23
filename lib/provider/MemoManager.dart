import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoManager extends ChangeNotifier {
  List<String> _memos = [];

  List<String> get memos => _memos;

  MemoManager() {
    _loadMemos();
  }

  Future<void> _loadMemos() async {
    final prefs = await SharedPreferences.getInstance();
    _memos = prefs.getStringList("memos") ?? [];
    notifyListeners(); // update listeners when loaded
  }

  Future<void> addMemo(String memo) async {
    final prefs = await SharedPreferences.getInstance();
    _memos.add(memo);
    await prefs.setStringList("memos", _memos);
    notifyListeners();
  }

  Future<void> removeMemo(String memo) async {
    final prefs = await SharedPreferences.getInstance();
    _memos.remove(memo);
    await prefs.setStringList("memos", _memos);
    notifyListeners();
  }
}
