import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedalya_mobile/services/api_service.dart';

class Register extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogin;
  final VoidCallback onDone;

  const Register({
    super.key,
    required this.onBack,
    required this.onLogin,
    required this.onDone,
  });

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();
XFile? selectedIdImage;

final TextEditingController nameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmPasswordController =
    TextEditingController();

    @override
void dispose() {
  nameController.dispose();
  emailController.dispose();
  phoneController.dispose();
  passwordController.dispose();
  confirmPasswordController.dispose();
  super.dispose();
}

Future<void> _pickIdFromGallery() async {
  final image = await _imagePicker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 85,
    maxWidth: 1600,
  );

  if (image == null || !mounted) return;

  setState(() {
    selectedIdImage = image;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('ID image selected successfully.'),
    ),
  );
}

Future<void> _pickIdFromCamera() async {
  final image = await _imagePicker.pickImage(
    source: ImageSource.camera,
    imageQuality: 85,
    maxWidth: 1600,
  );

  if (image == null || !mounted) return;

  setState(() {
    selectedIdImage = image;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('ID photo captured successfully.'),
    ),
  );
}

Future<void> _register() async {
  final name = nameController.text.trim();
  final email = emailController.text.trim();
  final phone = phoneController.text.trim();
  final password = passwordController.text;
  final confirmPassword = confirmPasswordController.text;

  if (name.isEmpty ||
      email.isEmpty ||
      password.isEmpty ||
      confirmPassword.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please complete all required fields.'),
      ),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Passwords do not match.'),
      ),
    );
    return;
  }

  if (selectedIdImage == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Please upload a valid ID before creating your account.',
      ),
    ),
  );
  return;
}

  setState(() {
    isLoading = true;
  });

  try {
    final result = await ApiService.register(
      name: name,
      email: email,
      phoneNumber: phone,
      password: password,
      passwordConfirmation: confirmPassword,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

if (result['success'] == true) {
  final uploadResult =
      await ApiService.uploadIdVerification(
    selectedIdImage!.path,
  );

  if (!mounted) return;

  if (uploadResult['success'] != true) {
    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          uploadResult['message']?.toString() ??
              'Account created, but ID upload failed.',
        ),
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Account created. Your ID is pending verification.',
      ),
    ),
  );

  widget.onDone();
}
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                'Unable to create account.',
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
      backgroundColor: const Color(0xFF080A15),
      body: Stack(
        children: [
          // =========================================
          // BACKGROUND
          // =========================================

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.45, 0.35, 0.30, 0, -25,
                0.30, 0.45, 0.30, 0, -25,
                0.30, 0.35, 0.45, 0, -25,
                0,    0,    0,    1,   0,
              ]),
              child: Image.asset(
                'assets/images/normal_bike.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x55070A14),
                    Color(0xAA080A15),
                    Color(0xFF080A15),
                  ],
                ),
              ),
            ),
          ),

          // =========================================
          // CONTENT
          // =========================================

          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                22,
                18,
                22,
                32,
              ),
              children: [
                // BACK
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white70,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 42),

                // BRAND
                const Text(
                  'PEDALYA',
                  style: TextStyle(
                    color: Color(0xFF80D6D4),
                    fontSize: 10,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                // TITLE
                const Text(
                  'JOIN THE RIDE.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 39,
                    height: 0.95,
                    letterSpacing: -1.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const Text(
                  'LET\'S GET YOU READY.',
                  style: TextStyle(
                    color: Color(0xFFAAD9BB),
                    fontSize: 32,
                    height: 1,
                    letterSpacing: -1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 13),

                const Text(
                  'Create your Pedalya rider account and start exploring.',
                  style: TextStyle(
                    color: Color(0xFFC4C6D0),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 34),

                // =========================================
                // PERSONAL DETAILS CARD
                // =========================================

                Container(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    22,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1D31),
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.07,
                      ),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x44000000),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF80D6D4),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'PERSONAL DETAILS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _RegisterField(
  label: 'FULL NAME',
  icon: Icons.person_outline_rounded,
  hintText: 'Enter your full name',
  controller: nameController,
),

                      const SizedBox(height: 17),

                       _RegisterField(
  label: 'EMAIL',
  icon: Icons.mail_outline_rounded,
  hintText: 'rider@email.com',
  keyboardType: TextInputType.emailAddress,
  controller: emailController,
),

                      const SizedBox(height: 17),

                      _RegisterField(
  label: 'MOBILE NUMBER',
  icon: Icons.phone_outlined,
  hintText: '09XX XXX XXXX',
  keyboardType: TextInputType.phone,
  controller: phoneController,
),

                      const SizedBox(height: 17),

                      _RegisterField(
                        label: 'PASSWORD',
                        icon: Icons.lock_outline_rounded,
                        hintText: 'Create a password',
                        controller: passwordController,
                        obscureText: obscurePassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: const Color(0xFF9699AA),
                          ),
                        ),
                      ),

                      const SizedBox(height: 17),

                      _RegisterField(
                        label: 'CONFIRM PASSWORD',
                        icon: Icons.lock_outline_rounded,
                        hintText: 'Re-enter your password',
                        controller: confirmPasswordController,
                        obscureText:
                            obscureConfirmPassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword =
                                  !obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: const Color(0xFF9699AA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =========================================
                // ID VERIFICATION CARD
                // =========================================

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1D31),
                    borderRadius: BorderRadius.circular(27),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.07,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF292D43),
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.badge_outlined,
                              color: Color(0xFFAAD9BB),
                            ),
                          ),

                          const SizedBox(width: 11),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Identity verification',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Valid government-issued ID',
                                  style: TextStyle(
                                    color:
                                        Color(0xFF9EA0AF),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF31364A),
                              borderRadius:
                                  BorderRadius.circular(30),
                            ),
                            child: const Text(
                              'REQUIRED',
                              style: TextStyle(
                                color: Color(0xFFF9F7C9),
                                fontSize: 8,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 17),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25283B),
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.07,
                            ),
                          ),
                        ),
                 child: selectedIdImage == null
    ? const Column(
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            color: Color(0xFF80BCBD),
            size: 34,
          ),
          SizedBox(height: 9),
          Text(
            'Upload your valid ID',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Make sure your name and photo are clearly visible.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9EA0AF),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      )
    : Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFFAAD9BB),
            size: 34,
          ),
          const SizedBox(height: 9),
          const Text(
            'ID image selected',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            selectedIdImage!.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9EA0AF),
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
                      ),

                      const SizedBox(height: 13),

                      Row(
                        children: [
                          Expanded(
                            child: _RegisterUploadButton(
                              icon: Icons
                                  .photo_library_outlined,
                              label: 'Gallery',
                             onTap: _pickIdFromGallery,
                            ),
                          ),

                          const SizedBox(width: 9),

                          Expanded(
                            child: _RegisterUploadButton(
                              icon:
                                  Icons.camera_alt_outlined,
                              label: 'Camera',
                              onTap: _pickIdFromCamera,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // INFO MESSAGE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF13262A),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: const Color(0xFF80BCBD)
                          .withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF80D6D4),
                        size: 20,
                      ),

                      SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          'Your ID must be verified before you can start renting a bicycle.',
                          style: TextStyle(
                            color: Color(0xFFC7CAD2),
                            fontSize: 11,
                            height: 1.45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // =========================================
                // CREATE ACCOUNT BUTTON
                // =========================================

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                   onPressed: isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFAAD9BB),
                      foregroundColor:
                          const Color(0xFF171827),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),

                        SizedBox(width: 8),

                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN LINK
                Center(
                  child: GestureDetector(
                    onTap: widget.onLogin,
                    child: const Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Color(0xFFB8BAC7),
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text:
                                'Already have an account? ',
                          ),
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color:
                                  Color(0xFF9EE2DE),
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hintText;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextEditingController controller;

  const _RegisterField({
    required this.label,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFFC857),
              size: 14,
            ),

            const SizedBox(width: 7),

            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB9BBC9),
                fontSize: 10,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),
TextField(
  controller: controller,
  obscureText: obscureText,
  keyboardType: keyboardType,
  style: const TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF8E91A2),
              fontSize: 13,
            ),
            suffixIcon: suffix,

            filled: true,
            fillColor: const Color(0xFF2A2D43),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 17,
              vertical: 17,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: const BorderSide(
                color: Color(0xFF80BCBD),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterUploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RegisterUploadButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              const Color(0xFF9EE2DE),

          side: BorderSide(
            color: const Color(0xFF80BCBD)
                .withValues(alpha: 0.50),
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}