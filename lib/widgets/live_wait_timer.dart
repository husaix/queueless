import 'dart:async';
import 'package:flutter/material.dart';

/// A reusable widget that calculates and displays the live elapsed waiting time
/// for a ticket. Uses [Timer.periodic] to update every second and cancels the timer
/// when disposed. The waiting time relies on [joinedAt] so it does NOT reset when
/// rebuilding or navigating across screens in the same session.
class LiveWaitTimer extends StatefulWidget {
  final DateTime joinedAt;
  final DateTime? endTime; // Optional fixed end time if called or served
  final TextStyle? style;
  final bool showLabel;

  const LiveWaitTimer({
    super.key,
    required this.joinedAt,
    this.endTime,
    this.style,
    this.showLabel = false,
  });

  @override
  State<LiveWaitTimer> createState() => _LiveWaitTimerState();
}

class _LiveWaitTimerState extends State<LiveWaitTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Only start a timer if the timer is still actively accumulating (endTime == null)
    if (widget.endTime == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final end = widget.endTime ?? DateTime.now();
    final duration = end.difference(widget.joinedAt);

    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';

    final timeString = '$hours$minutes:$seconds';

    if (widget.showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            'Wait: $timeString',
            style: widget.style ?? const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      );
    }

    return Text(
      timeString,
      style: widget.style ?? const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
