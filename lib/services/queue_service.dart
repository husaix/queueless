import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../models/department.dart';

/// In-memory queue service managing real-time ticket states, counters, and statistics.
class QueueService extends ChangeNotifier {
  final Map<String, List<Ticket>> _queues = {};
  final Map<String, int> _counters = {};

  // Track user's active ticket for demo purposes
  Ticket? currentUserTicket;

  QueueService() {
    for (final d in Departments.all) {
      _queues[d.id] = [];
      _counters[d.id] = 1;
    }
  }

  /// Get waiting tickets for a specific department
  List<Ticket> waitingTickets(String departmentId) {
    return List.unmodifiable(
      (_queues[departmentId] ?? [])
          .where((t) => t.status == TicketStatus.waiting)
          .toList(),
    );
  }

  /// Get currently called tickets for a department
  List<Ticket> calledTickets(String departmentId) {
    return List.unmodifiable(
      (_queues[departmentId] ?? [])
          .where((t) => t.status == TicketStatus.called)
          .toList(),
    );
  }

  /// Get served/completed tickets for a department
  List<Ticket> servedTickets(String departmentId) {
    return List.unmodifiable(
      (_queues[departmentId] ?? [])
          .where((t) => t.status == TicketStatus.served)
          .toList(),
    );
  }

  /// Get all tickets ever generated for a department
  List<Ticket> allTickets(String departmentId) {
    return List.unmodifiable(_queues[departmentId] ?? []);
  }

  /// Calculate how many people are ahead of a ticket
  int peopleAhead(Ticket ticket) {
    final waiting = waitingTickets(ticket.departmentId);
    final idx = waiting.indexWhere((t) => t.id == ticket.id);
    return idx < 0 ? 0 : idx;
  }

  /// Calculate estimated wait time in minutes for a ticket
  int estimatedWaitMinutes(Ticket ticket) {
    final dept = Departments.byId(ticket.departmentId);
    final ahead = peopleAhead(ticket);
    final avg = dept?.avgServiceMinutes ?? 4;
    return (ahead + 1) * avg;
  }

  /// User joins queue for a given department with their name
  Ticket joinQueue(String departmentId, {String userName = 'Guest'}) {
    final dept = Departments.byId(departmentId);
    if (dept == null) {
      throw Exception('Department not found');
    }

    final cleanName = userName.trim().isEmpty ? 'Guest' : userName.trim();

    // If user already has an active waiting/called ticket, return it
    if (currentUserTicket != null &&
        (currentUserTicket!.status == TicketStatus.waiting ||
            currentUserTicket!.status == TicketStatus.called)) {
      return currentUserTicket!;
    }

    final number = _counters[departmentId]!;
    _counters[departmentId] = number + 1;

    final ticket = Ticket(
      id: '${departmentId}_${number}_${DateTime.now().millisecondsSinceEpoch}',
      number: number,
      departmentId: departmentId,
      departmentName: dept.name,
      userName: cleanName,
      joinedAt: DateTime.now(),
    );

    _queues[departmentId]!.add(ticket);
    currentUserTicket = ticket;
    notifyListeners();
    return ticket;
  }

  /// Cancel an active ticket
  void cancelTicket(Ticket ticket) {
    if (ticket.status != TicketStatus.waiting &&
        ticket.status != TicketStatus.called) {
      return;
    }
    ticket.status = TicketStatus.cancelled;
    if (currentUserTicket?.id == ticket.id) {
      currentUserTicket = null;
    }
    notifyListeners();
  }

  /// Management: call the next ticket in queue
  Ticket? callNext(String departmentId) {
    final waiting = waitingTickets(departmentId);
    if (waiting.isEmpty) {
      return null;
    }

    final next = waiting.first;
    next.status = TicketStatus.called;
    next.calledAt = DateTime.now();
    notifyListeners();
    return next;
  }

  /// Management: mark ticket as served/completed
  void markServed(Ticket ticket) {
    if (ticket.status != TicketStatus.called &&
        ticket.status != TicketStatus.waiting) {
      return;
    }

    ticket.status = TicketStatus.served;
    ticket.servedAt = DateTime.now();

    if (currentUserTicket?.id == ticket.id) {
      currentUserTicket = null;
    }
    notifyListeners();
  }

  /// Management: skip ticket
  void skipTicket(Ticket ticket) {
    if (ticket.status != TicketStatus.waiting &&
        ticket.status != TicketStatus.called) {
      return;
    }
    ticket.status = TicketStatus.skipped;
    if (currentUserTicket?.id == ticket.id) {
      currentUserTicket = null;
    }
    notifyListeners();
  }

  // ================= ADMIN STATISTICS HELPERS =================

  /// Total tickets generated across all departments
  int get totalTicketsGenerated {
    return _queues.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Total Café tickets generated
  int get totalCafeTickets {
    return _queues[Departments.cafe.id]?.length ?? 0;
  }

  /// Total Administration Office tickets generated
  int get totalAdminOfficeTickets {
    return _queues[Departments.adminOffice.id]?.length ?? 0;
  }

  /// Total tickets currently in waiting status across all departments
  int get totalWaitingTickets {
    int sum = 0;
    _queues.forEach((_, list) {
      sum += list.where((t) => t.status == TicketStatus.waiting).length;
    });
    return sum;
  }

  /// Total tickets currently called across all departments
  int get totalCalledTickets {
    int sum = 0;
    _queues.forEach((_, list) {
      sum += list.where((t) => t.status == TicketStatus.called).length;
    });
    return sum;
  }

  /// Total tickets completed/served across all departments
  int get totalServedTickets {
    int sum = 0;
    _queues.forEach((_, list) {
      sum += list.where((t) => t.status == TicketStatus.served).length;
    });
    return sum;
  }

  /// Get total count for waiting tickets by dept
  int currentWaitingCount(String departmentId) =>
      waitingTickets(departmentId).length;

  /// Get total count for called tickets by dept
  int currentCalledCount(String departmentId) =>
      calledTickets(departmentId).length;

  /// Get total count for served tickets by dept
  int totalServedCount(String departmentId) =>
      servedTickets(departmentId).length;
}
