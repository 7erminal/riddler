import 'dart:async';
import 'package:flutter/material.dart';

class InactivityService {
  Timer? _inactivityTimer;
  final Duration inactivityDuration;
  final VoidCallback onInactive;

  InactivityService({
    required this.inactivityDuration,
    required this.onInactive,
  });

  void startTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityDuration, () {
      onInactive();
    });
  }

  void resetTimer() {
    startTimer();
  }

  void stopTimer() {
    _inactivityTimer?.cancel();
  }

  void dispose() {
    _inactivityTimer?.cancel();
  }
}