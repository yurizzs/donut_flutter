import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_loading.dart';

class RegisterModal extends ConsumerStatefulWidget {
  const RegisterModal({super.key});

  @override
  ConsumerState<RegisterModal> createState() => _RegisterModalState();
}

class _RegisterModalState extends ConsumerState<RegisterModal> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers matching AuthModal.tsx
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Matching the payload in AuthModal.tsx handleRegister
    final data = {
      'full_name': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
    };

    await ref.read(authProvider.notifier).register(data);

    final authState = ref.read(authProvider);

    if (authState is AsyncData && authState.value != null) {
      if (mounted) {
        Navigator.pop(context); // Close Register Modal
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AsyncLoading;
    final error = authState is AsyncError ? authState.error.toString() : null;

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text('Register',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText)),
                ),
                const SizedBox(height: 24),
                
                _buildLabel('Full name'),
                _buildTextField(_fullNameController, required: true),
                const SizedBox(height: 16),
                
                _buildLabel('Email'),
                _buildTextField(_emailController, required: true, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                _buildLabel('Phone'),
                _buildTextField(_phoneController, required: true, keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                
                _buildLabel('Role'),
                TextFormField(
                  initialValue: 'Customer',
                  enabled: false,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildLabel('Password'),
                _buildTextField(_passwordController, required: true, obscureText: true),
                const SizedBox(height: 16),
                
                _buildLabel('Confirm password'),
                _buildTextField(_confirmPasswordController, required: true, obscureText: true),
                
                if (error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
                
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const DonutSpinner(size: 20)
                        : Text('Create account', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Already have an account? Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    {bool required = false, bool obscureText = false, TextInputType? keyboardType}
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: required ? (value) => value == null || value.isEmpty ? 'Required' : null : null,
    );
  }
}
