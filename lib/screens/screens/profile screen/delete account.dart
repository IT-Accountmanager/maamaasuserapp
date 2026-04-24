// ignore: file_names
// ignore: file_names
// ignore: file_names
import 'package:flutter/material.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import '../../../Services/Auth_service/Subscription_authservice.dart';
import '../login_page.dart';
import '../loginscreensas.dart';

// ignore: camel_case_types
class deleteAccountScreen extends StatefulWidget {
  const deleteAccountScreen({super.key});

  @override
  State<deleteAccountScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<deleteAccountScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _understandConsequences = false;
  bool _confirmDeletion = false;
  bool _isLoading = false;
  bool get _isFormValid => _understandConsequences && _confirmDeletion;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Account Deletion'),
          content: const Text(
            'This action is permanent and cannot be undone. '
            'All your data will be permanently erased.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performAccountDeletion();
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _performAccountDeletion() async {
    setState(() => _isLoading = true);
    final success = await subscription_AuthService.deleteAccount();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      AppAlert.success(context, 'Account successfully deleted');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ), // <-- direct class
        (route) => false,
      );
    } else {
      AppAlert.error(context, 'Failed to delete account');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Delete Account'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Warning Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Warning',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Deleting your account will:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('• Permanently erase your profile data'),
                          const Text('• Delete all your created content'),
                          const Text('• Remove all your personal information'),
                          const Text('• This action cannot be undone'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Confirmation Checkboxes
                    _buildCheckboxListTile(
                      title: 'I understand the consequences',
                      value: _understandConsequences,
                      onChanged: (value) {
                        setState(() {
                          _understandConsequences = value ?? false;
                        });
                      },
                    ),

                    _buildCheckboxListTile(
                      title: 'I confirm I want to delete my account',
                      value: _confirmDeletion,
                      onChanged: (value) {
                        setState(() {
                          _confirmDeletion = value ?? false;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Delete Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isFormValid
                            ? _showConfirmationDialog
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'DELETE MY ACCOUNT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCheckboxListTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
