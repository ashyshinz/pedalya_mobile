import 'package:flutter/material.dart';
import 'package:pedalya_mobile/services/api_service.dart';
import 'package:pedalya_mobile/screens/auth/forgot_password_screen.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onRegister;
  final VoidCallback onDone;

  const LoginPage({
    super.key,
    required this.onBack,
    required this.onRegister,
    required this.onDone,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscurePassword = true;
  bool isLoading = false;

final TextEditingController emailController =
    TextEditingController();

final TextEditingController passwordController =
    TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
  final email = emailController.text.trim();
  final password = passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your email and password.'),
      ),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    final result = await ApiService.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      widget.onDone();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Unable to sign in.',
          ),
        ),
      );
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not connect to Pedalya. Please try again.',
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B16),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/PEDAL.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x66070B16),
                    Color(0xB3070B16),
                    Color(0xF5070B16),
                    Color(0xFF050814),
                  ],
                  stops: [0.0, 0.35, 0.68, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Align(
  alignment: Alignment.centerLeft,
  child: InkWell(
    onTap: widget.onBack,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      child: const Icon(
        Icons.arrow_back_rounded,
        color: Colors.white70,
        size: 21,
      ),
    ),
  ),
),



                  const SizedBox(height: 220),

RichText(
  text: const TextSpan(
    children: [
      TextSpan(
        text: 'WELCOME BACK,\n',
        style: TextStyle(
          color: Colors.white,
          fontSize: 41,
          height: 0.93,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
        ),
      ),
      TextSpan(
        text: 'RIDER',
        style: TextStyle(
          color: Color(0xFFAAD9BB),
          fontSize: 41,
          height: 0.93,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.5,
        ),
      ),
      TextSpan(
        text: ' 👋',
        style: TextStyle(
          fontSize: 34,
        ),
      ),
    ],
  ),
),

const SizedBox(height: 14),

const Text(
  'Where are we going today?',
  style: TextStyle(
    color: Color(0xFFC7CAD7),
    fontSize: 14,
    fontWeight: FontWeight.w500,
  ),
),

const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1F37).withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 24,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LoginField(
                          label: 'EMAIL',
                          icon: Icons.email_outlined,
                          hintText: 'rider@pedalya.com',
                          controller: emailController,
                        ),

                        const SizedBox(height: 15),

                        _LoginField(
                          label: 'PASSWORD',
                          icon: Icons.lock_outline_rounded,
                          hintText: '••••••••',
                          controller: passwordController,
                          obscureText: obscurePassword,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: const Color(0xFF9CA3B2),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                            Navigator.push(
                            context,
                             MaterialPageRoute(
                              builder: (context) =>
                            const ForgotPasswordScreen(),
                                  ),
                                   );
                                    },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFF9EE2DE),
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFAAD9BB),
                              foregroundColor: const Color(0xFF182236),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                           child: isLoading
    ? const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Color(0xFF182236),
        ),
      )
    : const Text(
        'Sign In →',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
                          ),
                        ),
                      ],
                    ),
                  ),

const SizedBox(height: 26),

Center(
  child: Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      const Text(
        'New here? ',
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFFB9BDD0),
          fontWeight: FontWeight.w500,
        ),
      ),
      GestureDetector(
        onTap: widget.onRegister,
        child: const Text(
          'Create an account',
          style: TextStyle(
            fontSize: 15,
            color: Color(0xFF9EE2DE),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  ),
),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;

  const _LoginField({
    required this.label,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFFFFC857)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB9BED0),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFF2B2F47),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFF80BCBD),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
