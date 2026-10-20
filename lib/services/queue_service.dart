import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../models/department.dart';

/// Simple in-memory queue manager for storing and updating tickets.
class QueueService extends ChangeNotifier {
  final Map<String, List<Ticket>> _queues = {};
  final Map<String, int> _counters = {}; // Ticket counter per department

  // Currently generated active user ticket
  Ticket? currentUserTicket;

  QueueService() {
    for (final dept in Departments.all) {
      _queues[dept.id] = [];
      _counters[dept.id] = 101; // Start ticket numbering at 101
    }
  }

  // --- Queue Queries for Management & User ---

  /// Waiting tickets in a specific department
  List<Ticket> waitingTickets(String departmentId) {
    return List.unmodifiable(
      (_queues[departmentId] ?? [])
          .where((t) => t.status == TicketStatus.waiting)
          .toList(),
    );
  }

  /// Currently called tickets in a specific department
  List<Ticket> calledTickets(String departmentId) {
    return List.unmodifiable(
      (_queues[departmentId] ?? [])
          .where((t) => t.status == TicketStatus.called)
          .toList(),
    );
  }

  /// All tickets in a specific department
  List<Ticket> allTickets(String departmentId) {
    return List.unmodifiable(_queues[departmentId] ?? []);
  }

  /// Number of people waiting ahead of a given ticket
  int peopleAhead(Ticket ticket) {
    final waiting = waitingTickets(ticket.departmentId);
    final index = waiting.indexWhere((t) => t.id == ticket.id);
    return index < 0 ? 0 : index;
  }

  /// Estimated wait time in minutes based on position and department average
  int estimatedWaitMinutes(Ticket ticket) {
    final dept = Departments.byId(ticket.departmentId);
    final ahead = peopleAhead(ticket);
    final avg = dept?.avgServiceMinutes ?? 4;
    return (ahead + 1) * avg;
  }

  // --- User Operations ---

  /// User generates a ticket for a selected department with their name
  Ticket joinQueue(String departmentId, {String userName = 'Guest'}) {
    final dept = Departments.byId(departmentId);
    if (dept == null) {
      throw Exception('Invalid department selected');
    }

    // If user already has an active waiting ticket and hasn't requested a new ticket, return it
    if (currentUserTicket != null &&
        currentUserTicket!.status == TicketStatus.waiting) {
      return currentUserTicket!;
    }

    final number = _counters[departmentId]!;
    _counters[departmentId] = number + 1;

    final cleanName = userName.trim().isEmpty ? 'Guest' : userName.trim();

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

  /// Resets the user's active ticket view so a new ticket can be generated for another user/department
  void clearUserTicketView() {
    currentUserTicket = null;
    notifyListeners();
  }

  /// User cancels their ticket
  void cancelTicket(Ticket ticket) {
    if (ticket.status != TicketStatus.waiting) return;
    ticket.status = TicketStatus.cancelled;
    if (currentUserTicket?.id == ticket.id) {
      currentUserTicket = null;
    }
    notifyListeners();
  }

  // --- Management Operations ---

  /// Staff calls the next waiting ticket in their department
  Ticket? callNext(String departmentId) {
    final waiting = waitingTickets(departmentId);
    if (waiting.isEmpty) return null;

    final next = waiting.first;
    next.status = TicketStatus.called;
    next.calledAt = DateTime.now();
    notifyListeners();
    return next;
  }

  /// Staff marks a called ticket as served/completed
  void markServed(Ticket ticket) {
    if (ticket.status != TicketStatus.called &&
        ticket.status != TicketStatus.waiting) return;

    ticket.status = TicketStatus.served;
    ticket.servedAt = DateTime.now();

    if (currentUserTicket?.id == ticket.id) {
      currentUserTicket = null;
    }
    notifyListeners();
  }

  /// Staff skips a ticket
  void skipTicket(Ticket ticket) {
    if (ticket.status != TicketStatus.waiting &&
        ticket.status != TicketStatus.called) return;

    ticket.status = TicketStatus.skipped;
    if (currentUserTicket?.id == ticket.id) {
      currentUserTicket = null;
    }
    notifyListeners();
  }

  // --- Read-Only Admin Statistics ---

  /// Total tickets generated across all departments
  int get totalTicketsGenerated {
    return _queues.values.fold(0, (sum, list) => sum + list.length);
  }

  /// Total tickets generated for a specific department
  int departmentTotalTickets(String departmentId) {
    return _queues[departmentId]?.length ?? 0;
  }

  /// Current waiting tickets count for a department
  int departmentWaitingCount(String departmentId) {
    return waitingTickets(departmentId).length;
  }

  /// Current called tickets count for a department
  int departmentCalledCount(String departmentId) {
    return calledTickets(departmentId).length;
  }

  /// Served/completed tickets count for a department
  int departmentServedCount(String departmentId) {
    return (_queues[departmentId] ?? [])
        .where((t) => t.status == TicketStatus.served)
        .length;
  }

  /// Total currently waiting tickets across all departments
  int get totalWaitingCount {
    return _queues.keys.fold(0, (sum, id) => sum + departmentWaitingCount(id));
  }

  /// Total called & served (completed) tickets across all departments
  int get totalCompletedCount {
    return _queues.values.fold(
      0,
      (sum, list) =>
          sum +
          list.where((t) => t.status == TicketStatus.served || t.status == TicketStatus.called).length,
    );
  }
}
