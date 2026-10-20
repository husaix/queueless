import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/department.dart';
import '../models/ticket.dart';
import '../services/queue_service.dart';
import 'user_home_screen.dart'; // for LiveWaitTimer
import 'login_screen.dart';

class StaffHomeScreen extends StatelessWidget {
  final String departmentId;

  const StaffHomeScreen({super.key, required this.departmentId});

  @override
  Widget build(BuildContext context) {
    final dept = Departments.byId(departmentId) ?? Departments.cafe;
    final isCafe = dept.id == 'cafe';

    return Scaffold(
      appBar: AppBar(
        title: Text('${dept.name} Management'),
        backgroundColor: isCafe ? Colors.orange.shade800 : Colors.indigo.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<QueueService>(
        builder: (context, queue, _) {
          final waiting = queue.waitingTickets(departmentId);
          final called = queue.calledTickets(departmentId);

          return Column(
            children: [
              // Management Top Dashboard Control Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isCafe ? Colors.orange.shade50 : Colors.indigo.shade50,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dept.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${waiting.length} waiting in line',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: waiting.isEmpty
                          ? null
                          : () {
                              final next = queue.callNext(departmentId);
                              if (next != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Now calling Ticket #${next.formattedNumber} (${next.userName})!',
                                    ),
                                    backgroundColor: Colors.teal.shade800,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            isCafe ? Colors.orange.shade800 : Colors.indigo.shade800,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.campaign_rounded),
                      label: const Text(
                        'Call Next',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Currently Called Tickets Banner
              if (called.isNotEmpty)
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.record_voice_over,
                              color: Colors.amber.shade900),
                          const SizedBox(width: 8),
                          Text(
                            'Currently Called Ticket(s)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...called.map(
                        (t) => _CalledTicketCard(
                          ticket: t,
                          onComplete: () => queue.markServed(t),
                          onSkip: () => queue.skipTicket(t),
                        ),
                      ),
                    ],
                  ),
                ),

              // Waiting Queue Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waiting Queue (${waiting.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 300),
                          crossFadeState: waiting.isEmpty
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 400),
                              opacity: waiting.isEmpty ? 1.0 : 0.0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check_circle_outline_rounded,
                                      size: 56,
                                      color: Colors.green.shade400,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Queue is empty!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'There are no waiting tickets for ${dept.name}.',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          secondChild: ListView.builder(
                            itemCount: waiting.length,
                            itemBuilder: (context, index) {
                              final ticket = waiting[index];
                              return _WaitingTicketCard(
                                ticket: ticket,
                                position: index + 1,
                                onSkip: () => queue.skipTicket(ticket),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CalledTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const _CalledTicketCard({
    required this.ticket,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ticket.formattedNumber,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.green.shade900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        'Waited: ',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      LiveWaitTimer(
                        joinedAt: ticket.joinedAt,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Served'),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
              tooltip: 'Skip / Cancel',
              onPressed: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingTicketCard extends StatelessWidget {
  final Ticket ticket;
  final int position;
  final VoidCallback onSkip;

  const _WaitingTicketCard({
    required this.ticket,
    required this.position,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Position Avatar
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              radius: 18,
              child: Text(
                '#$position',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Ticket Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket ${ticket.formattedNumber} · ${ticket.userName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Waiting: ',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      LiveWaitTimer(
                        joinedAt: ticket.joinedAt,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent),
              tooltip: 'Cancel Ticket',
              onPressed: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}
