import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.donut_large, size: 100, color: AppColors.accent),
            const SizedBox(height: 24),
            Text(
              'Doughlicious',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We are a premium donut shop dedicated to bringing you the finest and freshest donuts in town. Our secret recipe has been passed down for generations, ensuring that every bite is a moment of pure joy.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.primaryText.withOpacity(0.8),
              ),
            ),
            const Spacer(),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(
                color: AppColors.primaryText.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
