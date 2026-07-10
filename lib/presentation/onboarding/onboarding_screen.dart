import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // Patuh pada tema font global
import '../../../core/constants/colors.dart'; // Patuh pada pondasi warna global
import '../../../providers/app_state_provider.dart';
import '../main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variabel Pendukung Animasi
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi Animation Controller dengan durasi organik (1100 milidetik)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Animasi Fade In (Transparansi dari 0.0 ke 1.0) dengan Curve Mulus
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Animasi Slide/Move Up (Bergeser dari bawah ke posisi idealnya)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2), // Mulai sedikit lebih rendah di bawah posisi asli
      end: Offset.zero,             // Berakhir di posisi layout asli
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Memicu animasi secara otomatis sesaat setelah halaman dimuat
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose(); // Memastikan controller dibersihkan dari memori
    super.dispose();
  }

  void _handleGetStarted() async {
  // 1. Validasi teks input (FormState) terlebih dahulu
  if (_formKey.currentState!.validate()) {
    final appState = context.read<AppStateProvider>();
    
    // 2. SEBELUM berpindah halaman, tulis data baru ke Penyimpanan Lokal secara asinkronus (await)
    await appState.completeOnboarding(_nameController.text.trim());

    if (mounted) {
      // 3. Setelah proses menulis selesai, lakukan navigasi pengganti (replacement) ke Navigasi Utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // =========================================================
                  // BRANDING & LOGO SECTION (DIALIRKAN DALAM SATU BLOK ANIMASI)
                  // =========================================================
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Memuat Logo PNG Kustom dengan ukuran proporsional & estetik
                          Image.asset(
                            'assets/images/logo_tasktide.png',
                            width: 140,
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'TaskTide',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryBlue,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Finish your assignments on time, manage non-academic activities, and confidently achieve your daily goals.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // ==========================================
                  // INPUT NICKNAME SECTION
                  // ==========================================
                  Text(
                    "What's your nickname?",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your nickname...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name!';
                      }
                      if (value.trim().length > 15) {
                        return 'Maximum 15 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ==========================================
                  // BUTTON ACTION
                  // ==========================================
                  ElevatedButton(
                    onPressed: _handleGetStarted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}