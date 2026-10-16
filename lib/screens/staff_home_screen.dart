import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/department.dart';
import '../models/ticket.dart';
import '../services/queue_service.dart';
import 'login_screen.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  String? _selectedDeptId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QueueLess – Management'),
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
      body: _selectedDeptId == null
          ? _buildDepartmentPicker()
          : _buildQueuePanel(_selectedDeptId!),
    );
  }

  Widget _buildDepartmentPicker() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Select your department',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'You will only see and manage the queue for this department.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        ...Departments.all.map((dept) {
          final waiting =
              context.watch<QueueService>().currentWaitingCount(dept.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade50,
                child: Icon(Icons.desk, color: Colors.teal.shade700),
              ),
              title: Text(
                dept.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('$waiting people waiting'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => _selectedDeptId = dept.id),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQueuePanel(String deptId) {
    final dept = Departments.byId(deptId)!;
    final queue = context.watch<QueueService>();
    final waiting = queue.waitingTickets(deptId);
    final called = queue
        .allTickets(deptId)
        .where((t) => t.status == TicketStatus.called)
        .toList();

    return Column(
      children: [
        // Header bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedDeptId = null),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dept.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${waiting.length} waiting',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: waiting.isEmpty
                    ? null
                    : () {
                        final next = queue.callNext(deptId);
                        if (next != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Calling ticket #${next.number}'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('Call Next'),
              ),
            ],
          ),
        ),
        // Called tickets (if any)
        if (called.isNotEmpty)
          Container(
            width: double.infinity,
            color: Colors.orange.shade50,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Currently called',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                ...called.map((t) => _TicketTile(
                      ticket: t,
                      isCalled: true,
                      onServe: () => queue.markServed(t),
                      onSkip: () => queue.skipTicket(t),
                    )),
              ],
            ),
          ),
        // Waiting list
        Expanded(
          child: waiting.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No one waiting right now',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: waiting.length,
                  itemBuilder: (context, index) {
                    final t = waiting[index];
                    return _TicketTile(
                      ticket: t,
                      position: index + 1,
                      onSkip: () => queue.skipTicket(t),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TicketTile extends StatelessWidget {
  final Ticket ticket;
  final int? position;
  final bool isCalled;
  final VoidCallback? onServe;
  final VoidCallback? onSkip;

  const _TicketTile({
    required this.ticket,
    this.position,
    this.isCalled = false,
    this.onServe,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCalled ? Colors.orange.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCalled
              ? Colors.orange.shade200
              : Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            '#${ticket.number}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        title: Text(
          isCalled ? 'Ticket #${ticket.number} (called)' : 'Ticket #${ticket.number}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          position != null
              ? 'Position $position · joined ${_formatTime(ticket.joinedAt)}'
              : 'Joined ${_formatTime(ticket.joinedAt)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onServe != null)
              IconButton(
                icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                tooltip: 'Mark served',
                onPressed: onServe,
              ),
            if (onSkip != null)
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

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
