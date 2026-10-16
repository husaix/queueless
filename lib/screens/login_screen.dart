import 'package:flutter/material.dart';
import 'user_home_screen.dart';
import 'staff_home_screen.dart';
import 'admin_home_screen.dart';

enum UserRole { user, management, admin }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectRole(UserRole role) async {
    setState(() => _isLoading = true);

    // Simple buffer / loading delay for polish
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    Widget nextScreen;
    switch (role) {
      case UserRole.user:
        nextScreen = const UserHomeScreen();
        break;
      case UserRole.management:
        nextScreen = const StaffHomeScreen();
        break;
      case UserRole.admin:
        nextScreen = const AdminHomeScreen();
        break;
    }

    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.9),
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    // App logo / title
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.queue_play_next_rounded,
                        size: 64,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'QueueLess',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Smart Virtual Queue Management',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    // Role selection cards
                    _RoleCard(
                      icon: Icons.person_outline_rounded,
                      title: 'User',
                      subtitle: 'Join a queue & track your ticket',
                      color: Colors.blue.shade600,
                      onTap: _isLoading ? null : () => _selectRole(UserRole.user),
                    ),
                    const SizedBox(height: 14),
                    _RoleCard(
                      icon: Icons.support_agent_rounded,
                      title: 'Management',
                      subtitle: 'Manage your department queue',
                      color: Colors.teal.shade600,
                      onTap: _isLoading
                          ? null
                          : () => _selectRole(UserRole.management),
                    ),
                    const SizedBox(height: 14),
                    _RoleCard(
                      icon: Icons.admin_panel_settings_rounded,
                      title: 'Admin',
                      subtitle: 'Overview & performance of all queues',
                      color: Colors.deepPurple.shade600,
                      onTap: _isLoading
                          ? null
                          : () => _selectRole(UserRole.admin),
                    ),
                    const SizedBox(height: 32),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 24),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Loading...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 64),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: onTap == null ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
