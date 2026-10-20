import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/department.dart';
import '../models/ticket.dart';
import '../services/queue_service.dart';
import '../widgets/live_wait_timer.dart';
import 'login_screen.dart';

class StaffHomeScreen extends StatelessWidget {
  final String departmentId;

  const StaffHomeScreen({
    super.key,
    required this.departmentId,
  });

  @override
  Widget build(BuildContext context) {
    final dept = Departments.byId(departmentId);
    if (dept == null) {
      return Scaffold(
        body: Center(
          child: Text('Error: Unknown department ($departmentId)'),
        ),
      );
    }

    final isCafe = departmentId == Departments.cafeId;
    final primaryColor = isCafe ? Colors.amber.shade800 : Colors.indigo.shade700;

    return Consumer<QueueService>(
      builder: (context, queue, _) {
        final waitingList = queue.waitingTickets(departmentId);
        final calledList = queue.calledTickets(departmentId);
        final totalServed = queue.departmentServedCount(departmentId);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${dept.name} Management',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Text(
                  'Staff Dashboard',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Log Out',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Top Dashboard Summary Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    _MetricCard(
                      label: 'Waiting',
                      value: '${waitingList.length}',
                      color: Colors.orange.shade800,
                      icon: Icons.hourglass_top_rounded,
                    ),
                    const SizedBox(width: 12),
                    _MetricCard(
                      label: 'Called',
                      value: '${calledList.length}',
                      color: Colors.blue.shade800,
                      icon: Icons.campaign_rounded,
                    ),
                    const SizedBox(width: 12),
                    _MetricCard(
                      label: 'Served Today',
                      value: '$totalServed',
                      color: Colors.green.shade800,
                      icon: Icons.check_circle_rounded,
                    ),
                  ],
                ),
              ),

              // "Call Next Ticket" Banner Action
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: waitingList.isEmpty
                        ? null
                        : () {
                            final calledTicket = queue.callNext(departmentId);
                            if (calledTicket != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Calling Ticket #${calledTicket.ticketCode} to counter!',
                                  ),
                                  backgroundColor: primaryColor,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.campaign_rounded, size: 22),
                    label: Text(
                      waitingList.isEmpty
                          ? 'Queue is Empty'
                          : 'Call Next Ticket (${waitingList.first.ticketCode})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              // Currently Called Ticket Section (if any ticket was called)
              if (calledList.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.record_voice_over_rounded,
                              size: 18, color: Colors.blue.shade800),
                          const SizedBox(width: 6),
                          Text(
                            'CURRENTLY CALLED AT COUNTER',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...calledList.map(
                        (t) => _CalledTicketCard(
                          ticket: t,
                          onMarkServed: () => queue.markServed(t),
                          onSkip: () => queue.skipTicket(t),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],

              // Queue List with AnimatedCrossFade (Empty state vs List state)
              Expanded(
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: waitingList.isEmpty
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_outline_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Waiting Tickets',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'The queue for ${dept.name} is currently empty.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  secondChild: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: waitingList.length,
                    itemBuilder: (context, index) {
                      final ticket = waitingList[index];
                      return _WaitingTicketCard(
                        ticket: ticket,
                        position: index + 1,
                        onCall: () => queue.callNext(departmentId),
                        onSkip: () => queue.skipTicket(ticket),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalledTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onMarkServed;
  final VoidCallback onSkip;

  const _CalledTicketCard({
    required this.ticket,
    required this.onMarkServed,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ticket.ticketCode,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Called to Counter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  LiveWaitTimer(
                    joinedAt: ticket.joinedAt,
                    showLabel: true,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: onMarkServed,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Served'),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.redAccent),
              tooltip: 'Skip',
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
  final VoidCallback onCall;
  final VoidCallback onSkip;

  const _WaitingTicketCard({
    required this.ticket,
    required this.position,
    required this.onCall,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Position Badge
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.shade200,
              child: Text(
                '#$position',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Ticket Number & Timer
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket ${ticket.ticketCode}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'Waiting: ',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      LiveWaitTimer(
                        joinedAt: ticket.joinedAt,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            TextButton.icon(
              onPressed: onSkip,
              icon: const Icon(Icons.close, size: 16, color: Colors.grey),
              label: const Text('Skip', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
