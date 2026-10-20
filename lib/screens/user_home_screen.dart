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
            title: const Text('QueueLess – User Portal'),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Return to Homepage',
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

/// Department Selection View - First page where user enters name and selects a department
class _SelectDepartmentView extends StatefulWidget {
  const _SelectDepartmentView();

  @override
  State<_SelectDepartmentView> createState() => _SelectDepartmentViewState();
}

class _SelectDepartmentViewState extends State<_SelectDepartmentView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _generateTicket(String departmentId) {
    final nameInput = _nameController.text.trim();

    // MUST require name before generating a ticket
    if (nameInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text('Name is required! Please enter your name first.'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final service = context.read<QueueService>();
    final newTicket = service.joinQueue(departmentId, userName: nameInput);

    // Empty the name bar for the next ticket before navigating
    _nameController.clear();

    final isCafe = departmentId == Departments.cafeId;
    final cardColor = isCafe ? Colors.amber.shade700 : Colors.indigo.shade600;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ticket ${newTicket.ticketCode} generated for ${newTicket.userName}!',
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
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        Text(
          'Get Your Ticket',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter user name below and select a department to join the queue.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 20),

        // Name Bar Input Field (Required)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.badge_outlined,
                      size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'User Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter full name (Required)',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Select Department',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        // Display departments: Café and Administration Office
        ...Departments.all.map((dept) {
          final isCafe = dept.id == Departments.cafeId;
          final waiting =
              context.watch<QueueService>().departmentWaitingCount(dept.id);
          final cardColor =
              isCafe ? Colors.amber.shade700 : Colors.indigo.shade600;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => _generateTicket(dept.id),
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
                          isCafe
                              ? Icons.local_cafe_rounded
                              : Icons.account_balance_rounded,
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

/// Active Ticket View - Displays current ticket (Appears ONLY after a ticket is generated)
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
    final primaryColor =
        isCafe ? Colors.amber.shade800 : Colors.indigo.shade700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Action Options Bar (Only appears on Active Ticket Page!)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Option 1: Get New Ticket
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<QueueService>().clearUserTicketView();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter a name and select a department to issue another ticket.',
                          ),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_card_rounded, size: 18),
                    label: const Text('Get New Ticket'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Option 2: Return to Homepage
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text('Return to Home'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

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
                      isCafe
                          ? Icons.local_cafe_rounded
                          : Icons.account_balance_rounded,
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

                const SizedBox(height: 10),

                // User Name Tag on Active Ticket
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_rounded,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        ticket.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
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
                    isNext
                        ? Icons.notifications_active_rounded
                        : Icons.info_outline_rounded,
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
                            color: isNext
                                ? Colors.green.shade900
                                : Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isNext
                              ? '${ticket.userName}, please move close to the counter.'
                              : 'Keep this screen open. We will call ${ticket.userName} when ready.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isNext
                                ? Colors.green.shade800
                                : Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

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
                      style:
                          FilledButton.styleFrom(backgroundColor: Colors.red),
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
