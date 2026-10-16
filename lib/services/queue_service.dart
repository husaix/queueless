import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../models/department.dart';

/// Simple in-memory queue manager for the prototype.
/// Later this will be replaced by Firebase / backend.
class QueueService extends ChangeNotifier {
  final Map<String, List<Ticket>> _queues = {};
  final Map<String, int> _counters = {}; // next ticket number per dept
  final Map<String, int> _servedCount = {}; // for admin performance
  final Map<String, Duration> _totalServiceTime = {}; // for avg speed

  // Currently logged-in user's ticket (simple single-user prototype)
  Ticket? currentUserTicket;

  QueueService() {
    for (final d in Departments.all) {
      _queues[d.id] = [];
      _counters[d.id] = 1;
      _servedCount[d.id] = 0;
      _totalServiceTime[d.id] = Duration.zero;
    }
  }

  List<Ticket> waitingTickets(String departmentId) {
    return List.unmodifiable(
      (_queues[departmentId] ?? [])
          .where((t) => t.status == TicketStatus.waiting)
          .toList(),
    );
  }

  List<Ticket> allTickets(String departmentId) {
    return List.unmodifiable(_queues[departmentId] ?? []);
  }

  int peopleAhead(Ticket ticket) {
    final waiting = waitingTickets(ticket.departmentId);
    final idx = waiting.indexWhere((t) => t.id == ticket.id);
    return idx < 0 ? 0 : idx;
  }

  int estimatedWaitMinutes(Ticket ticket) {
    final dept = Departments.byId(ticket.departmentId);
    final ahead = peopleAhead(ticket);
    final avg = dept?.avgServiceMinutes ?? 5;
    return (ahead + 1) * avg;
  }

  /// User joins a queue
  Ticket joinQueue(String departmentId) {
    final dept = Departments.byId(departmentId);
    if (dept == null) {
      throw Exception('Unknown department');
    }

    // If user already has a waiting ticket, return it
    if (currentUserTicket != null &&
        currentUserTicket!.status == TicketStatus.waiting) {
      return currentUserTicket!;
    }

    final number = _counters[departmentId]!;
    _counters[departmentId] = number + 1;

    final ticket = Ticket(
      id: '${departmentId}_${number}_${DateTime.now().millisecondsSinceEpoch}',
      number: number,
      departmentId: departmentId,
      departmentName: dept.name,
      joinedAt: DateTime.now(),
    );

    _queues[departmentId]!.add(ticket);
    currentUserTicket = ticket;
    notifyListeners();
    return ticket;
  }

  void cancelTicket(Ticket ticket) {
    if (ticket.status != TicketStatus.waiting) return;
    ticket.status = TicketStatus.cancelled;
    if (currentUserTicket?.id == ticket.id) {
      currentUserTicket = null;
    }
    notifyListeners();
  }

  /// Staff: call the next waiting ticket
  Ticket? callNext(String departmentId) {
    final waiting = waitingTickets(departmentId);
    if (waiting.isEmpty) return null;

    final next = waiting.first;
    next.status = TicketStatus.called;
    next.calledAt = DateTime.now();
    notifyListeners();
    return next;
  }

  /// Staff: mark as served
  void markServed(Ticket ticket) {
    if (ticket.status != TicketStatus.called &&
        ticket.status != TicketStatus.waiting) return;

    ticket.status = TicketStatus.served;
    ticket.servedAt = DateTime.now();

    final serviceTime = ticket.servedAt!.difference(ticket.joinedAt);
    _servedCount[ticket.departmentId] =
        (_servedCount[ticket.departmentId] ?? 0) + 1;
    _totalServiceTime[ticket.departmentId] =
        (_totalServiceTime[ticket.departmentId] ?? Duration.zero) + serviceTime;

    if (currentUserTicket?.id == ticket.id) {
      currentUserTicket = null;
    }
    notifyListeners();
  }

  /// Staff: skip a ticket
  void skipTicket(Ticket ticket) {
    if (ticket.status != TicketStatus.waiting &&
        ticket.status != TicketStatus.called) return;
    ticket.status = TicketStatus.skipped;
    if (currentUserTicket?.id == ticket.id) {
      currentUserTicket = null;
    }
    notifyListeners();
  }

  // ----- Admin performance helpers -----
  int servedToday(String departmentId) => _servedCount[departmentId] ?? 0;

  double averageServiceMinutes(String departmentId) {
    final count = _servedCount[departmentId] ?? 0;
    if (count == 0) return 0;
    final total = _totalServiceTime[departmentId] ?? Duration.zero;
    return total.inSeconds / 60.0 / count;
  }

  int currentWaitingCount(String departmentId) =>
      waitingTickets(departmentId).length;
}
