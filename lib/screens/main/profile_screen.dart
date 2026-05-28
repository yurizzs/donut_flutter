import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_modal.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) return _buildLoginView(context);
          return _buildProfileView(context, ref, user);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => _buildErrorView(ref),
      ),
    );
  }

  Widget _buildLoginView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Please log in to view your profile', style: GoogleFonts.poppins(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const LoginModal(),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Unable to load profile', style: GoogleFonts.poppins()),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.invalidate(authProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, WidgetRef ref, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(radius: 50, backgroundColor: AppColors.accent, child: Text(user.name.isNotEmpty ? user.name[0] : '?', style: const TextStyle(fontSize: 40, color: Colors.white))),
          const SizedBox(height: 24),
          _buildInfoTile('Name', user.name),
          _buildInfoTile('Email', user.email),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.poppins(color: Colors.grey)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
