import 'package:flutter/material.dart';
import 'staff_home_screen.dart';

/// Predefined demo credentials for Management Section
class ManagementCredentials {
  static const Map<String, Map<String, String>> accounts = {
    'cafe': {
      'password': '123',
      'deptId': 'cafe',
      'label': 'Café Management',
    },
    'adminoffice': {
      'password': '123',
      'deptId': 'admin_office',
      'label': 'Administration Office Management',
    },
  };
}

class ManagementLoginScreen extends StatefulWidget {
  const ManagementLoginScreen({super.key});

  @override
  State<ManagementLoginScreen> createState() => _ManagementLoginScreenState();
}

class _ManagementLoginScreenState extends State<ManagementLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'cafe');
  final _passwordController = TextEditingController(text: '123');
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    setState(() => _errorMessage = null);

    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim().toLowerCase();
      final password = _passwordController.text.trim();

      if (ManagementCredentials.accounts.containsKey(username) &&
          ManagementCredentials.accounts[username]!['password'] == password) {
        final deptId = ManagementCredentials.accounts[username]!['deptId']!;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => StaffHomeScreen(departmentId: deptId),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Invalid credentials. Please use demo credentials shown below.';
        });
      }
    }
  }

  void _quickFill(String username) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = '123';
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Login'),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Header
              Container(
                padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              Text(
                'Department Management',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Log in to manage live departmental queues',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 28),

              // Login Form Card
              Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: Colors.red.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'cafe or adminoffice',
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
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _login,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.login_rounded),
                          label: const Text(
                            'Login to Management',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Demo Credentials Helper Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.teal.shade800),
                        const SizedBox(width: 8),
                        Text(
                          'Demo Credentials (Tap to Auto-fill)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ActionChip(
                            avatar: const Icon(Icons.local_cafe, size: 16),
                            label: const Text('Café (cafe / 123)'),
                            onPressed: () => _quickFill('cafe'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ActionChip(
                            avatar: const Icon(Icons.business, size: 16),
                            label: const Text('Admin (adminoffice / 123)'),
                            onPressed: () => _quickFill('adminoffice'),
                          ),
                        ),
                      ],
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
