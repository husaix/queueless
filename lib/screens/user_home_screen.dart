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
            title: const Text('QueueLess – User'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Back to login',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
          body: ticket != null && ticket.status == TicketStatus.waiting
              ? _MyTicketView(ticket: ticket)
              : const _SelectServiceView(),
        );
      },
    );
  }
}

class _SelectServiceView extends StatelessWidget {
  const _SelectServiceView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Choose a service',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tap a department to join its virtual queue.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        ...Departments.all.map((dept) {
          final waiting = context.watch<QueueService>().currentWaitingCount(dept.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  _iconFor(dept.id),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                dept.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '$waiting waiting · ~${dept.avgServiceMinutes} min each',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final service = context.read<QueueService>();
                service.joinQueue(dept.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Joined ${dept.name} queue'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  IconData _iconFor(String id) {
    switch (id) {
      case 'student_affairs':
        return Icons.school_outlined;
      case 'canteen':
        return Icons.restaurant_outlined;
      case 'library':
        return Icons.local_library_outlined;
      case 'clinic':
        return Icons.local_hospital_outlined;
      case 'admin_office':
        return Icons.business_outlined;
      default:
        return Icons.queue;
    }
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

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    ticket.departmentName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Ticket',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${ticket.number}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatChip(
                        label: 'People ahead',
                        value: '$ahead',
                        icon: Icons.people_outline,
                      ),
                      _StatChip(
                        label: 'Est. wait',
                        value: '$waitMin min',
                        icon: Icons.timer_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (ahead == 0)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are next! Please proceed to the counter when called.',
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                  ),
                ],
              ),
            ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Leave queue?'),
                  content: const Text(
                      'Your ticket will be cancelled and you will lose your place.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Keep waiting'),
                    ),
                    FilledButton(
                      onPressed: () {
                        context.read<QueueService>().cancelTicket(ticket);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Cancel ticket'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Cancel my ticket'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 14),
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

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
