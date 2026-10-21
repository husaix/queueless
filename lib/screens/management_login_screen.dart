import 'package:flutter/material.dart';
import '../models/department.dart';
import 'staff_home_screen.dart';

/// Predefined Management Demo Credentials
class ManagementCredentials {
  static const String cafeUser = 'cafe';
  static const String cafePass = '123';

  static const String adminOfficeUser = 'admin_office';
  static const String adminOfficePass = '123';
}

class ManagementLoginScreen extends StatefulWidget {
  const ManagementLoginScreen({super.key});

  @override
  State<ManagementLoginScreen> createState() => _ManagementLoginScreenState();
}

class _ManagementLoginScreenState extends State<ManagementLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _autofillDemo(String username, String password) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = password;
      _errorMessage = null;
    });
  }

  void _handleLogin() {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();

    String? targetDeptId;

    if (user == ManagementCredentials.cafeUser &&
        pass == ManagementCredentials.cafePass) {
      targetDeptId = Departments.cafeId;
    } else if (user == ManagementCredentials.adminOfficeUser &&
        pass == ManagementCredentials.adminOfficePass) {
      targetDeptId = Departments.adminOfficeId;
    }

    if (targetDeptId != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => StaffHomeScreen(departmentId: targetDeptId!),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid username or password. Please try demo credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Login'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // Header Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    size: 54,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Staff Portal',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Log in to operate your department queue',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'e.g. cafe or admin_office',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'e.g. 123',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Login Button
              FilledButton(
                onPressed: _handleLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Log In to Dashboard',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 32),

              // Quick Demo Credentials Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.key_outlined, size: 18, color: Colors.teal.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Demo Accounts (Tap to autofill):',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DemoChip(
                      label: 'Café Staff',
                      credentials: 'cafe / 123',
                      color: Colors.amber.shade700,
                      onTap: () => _autofillDemo(
                        ManagementCredentials.cafeUser,
                        ManagementCredentials.cafePass,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DemoChip(
                      label: 'Administration Office Staff',
                      credentials: 'admin_office / 123',
                      color: Colors.indigo.shade700,
                      onTap: () => _autofillDemo(
                        ManagementCredentials.adminOfficeUser,
                        ManagementCredentials.adminOfficePass,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoChip extends StatelessWidget {
  final String label;
  final String credentials;
  final Color color;
  final VoidCallback onTap;

  const _DemoChip({
    required this.label,
    required this.credentials,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'User: ${credentials.split(' / ')[0]}  |  Pass: ${credentials.split(' / ')[1]}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            Icon(Icons.touch_app_outlined, size: 18, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}
