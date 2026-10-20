import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/department.dart';
import '../models/ticket.dart';
import '../services/queue_service.dart';
import '../widgets/live_wait_timer.dart';
import 'login_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueService>(
      builder: (context, queue, _) {
        final ticket = queue.currentUserTicket;
        final hasActiveTicket =
            ticket != null && ticket.status == TicketStatus.waiting;

        return Scaffold(
          appBar: AppBar(
            title: const Text('QueueLess – User'),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Back to Portals',
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
          body: AnimatedCrossFade(
            duration: const Duration(milliseconds: 400),
            crossFadeState: hasActiveTicket
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const _SelectDepartmentView(),
            secondChild: hasActiveTicket
                ? _ActiveTicketView(ticket: ticket)
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

/// Department Selection View - Displays Café and Administration Office
class _SelectDepartmentView extends StatelessWidget {
  const _SelectDepartmentView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        Text(
          'Select Department',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap a department below to generate your virtual ticket.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Display exactly the two departments: Café and Administration Office
        ...Departments.all.map((dept) {
          final isCafe = dept.id == Departments.cafeId;
          final waiting =
              context.watch<QueueService>().departmentWaitingCount(dept.id);
          final cardColor = isCafe ? Colors.amber.shade700 : Colors.indigo.shade600;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {
                  final service = context.read<QueueService>();
                  final newTicket = service.joinQueue(dept.id);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Ticket ${newTicket.ticketCode} generated for ${dept.name}!',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: cardColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isCafe ? Icons.local_cafe_rounded : Icons.account_balance_rounded,
                          color: cardColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dept.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dept.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.people_alt_outlined,
                                    size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  '$waiting in queue',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.access_time_rounded,
                                    size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  '~${dept.avgServiceMinutes} min/person',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: Colors.grey.shade400),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Active Ticket View - Displays current ticket, queue position, live timer, and status
class _ActiveTicketView extends StatelessWidget {
  final Ticket ticket;

  const _ActiveTicketView({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>();
    final ahead = queue.peopleAhead(ticket);
    final estWait = queue.estimatedWaitMinutes(ticket);
    final isNext = ahead == 0;

    final isCafe = ticket.departmentId == Departments.cafeId;
    final primaryColor = isCafe ? Colors.amber.shade800 : Colors.indigo.shade700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          // Ticket Card Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCafe ? Icons.local_cafe_rounded : Icons.account_balance_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticket.departmentName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'YOUR TICKET NUMBER',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Animated ticket number
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    ticket.ticketCode,
                    key: ValueKey(ticket.ticketCode),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white30, height: 1),
                const SizedBox(height: 16),

                // Stats Row: People Ahead, Est. Wait, Live Elapsed Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TicketMetric(
                      label: 'People Ahead',
                      value: '$ahead',
                      icon: Icons.people_outline_rounded,
                    ),
                    Container(height: 30, width: 1, color: Colors.white30),
                    _TicketMetric(
                      label: 'Est. Wait',
                      value: '$estWait min',
                      icon: Icons.timelapse_rounded,
                    ),
                    Container(height: 30, width: 1, color: Colors.white30),
                    Column(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 20, color: Colors.white70),
                        const SizedBox(height: 4),
                        LiveWaitTimer(
                          joinedAt: ticket.joinedAt,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Elapsed',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status Alert Banner
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isNext ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isNext ? Colors.green.shade300 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isNext ? Icons.notifications_active_rounded : Icons.info_outline_rounded,
                    color: isNext ? Colors.green.shade700 : Colors.blue.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isNext ? 'You are next in line!' : 'Waiting in Queue',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isNext ? Colors.green.shade900 : Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isNext
                              ? 'Please move close to the counter and get ready.'
                              : 'Keep this screen open. We will notify you when called.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isNext ? Colors.green.shade800 : Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Cancel Ticket Button
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cancel Ticket?'),
                  content: const Text(
                    'Are you sure you want to cancel your ticket? You will lose your position in the queue.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Keep Waiting'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        context.read<QueueService>().cancelTicket(ticket);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Yes, Cancel Ticket'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel My Ticket'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TicketMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.white70),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
