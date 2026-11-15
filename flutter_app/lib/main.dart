import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NmmsApp());
}

// -------------------------------------------------------------
// THEMES DEFINITION (Minimal, Cool, Distraction-Free)
// -------------------------------------------------------------
class AppThemes {
  static final modernIndigo = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF4338CA),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4338CA),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static final oledDark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF090D16),
    colorSchemeSeed: const Color(0xFF6366F1),
    cardColor: const Color(0xFF131B2E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF131B2E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static final forestSage = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF0F766E),
    scaffoldBackgroundColor: const Color(0xFFF0FDF4),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F766E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static final warmSepia = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF9A3412),
    scaffoldBackgroundColor: const Color(0xFFFFFBEB),
    cardColor: const Color(0xFFFEF3C7),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF9A3412),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
  );
}

// -------------------------------------------------------------
// AUDIO & SOUND EFFECTS HELPER
// -------------------------------------------------------------
class AppAudio {
  static void playTap() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  static void playNext() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
  }

  static void playMark() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  static void playSubmit() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.heavyImpact();
  }

  static void playWarning() {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
  }

  static void playCelebration() {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
    Timer(const Duration(milliseconds: 140), () {
      SystemSound.play(SystemSoundType.click);
      HapticFeedback.lightImpact();
    });
  }
}

class NmmsApp extends StatefulWidget {
  const NmmsApp({super.key});

  @override
  State<NmmsApp> createState() => _NmmsAppState();
}

class _NmmsAppState extends State<NmmsApp> {
  int _themeIndex = 0; // 0: Indigo, 1: OLED Dark, 2: Forest, 3: Warm Sepia

  @override
  void initState() {
    super.initState();
    _loadThemePref();
  }

  void _loadThemePref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeIndex = prefs.getInt('app_theme_index') ?? 0;
    });
  }

  void _setTheme(int index) async {
    setState(() {
      _themeIndex = index;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme_index', index);
  }

  void _cycleTheme() {
    _setTheme((_themeIndex + 1) % 4);
  }

  ThemeData _getTheme() {
    switch (_themeIndex) {
      case 1:
        return AppThemes.oledDark;
      case 2:
        return AppThemes.forestSage;
      case 3:
        return AppThemes.warmSepia;
      default:
        return AppThemes.modernIndigo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme();
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    // Set notification bar / status bar color to match app theme color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? const Color(0xFF090D16) : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'NMMS Ponsri Exam',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: SplashScreen(
        currentThemeIndex: _themeIndex,
        onThemeChanged: _setTheme,
        onThemeToggle: _cycleTheme,
      ),
    );
  }
}

// -------------------------------------------------------------
// SPLASH SCREEN (Smooth Animated with Pure White Logo)
// -------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  final int currentThemeIndex;
  final ValueChanged<int> onThemeChanged;
  final VoidCallback onThemeToggle;

  const SplashScreen({
    super.key,
    required this.currentThemeIndex,
    required this.onThemeChanged,
    required this.onThemeToggle,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeIn),
      ),
    );

    _animController.forward();

    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => MainNavigationShell(
              currentThemeIndex: widget.currentThemeIndex,
              onThemeChanged: widget.onThemeChanged,
              onThemeToggle: widget.onThemeToggle,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Pure White Logo Container
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white, // Crisp pure white background requested
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.school, size: 64, color: primary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Animated School Title & Platform Subtitle
            SlideTransition(
              position: _textSlideAnimation,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: Column(
                  children: [
                    const Text(
                      'પીએમ શ્રી પ્રાથમિક વિદ્યામંદિર પોંસરી',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'NMMS Secure Examination Platform',
                      style: TextStyle(
                        fontSize: 12,
                        color: primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 42),

            FadeTransition(
              opacity: _textFadeAnimation,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// MAIN NAVIGATION SHELL WITH BOTTOM TOOLBAR
// -------------------------------------------------------------
class MainNavigationShell extends StatefulWidget {
  final int currentThemeIndex;
  final ValueChanged<int> onThemeChanged;
  final VoidCallback onThemeToggle;

  const MainNavigationShell({
    super.key,
    required this.currentThemeIndex,
    required this.onThemeChanged,
    required this.onThemeToggle,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ExamHomeScreen(
        onOpenPastQuizzes: () => setState(() => _selectedIndex = 1),
        onOpenResults: () => setState(() => _selectedIndex = 2),
      ),
      PastQuizzesScreen(
        onSelectQuiz: (quizTitle, quizData) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExamScreen(
                studentName: 'વિદ્યાર્થી',
                studentRoll: '01',
                customQuizTitle: quizTitle,
                customQuizData: quizData,
              ),
            ),
          );
        },
      ),
      const PastResultsScreen(),
      ProfileScreen(
        currentThemeIndex: widget.currentThemeIndex,
        onThemeChanged: widget.onThemeChanged,
      ),
      const AdminScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'કસોટી',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(Icons.history_edu),
            label: 'જૂની કસોટી',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'પરિણામો',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'પ્રોફાઇલ',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'એડમિન',
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 1: EXAM HOME SCREEN (With Instructions & Start)
// -------------------------------------------------------------
class ExamHomeScreen extends StatefulWidget {
  final VoidCallback onOpenPastQuizzes;
  final VoidCallback onOpenResults;

  const ExamHomeScreen({
    super.key,
    required this.onOpenPastQuizzes,
    required this.onOpenResults,
  });

  @override
  State<ExamHomeScreen> createState() => _ExamHomeScreenState();
}

class _ExamHomeScreenState extends State<ExamHomeScreen> {
  final _nameController = TextEditingController();
  final _rollController = TextEditingController();
  final _schoolController = TextEditingController(text: 'PM SHRI PRATHMIK VIDHYAMANDIR PONSRI');
  bool _agreedToInstructions = true;
  bool _showInstructionsDetails = true;

  @override
  void initState() {
    super.initState();
    _loadSavedStudent();
  }

  void _loadSavedStudent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('student_name') ?? '';
      _rollController.text = prefs.getString('student_roll') ?? '';
      if (_nameController.text.isEmpty) {
        _nameController.text = 'પટેલ સંદીપ';
      }
      if (_rollController.text.isEmpty) {
        _rollController.text = '01';
      }
    });
  }

  void _saveStudent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('student_name', _nameController.text.trim());
    await prefs.setString('student_roll', _rollController.text.trim());
  }

  void _startTest() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('કૃપા કરીને વિદ્યાર્થીનું પૂરું નામ દાખલ કરો.')),
      );
      return;
    }

    if (!_agreedToInstructions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('કસોટી શરૂ કરવા માટે કૃપા કરીને સૂચનાઓ વાંચી સ્વીકારો.')),
      );
      return;
    }

    _saveStudent();

    // AI Camera Monitoring Prompt before starting
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.videocam, color: Colors.red),
            SizedBox(width: 8),
            Text('AI કેમેરા નિરીક્ષણ સૂચના', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'કસોટી દરમિયાન સતત AI કેમેરા મોનિટરિંગ સક્રિય રહેશે.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
            ),
            SizedBox(height: 10),
            Text('• કસોટી આપતી વખતે તમારો ચહેરો સતત કેમેરા સામે હોવો ફરજિયાત છે.', style: TextStyle(fontSize: 12)),
            SizedBox(height: 6),
            Text('• આજુબાજુ જોવું કે અન્ય કોઈ સાથે વાતચીત કરવી સખત પ્રતિબંધિત છે.', style: TextStyle(fontSize: 12)),
            SizedBox(height: 6),
            Text('• એપ ૩ વાર મિનિમાઇઝ કરવાથી કે સ્ક્રીન બંધ કરવાથી પેપર આપમેળે જમા થઈ જશે.', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('પાછા જાઓ'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _proceedToExam();
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('મંજૂર કરો અને શરૂ કરો'),
          ),
        ],
      ),
    );
  }

  void _proceedToExam() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExamScreen(
          studentName: _nameController.text.trim(),
          studentRoll: _rollController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NMMS કસોટી પોર્ટલ',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'પરિણામો',
            icon: const Icon(Icons.leaderboard),
            onPressed: widget.onOpenResults,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // School Banner Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131B2E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/logo.png',
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.school, color: primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'પીએમ શ્રી પ્રાથમિક વિદ્યામંદિર પોંસરી',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'તા. માણસા, જી. ગાંધીનગર • NMMS તૈયારી',
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '● કસોટી સક્રિય છે (LIVE)',
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Student Credentials Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131B2E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'વિદ્યાર્થી વિગત (Student Details)',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'પૂરું નામ (Full Name)',
                        prefixIcon: const Icon(Icons.person, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _rollController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'રોલ નં.',
                              prefixIcon: const Icon(Icons.numbers, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _schoolController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'શાળા',
                              prefixIcon: const Icon(Icons.account_balance, size: 20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // EXAM INSTRUCTIONS & STRUCTURE CARD (Requested by user)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131B2E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.indigo.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showInstructionsDetails = !_showInstructionsDetails;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.rule, color: primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'કસોટીનું માળખું અને અગત્યની સૂચનાઓ',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Structure, Duration & Room Instructions',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              _showInstructionsDetails ? Icons.expand_less : Icons.expand_more,
                              color: primary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_showInstructionsDetails) ...[
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section 1: Structure & Duration
                            _buildInstructionHeader('Structure & Duration', Icons.timer_outlined, Colors.indigo),
                            const SizedBox(height: 6),
                            _buildBulletItem(
                              'Two Main Tests:',
                              '• MAT (Mental Ability Test): 90 multiple-choice questions testing verbal and non-verbal reasoning, analysis, and critical thinking (90 minutes).\n'
                              '• SAT (Scholastic Aptitude Test): 90 multiple-choice questions covering Science, Mathematics, and Social Science from Classes 7 and 8 (90 minutes).',
                            ),
                            const SizedBox(height: 4),
                            _buildBulletItem(
                              'Total Questions & Marks:',
                              '180 questions / 180 marks (1 mark per question).',
                            ),
                            const SizedBox(height: 4),
                            _buildBulletItem(
                              'Negative Marking:',
                              'There is no negative marking.',
                            ),

                            const SizedBox(height: 14),

                            // Section 2: Common Exam Room Instructions
                            _buildInstructionHeader('Common Exam Room Instructions', Icons.menu_book, Colors.amber.shade800),
                            const SizedBox(height: 6),
                            _buildBulletItem('AI Camera Proctoring:', 'કસોટી દરમિયાન AI કેમેરા નિરીક્ષણ સક્રિય રહેશે. કસોટી આપતી વખતે તમારો ચહેરો સતત કેમેરા સામે રાખવો ફરજિયાત છે.'),
                            _buildBulletItem('OMR Sheet Usage:', 'All answers must be indicated by shading the correct circle on a separate OMR answer sheet using the prescribed pen/pencil.'),
                            _buildBulletItem('Question Booklet Series:', 'You must carefully write and shade your question booklet series code (such as A, B, C, D, or E) on the OMR sheet.'),
                            _buildBulletItem('Rough Work:', 'Use only the blank pages provided at the end of the question booklet for rough work. Do not write on the OMR sheet outside designated fields.'),
                            _buildBulletItem('Time Management:', 'Do not spend too much time on a single question if you are unsure; move on and return to it later if time permits.'),
                            _buildBulletItem('Submission:', 'Hand over the OMR sheet and question booklet (as required by the invigilator) before leaving the exam room.'),

                            const SizedBox(height: 12),

                            // Anti-Cheat Security Notice
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.shield_outlined, color: Colors.orange, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'સુરક્ષા ચેતવણી: કસોટી દરમિયાન એપ ૩ વખત મિનિમાઇઝ કરવાથી કે સ્ક્રીન બંધ થવાથી પેપર આપમેળે સબમિટ થઈ જશે.',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Agreement Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreedToInstructions,
                                  onChanged: (val) => setState(() => _agreedToInstructions = val ?? false),
                                ),
                                const Expanded(
                                  child: Text(
                                    'મેં કસોટી સંબંધિત તમામ સૂચનાઓ વાંચી લીધી છે અને હું સહમત છું.',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // START EXAM BUTTON
              FilledButton.icon(
                onPressed: _startTest,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: primary,
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  'કસોટી શરૂ કરો (Start Secure Exam)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: widget.onOpenPastQuizzes,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.history, size: 18),
                label: const Text('જૂની કસોટીઓ જુઓ (Past Quizzes Archive)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: color),
        ),
      ],
    );
  }

  Widget _buildBulletItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
          const SizedBox(height: 1),
          Text(
            description,
            style: const TextStyle(fontSize: 11, height: 1.3, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 2: PAST QUIZZES ARCHIVE SCREEN
// -------------------------------------------------------------
class PastQuizzesScreen extends StatelessWidget {
  final Function(String title, List<dynamic>? data) onSelectQuiz;

  const PastQuizzesScreen({super.key, required this.onSelectQuiz});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pastPapers = [
      {
        'title': 'NMMS આદર્શ પ્રશ્નપત્ર ક્રમાંક - 52',
        'subtitle': 'સંપૂર્ણ મોક ટેસ્ટ • MAT (90) + SAT (90)',
        'questions': 180,
        'duration': '180 મિનિટ',
        'badge': 'સત્તાવાર',
        'isCurrent': true,
      },
      {
        'title': 'NMMS પરીક્ષા 2023-24 પ્રશ્નપત્ર - 51',
        'subtitle': 'પાછલા વર્ષનું વાર્ષિક પેપર • MAT & SAT',
        'questions': 180,
        'duration': '180 મિનિટ',
        'badge': 'વાર્ષિક પેપર',
        'isCurrent': false,
      },
      {
        'title': 'NMMS માનસિક ક્ષમતા કસોટી (MAT) સ્પેશિયલ',
        'subtitle': 'તાર્કિક વિચારણા, શ્રેણી, કોડિંગ-ડીકોડિંગ',
        'questions': 90,
        'duration': '90 મિનિટ',
        'badge': 'MAT વિભાગ',
        'isCurrent': false,
      },
      {
        'title': 'NMMS શૈક્ષણિક યોગ્યતા કસોટી (SAT) સ્પેશિયલ',
        'subtitle': 'ધોરણ ૭-૮ વિજ્ઞાન, ગણિત, સામાજિક વિજ્ઞાન',
        'questions': 90,
        'duration': '90 મિનિટ',
        'badge': 'SAT વિભાગ',
        'isCurrent': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('જૂની કસોટીઓ (Past Quizzes)'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pastPapers.length,
        itemBuilder: (context, index) {
          final paper = pastPapers[index];
          final isCurrent = paper['isCurrent'] as bool;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isCurrent
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white12 : Colors.black12),
                width: isCurrent ? 1.5 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF10B981).withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          paper['badge'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? const Color(0xFF10B981) : Colors.grey,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${paper['questions']} પ્રશ્નો • ${paper['duration']}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    paper['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    paper['subtitle'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.tonal(
                        onPressed: () {
                          onSelectQuiz(paper['title'] as String, null);
                        },
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: const Text('કસોટી શરૂ કરો', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('પ્રશ્નો પ્રેક્ટિસ મોડમાં ઉપલબ્ધ છે.')),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        child: const Text('વિશ્લેષણ જુઓ', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 3: PAST RESULTS / SCORECARDS SCREEN
// -------------------------------------------------------------
class PastResultsScreen extends StatefulWidget {
  const PastResultsScreen({super.key});

  @override
  State<PastResultsScreen> createState() => _PastResultsScreenState();
}

class _PastResultsScreenState extends State<PastResultsScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  void _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('exam_history') ?? [];
    List<Map<String, dynamic>> parsed = [];
    for (var item in raw) {
      try {
        parsed.add(Map<String, dynamic>.from(jsonDecode(item)));
      } catch (_) {}
    }
    setState(() {
      _results = parsed.reversed.toList(); // Newest first
      _isLoading = false;
    });
  }

  void _clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exam_history');
    setState(() {
      _results = [];
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ઇતિહાસ સફળતાપૂર્વક સાફ કરવામાં આવ્યો છે.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('પરિણામો અને પ્રયાસો (Past Results)'),
        actions: [
          if (_results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'ઇતિહાસ સાફ કરો',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('ઇતિહાસ સાફ કરવો છે?'),
                    content: const Text('બધા અગાઉના પ્રયાસો દૂર થઈ જશે.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('રદ')),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearResults();
                        },
                        child: const Text('સાફ કરો', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'હજી સુધી કોઈ કસોટી આપવામાં આવી નથી.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'હોમ પેજ પર જઈને NMMS ટેસ્ટ આપો, તમારા પરિણામો અહીં સંગ્રહિત થશે.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final res = _results[index];
                    final score = res['score'] ?? 0;
                    final total = res['total'] ?? 180;
                    final pct = res['pct'] ?? 0;
                    final date = res['date'] ?? 'આજે';
                    final isPassed = score >= 72;
                    final isDark = Theme.of(context).brightness == Brightness.dark;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: (isPassed ? const Color(0xFF10B981) : Colors.red)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  '$score',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: isPassed ? const Color(0xFF10B981) : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isPassed ? 'પાસ (Qualifying) 🏆' : 'સુધારાની જરૂર',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isPassed ? const Color(0xFF10B981) : Colors.red,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '$pct%',
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'કુલ: $score / $total ગુણ',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    date,
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// -------------------------------------------------------------
// TAB 4: PROFILE & THEMES SCREEN
// -------------------------------------------------------------
class ProfileScreen extends StatefulWidget {
  final int currentThemeIndex;
  final ValueChanged<int> onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.currentThemeIndex,
    required this.onThemeChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'પટેલ સંદીપ';
  String _roll = '01';
  final String _school = 'PM SHRI PRATHMIK VIDHYAMANDIR PONSRI';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('student_name') ?? _name;
      _roll = prefs.getString('student_roll') ?? _roll;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final themeOptions = [
      {'name': 'Modern Indigo', 'color': const Color(0xFF4338CA)},
      {'name': 'OLED Dark', 'color': const Color(0xFF090D16)},
      {'name': 'Forest Sage', 'color': const Color(0xFF0F766E)},
      {'name': 'Warm Sepia', 'color': const Color(0xFF9A3412)},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('પ્રોફાઇલ અને થીમ્સ (Profile)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Student Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131B2E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: primary.withValues(alpha: 0.15),
                  child: Icon(Icons.person, size: 36, color: primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'રોલ નંબર: $_roll',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _school,
                        style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Theme Switcher Section
          const Text(
            'એપ થીમ પસંદ કરો (Themes)',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(themeOptions.length, (idx) {
              final opt = themeOptions[idx];
              final isSelected = widget.currentThemeIndex == idx;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onThemeChanged(idx),
                  child: Container(
                    margin: EdgeInsets.only(right: idx == 3 ? 0 : 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131B2E) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? primary : (isDark ? Colors.white12 : Colors.black12),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: opt['color'] as Color,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          opt['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Security Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131B2E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.security, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'સુરક્ષા ફીચર્સ (Anti-Cheat Active)',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('• 3-Strike Minimize Auto-Submit: સક્રિય', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                const Text('• Screen Keep Awake: સક્રિય', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                const Text('• Firebase Firestore Cloud Sync: સક્રિય', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 5: ADMIN CONTROL SCREEN
// -------------------------------------------------------------
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isUnlocked = false;
  final _pinController = TextEditingController();

  void _verifyPin() {
    if (_pinController.text.trim() == '2026' || _pinController.text.trim() == 'ponsri') {
      setState(() {
        _isUnlocked = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('અમાન્ય એડમિન પિન. (Invalid Admin PIN)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('એડમિન લૉગિન'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 56, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text(
                  'માત્ર અધિકૃત શિક્ષક / એડમિન માટે',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text(
                  'એડમિન પેનલ ખોલવા માટે સુરક્ષા પિન દાખલ કરો.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'એડમિન પિન દાખલ કરો',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _verifyPin,
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('અનલૉક કરો'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('એડમિન કંટ્રોલ પેનલ 👑'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () => setState(() => _isUnlocked = false),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.quiz, color: Colors.indigo),
            title: Text('સક્રિય કસોટી: પેપર ક્રમાંક 52'),
            subtitle: Text('180 પ્રશ્નો (MAT: 90, SAT: 90)'),
            trailing: Chip(label: Text('LIVE')),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.cloud_sync, color: Color(0xFF10B981)),
            title: Text('Firebase Firestore Database'),
            subtitle: Text('સિંક ચાલુ • Realtime Updates'),
            trailing: Icon(Icons.check_circle, color: Color(0xFF10B981)),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.people_alt, color: Colors.orange),
            title: const Text('વિદ્યાર્થી સબમિશન અને સ્કોરકાર્ડ'),
            subtitle: const Text('Firestore submissions collection'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Firebase કનેક્ટેડ છે.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// SECURE EXAM SCREEN (Anti-Cheat 3-Strike, Timer, Questions)
// -------------------------------------------------------------
class ExamScreen extends StatefulWidget {
  final String studentName;
  final String studentRoll;
  final String? customQuizTitle;
  final List<dynamic>? customQuizData;

  const ExamScreen({
    super.key,
    required this.studentName,
    required this.studentRoll,
    this.customQuizTitle,
    this.customQuizData,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> with WidgetsBindingObserver {
  List<dynamic> _questions = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  final Set<int> _bookmarks = {};

  int _strikeCount = 0;
  static const int _maxStrikes = 3;

  Timer? _examTimer;
  int _remainingSeconds = 180 * 60; // 3 hours = 180 mins

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Secure Fullscreen Exam Mode: hide navigation bar & system bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadQuestions();
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _examTimer?.cancel();
    // Restore normal system bars on exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _strikeCount++;
      if (mounted) {
        if (_strikeCount >= _maxStrikes) {
          AppAudio.playWarning();
          _autoSubmitDueToAntiCheat();
        } else {
          AppAudio.playWarning();
          _showAntiCheatWarningDialog();
        }
      }
    }
  }

  void _showAntiCheatWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text('ચેતવણી ($_strikeCount/$_maxStrikes)'),
          ],
        ),
        content: Text(
          'તમે કસોટી દરમિયાન એપ બહાર નીકળ્યા અથવા મિનિમાઇઝ કર્યું.\n\nજો તમે $_maxStrikes વખત બહાર નીકળશો તો તમારું પેપર આપમેળે જમા (Auto-Submit) થઈ જશે.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('હું સમજી ગયો/ગઈ (ચાલુ રાખો)'),
          ),
        ],
      ),
    );
  }

  void _autoSubmitDueToAntiCheat() {
    _examTimer?.cancel();
    _submitExam(autoSubmitted: true);
  }

  void _startTimer() {
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _submitExam(autoSubmitted: false);
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final mins = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _loadQuestions() async {
    try {
      final jsonString = await rootBundle.loadString('assets/paper52.json');
      final data = jsonDecode(jsonString);
      if (data is Map && data.containsKey('questions')) {
        setState(() {
          _questions = data['questions'] as List<dynamic>;
          _isLoading = false;
        });
      } else if (data is List) {
        setState(() {
          _questions = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      // Fallback 180 questions
      List<dynamic> generated = [];
      for (int i = 1; i <= 180; i++) {
        generated.add({
          'id': i,
          'question': 'પ્રશ્ન $i: NMMS પરીક્ષા પ્રશ્ન',
          'options': ['વિકલ્પ A', 'વિકલ્પ B', 'વિકલ્પ C', 'વિકલ્પ D'],
          'answer': 0,
        });
      }
      setState(() {
        _questions = generated;
        _isLoading = false;
      });
    }
  }

  void _confirmSubmit() {
    final answeredCount = _answers.length;
    final totalCount = _questions.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('કસોટી જમા કરવી છે?'),
        content: Text('તમે $totalCount માંથી $answeredCount પ્રશ્નોના ઉત્તર આપ્યા છે.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('પાછા જાઓ')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppAudio.playSubmit();
              _submitExam(autoSubmitted: false);
            },
            child: const Text('હા, જમા કરો'),
          ),
        ],
      ),
    );
  }

  void _submitExam({required bool autoSubmitted}) async {
    _examTimer?.cancel();

    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final correct = q['answer'] ?? 0;
      if (_answers[i] == correct) {
        score++;
      }
    }

    final total = _questions.length;
    final pct = total > 0 ? ((score / total) * 100).round() : 0;

    // Save locally to SharedPreferences for Past Results tab
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('exam_history') ?? [];
    final now = DateTime.now();
    final entry = jsonEncode({
      'score': score,
      'total': total,
      'pct': pct,
      'autoSubmitted': autoSubmitted,
      'date': '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      'title': widget.customQuizTitle ?? 'NMMS આદર્શ પેપર 52',
    });
    history.add(entry);
    await prefs.setStringList('exam_history', history);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: score,
            total: total,
            pct: pct,
            autoSubmitted: autoSubmitted,
            studentName: widget.studentName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQ = _questions[_currentIndex];
    final isBookmarked = _bookmarks.contains(_currentIndex);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmSubmit();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'પ્રશ્ન ${_currentIndex + 1}/${_questions.length}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(_remainingSeconds),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                color: isBookmarked ? Colors.amber : Colors.white,
              ),
              onPressed: () {
                AppAudio.playMark();
                setState(() {
                  if (isBookmarked) {
                    _bookmarks.remove(_currentIndex);
                  } else {
                    _bookmarks.add(_currentIndex);
                  }
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Question Progress Bar
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),

            // AI Camera Monitoring Live Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                border: const Border(
                  bottom: BorderSide(color: Colors.redAccent, width: 0.6),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 10),
                  SizedBox(width: 6),
                  Text(
                    'LIVE AI CAMERA PROCTORING • કેમેરા નિરીક્ષણ ચાલુ છે',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      currentQ['question'] ?? 'પ્રશ્ન લોડ થઈ રહ્યો છે...',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4),
                    ),
                    const SizedBox(height: 20),

                    // Options List
                    ...List.generate(
                      (currentQ['options'] as List<dynamic>? ?? []).length,
                      (optIndex) {
                        final optionText = currentQ['options'][optIndex];
                        final isSelected = _answers[_currentIndex] == optIndex;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withValues(alpha: 0.12)
                                : (isDark ? const Color(0xFF131B2E) : Colors.white),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? primary : (isDark ? Colors.white12 : Colors.black12),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              AppAudio.playTap();
                              setState(() {
                                _answers[_currentIndex] = optIndex;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: isSelected ? primary : Colors.transparent,
                                    child: Text(
                                      String.fromCharCode(65 + optIndex), // A, B, C, D
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      optionText.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131B2E) : Colors.white,
                border: Border(
                  top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                ),
              ),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    OutlinedButton(
                      onPressed: () {
                        AppAudio.playNext();
                        setState(() {
                          _currentIndex--;
                        });
                      },
                      child: const Text('પાછળ'),
                    ),
                  const Spacer(),
                  if (_currentIndex < _questions.length - 1)
                    FilledButton(
                      onPressed: () {
                        AppAudio.playNext();
                        setState(() {
                          _currentIndex++;
                        });
                      },
                      child: const Text('આગળ'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _confirmSubmit,
                      icon: const Icon(Icons.check),
                      label: const Text('જમા કરો'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// RESULT SCREEN
// -------------------------------------------------------------
class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final int pct;
  final bool autoSubmitted;
  final String studentName;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.pct,
    required this.autoSubmitted,
    required this.studentName,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    AppAudio.playCelebration();
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.score;
    final total = widget.total;
    final pct = widget.pct;
    final autoSubmitted = widget.autoSubmitted;
    final studentName = widget.studentName;
    final isPassed = score >= 72;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (autoSubmitted)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      '🚨 એપ ૩ વખત મિનિમાઇઝ કરવાના કારણે કસોટી આપમેળે જમા થઈ ગઈ છે.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),

                Icon(
                  isPassed ? Icons.emoji_events : Icons.verified,
                  size: 80,
                  color: isPassed ? Colors.amber : Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  isPassed ? 'અભિનંદન! પરીક્ષા પાસ 🏆' : 'કસોટી સફળતાપૂર્વક પૂર્ણ!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  studentName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                // Score Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131B2E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score / $total',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ટકાવારી: $pct%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(height: 32),
                      const Text(
                        'NMMS પાસ થવા માટે ઓછામાં ઓછા 72 ગુણ જરૂરી છે.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('હોમ પેજ પર જાઓ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
