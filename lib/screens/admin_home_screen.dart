import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/department.dart';
import '../services/queue_service.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueService>(
      builder: (context, queue, _) {
        final totalGenerated = queue.totalTicketsGenerated;
        final cafeTotal = queue.departmentTotalTickets(Departments.cafeId);
        final adminOfficeTotal = queue.departmentTotalTickets(Departments.adminOfficeId);
        final totalWaiting = queue.totalWaitingCount;
        final totalCompleted = queue.totalCompletedCount;

        final cafeWaiting = queue.departmentWaitingCount(Departments.cafeId);
        final cafeServed = queue.departmentServedCount(Departments.cafeId);

        final adminOfficeWaiting = queue.departmentWaitingCount(Departments.adminOfficeId);
        final adminOfficeServed = queue.departmentServedCount(Departments.adminOfficeId);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple.shade800,
            foregroundColor: Colors.white,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Admin Dashboard',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'System Overview & Read-Only Analytics',
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Read-Only Banner Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_rounded,
                          color: Colors.deepPurple.shade700, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Read-Only Mode: Real-time system statistics for monitored departments.',
                          style: TextStyle(
                            color: Colors.deepPurple.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Overall Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Top Key Metric Cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Generated',
                        value: '$totalGenerated',
                        icon: Icons.confirmation_number_rounded,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Currently Waiting',
                        value: '$totalWaiting',
                        icon: Icons.hourglass_top_rounded,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Completed',
                        value: '$totalCompleted',
                        icon: Icons.check_circle_rounded,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Active Departments',
                        value: '2',
                        icon: Icons.business_rounded,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                Text(
                  'Department Performance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),

                // Department 1: Café Analytics
                _DepartmentStatCard(
                  name: 'Café',
                  icon: Icons.local_cafe_rounded,
                  color: Colors.amber.shade800,
                  totalGenerated: cafeTotal,
                  waitingCount: cafeWaiting,
                  servedCount: cafeServed,
                ),

                const SizedBox(height: 16),

                // Department 2: Administration Office Analytics
                _DepartmentStatCard(
                  name: 'Administration Office',
                  icon: Icons.account_balance_rounded,
                  color: Colors.indigo.shade700,
                  totalGenerated: adminOfficeTotal,
                  waitingCount: adminOfficeWaiting,
                  servedCount: adminOfficeServed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                value,
                key: ValueKey(value),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentStatCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final int totalGenerated;
  final int waitingCount;
  final int servedCount;

  const _DepartmentStatCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.totalGenerated,
    required this.waitingCount,
    required this.servedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SubStat(
                  label: 'Tickets Created',
                  value: '$totalGenerated',
                  color: Colors.black87,
                ),
                _SubStat(
                  label: 'Waiting',
                  value: '$waitingCount',
                  color: Colors.orange.shade800,
                ),
                _SubStat(
                  label: 'Served',
                  value: '$servedCount',
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SubStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            value,
            key: ValueKey(value),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
