import 'dart:async';

import 'package:flutter/material.dart';
import 'package:success_subliminal/utils/constant.dart';

class OtpTimer extends StatefulWidget {
  final int timeInSec;
  final Function onTimerEnd;
  final GlobalKey<OtpTimerState> key;

  const OtpTimer(
      {this.timeInSec = 30, required this.onTimerEnd, required this.key})
      : super(key: key);

  @override
  OtpTimerState createState() => OtpTimerState();
}

class OtpTimerState extends State<OtpTimer> {
  late int _currentSecond;
  late Timer _timer;

  @override
  void initState() {
    _currentSecond = widget.timeInSec;
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '00:$_currentSecond',
      style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: 'DPClear',
          color: accent),
    );
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentSecond--;
      });
      if (_currentSecond == 0) {
        stopTimer();
        widget.onTimerEnd();
      }
    });
  }

  void stopTimer() {
    _timer.cancel();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  void restartTimer() {
    setState(() {
      _currentSecond = widget.timeInSec;
    });
    startTimer();
  }
}
