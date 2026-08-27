import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedalya_mobile/core/theme/app_colors.dart';
import 'package:pedalya_mobile/services/api_service.dart';


class Profile extends StatefulWidget {
  final VoidCallback onLogout;

  const Profile({
    super.key,
    required this.onLogout,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
void initState() {
  super.initState();
  _refreshProfile();
}

Future<void> _refreshProfile() async {
  final result = await ApiService.getProfile();

  if (!mounted) return;

  if (result['success'] == true) {
    setState(() {});
  }
}


  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

final String name =
    user?['name']?.toString() ?? 'Pedalya Rider';

final String email =
    user?['email']?.toString() ?? 'No email';

final String phone =
    user?['phoneNumber']?.toString() ?? 'No mobile number';

final bool isVerified =
    user?['verified'] == true ||
    user?['verified'] == 1 ||
    user?['verified']?.toString() == '1';

    final bool idUploaded =
    user?['idUploaded'] == true ||
    user?['idUploaded'] == 1 ||
    user?['idUploaded']?.toString() == '1';

final Map<String, dynamic> idVerification =
    user?['idVerification'] is Map
        ? Map<String, dynamic>.from(
            user!['idVerification'] as Map,
          )
        : <String, dynamic>{};

final String verificationStatus = isVerified
    ? 'approved'
    : idVerification['status']?.toString().toLowerCase() ??
        (idUploaded ? 'pending' : 'not_uploaded');

final String verificationReason =
    idVerification['reason']?.toString() ?? '';

    return Container(
      color: const Color(0xFF0B0D18),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          28,
          20,
          30,
        ),
        children: [
          // =========================================
          // HEADER
          // =========================================

          const Text(
            'Your profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Manage your rider information and account.',
            style: TextStyle(
              color: Color(0xFF9699A8),
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 26),

          // =========================================
          // PROFILE HERO CARD
          // =========================================

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF173033),
                  Color(0xFF20243A),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xFF80BCBD)
                    .withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              children: [
                // AVATAR
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFF292D43),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFAAD9BB),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: Color(0xFFAAD9BB),
                      ),
                    ),
                  if (isVerified)
                    Positioned(
                      right: -2,
                      bottom: 2,
                      child: Container(
                        width: 27,
                        height: 27,
                        decoration: BoxDecoration(
                          color: const Color(0xFFAAD9BB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF20243A),
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF171827),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Pedalya Rider',
                  style: TextStyle(
                    color: Color(0xFF9699A8),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 12),

               Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 11,
    vertical: 6,
  ),
  decoration: BoxDecoration(
    color: isVerified
        ? const Color(0xFF16312C)
        : const Color(0xFF2D2525),
    borderRadius: BorderRadius.circular(30),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        isVerified
            ? Icons.verified_rounded
            : Icons.info_outline_rounded,
        color: isVerified
            ? const Color(0xFFAAD9BB)
            : const Color(0xFFFFB4A9),
        size: 14,
      ),
      const SizedBox(width: 5),
      Text(
        isVerified ? 'VERIFIED RIDER' : 'NOT VERIFIED',
        style: TextStyle(
          color: isVerified
              ? const Color(0xFFAAD9BB)
              : const Color(0xFFFFB4A9),
          fontSize: 9,
          letterSpacing: 0.7,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  ),
),
              ],
            ),
          ),

          const SizedBox(height: 27),

          // =========================================
          // PERSONAL INFORMATION
          // =========================================

          const Text(
            'Personal information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
            child: Column(
              children: [
                _DarkProfileDetail(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: email,
                ),

                _ProfileDivider(),

                _DarkProfileDetail(
                  icon: Icons.phone_outlined,
                  label: 'Mobile number',
                  value: phone,
                ),

                _ProfileDivider(),

                _DarkProfileDetail(
                 icon: Icons.badge_outlined,
                 label: 'ID verification',
                value: verificationStatus == 'approved'
                 ? 'Verified'
                  : verificationStatus == 'pending'
                   ? 'Pending verification'
                   : verificationStatus == 'rejected'
                      ? verificationReason.isNotEmpty
                  ? 'Rejected — $verificationReason'
                  : 'Rejected'
              : 'ID required',
             verified: isVerified,
               ),

               if (verificationStatus == 'not_uploaded' ||
                verificationStatus == 'rejected') ...[
               const _ProfileDivider(),
              _ProfileMenuItem(
               icon: Icons.upload_file_rounded,
               title: verificationStatus == 'rejected'
               ? 'Re-upload ID'
               : 'Upload ID',
                subtitle: verificationStatus == 'rejected'
               ? 'Submit another valid ID for review'
                : 'Submit a valid government-issued ID',
                onTap: _showIdUploadOptions,
                  ),
                ],

              ],
            ),
          ),

          const SizedBox(height: 27),

          // =========================================
          // ACCOUNT
          // =========================================

          const Text(
            'Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D2E),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.06,
                ),
              ),
            ),
            child: Column(
              children: [
               _ProfileMenuItem(
  icon: Icons.edit_outlined,
  title: 'Edit profile',
  subtitle: 'Update your personal details',
  onTap: () => _showEditProfileDialog(
    context,
    name: name,
    email: email,
    phone: phone,
    address: user?['address']?.toString() ?? '',
  ),
),

const _ProfileDivider(),

_ProfileMenuItem(
  icon: Icons.lock_outline_rounded,
  title: 'Change password',
  subtitle: 'Keep your account secure',
  onTap: () => _showChangePasswordDialog(context),
),

const _ProfileDivider(),

_ProfileMenuItem(
  icon: Icons.help_outline_rounded,
  title: 'Help & support',
  subtitle: 'Get assistance',
  onTap: () => _showHelpSupportDialog(context),
),

const SizedBox(height: 18),

// =========================================
// SECURITY INFO
// =========================================
Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: const Color(0xFF17292B),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: const Color(0xFF80BCBD).withValues(alpha: 0.15),
    ),
  ),
  child: const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        Icons.shield_outlined,
        color: Color(0xFFAAD9BB),
        size: 21,
      ),
      SizedBox(width: 10),
      Expanded(
        child: Text(
          'Your verified identity helps keep bicycle rentals safe and secure.',
          style: TextStyle(
            color: Color(0xFFC6C8D1),
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
),

const SizedBox(height: 20),

// =========================================
// LOG OUT
// =========================================
SizedBox(
  width: double.infinity,
  height: 52,
  child: OutlinedButton.icon(
    onPressed: _logout,
    icon: const Icon(
      Icons.logout_rounded,
      size: 18,
    ),
    label: const Text('Log Out'),
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFFF7D7D),
      side: BorderSide(
        color: const Color(0xFFFF6B6B).withValues(alpha: 0.45),
      ),
      backgroundColor: const Color(0xFF25141A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w900,
      ),
    ),
   ),
), // closes Logout SizedBox

              ], // closes Account Column children
            ), // closes Account Column
          ), // closes Account Container

        ], // closes ListView children
      ), // closes ListView
    ); // closes main Container
  }
  Future<void> _showEditProfileDialog(
  BuildContext context, {
  required String name,
  required String email,
  required String phone,
  required String address,
}) async {
  final nameController = TextEditingController(text: name);
  final emailController = TextEditingController(text: email);
  final phoneController = TextEditingController(text: phone);
  final addressController = TextEditingController(text: address);

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Edit profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setDialogState(() {
                          isLoading = true;
                        });

                        final response = await ApiService.updateProfile(
                          name: nameController.text,
                          email: emailController.text,
                          phoneNumber: phoneController.text,
                          address: addressController.text,
                        );

                        if (!dialogContext.mounted) return;
                        if (!context.mounted) return;

                        setDialogState(() {
                          isLoading = false;
                        });

                       if (response['success'] == true) {
                         Navigator.of(dialogContext).pop(true);
                           }else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message']?.toString() ??
                                    'Failed to update profile.',
                              ),
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

if (result == true) {
  if (!mounted) return;

  setState(() {});

  ScaffoldMessenger.of(this.context).showSnackBar(
    const SnackBar(
      content: Text('Profile updated successfully.'),
    ),
  );
}
}
Future<void> _showChangePasswordDialog(BuildContext context) async {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      bool isLoading = false;
      bool obscureCurrent = true;
      bool obscureNew = true;
      bool obscureConfirm = true;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Change password'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscureCurrent = !obscureCurrent;
                          });
                        },
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscureNew = !obscureNew;
                          });
                        },
                        icon: Icon(
                          obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm new password',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final currentPassword =
                            currentPasswordController.text;

                        final newPassword =
                            newPasswordController.text;

                        final confirmPassword =
                            confirmPasswordController.text;

                        if (currentPassword.isEmpty ||
                            newPassword.isEmpty ||
                            confirmPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please complete all password fields.',
                              ),
                            ),
                          );
                          return;
                        }

                        if (newPassword != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'New passwords do not match.',
                              ),
                            ),
                          );
                          return;
                        }

                        setDialogState(() {
                          isLoading = true;
                        });

                        final response =
                            await ApiService.changePassword(
                          currentPassword: currentPassword,
                          newPassword: newPassword,
                          passwordConfirmation: confirmPassword,
                        );

                        if (!dialogContext.mounted) return;
                        if (!context.mounted) return;

                        setDialogState(() {
                          isLoading = false;
                        });

                        if (response['success'] == true) {
                          Navigator.of(dialogContext).pop();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  response['message']?.toString() ??
                                      'Password changed successfully.',
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['message']?.toString() ??
                                    'Failed to change password.',
                              ),
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Change'),
              ),
            ],
          );
        },
      );
    },
  );
}
Future<void> _logout() async {
  final response = await ApiService.logout();

  if (!mounted) return;

  if (response['success'] == true) {
    widget.onLogout();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          response['message']?.toString() ?? 'Failed to log out.',
        ),
      ),
    );
  }
}

Future<void> _showHelpSupportDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.support_agent_rounded),
            SizedBox(width: 10),
            Text('Help & Support'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How can we help?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 16),

              Text(
                'Renting a bicycle',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Select an available bicycle, choose your rental duration, and complete the rental process.',
              ),

              SizedBox(height: 16),

              Text(
                'Returning a bicycle',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'Return the bicycle to the designated rental station and complete the return process in the app.',
              ),

              SizedBox(height: 16),

              Text(
                'Accident or emergency',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'If an accident occurs, seek immediate assistance when necessary. Pedalya may also send an accident alert to the system administrator.',
              ),

              SizedBox(height: 16),

              Text(
                'Account problems',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'For login, account, or rental concerns, please contact the Pedalya rental station.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

final ImagePicker _imagePicker = ImagePicker();

Future<void> _uploadId(ImageSource source) async {
  final image = await _imagePicker.pickImage(
    source: source,
    imageQuality: 85,
    maxWidth: 1600,
  );

  if (image == null || !mounted) return;

  final result =
      await ApiService.uploadIdVerification(image.path);

  if (!mounted) return;

  if (result['success'] != true) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message']?.toString() ??
              'Failed to upload ID.',
        ),
      ),
    );
    return;
  }

  await ApiService.getProfile();

  if (!mounted) return;

  setState(() {});

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'ID submitted. Verification is now pending.',
      ),
    ),
  );
}

void _showIdUploadOptions() {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF1A1D2E),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upload valid ID',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF80BCBD),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _uploadId(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF80BCBD),
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _uploadId(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

}
class _DarkProfileDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool verified;

  const _DarkProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
    this.verified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF292D43),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF80D6D4),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9699A8),
                    fontSize: 10,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    color: verified
                        ? const Color(0xFFAAD9BB)
                        : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          if (verified)
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFAAD9BB),
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF292D43),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF80D6D4),
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9699A8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF777B8E),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 15,
      endIndent: 15,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}

class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F5F1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: ink,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              trailing ??
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: muted,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
