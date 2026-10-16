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

  Duration get waitDuration {
    final end = servedAt ?? calledAt ?? DateTime.now();
    return end.difference(joinedAt);
  }
}
