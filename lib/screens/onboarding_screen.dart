import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import '../services/app_config.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Calibration State
  double _weightKg = 70.0;
  double _durationMins = 45.0;
  String _selectedDiscipline = 'Squats';

  final List<String> _disciplines = [
    'Squats',
    'Taekwondo Forms',
    'Jumping Jacks',
    'Push-ups',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1F),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F0B24), Color(0xFF1A1433)],
              ),
            ),
          ),

          // Outer ambient cosmic glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF67E8F9).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC084FC).withOpacity(0.06),
              ),
            ),
          ),

          // Main PageView content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Top Logo/Header
                Text(
                  'ANTIGRAVITY',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    letterSpacing: 4.0,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildIntroPage(),
                      _buildCalibrationPage(),
                      _buildCommitmentPage(),
                    ],
                  ),
                ),

                // Page Indicator and Next/Start Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicators
                      Row(
                        children: List.generate(
                          3,
                          (index) => _buildIndicator(index),
                        ),
                      ),

                      // Navigation Button
                      _currentPage == 2
                          ? ElevatedButton(
                              onPressed: _initializeSystem,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF67E8F9),
                                foregroundColor: const Color(0xFF0A0A1F),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                shadowColor: const Color(
                                  0xFF67E8F9,
                                ).withOpacity(0.4),
                                elevation: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'INITIALIZE SYSTEM',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.bolt, size: 18),
                                ],
                              ),
                            )
                          : FloatingActionButton(
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              },
                              backgroundColor: Colors.white.withOpacity(0.08),
                              foregroundColor: const Color(0xFF67E8F9),
                              elevation: 0,
                              shape: const CircleBorder(
                                side: BorderSide(color: Colors.white10),
                              ),
                              child: const Icon(Icons.arrow_forward),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isSelected ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF67E8F9)
            : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  Widget _buildIntroPage() {
    return _buildPageWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.blur_on, size: 80, color: Color(0xFF67E8F9)),
          const SizedBox(height: 30),
          Text(
            'Reclaim Your Focus',
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome to Antigravity. We restore discipline by locking access to distracting apps when you procrastinate. The only way to unlock them is by submitting a metabolic effort toll.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFFCBD5E1),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationPage() {
    return _buildPageWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Biological Calibration',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Weight Calibration
          Text(
            'BODY WEIGHT (KG)',
            style: GoogleFonts.inter(
              color: const Color(0xFF67E8F9),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_weightKg.toStringAsFixed(0)} kg',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _weightKg,
                  min: 40.0,
                  max: 150.0,
                  activeColor: const Color(0xFF67E8F9),
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (val) {
                    setState(() {
                      _weightKg = val;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Daily Target Target Focus
          Text(
            'DAILY TARGET FOCUS (MINUTES)',
            style: GoogleFonts.inter(
              color: const Color(0xFFC084FC),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_durationMins.toStringAsFixed(0)} min',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Slider(
                  value: _durationMins,
                  min: 15.0,
                  max: 180.0,
                  activeColor: const Color(0xFFC084FC),
                  inactiveColor: Colors.white.withOpacity(0.1),
                  onChanged: (val) {
                    setState(() {
                      _durationMins = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommitmentPage() {
    return _buildPageWrapper(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Movement Commitment',
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Select the physical toll action you will perform to unlock system access.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFFCBD5E1),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: _disciplines.map((discipline) {
              final isSelected = _selectedDiscipline == discipline;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDiscipline = discipline;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF67E8F9).withOpacity(0.12)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF67E8F9)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          discipline,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF67E8F9),
                          )
                        else
                          Icon(
                            Icons.circle_outlined,
                            color: Colors.white.withOpacity(0.3),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPageWrapper({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: -10,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initializeSystem() {
    AppConfig.weightKg = _weightKg;
    AppConfig.durationMinutes = _durationMins;
    AppConfig.discipline = _selectedDiscipline;
    AppConfig.hasCompletedOnboarding = true;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          weightKg: _weightKg,
          durationMinutes: _durationMins,
        ),
      ),
    );
  }
}
