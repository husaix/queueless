import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/department.dart';
import '../services/queue_service.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final queue = context.watch<QueueService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('QueueLess – Admin'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'All Departments Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Live queue counts and service performance.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ...Departments.all.map((dept) {
            final waiting = queue.currentWaitingCount(dept.id);
            final served = queue.servedToday(dept.id);
            final avgMin = queue.averageServiceMinutes(dept.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade50,
                          child: Icon(
                            Icons.business_center_outlined,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            dept.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: waiting > 5
                                ? Colors.red.shade50
                                : waiting > 2
                                    ? Colors.orange.shade50
                                    : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$waiting waiting',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: waiting > 5
                                  ? Colors.red.shade800
                                  : waiting > 2
                                      ? Colors.orange.shade800
                                      : Colors.green.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _Metric(
                          label: 'Served',
                          value: '$served',
                          icon: Icons.check_circle_outline,
                        ),
                        const SizedBox(width: 24),
                        _Metric(
                          label: 'Avg. time',
                          value: served == 0
                              ? '—'
                              : '${avgMin.toStringAsFixed(1)} min',
                          icon: Icons.speed_outlined,
                        ),
                        const SizedBox(width: 24),
                        _Metric(
                          label: 'Target',
                          value: '${dept.avgServiceMinutes} min',
                          icon: Icons.flag_outlined,
                        ),
                      ],
                    ),
                    if (served > 0) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (dept.avgServiceMinutes /
                                (avgMin > 0 ? avgMin : 1))
                            .clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        color: avgMin <= dept.avgServiceMinutes
                            ? Colors.green
                            : Colors.orange,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        avgMin <= dept.avgServiceMinutes
                            ? 'On or under target'
                            : 'Slower than target',
                        style: TextStyle(
                          fontSize: 12,
                          color: avgMin <= dept.avgServiceMinutes
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Metric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }
}
