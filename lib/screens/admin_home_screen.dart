import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/department.dart';
import '../services/queue_service.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Analytics Dashboard'),
        backgroundColor: Colors.deepPurple.shade800,
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
          final totalGenerated = queue.totalTicketsGenerated;
          final cafeTickets = queue.totalCafeTickets;
          final adminOfficeTickets = queue.totalAdminOfficeTickets;
          final totalWaiting = queue.totalWaitingTickets;
          final totalCalled = queue.totalCalledTickets;
          final totalServed = queue.totalServedTickets;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header description
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'System Statistics Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Read-only live queue monitoring',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Key Overview Stat Cards (Grid)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _SummaryStatCard(
                    title: 'Total Generated',
                    value: '$totalGenerated',
                    icon: Icons.confirmation_number_outlined,
                    color: Colors.purple.shade700,
                    bgColor: Colors.purple.shade50,
                  ),
                  _SummaryStatCard(
                    title: 'Currently Waiting',
                    value: '$totalWaiting',
                    icon: Icons.hourglass_empty_rounded,
                    color: Colors.orange.shade700,
                    bgColor: Colors.orange.shade50,
                  ),
                  _SummaryStatCard(
                    title: 'Currently Called',
                    value: '$totalCalled',
                    icon: Icons.campaign_outlined,
                    color: Colors.blue.shade700,
                    bgColor: Colors.blue.shade50,
                  ),
                  _SummaryStatCard(
                    title: 'Total Completed',
                    value: '$totalServed',
                    icon: Icons.task_alt_rounded,
                    color: Colors.green.shade700,
                    bgColor: Colors.green.shade50,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Department Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Café Breakdown Card
              _DepartmentBreakdownCard(
                dept: Departments.cafe,
                totalTickets: cafeTickets,
                waitingCount: queue.currentWaitingCount(Departments.cafe.id),
                calledCount: queue.currentCalledCount(Departments.cafe.id),
                servedCount: queue.totalServedCount(Departments.cafe.id),
                accentColor: Colors.orange.shade800,
                icon: Icons.local_cafe_rounded,
              ),

              const SizedBox(height: 12),

              // Administration Office Breakdown Card
              _DepartmentBreakdownCard(
                dept: Departments.adminOffice,
                totalTickets: adminOfficeTickets,
                waitingCount:
                    queue.currentWaitingCount(Departments.adminOffice.id),
                calledCount:
                    queue.currentCalledCount(Departments.adminOffice.id),
                servedCount:
                    queue.totalServedCount(Departments.adminOffice.id),
                accentColor: Colors.indigo.shade800,
                icon: Icons.business_rounded,
              ),

              const SizedBox(height: 24),

              // Admin Read-only Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 20, color: Colors.grey.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Read-only view: Administrator mode is restricted to viewing queue metrics only.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _SummaryStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                value,
                key: ValueKey(value),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentBreakdownCard extends StatelessWidget {
  final Department dept;
  final int totalTickets;
  final int waitingCount;
  final int calledCount;
  final int servedCount;
  final Color accentColor;
  final IconData icon;

  const _DepartmentBreakdownCard({
    required this.dept,
    required this.totalTickets,
    required this.waitingCount,
    required this.calledCount,
    required this.servedCount,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    dept.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalTickets Total',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DeptMetricItem(
                  label: 'Waiting',
                  value: '$waitingCount',
                  color: Colors.orange.shade800,
                ),
                _DeptMetricItem(
                  label: 'Called',
                  value: '$calledCount',
                  color: Colors.blue.shade800,
                ),
                _DeptMetricItem(
                  label: 'Served',
                  value: '$servedCount',
                  color: Colors.green.shade800,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeptMetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DeptMetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            value,
            key: ValueKey(value),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
