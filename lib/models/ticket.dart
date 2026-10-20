enum TicketStatus { waiting, called, served, skipped, cancelled }

class Ticket {
  final String id;
  final int number;
  final String departmentId;
  final String departmentName;
  final DateTime joinedAt;
  TicketStatus status;
  DateTime? calledAt;
  DateTime? servedAt;

  Ticket({
    required this.id,
    required this.number,
    required this.departmentId,
    required this.departmentName,
    required this.joinedAt,
    this.status = TicketStatus.waiting,
    this.calledAt,
    this.servedAt,
  });

  /// Department ticket code prefix (e.g. C-101 for Café, A-101 for Admin Office)
  String get ticketCode {
    final prefix = departmentId == 'cafe' ? 'C' : 'A';
    final numStr = number.toString().padLeft(3, '0');
    return '$prefix-$numStr';
  }

  /// Calculates elapsed wait time since the ticket was generated.
  /// If called or served, calculates total time spent waiting before service.
  Duration get currentWaitDuration {
    final end = servedAt ?? calledAt ?? DateTime.now();
    return end.difference(joinedAt);
  }

  /// Formatted elapsed time in MM:SS string format.
  String get formattedWaitTime {
    final dur = currentWaitDuration;
    final minutes = dur.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = dur.inHours > 0 ? '${dur.inHours}:' : '';
    return '$hours$minutes:$seconds';
  }
}
