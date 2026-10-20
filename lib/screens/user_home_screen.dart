import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/department.dart';
import '../models/ticket.dart';
import '../services/queue_service.dart';
import 'login_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueService>(
      builder: (context, queue, _) {
        final ticket = queue.currentUserTicket;

        return Scaffold(
          appBar: AppBar(
            title: const Text('User Portal'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Back to Role Selection',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
          body: AnimatedCrossFade(
            duration: const Duration(milliseconds: 350),
            crossFadeState: (ticket != null &&
                    (ticket.status == TicketStatus.waiting ||
                        ticket.status == TicketStatus.called))
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const _SelectDepartmentView(),
            secondChild: ticket != null
                ? _MyTicketView(ticket: ticket)
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}

class _SelectDepartmentView extends StatefulWidget {
  const _SelectDepartmentView();

  @override
  State<_SelectDepartmentView> createState() => _SelectDepartmentViewState();
}

class _SelectDepartmentViewState extends State<_SelectDepartmentView> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onDepartmentSelected(Department dept) {
    final enteredName = _nameController.text.trim();
    if (enteredName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your name before selecting a department.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isCafe = dept.id == 'cafe';
    final service = context.read<QueueService>();
    final ticket = service.joinQueue(dept.id, userName: enteredName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ticket #${ticket.formattedNumber} generated for ${ticket.userName} (${dept.name})!',
        ),
        backgroundColor: isCafe ? Colors.orange.shade800 : Colors.indigo.shade800,
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
        Text(
          'Get Your Ticket',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter your name and select a department to generate your ticket.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 20),

        // Name Entry Field
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Step 1: Enter Your Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Full Name',
                      hintText: 'e.g., John Doe',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Text(
          'Step 2: Select a Department',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 12),

        ...Departments.all.map((dept) {
          final waiting =
              context.watch<QueueService>().currentWaitingCount(dept.id);
          final isCafe = dept.id == 'cafe';

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onDepartmentSelected(dept),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCafe ? Colors.orange.shade50 : Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isCafe ? Icons.local_cafe_rounded : Icons.business_rounded,
                        size: 32,
                        color: isCafe ? Colors.orange.shade700 : Colors.indigo.shade700,
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.people_alt_outlined,
                                  size: 16, color: Colors.grey.shade700),
                              const SizedBox(width: 4),
                              Text(
                                '$waiting waiting',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.grey.shade700),
                              const SizedBox(width: 4),
                              Text(
                                '~${dept.avgServiceMinutes} min/person',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MyTicketView extends StatelessWidget {
  final Ticket ticket;

  const _MyTicketView({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>();
    final ahead = queue.peopleAhead(ticket);
    final waitMin = queue.estimatedWaitMinutes(ticket);
    final isCalled = ticket.status == TicketStatus.called;
    final isCafe = ticket.departmentId == 'cafe';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Department Badge & Header
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: isCafe ? Colors.orange.shade100 : Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCafe ? Icons.local_cafe : Icons.business,
                  color: isCafe ? Colors.orange.shade900 : Colors.indigo.shade900,
                ),
                const SizedBox(width: 8),
                Text(
                  ticket.departmentName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCafe ? Colors.orange.shade900 : Colors.indigo.shade900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Main Ticket Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_rounded,
                          size: 18, color: Colors.grey.shade700),
                      const SizedBox(width: 6),
                      Text(
                        ticket.userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your Ticket Number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      ticket.formattedNumber,
                      key: ValueKey(ticket.formattedNumber),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: isCalled
                            ? Colors.green.shade700
                            : Theme.of(context).colorScheme.primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                        label: 'People Ahead',
                        value: isCalled ? '0' : '$ahead',
                        icon: Icons.groups_outlined,
                        color: Colors.blue.shade700,
                      ),
                      _StatChip(
                        label: 'Est. Wait',
                        value: isCalled ? 'Now!' : '$waitMin min',
                        icon: Icons.timer_outlined,
                        color: Colors.orange.shade700,
                      ),
                      _StatChipWidget(
                        label: 'Time Waiting',
                        icon: Icons.hourglass_bottom_rounded,
                        color: Colors.teal.shade700,
                        child: LiveWaitTimer(
                          joinedAt: ticket.joinedAt,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Called Banner Notification
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isCalled ? 1.0 : (ahead == 0 ? 1.0 : 0.85),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCalled ? Colors.green.shade100 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCalled ? Colors.green.shade400 : Colors.blue.shade200,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCalled
                        ? Icons.notifications_active_rounded
                        : Icons.info_outline,
                    color: isCalled ? Colors.green.shade800 : Colors.blue.shade800,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      isCalled
                          ? 'IT IS YOUR TURN, ${ticket.userName.toUpperCase()}! Please proceed immediately to the counter.'
                          : (ahead == 0
                              ? 'You are next in line, ${ticket.userName}! Please stay ready.'
                              : 'Your ticket is active. Please wait for your number.'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isCalled ? Colors.green.shade900 : Colors.blue.shade900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Cancel Ticket Button
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cancel Ticket?'),
                  content: Text(
                    'Are you sure you want to cancel ticket #${ticket.formattedNumber}? You will lose your position in line.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Keep Ticket'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                      ),
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _StatChipWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Widget child;

  const _StatChipWidget({
    required this.label,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 6),
        child,
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

/// Live timer widget using Timer.periodic to update elapsed wait duration every second
class LiveWaitTimer extends StatefulWidget {
  final DateTime joinedAt;
  final TextStyle? style;

  const LiveWaitTimer({
    super.key,
    required this.joinedAt,
    this.style,
  });

  @override
  State<LiveWaitTimer> createState() => _LiveWaitTimerState();
}

class _LiveWaitTimerState extends State<LiveWaitTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(widget.joinedAt);
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');

    return Text(
      '${mStr}m ${sStr}s',
      style: widget.style ?? const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
