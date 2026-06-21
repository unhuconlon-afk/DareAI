import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/anti_procrastination_service.dart';
import '../services/metabolic_ffi_service.dart';
import '../services/app_blocker_service.dart';
import '../services/app_config.dart';
import '../main.dart'; // For TestSOSTriggerWidget

class DashboardScreen extends StatefulWidget {
  final double weightKg;
  final double durationMinutes;

  const DashboardScreen({
    super.key,
    required this.weightKg,
    required this.durationMinutes,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final MetabolicFFIService _ffiService = MetabolicFFIService();
  final AppBlockerService _appBlockerService = AppBlockerService();
  late AnimationController _floatController;

  // Active / Stagnant UI States
  bool _isActive = true;
  bool _isLocked = false;

  // Permission Statuses
  bool _overlayPermission = false;
  bool _usagePermission = false;

  late double _currentWeightKg;
  late double _currentDurationMinutes;

  Map<String, double> metrics = {};

  // Dynamic Apps Configuration
  final Map<String, String> _availableApps = {
    'YouTube': 'com.google.android.youtube',
    'TikTok': 'com.zhiliaoapp.musically',
    'Facebook': 'com.facebook.katana',
    'Instagram': 'com.instagram.android',
  };
  final Set<String> _selectedRestrictedApps = {'com.google.android.youtube'};

  @override
  void initState() {
    super.initState();
    _currentWeightKg = widget.weightKg;
    _currentDurationMinutes = widget.durationMinutes;
    WidgetsBinding.instance.addObserver(this);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    metrics = _ffiService.calculateAllMetrics(
      _currentWeightKg,
      _currentDurationMinutes,
    );

    // Bind Native App Blocker callback
    _appBlockerService.onUnlockedCallback = () {
      setState(() {
        _isLocked = false;
        _isActive = true;
      });
      _showUnlockSnackBar();
    };

    // Check permissions and start native blocker service
    _checkBlockerPermissions();
    _appBlockerService.startService();
    _appBlockerService.updateRestrictedApps(_selectedRestrictedApps.toList());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _floatController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBlockerPermissions();
    }
  }

  Future<void> _checkBlockerPermissions() async {
    final perms = await _appBlockerService.checkPermissions();
    setState(() {
      _overlayPermission = perms['overlay'] ?? false;
      _usagePermission = perms['usage'] ?? false;
    });
  }

  void _setLockState(bool locked) {
    setState(() {
      _isLocked = locked;
      if (locked) {
        _isActive = false;
      }
    });
    _appBlockerService.setLocked(locked);
  }

  void _showUnlockSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.yellowAccent),
            const SizedBox(width: 8),
            Text(
              'Energy surge! System unlocked.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F0B24),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: const Color(0xFF0A0A1F),
        appBar: _isLocked
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'ANTIGRAVITY',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                bottom: TabBar(
                  indicatorColor: const Color(0xFF67E8F9),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  labelStyle: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 13),
                  tabs: const [
                    Tab(text: 'FOCUS WORKSPACE'),
                    Tab(text: 'EFFORT ARENA'),
                  ],
                ),
              ),
        body: Stack(
          children: [
            // Main Dashboard Content
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isActive
                      ? [const Color(0xFF0F0B24), const Color(0xFF1A1433)]
                      : [
                          const Color(0xFF0D0F14),
                          const Color(0xFF1A1D24),
                        ], // Dim blue/gray background gradient
                ),
              ),
              child: SafeArea(
                child: TabBarView(
                  children: [_buildFocusWorkspace(), _buildEffortArena()],
                ),
              ),
            ),

            // Effort Toll Lock Screen Overlay
            if (_isLocked) _buildLockScreenOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildFocusWorkspace() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        _buildGreeting(),
        const SizedBox(height: 32),
        _buildEnergyWaveChart(),
        const SizedBox(height: 24),
        _buildSettingsCard(),
        const SizedBox(height: 24),
        _buildStateSimulatorCard(),
        const SizedBox(height: 24),
        GlassCard(
          isActive: _isActive,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  'SOS Alert Control',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 150, child: TestSOSTriggerWidget()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEffortArena() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        _buildEffortGreeting(),
        const SizedBox(height: 32),
        _buildCalibrationAdjustmentCard(),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                _isActive ? 'Energy Level' : 'Bio-Battery Charge',
                _isActive ? '87%' : '12%',
                Icons.bolt,
                _isActive ? const Color(0xFF67E8F9) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                _isActive ? 'Flexibility' : 'Joint Stiffness',
                _isActive ? 'High' : 'Stiff',
                _isActive
                    ? Icons.accessibility_new
                    : Icons.report_problem_outlined,
                _isActive ? const Color(0xFFC084FC) : const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildMuscleHeatMap(),
        const SizedBox(height: 24),
        _buildMetabolicProjections(),
      ],
    );
  }

  Widget _buildEffortGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EFFORT ARENA',
          style: GoogleFonts.inter(
            color: const Color(0xFFC084FC),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Metabolic Calibration\n& Performance Stats',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationAdjustmentCard() {
    return GlassCard(
      isActive: _isActive,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Color(0xFF67E8F9), size: 20),
                const SizedBox(width: 8),
                Text(
                  'ADJUST BIOLOGICAL CALIBRATION',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weight: ${_currentWeightKg.toStringAsFixed(0)} kg',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _currentWeightKg,
                    min: 40.0,
                    max: 150.0,
                    activeColor: const Color(0xFF67E8F9),
                    inactiveColor: Colors.white.withOpacity(0.1),
                    onChanged: (val) {
                      setState(() {
                        _currentWeightKg = val;
                        AppConfig.weightKg = val;
                        metrics = _ffiService.calculateAllMetrics(
                          _currentWeightKg,
                          _currentDurationMinutes,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Focus Goal: ${_currentDurationMinutes.toStringAsFixed(0)} min',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: _currentDurationMinutes,
                    min: 15.0,
                    max: 180.0,
                    activeColor: const Color(0xFFC084FC),
                    inactiveColor: Colors.white.withOpacity(0.1),
                    onChanged: (val) {
                      setState(() {
                        _currentDurationMinutes = val;
                        AppConfig.durationMinutes = val;
                        metrics = _ffiService.calculateAllMetrics(
                          _currentWeightKg,
                          _currentDurationMinutes,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isActive ? 'Active State' : 'Stagnant State',
          style: GoogleFonts.inter(
            color: _isActive
                ? const Color(0xFF67E8F9)
                : const Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isActive
              ? 'Energy surging.\nReady for impact.'
              : 'System stagnant.\nInactivity detected.',
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyWaveChart() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * _floatController.value),
          child: GlassCard(
            isActive: _isActive,
            child: Container(
              height: 140,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isActive
                      ? [
                          Colors.orangeAccent.withOpacity(0.2),
                          Colors.yellowAccent.withOpacity(0.05),
                        ]
                      : [
                          const Color(0xFF475569).withOpacity(0.15),
                          const Color(0xFF334155).withOpacity(0.05),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BIO-BATTERY',
                    style: GoogleFonts.inter(
                      color: _isActive
                          ? Colors.orangeAccent
                          : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _isActive ? 0.87 : 0.12,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isActive
                                ? [Colors.orange, Colors.yellowAccent]
                                : [
                                    const Color(0xFF64748B),
                                    const Color(0xFF475569),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (_isActive
                                          ? Colors.orange
                                          : const Color(0xFF475569))
                                      .withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isActive
                        ? 'Optimal performance maintained.'
                        : 'Bio-battery depleted. Inactivity detected.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassCard(
      isActive: _isActive,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.inter(
                color: const Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMuscleHeatMap() {
    return GlassCard(
      isActive: _isActive,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (_isActive
                            ? const Color(0xFF67E8F9)
                            : const Color(0xFF64748B))
                        .withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Icon(
                _isActive ? Icons.fitness_center : Icons.warning,
                color: _isActive
                    ? const Color(0xFF67E8F9)
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isActive ? 'MUSCLE HEAT MAP' : 'ENERGY CONGESTION',
                    style: GoogleFonts.inter(
                      color: _isActive
                          ? const Color(0xFF67E8F9)
                          : const Color(0xFF94A3B8),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isActive
                        ? 'Core engagement active. Limber state achieved.'
                        : 'Biological machine is beginning to rust. Release pent-up energy.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFCBD5E1),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetabolicProjections() {
    return GlassCard(
      isActive: _isActive,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isActive ? '30-DAY METABOLIC PROJECTION' : 'PROJECTION DEGRADED',
              style: GoogleFonts.inter(
                color: _isActive
                    ? const Color(0xFFF472B6)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calories Burned',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isActive
                          ? '${metrics['projected30DayKcalBurned']?.toStringAsFixed(0) ?? 0} Kcal'
                          : '0 Kcal (Stagnant)',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Estimated Fat Loss',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isActive
                          ? '${metrics['projected30DayFatLossKg']?.toStringAsFixed(2) ?? 0} kg'
                          : '0.00 kg',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateSimulatorCard() {
    return GlassCard(
      isActive: _isActive,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tune,
                  color: _isActive
                      ? const Color(0xFF67E8F9)
                      : const Color(0xFF94A3B8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'SYSTEM STATE SIMULATOR',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white70,
                    size: 18,
                  ),
                  onPressed: _checkBlockerPermissions,
                  tooltip: 'Check Permission Status',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Native permissions UI status / warning
            if (!_overlayPermission || !_usagePermission) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Native App Blocker Permissions Required',
                          style: GoogleFonts.inter(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'To block apps like YouTube when stagnant, you must grant the following permissions in Android Settings:',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFCBD5E1),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (!_overlayPermission)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _appBlockerService
                                    .requestOverlayPermission();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.withOpacity(
                                  0.2,
                                ),
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Draw Over Apps',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        if (!_overlayPermission && !_usagePermission)
                          const SizedBox(width: 8),
                        if (!_usagePermission)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _appBlockerService
                                    .requestUsagePermission();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent.withOpacity(
                                  0.2,
                                ),
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.redAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Usage Stats',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF67E8F9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF67E8F9).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF67E8F9),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isLocked
                          ? 'App Blocker Active'
                          : 'System Ready (Permissions Secured)',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF67E8F9),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stagnant Mode Theme',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFCBD5E1),
                    fontSize: 14,
                  ),
                ),
                Switch(
                  value: !_isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = !value;
                    });
                  },
                  activeColor: const Color(0xFF64748B),
                  activeTrackColor: const Color(0xFF334155),
                  inactiveThumbColor: const Color(0xFF67E8F9),
                  inactiveTrackColor: const Color(0xFF0F0B24),
                ),
              ],
            ),
            if (!_isActive) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _setLockState(true);
                  },
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Trigger Stagnation Lock Screen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF475569),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF64748B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard() {
    return GlassCard(
      isActive: _isActive,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.app_blocking_outlined,
                  color: _isActive
                      ? const Color(0xFF67E8F9)
                      : const Color(0xFF94A3B8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'RESTRICTED APPS CONFIGURATION',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select the apps that should trigger an Effort Toll when opened during a stagnant state.',
              style: GoogleFonts.inter(
                color: const Color(0xFFCBD5E1),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _availableApps.entries.map((entry) {
                final isSelected = _selectedRestrictedApps.contains(
                  entry.value,
                );
                return FilterChip(
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedRestrictedApps.add(entry.value);
                      } else {
                        _selectedRestrictedApps.remove(entry.value);
                      }
                      _appBlockerService.updateRestrictedApps(
                        _selectedRestrictedApps.toList(),
                      );
                    });
                  },
                  backgroundColor: Colors.white.withOpacity(0.05),
                  selectedColor: _isActive
                      ? const Color(0xFF67E8F9).withOpacity(0.3)
                      : const Color(0xFF475569),
                  checkmarkColor: Colors.white,
                  labelStyle: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? (_isActive ? const Color(0xFF67E8F9) : Colors.white)
                        : Colors.white.withOpacity(0.1),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockScreenOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            color: Colors.black.withOpacity(0.85),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.8, end: 1.2),
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF3B82F6).withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.report_gmailerrorred_rounded,
                            color: Color(0xFF67E8F9),
                            size: 64,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'EFFORT TOLL REQUIRED',
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Biological System Stagnant',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'INSTRUCTION TO UNLOCK',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF67E8F9),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your metabolic metrics indicate prolonged physical rust. You must spike your heart rate and release pent-up energy to unlock the dashboard.',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFCBD5E1),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.directions_run,
                                  color: Color(0xFF67E8F9),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Complete 1-2 Taekwondo forms or 20 deep squats.',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _setLockState(false);
                            setState(() {
                              _isActive = true;
                            });
                            _showUnlockSnackBar();
                          },
                          icon: const Icon(Icons.bolt),
                          label: Text(
                            'Simulate Exercise Completion',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF67E8F9),
                            foregroundColor: const Color(0xFF0A0A1F),
                            shadowColor: const Color(
                              0xFF67E8F9,
                            ).withOpacity(0.5),
                            elevation: 15,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unlock is monitored natively via C++ metabolic verification.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final bool isActive;

  const GlassCard({super.key, required this.child, this.isActive = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 40,
            spreadRadius: -15,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color:
                (isActive ? const Color(0xFF67E8F9) : const Color(0xFF475569))
                    .withOpacity(0.15),
            blurRadius: 35,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: child,
        ),
      ),
    );
  }
}
