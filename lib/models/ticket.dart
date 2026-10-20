enum TicketStatus { waiting, called, served, skipped, cancelled }

class Ticket {
  final String id;
  final int number;
  final String departmentId;
  final String departmentName;
  final String userName;
  final DateTime joinedAt;
  TicketStatus status;
  DateTime? calledAt;
  DateTime? servedAt;

  Ticket({
    required this.id,
    required this.number,
    required this.departmentId,
    required this.departmentName,
    this.userName = 'Guest',
    required this.joinedAt,
    this.status = TicketStatus.waiting,
    this.calledAt,
    this.servedAt,
  });

  /// Formats the ticket display number with prefix (e.g., C-001 or A-002)
  String get formattedNumber {
    final prefix = departmentId == 'cafe' ? 'C' : 'A';
    final paddedNum = number.toString().padLeft(3, '0');
    return '$prefix-$paddedNum';
  }

  /// Calculates duration ticket spent waiting
  Duration get waitDuration {
    final end = servedAt ?? calledAt ?? DateTime.now();
    return end.difference(joinedAt);
  }

  /// Calculates current waiting time string formatted as MMm SSs
  String get formattedWaitTime {
    final duration = waitDuration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '${mStr}m ${sStr}s';
  }
}
