import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NmmsApp());
}

// -------------------------------------------------------------
// GOOGLE AUTH STATE & HELPERS
// -------------------------------------------------------------
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);

class AppAuth {
  static GoogleSignInAccount? currentUser;
  static String? userEmail;
  static String? userDisplayName;
  static String? userPhotoUrl;

  static final ValueNotifier<String?> userEmailNotifier = ValueNotifier<String?>(null);

  static bool get isSignedIn => userEmail != null && userEmail!.isNotEmpty;

  static bool get isAdmin {
    if (!isSignedIn) return false;
    final em = userEmail!.toLowerCase();
    return em == 'patelsandip288@gmail.com' || em == 'ponsri.big.gan.nav@gmail.com';
  }

  static Future<void> loadPersistedUser() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('auth_user_email');
    userDisplayName = prefs.getString('auth_user_name');
    userPhotoUrl = prefs.getString('auth_user_photo');
    userEmailNotifier.value = userEmail;
  }

  static Future<bool> signIn(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        currentUser = account;
        userEmail = account.email;
        userDisplayName = account.displayName ?? account.email.split('@')[0];
        userPhotoUrl = account.photoUrl;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user_email', userEmail!);
        await prefs.setString('auth_user_name', userDisplayName!);
        if (userPhotoUrl != null) {
          await prefs.setString('auth_user_photo', userPhotoUrl!);
        }
        await prefs.setString('student_name', userDisplayName!);
        userEmailNotifier.value = userEmail;
        return true;
      }
    } catch (e) {
      debugPrint('Google Sign-In notice: $e');
    }
    return false;
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    currentUser = null;
    userEmail = null;
    userDisplayName = null;
    userPhotoUrl = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user_email');
    await prefs.remove('auth_user_name');
    await prefs.remove('auth_user_photo');
    await prefs.remove('student_name');
    userEmailNotifier.value = null;
  }
}

// -------------------------------------------------------------
// LIVE QUIZ STATE (Admin Controls What is Live)
// -------------------------------------------------------------
class LiveQuizState {
  static final ValueNotifier<bool> isLive = ValueNotifier<bool>(true);
  static final ValueNotifier<String> activeQuizId = ValueNotifier<String>('paper52');
  static final ValueNotifier<String> activeQuizTitle =
      ValueNotifier<String>('NMMS આદર્શ પ્રશ્નપત્ર ક્રમાંક - 52');

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isLive.value = prefs.getBool('is_quiz_live') ?? true;
    activeQuizId.value = prefs.getString('active_quiz_id') ?? 'paper52';
    activeQuizTitle.value = prefs.getString('active_quiz_title') ??
        'NMMS આદર્શ પ્રશ્નપત્ર ક્રમાંક - 52';
  }

  static Future<void> setLiveQuiz(String id, String title) async {
    isLive.value = true;
    activeQuizId.value = id;
    activeQuizTitle.value = title;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_quiz_live', true);
    await prefs.setString('active_quiz_id', id);
    await prefs.setString('active_quiz_title', title);

    final ids = prefs.getStringList('past_live_quiz_ids') ?? [];
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList('past_live_quiz_ids', ids);
    }
  }

  static Future<void> stopLiveQuiz() async {
    isLive.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_quiz_live', false);
  }
}

// -------------------------------------------------------------
// PERMANENT LIVE LEADERBOARD MANAGER
// -------------------------------------------------------------
class LiveLeaderboardEntry {
  final String studentName;
  final String studentRoll;
  final int score;
  final int total;
  final int pct;
  final String date;
  final String quizId;
  final String quizTitle;

  LiveLeaderboardEntry({
    required this.studentName,
    required this.studentRoll,
    required this.score,
    required this.total,
    required this.pct,
    required this.date,
    required this.quizId,
    required this.quizTitle,
  });

  Map<String, dynamic> toJson() => {
        'studentName': studentName,
        'studentRoll': studentRoll,
        'score': score,
        'total': total,
        'pct': pct,
        'date': date,
        'quizId': quizId,
        'quizTitle': quizTitle,
      };

  factory LiveLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LiveLeaderboardEntry(
        studentName: json['studentName'] ?? '',
        studentRoll: json['studentRoll'] ?? '-',
        score: json['score'] ?? 0,
        total: json['total'] ?? 180,
        pct: json['pct'] ?? 0,
        date: json['date'] ?? '',
        quizId: json['quizId'] ?? '',
        quizTitle: json['quizTitle'] ?? '',
      );
}

class LiveLeaderboardManager {
  static Future<List<LiveLeaderboardEntry>> getLeaderboardForQuiz(
      String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('live_lb_$quizId') ?? [];
    final list =
        raw.map((s) => LiveLeaderboardEntry.fromJson(jsonDecode(s))).toList();
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  static List<Map<String, String>> getAllAvailableQuizzes() {
    return const [
      {
        'id': 'paper52',
        'title': 'NMMS આદર્શ પ્રશ્નપત્ર ક્રમાંક - 52',
        'desc': 'સંપૂર્ણ મોક ટેસ્ટ • MAT (90) + SAT (90)',
        'total': '180',
      },
      {
        'id': 'paper51',
        'title': 'NMMS પરીક્ષા 2023-24 પ્રશ્નપત્ર - 51',
        'desc': 'પાછલા વર્ષનું વાર્ષિક પેપર • MAT & SAT',
        'total': '180',
      },
      {
        'id': 'mat_special',
        'title': 'NMMS માનસિક ક્ષમતા કસોટી (MAT) સ્પેશિયલ',
        'desc': 'તાર્કિક વિચારણા, શ્રેણી, કોડિંગ-ડીકોડિંગ',
        'total': '90',
      },
      {
        'id': 'sat_special',
        'title': 'NMMS શૈક્ષણિક યોગ્યતા કસોટી (SAT) સ્પેશિયલ',
        'desc': 'ધોરણ ૭-૮ વિજ્ઞાન, ગણિત, સામાજિક વિજ્ઞાન',
        'total': '90',
      },
    ];
  }

  static Future<void> recordLiveSubmission({
    required String quizId,
    required String quizTitle,
    required String studentName,
    required String studentRoll,
    required int score,
    required int total,
    required int pct,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateStr =
        '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final entry = LiveLeaderboardEntry(
      studentName: studentName,
      studentRoll: studentRoll,
      score: score,
      total: total,
      pct: pct,
      date: dateStr,
      quizId: quizId,
      quizTitle: quizTitle,
    );

    final raw = prefs.getStringList('live_lb_$quizId') ?? [];
    raw.add(jsonEncode(entry.toJson()));
    await prefs.setStringList('live_lb_$quizId', raw);

    final ids = prefs.getStringList('past_live_quiz_ids') ?? [];
    if (!ids.contains(quizId)) {
      ids.add(quizId);
      await prefs.setStringList('past_live_quiz_ids', ids);
    }
  }
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

  static final simpleLight = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: const Color(0xFF2563EB),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    cardColor: const Color(0xFFF1F5F9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2563EB),
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
  int _themeIndex = 0; // 0: Indigo, 1: Simple Light, 2: OLED Dark, 3: Forest, 4: Warm Sepia

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    await AppAuth.loadPersistedUser();
    await LiveQuizState.load();
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
    _setTheme((_themeIndex + 1) % 5);
  }

  ThemeData _getTheme() {
    switch (_themeIndex) {
      case 1:
        return AppThemes.simpleLight;
      case 2:
        return AppThemes.oledDark;
      case 3:
        return AppThemes.forestSage;
      case 4:
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
            // Animated Pure White Logo Container (No Border Line)
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.12),
                        blurRadius: 24,
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
    return ValueListenableBuilder<String?>(
      valueListenable: AppAuth.userEmailNotifier,
      builder: (context, userEmail, _) {
        final bool isAdmin = AppAuth.isAdmin;

        final List<Widget> pages = [
          ExamHomeScreen(
            onOpenPastQuizzes: () => setState(() => _selectedIndex = 1),
            onOpenResults: () => setState(() => _selectedIndex = 2),
            onOpenAdmin: isAdmin ? () => setState(() => _selectedIndex = 4) : null,
          ),
          PastQuizzesScreen(
            onSelectQuiz: (quizTitle, quizData) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExamScreen(
                    studentName: AppAuth.userDisplayName ?? 'વિદ્યાર્થી',
                    studentRoll: '01',
                    customQuizTitle: quizTitle,
                    customQuizData: quizData,
                    isLiveExam: false,
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
          if (isAdmin) const AdminScreen(),
        ];

        final List<NavigationDestination> destinations = [
          const NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'કસોટી',
          ),
          const NavigationDestination(
            icon: Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(Icons.history_edu),
            label: 'જૂની કસોટી',
          ),
          const NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'પરિણામો',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'પ્રોફાઇલ',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: Icon(Icons.admin_panel_settings),
              label: 'એડમિન',
            ),
        ];

        if (_selectedIndex >= pages.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
          body: pages[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: destinations,
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// ANIMATED BATTERY WARNING WIDGET (100% Charge Warning)
// -------------------------------------------------------------
class AnimatedBatteryWarningWidget extends StatefulWidget {
  const AnimatedBatteryWarningWidget({super.key});

  @override
  State<AnimatedBatteryWarningWidget> createState() => _AnimatedBatteryWarningWidgetState();
}

class _AnimatedBatteryWarningWidgetState extends State<AnimatedBatteryWarningWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _batteryProgress;
  late Animation<double> _pulseGlow;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _batteryProgress = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _pulseGlow = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF1E1B4B).withValues(alpha: 0.9),
                      const Color(0xFF064E3B).withValues(alpha: 0.8),
                    ]
                  : [
                      const Color(0xFFFEF3C7),
                      const Color(0xFFDCFCE7),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.5 * _pulseGlow.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.12 * _pulseGlow.value),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Battery Graphic
                  Container(
                    width: 44,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: (_batteryProgress.value * 100).toInt(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _batteryProgress.value > 0.8
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: (100 - (_batteryProgress.value * 100)).toInt().clamp(0, 100),
                          child: const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 3,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(2),
                        bottomRight: Radius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.bolt, color: Color(0xFFF59E0B), size: 22),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'ફોન ૧૦૦% ચાર્જ રાખવો ફરજિયાત છે!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: isDark ? const Color(0xFF34D399) : const Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'આ NMMS કસોટી ૧૮૦ મિનિટ (૩ કલાક) ચાલશે. કસોટી દરમિયાન ફોન સ્વીચ-ઑફ ન થાય તે માટે ફોનને ૧૦૦% ચાર્જ રાખીને જ કસોટી શરૂ કરવી અથવા ચાર્જર જોડીને રાખવું.',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.battery_charging_full, size: 14, color: Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text(
                          '૧૦૦% ચાર્જિંગ સુનિશ્ચિત કરો (100% Charged Required)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// TAB 1: EXAM HOME SCREEN (With Instructions & Start)
// -------------------------------------------------------------
class ExamHomeScreen extends StatefulWidget {
  final VoidCallback onOpenPastQuizzes;
  final VoidCallback onOpenResults;
  final VoidCallback? onOpenAdmin;

  const ExamHomeScreen({
    super.key,
    required this.onOpenPastQuizzes,
    required this.onOpenResults,
    this.onOpenAdmin,
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

    // AI Camera Monitoring Security Dialog before starting
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
            Text('• કસોટી શરૂ કરવા માટે કેમેરા પરમિશન આપવી ફરજિયાત છે.', style: TextStyle(fontSize: 12)),
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
            onPressed: () async {
              Navigator.pop(ctx);
              // Request native Android runtime camera permission
              try {
                const channel = MethodChannel('in.ponsrischool.nmms/camera');
                await channel.invokeMethod('requestCameraPermission');
              } catch (e) {
                debugPrint('Native camera request error: $e');
              }
              _proceedToExam();
            },
            icon: const Icon(Icons.videocam, size: 18),
            label: const Text('કેમેરા મંજૂર કરો અને શરૂ કરો'),
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
          customQuizTitle: LiveQuizState.activeQuizTitle.value,
          isLiveExam: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return ValueListenableBuilder<bool>(
      valueListenable: LiveQuizState.isLive,
      builder: (context, isLive, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LiveQuizState.activeQuizTitle,
          builder: (context, activeTitle, _) {
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.school, color: primary),
                                ),
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
                                    'તા. ગણદેવી, જી. નવસારી • NMMS તૈયારી',
                                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isLive
                                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                          : Colors.red.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isLive
                                          ? '● કસોટી સક્રિય છે (LIVE)'
                                          : '● લાઈવ કસોટી બંધ છે (QUIZ STOPPED)',
                                      style: TextStyle(
                                        color: isLive ? const Color(0xFF10B981) : Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // If NO Quiz is currently live, show clear alert card
                      if (!isLive) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.pause_circle_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 10),
                              const Text(
                                'હાલમાં કોઈ કસોટી લાઈવ નથી',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.red),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'શિક્ષક / એડમિન દ્વારા નવી લાઈવ કસોટી શરૂ કરવામાં આવે ત્યાં સુધી રાહ જુઓ.\nપરંતુ તમે પ્રેક્ટિસ માટે નીચેથી જૂની કસોટીઓ આપી શકો છો!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 14),
                              FilledButton.icon(
                                onPressed: widget.onOpenPastQuizzes,
                                icon: const Icon(Icons.history_edu),
                                label: const Text('જૂની કસોટીઓ આપો (Past Quizzes)'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

              const SizedBox(height: 14),

              // Google Sign-In & Profile Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131B2E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: AppAuth.isSignedIn
                    ? Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: primary.withValues(alpha: 0.15),
                            backgroundImage: AppAuth.userPhotoUrl != null
                                ? NetworkImage(AppAuth.userPhotoUrl!)
                                : null,
                            child: AppAuth.userPhotoUrl == null
                                ? Icon(Icons.person, color: primary, size: 24)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        AppAuth.userDisplayName ?? 'વિદ્યાર્થી',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppAuth.userEmail ?? '',
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await AppAuth.signOut();
                              setState(() {
                                _nameController.clear();
                              });
                            },
                            child: const Text('બદલો', style: TextStyle(fontSize: 11)),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.account_circle_outlined, color: Colors.redAccent, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Google સાઇન-ઇન (Google Account)',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
                                    Text(
                                      'પરીક્ષા પરિણામ સુરક્ષિત સેવ કરવા લૉગિન કરો',
                                      style: TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () async {
                              final ok = await AppAuth.signIn(context);
                              if (ok && mounted) {
                                setState(() {
                                  _nameController.text = AppAuth.userDisplayName ?? '';
                                });
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF4285F4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.login, size: 18),
                            label: const Text(
                              'Google વડે સાઇન-ઇન કરો',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
              ),

              // Admin Access Banner on Home Screen (ONLY when signed in as Admin)
              if (AppAuth.isAdmin) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'એડમિન મોડ સક્રિય છે 👑',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'કસોટી લાઈવ/સ્ટોપ કરો અને લીડરબોર્ડ નિયંત્રિત કરો',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: widget.onOpenAdmin,
                        icon: const Icon(Icons.tune, size: 16),
                        label: const Text('કંટ્રોલ પેનલ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],

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

              // Animated Battery 100% Warning Widget
              const AnimatedBatteryWarningWidget(),

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
                              isDark,
                            ),
                            const SizedBox(height: 4),
                            _buildBulletItem(
                              'Total Questions & Marks:',
                              '180 questions / 180 marks (1 mark per question).',
                              isDark,
                            ),
                            const SizedBox(height: 4),
                            _buildBulletItem(
                              'Negative Marking:',
                              'There is no negative marking.',
                              isDark,
                            ),

                            const SizedBox(height: 14),

                            // Section 2: Common Exam Room Instructions
                            _buildInstructionHeader('Common Exam Room Instructions', Icons.menu_book, Colors.amber.shade800),
                            const SizedBox(height: 6),
                            _buildBulletItem('AI Camera Proctoring:', 'કસોટી દરમિયાન AI કેમેરા નિરીક્ષણ સક્રિય રહેશે. કસોટી આપતી વખતે તમારો ચહેરો સતત કેમેરા સામે રાખવો ફરજિયાત છે.', isDark),
                            _buildBulletItem('OMR Sheet Usage:', 'All answers must be indicated by shading the correct circle on a separate OMR answer sheet using the prescribed pen/pencil.', isDark),
                            _buildBulletItem('Question Booklet Series:', 'You must carefully write and shade your question booklet series code (such as A, B, C, D, or E) on the OMR sheet.', isDark),
                            _buildBulletItem('Rough Work:', 'Use only the blank pages provided at the end of the question booklet for rough work. Do not write on the OMR sheet outside designated fields.', isDark),
                            _buildBulletItem('Time Management:', 'Do not spend too much time on a single question if you are unsure; move on and return to it later if time permits.', isDark),
                            _buildBulletItem('Submission:', 'Hand over the OMR sheet and question booklet (as required by the invigilator) before leaving the exam room.', isDark),

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

              // START EXAM BUTTON (Active only when Quiz is Live)
              FilledButton.icon(
                onPressed: isLive ? _startTest : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: isLive ? primary : Colors.grey.shade400,
                ),
                icon: Icon(isLive ? Icons.play_arrow : Icons.lock_clock),
                label: Text(
                  isLive
                      ? 'કસોટી શરૂ કરો: $activeTitle'
                      : 'લાઈવ કસોટી હાલમાં બંધ છે',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
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
          },
        );
      },
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

  Widget _buildBulletItem(String title, String description, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              height: 1.35,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
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
// TAB 3: PAST RESULTS & PERMANENT LIVE LEADERBOARDS SCREEN
// -------------------------------------------------------------
class PastResultsScreen extends StatefulWidget {
  const PastResultsScreen({super.key});

  @override
  State<PastResultsScreen> createState() => _PastResultsScreenState();
}

class _PastResultsScreenState extends State<PastResultsScreen> {
  List<Map<String, dynamic>> _myResults = [];
  bool _isLoadingMy = true;

  String _selectedQuizId = 'paper52';
  List<LiveLeaderboardEntry> _liveLeaderboard = [];
  bool _isLoadingLb = false;

  @override
  void initState() {
    super.initState();
    _loadMyResults();
    _loadLiveLeaderboard();
  }

  void _loadMyResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('exam_history') ?? [];
    List<Map<String, dynamic>> parsed = [];
    for (var item in raw) {
      try {
        parsed.add(Map<String, dynamic>.from(jsonDecode(item)));
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _myResults = parsed.reversed.toList(); // Newest first
        _isLoadingMy = false;
      });
    }
  }

  void _loadLiveLeaderboard() async {
    setState(() {
      _isLoadingLb = true;
    });
    final lb = await LiveLeaderboardManager.getLeaderboardForQuiz(_selectedQuizId);
    if (mounted) {
      setState(() {
        _liveLeaderboard = lb;
        _isLoadingLb = false;
      });
    }
  }

  void _clearMyResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('exam_history');
    setState(() {
      _myResults = [];
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('તમારો ઇતિહાસ સફળતાપૂર્વક સાફ કરવામાં આવ્યો છે.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final quizzes = LiveLeaderboardManager.getAllAvailableQuizzes();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('પરિણામો અને લીડરબોર્ડ'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.history, size: 20), text: 'મારા પ્રયાસો'),
              Tab(icon: Icon(Icons.emoji_events, size: 20), text: '🏆 લાઈવ લીડરબોર્ડ'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'ઇતિહાસ સાફ કરો',
              onPressed: _clearMyResults,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'રીફ્રેશ કરો',
              onPressed: () {
                _loadMyResults();
                _loadLiveLeaderboard();
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // TAB 1: MY ATTEMPTS
            _isLoadingMy
                ? const Center(child: CircularProgressIndicator())
                : _myResults.isEmpty
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
                        itemCount: _myResults.length,
                        itemBuilder: (context, index) {
                          final res = _myResults[index];
                          final score = res['score'] ?? 0;
                          final total = res['total'] ?? 180;
                          final pct = res['pct'] ?? 0;
                          final date = res['date'] ?? 'આજે';
                          final title = res['title'] ?? 'NMMS આદર્શ પેપર 52';
                          final isPassed = score >= (total * 0.4).round();

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
                                        const SizedBox(height: 2),
                                        Text(
                                          title,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$score / $total ગુણ • $date',
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                        if (res['questionAnalysis'] != null &&
                                            (res['questionAnalysis'] as List).isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          FilledButton.tonalIcon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ExamReviewScreen(
                                                    quizTitle: title,
                                                    score: score,
                                                    total: total,
                                                    questionAnalysis:
                                                        res['questionAnalysis'] as List<dynamic>,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.analytics_outlined, size: 14),
                                            label: const Text('પ્રશ્નો અને સમય વિશ્લેષણ જુઓ',
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                            style: FilledButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

            // TAB 2: PERMANENT LIVE LEADERBOARD
            Column(
              children: [
                // Live Quiz Picker Strip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9),
                    border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: quizzes.map((q) {
                        final isSelected = q['id'] == _selectedQuizId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(q['title']!),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedQuizId = q['id']!;
                                });
                                _loadLiveLeaderboard();
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Leaderboard List
                Expanded(
                  child: _isLoadingLb
                      ? const Center(child: CircularProgressIndicator())
                      : _liveLeaderboard.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.military_tech_outlined, size: 64, color: Colors.amber),
                                    SizedBox(height: 14),
                                    Text(
                                      'આ લાઈવ કસોટી માટે હજી કોઈ પરિણામ નોંધાયેલ નથી.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'માત્ર લાઈવ કસોટી આપનારા વિદ્યાર્થીઓનું પરિણામ જ કાયમી લીડરબોર્ડમાં સમાવેશ થાય છે.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _liveLeaderboard.length,
                              itemBuilder: (context, index) {
                                final entry = _liveLeaderboard[index];
                                final rank = index + 1;

                                Color rankBadgeColor;
                                String rankMedal = '$rank';
                                if (rank == 1) {
                                  rankBadgeColor = const Color(0xFFF59E0B);
                                  rankMedal = '🥇 1';
                                } else if (rank == 2) {
                                  rankBadgeColor = const Color(0xFF94A3B8);
                                  rankMedal = '🥈 2';
                                } else if (rank == 3) {
                                  rankBadgeColor = const Color(0xFFB45309);
                                  rankMedal = '🥉 3';
                                } else {
                                  rankBadgeColor = isDark ? Colors.white24 : Colors.black26;
                                }

                                return Card(
                                  elevation: 0,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: rank <= 3
                                          ? rankBadgeColor.withValues(alpha: 0.6)
                                          : (isDark ? Colors.white12 : Colors.black12),
                                      width: rank <= 3 ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: rankBadgeColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            rankMedal,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: rank <= 3 ? 14 : 16,
                                              color: rankBadgeColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.studentName,
                                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'રોલ નં: ${entry.studentRoll} • ${entry.date}',
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${entry.score}/${entry.total}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 15,
                                                color: primary,
                                              ),
                                            ),
                                            Text(
                                              '${entry.pct}%',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
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
  String _name = 'વિદ્યાર્થી';
  String _roll = '-';
  final String _school = 'PM SHRI PRATHMIK VIDHYAMANDIR PONSRI';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('student_name') ?? 'વિદ્યાર્થી';
      _roll = prefs.getString('student_roll') ?? '-';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final themeOptions = [
      {'name': 'Modern Indigo', 'color': const Color(0xFF4338CA)},
      {'name': 'Simple Light', 'color': const Color(0xFF2563EB)},
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
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: primary.withValues(alpha: 0.15),
                      backgroundImage: AppAuth.userPhotoUrl != null
                          ? NetworkImage(AppAuth.userPhotoUrl!)
                          : null,
                      child: AppAuth.userPhotoUrl == null
                          ? Icon(Icons.person, size: 36, color: primary)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppAuth.isSignedIn ? (AppAuth.userDisplayName ?? _name) : _name,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (AppAuth.isSignedIn) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: Color(0xFF10B981), size: 18),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppAuth.isSignedIn
                                ? (AppAuth.userEmail ?? '')
                                : 'રોલ નંબર: $_roll',
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
                if (AppAuth.isSignedIn) ...[
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppAuth.isAdmin
                              ? Colors.purple.withValues(alpha: 0.15)
                              : Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppAuth.isAdmin ? '👑 એડમિન એકાઉન્ટ' : '🎓 વિદ્યાર્થી એકાઉન્ટ',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppAuth.isAdmin ? Colors.purple : Colors.blue,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await AppAuth.signOut();
                          setState(() {});
                        },
                        icon: const Icon(Icons.logout, size: 14),
                        label: const Text('લૉગઆઉટ', style: TextStyle(fontSize: 11)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
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
                    margin: EdgeInsets.only(right: idx == themeOptions.length - 1 ? 0 : 6),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'સુરક્ષા ફીચર્સ (Anti-Cheat Active)',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text('• 3-Strike Minimize Auto-Submit: સક્રિય', style: TextStyle(fontSize: 12)),
                SizedBox(height: 4),
                Text('• Screen Keep Awake: સક્રિય', style: TextStyle(fontSize: 12)),
                SizedBox(height: 4),
                Text('• Firebase Firestore Cloud Sync: સક્રિય', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 5: ADMIN CONTROL SCREEN (Google Auth, Live Controller, Leaderboard)
// -------------------------------------------------------------
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _selectedAdminQuizId = 'paper52';
  List<LiveLeaderboardEntry> _adminLeaderboard = [];
  bool _isLoadingLb = false;

  @override
  void initState() {
    super.initState();
    _loadAdminLeaderboard();
  }

  void _loadAdminLeaderboard() async {
    setState(() => _isLoadingLb = true);
    final lb = await LiveLeaderboardManager.getLeaderboardForQuiz(_selectedAdminQuizId);
    if (mounted) {
      setState(() {
        _adminLeaderboard = lb;
        _isLoadingLb = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final allQuizzes = LiveLeaderboardManager.getAllAvailableQuizzes();

    // 1. Google Authentication Gate (No PIN, Only Google Sign-In)
    if (!AppAuth.isAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('એડમિન લૉગિન'),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 48, color: Colors.indigo),
                ),
                const SizedBox(height: 20),
                const Text(
                  'શિક્ષક / એડમિન ઓથોરાઇઝેશન',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'કસોટી લાઈવ કરવા, રોકવા અથવા લીડરબોર્ડ નિયંત્રણ માટે એડમિન Google એકાઉન્ટ વડે સાઇન-ઇન કરવું ફરજિયાત છે.\n\n(અધિકૃત: patelsandip288@gmail.com / ponsri.big.gan.nav@gmail.com)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await AppAuth.signIn(context);
                    if (ok && mounted) {
                      setState(() {});
                    } else if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('આ Google એકાઉન્ટ પાસે એડમિન પરવાનગી નથી.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text(
                    'Google વડે એડમિન પ્રવેશ કરો',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Admin Control Dashboard (Authorized)
    return ValueListenableBuilder<bool>(
      valueListenable: LiveQuizState.isLive,
      builder: (context, isLive, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LiveQuizState.activeQuizTitle,
          builder: (context, activeTitle, _) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('એડમિન કંટ્રોલ પેનલ 👑'),
                actions: [
                  IconButton(
                    tooltip: 'લૉગઆઉટ',
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await AppAuth.signOut();
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Admin Identity Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
                            : [const Color(0xFFEEF2FF), const Color(0xFFFAF5FF)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.indigo.withValues(alpha: 0.2),
                          backgroundImage: AppAuth.userPhotoUrl != null
                              ? NetworkImage(AppAuth.userPhotoUrl!)
                              : null,
                          child: AppAuth.userPhotoUrl == null
                              ? const Icon(Icons.shield, color: Colors.indigo, size: 28)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppAuth.userDisplayName ?? 'પટેલ સંદીપ',
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified, color: Colors.indigo, size: 16),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppAuth.userEmail ?? '',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'પીએમ શ્રી શાળા પોંસરી • મુખ્ય એડમિનિસ્ટ્રેટર',
                                style: TextStyle(fontSize: 10, color: Colors.indigo, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // LIVE QUIZ CONTROLLER CARD
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131B2E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isLive ? const Color(0xFF10B981) : Colors.red,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isLive ? const Color(0xFF10B981) : Colors.red).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fiber_manual_record,
                                    size: 10,
                                    color: isLive ? const Color(0xFF10B981) : Colors.red,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isLive ? 'કસોટી લાઈવ ચાલુ છે' : 'કસોટી લાઈવ બંધ છે',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: isLive ? const Color(0xFF10B981) : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: isLive,
                              activeThumbColor: const Color(0xFF10B981),
                              onChanged: (val) async {
                                if (val) {
                                  await LiveQuizState.setLiveQuiz(
                                    LiveQuizState.activeQuizId.value,
                                    LiveQuizState.activeQuizTitle.value,
                                  );
                                } else {
                                  await LiveQuizState.stopLiveQuiz();
                                }
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'સક્રિય લાઈવ કસોટી:',
                          style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          activeTitle,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            if (isLive)
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    await LiveQuizState.stopLiveQuiz();
                                    setState(() {});
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('લાઈવ કસોટી સફળતાપૂર્વક બંધ કરવામાં આવી.')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.stop, size: 18),
                                  label: const Text('કસોટી લાઈવ બંધ કરો'),
                                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                ),
                              )
                            else
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    await LiveQuizState.setLiveQuiz(
                                      LiveQuizState.activeQuizId.value,
                                      LiveQuizState.activeQuizTitle.value,
                                    );
                                    setState(() {});
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('કસોટી સફળતાપૂર્વક લાઈવ શરૂ કરવામાં આવી.')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.play_arrow, size: 18),
                                  label: const Text('કસોટી લાઈવ શરૂ કરો'),
                                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // MAKE ANY PAST QUIZ LIVE SECTION
                  const Text(
                    'કોઈપણ કસોટી લાઈવ બનાવો (Make Any Quiz Live)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'અહીંથી કોઈપણ જૂની કે નવી કસોટી પસંદ કરીને તેને લાઈવ કરી શકો છો:',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  ...allQuizzes.map((quiz) {
                    final isThisLive = isLive && LiveQuizState.activeQuizId.value == quiz['id'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131B2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isThisLive
                              ? const Color(0xFF10B981)
                              : (isDark ? Colors.white10 : Colors.black12),
                          width: isThisLive ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: (isThisLive ? const Color(0xFF10B981) : primary).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.quiz_outlined,
                              color: isThisLive ? const Color(0xFF10B981) : primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quiz['title']!,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  quiz['desc']!,
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isThisLive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'સક્રિય લાઈવ',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            FilledButton.tonal(
                              onPressed: () async {
                                await LiveQuizState.setLiveQuiz(quiz['id']!, quiz['title']!);
                                setState(() {
                                  _selectedAdminQuizId = quiz['id']!;
                                });
                                _loadAdminLeaderboard();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${quiz['title']} લાઈવ થઈ ગઈ છે!')),
                                  );
                                }
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('લાઈવ કરો', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 24),

                  // PERMANENT LEADERBOARDS INSPECTOR (ADMIN VIEW)
                  Row(
                    children: [
                      const Icon(Icons.leaderboard, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'કાયમી લાઈવ લીડરબોર્ડ્સ (Permanent Leaderboards)',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        tooltip: 'રીફ્રેશ',
                        onPressed: _loadAdminLeaderboard,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'માત્ર લાઈવ કસોટી આપનારા વિદ્યાર્થીઓના રેકોર્ડ જ સંગ્રહાય છે:',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),

                  // Quiz Filter Chips for Admin Leaderboard
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: allQuizzes.map((q) {
                        final isSelected = q['id'] == _selectedAdminQuizId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(q['title']!),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) {
                                setState(() {
                                  _selectedAdminQuizId = q['id']!;
                                });
                                _loadAdminLeaderboard();
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_isLoadingLb)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  else if (_adminLeaderboard.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131B2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: const Center(
                        child: Text(
                          'આ લાઈવ કસોટી માટે હજી સુધી કોઈ વિદ્યાર્થીએ સબમિટ કર્યું નથી.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_adminLeaderboard.length, (idx) {
                      final item = _adminLeaderboard[idx];
                      final rank = idx + 1;
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: rank <= 3
                                ? (rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey : Colors.brown))
                                : (isDark ? Colors.white12 : Colors.black12),
                            child: Text(
                              rank <= 3 ? (rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉')) : '$rank',
                              style: TextStyle(
                                fontSize: rank <= 3 ? 14 : 12,
                                fontWeight: FontWeight.bold,
                                color: rank <= 3 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ),
                          title: Text(item.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('રોલ નં: ${item.studentRoll} • ${item.date}', style: const TextStyle(fontSize: 10)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${item.score}/${item.total}', style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontSize: 14)),
                              Text('${item.pct}%', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        );
      },
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
  final bool isLiveExam;

  const ExamScreen({
    super.key,
    required this.studentName,
    required this.studentRoll,
    this.customQuizTitle,
    this.customQuizData,
    this.isLiveExam = true,
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
  DateTime? _lastStrikeTime;

  Timer? _examTimer;
  int _remainingSeconds = 180 * 60; // 3 hours = 180 mins

  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isCameraCollapsed = false;

  final Map<int, int> _timeSpentPerQuestion = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Secure Fullscreen Exam Mode: hide navigation bar & system bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initCamera();
    _loadQuestions();
    _startTimer();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final frontCam = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        final ctrl = CameraController(
          frontCam,
          ResolutionPreset.low,
          enableAudio: false,
        );
        _cameraController = ctrl;
        await ctrl.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Camera proctoring init notice: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _examTimer?.cancel();
    _cameraController?.dispose();
    // Restore normal system bars on exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      final now = DateTime.now();
      // Debounce multiple lifecycle events from a single minimize to home screen
      if (_lastStrikeTime != null && now.difference(_lastStrikeTime!) < const Duration(seconds: 3)) {
        return;
      }
      _lastStrikeTime = now;
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
        content: const Text(
          'તમે કસોટી દરમિયાન એપ બહાર નીકળ્યા અથવા મિનિમાઇઝ કર્યું.\n\nજો તમે ૩ વખત બહાર નીકળશો તો તમારું પેપર આપમેળે જમા (Auto-Submit) થઈ જશે.',
          style: TextStyle(fontSize: 13),
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
          _timeSpentPerQuestion[_currentIndex] =
              (_timeSpentPerQuestion[_currentIndex] ?? 0) + 1;
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

  void _openQuestionNavigator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _QuestionNavigatorSheet(
        totalQuestions: _questions.length,
        currentIndex: _currentIndex,
        answers: _answers,
        bookmarks: _bookmarks,
        onSelectQuestion: (index) {
          setState(() {
            _currentIndex = index;
          });
          AppAudio.playTap();
        },
        onSubmit: () {
          _confirmSubmit();
        },
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

    // Build question analysis (which questions were wrong, empty, correct, and time spent)
    final List<Map<String, dynamic>> questionAnalysis = [];
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final studentAns = _answers[i];
      final correctAns = q['answer'] ?? 0;
      final timeSpent = _timeSpentPerQuestion[i] ?? 0;
      final String status = studentAns == null
          ? 'unattempted'
          : (studentAns == correctAns ? 'correct' : 'incorrect');

      questionAnalysis.add({
        'index': i,
        'question': q['question'] ?? 'પ્રશ્ન ${i + 1}',
        'options': q['options'] ?? ['વિકલ્પ A', 'વિકલ્પ B', 'વિકલ્પ C', 'વિકલ્પ D'],
        'studentAnswer': studentAns,
        'correctAnswer': correctAns,
        'status': status,
        'timeSpentSeconds': timeSpent,
      });
    }

    // Record to permanent live leaderboard ONLY if this is an official Live Exam
    if (widget.isLiveExam) {
      await LiveLeaderboardManager.recordLiveSubmission(
        quizId: LiveQuizState.activeQuizId.value,
        quizTitle: widget.customQuizTitle ?? LiveQuizState.activeQuizTitle.value,
        studentName: widget.studentName,
        studentRoll: widget.studentRoll,
        score: score,
        total: total,
        pct: pct,
      );
    }

    // Save locally to SharedPreferences for personal history
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('exam_history') ?? [];
    final now = DateTime.now();
    final entry = jsonEncode({
      'score': score,
      'total': total,
      'pct': pct,
      'autoSubmitted': autoSubmitted,
      'isLive': widget.isLiveExam,
      'date': '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
      'title': widget.customQuizTitle ?? LiveQuizState.activeQuizTitle.value,
      'questionAnalysis': questionAnalysis,
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
            quizTitle: widget.customQuizTitle ?? LiveQuizState.activeQuizTitle.value,
            questionAnalysis: questionAnalysis,
          ),
        ),
      );
    }
  }

  Widget _buildFloatingCameraProctorTile(bool isDark) {
    if (_isCameraCollapsed) {
      return GestureDetector(
        onTap: () => setState(() => _isCameraCollapsed = false),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.3),
                blurRadius: 6,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fiber_manual_record, color: Colors.red, size: 10),
              SizedBox(width: 4),
              Text(
                'AI CAM ON',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 105,
      height: 135,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withValues(alpha: 0.25),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (_isCameraReady && _cameraController != null && _cameraController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 100,
                  height: _cameraController!.value.previewSize?.width ?? 130,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            Container(
              color: const Color(0xFF0F172A),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face, color: Colors.white54, size: 36),
                    SizedBox(height: 4),
                    Text(
                      'AI SCANNING',
                      style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // Face Bounding Box
          Center(
            child: Container(
              width: 70,
              height: 90,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Red REC Badge
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.white, size: 7),
                  SizedBox(width: 3),
                  Text(
                    'REC',
                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // Collapse Button
          Positioned(
            top: 2,
            right: 2,
            child: InkWell(
              onTap: () => setState(() => _isCameraCollapsed = true),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.close, color: Colors.white70, size: 12),
              ),
            ),
          ),

          // Bottom AI Proctor Tag
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2),
              color: Colors.black.withValues(alpha: 0.7),
              child: const Text(
                'AI PROCTOR • LIVE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
            IconButton(
              tooltip: 'પ્રશ્ન નેવિગેટર (Question Grid)',
              icon: const Icon(Icons.grid_view_rounded),
              onPressed: _openQuestionNavigator,
            ),
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
        body: Stack(
          children: [
            Column(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        )
                      else
                        const SizedBox(width: 60),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _openQuestionNavigator,
                        icon: const Icon(Icons.grid_view_rounded, size: 16),
                        label: Text('${_currentIndex + 1}/${_questions.length}'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
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

            // Floating Live Camera Proctoring Tile (Top Right)
            Positioned(
              top: 8,
              right: 12,
              child: _buildFloatingCameraProctorTile(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// QUESTION NAVIGATOR MODAL SHEET (Matches User's UI Screenshot)
// -------------------------------------------------------------
class _QuestionNavigatorSheet extends StatefulWidget {
  final int totalQuestions;
  final int currentIndex;
  final Map<int, int> answers;
  final Set<int> bookmarks;
  final ValueChanged<int> onSelectQuestion;
  final VoidCallback onSubmit;

  const _QuestionNavigatorSheet({
    required this.totalQuestions,
    required this.currentIndex,
    required this.answers,
    required this.bookmarks,
    required this.onSelectQuestion,
    required this.onSubmit,
  });

  @override
  State<_QuestionNavigatorSheet> createState() => _QuestionNavigatorSheetState();
}

class _QuestionNavigatorSheetState extends State<_QuestionNavigatorSheet> {
  int _filterIndex = 0; // 0: બધા (All), 1: આપેલ (Answered), 2: બાકી (Pending), 3: રિવ્યુ (Review)

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final answeredCount = widget.answers.length;
    final reviewCount = widget.bookmarks.length;
    final pendingCount = widget.totalQuestions - answeredCount;

    // Filter questions based on selected tab
    final List<int> displayIndices = [];
    for (int i = 0; i < widget.totalQuestions; i++) {
      if (_filterIndex == 1) {
        if (widget.answers.containsKey(i)) displayIndices.add(i);
      } else if (_filterIndex == 2) {
        if (!widget.answers.containsKey(i)) displayIndices.add(i);
      } else if (_filterIndex == 3) {
        if (widget.bookmarks.contains(i)) displayIndices.add(i);
      } else {
        displayIndices.add(i);
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header Row: Grid Icon, Title, Total Count Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: Color(0xFF818CF8), size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'પ્રશ્ન નેવિગેટર',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'કુલ: ${widget.totalQuestions}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Status Legend Row (Answered, Review, Pending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem(const Color(0xFF10B981), 'ઉત્તર આપેલ ($answeredCount)'),
                    _buildLegendItem(const Color(0xFFF59E0B), 'રિવ્યુ ($reviewCount)'),
                    _buildLegendItem(Colors.white38, 'બાકી ($pendingCount)'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter Tabs: [બધા] [આપેલ] [બાકી] [રિવ્યુ]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildFilterTab(0, 'બધા'),
                    _buildFilterTab(1, 'આપેલ'),
                    _buildFilterTab(2, 'બાકી'),
                    _buildFilterTab(3, 'રિવ્યુ'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Questions 5-Column Grid
            Expanded(
              child: displayIndices.isEmpty
                  ? const Center(
                      child: Text(
                        'આ કેટેગરીમાં કોઈ પ્રશ્નો નથી.',
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: displayIndices.length,
                      itemBuilder: (context, idx) {
                        final qIndex = displayIndices[idx];
                        final isCurrent = qIndex == widget.currentIndex;
                        final isAnswered = widget.answers.containsKey(qIndex);
                        final isBookmarked = widget.bookmarks.contains(qIndex);

                        Color bgColor;
                        Color textColor;
                        Color borderColor;

                        if (isCurrent) {
                          bgColor = Colors.white;
                          textColor = const Color(0xFF4338CA);
                          borderColor = const Color(0xFF818CF8);
                        } else if (isAnswered) {
                          bgColor = const Color(0xFF10B981).withValues(alpha: 0.22);
                          textColor = const Color(0xFF34D399);
                          borderColor = const Color(0xFF10B981);
                        } else if (isBookmarked) {
                          bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.22);
                          textColor = const Color(0xFFFBBF24);
                          borderColor = const Color(0xFFF59E0B);
                        } else {
                          bgColor = Colors.white.withValues(alpha: 0.08);
                          textColor = Colors.white70;
                          borderColor = Colors.white.withValues(alpha: 0.12);
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSelectQuestion(qIndex);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                                width: isCurrent ? 2 : 1,
                              ),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  '${qIndex + 1}',
                                  style: TextStyle(
                                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.bold,
                                    fontSize: 13,
                                    color: textColor,
                                  ),
                                ),
                                if (isBookmarked && !isCurrent)
                                  const Positioned(
                                    top: 2,
                                    right: 2,
                                    child: Icon(Icons.bookmark, size: 9, color: Color(0xFFF59E0B)),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Submit Exam Action Button (at bottom of Navigator Sheet)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSubmit();
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'કસોટી જમા કરો',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color dotColor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildFilterTab(int index, String label) {
    final isSelected = _filterIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filterIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF334155) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.white60,
            ),
          ),
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
  final String quizTitle;
  final List<dynamic> questionAnalysis;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.pct,
    required this.autoSubmitted,
    required this.studentName,
    this.quizTitle = 'NMMS આદર્શ પેપર 52',
    this.questionAnalysis = const [],
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
    final qList = widget.questionAnalysis;
    final incorrectCount = qList.where((q) => q['status'] == 'incorrect').length;
    final unattemptedCount = qList.where((q) => q['status'] == 'unattempted').length;

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
                      const Divider(height: 28),

                      // Breakdown Pills
                      if (qList.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '✅ સાચા: $score',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '❌ ખોટા: $incorrectCount',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '⚪ બાકી: $unattemptedCount',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],

                      const Text(
                        'NMMS પાસ થવા માટે ઓછામાં ઓછા 72 ગુણ જરૂરી છે.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Button 1: Review Questions & Answers (Requested by User)
                if (qList.isNotEmpty) ...[
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExamReviewScreen(
                            quizTitle: widget.quizTitle,
                            score: score,
                            total: total,
                            questionAnalysis: qList,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.analytics_outlined),
                    label: const Text('પ્રશ્નો, ઉત્તરો અને સમય વિશ્લેષણ જુઓ'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('હોમ પેજ પર જાઓ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// EXAM REVIEW SCREEN (Questions, Answers, Time Spent Per Question)
// -------------------------------------------------------------
class ExamReviewScreen extends StatefulWidget {
  final String quizTitle;
  final int score;
  final int total;
  final List<dynamic> questionAnalysis;

  const ExamReviewScreen({
    super.key,
    required this.quizTitle,
    required this.score,
    required this.total,
    required this.questionAnalysis,
  });

  @override
  State<ExamReviewScreen> createState() => _ExamReviewScreenState();
}

class _ExamReviewScreenState extends State<ExamReviewScreen> {
  int _filterIndex = 0; // 0: બધા, 1: ખોટા, 2: સાચા, 3: ખાલી રાખેલ

  String _formatSeconds(int seconds) {
    if (seconds < 60) {
      return '$seconds સેકન્ડ';
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m મિ. $s સેકન્ડ';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final allList = widget.questionAnalysis;
    final correctList = allList.where((q) => q['status'] == 'correct').toList();
    final incorrectList = allList.where((q) => q['status'] == 'incorrect').toList();
    final unattemptedList = allList.where((q) => q['status'] == 'unattempted').toList();

    List<dynamic> displayedList;
    if (_filterIndex == 1) {
      displayedList = incorrectList;
    } else if (_filterIndex == 2) {
      displayedList = correctList;
    } else if (_filterIndex == 3) {
      displayedList = unattemptedList;
    } else {
      displayedList = allList;
    }

    // Calculate total & average time
    int totalTimeSeconds = 0;
    for (var q in allList) {
      totalTimeSeconds += (q['timeSpentSeconds'] as int? ?? 0);
    }
    final avgSeconds = allList.isNotEmpty ? (totalTimeSeconds / allList.length).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('પેપર વિશ્લેષણ અને સોલ્યુશન'),
      ),
      body: Column(
        children: [
          // Stat Summary Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9),
              border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.quizTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatChip('સાચા: ${correctList.length}', const Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    _buildStatChip('ખોટા: ${incorrectList.length}', Colors.red),
                    const SizedBox(width: 8),
                    _buildStatChip('ખાલી: ${unattemptedList.length}', Colors.grey),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⏱️ સરેરાશ: $avgSeconds સે.',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Segmented Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterButton(0, 'બધા (${allList.length})'),
                const SizedBox(width: 6),
                _buildFilterButton(1, 'ખોટા (${incorrectList.length})'),
                const SizedBox(width: 6),
                _buildFilterButton(2, 'સાચા (${correctList.length})'),
                const SizedBox(width: 6),
                _buildFilterButton(3, 'ખાલી (${unattemptedList.length})'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Question Cards List
          Expanded(
            child: displayedList.isEmpty
                ? const Center(
                    child: Text(
                      'આ કેટેગરીમાં કોઈ પ્રશ્નો નથી.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayedList.length,
                    itemBuilder: (context, index) {
                      final item = displayedList[index];
                      final qIndex = (item['index'] as int? ?? index) + 1;
                      final status = item['status'] as String? ?? 'unattempted';
                      final timeSpent = item['timeSpentSeconds'] as int? ?? 0;
                      final studentAns = item['studentAnswer'] as int?;
                      final correctAns = item['correctAnswer'] as int? ?? 0;
                      final options = (item['options'] as List<dynamic>? ?? []);

                      Color statusColor;
                      String statusText;
                      IconData statusIcon;

                      if (status == 'correct') {
                        statusColor = const Color(0xFF10B981);
                        statusText = 'સાચો ઉત્તર';
                        statusIcon = Icons.check_circle_outline;
                      } else if (status == 'incorrect') {
                        statusColor = Colors.red;
                        statusText = 'ખોટો ઉત્તર';
                        statusIcon = Icons.cancel_outlined;
                      } else {
                        statusColor = Colors.grey;
                        statusText = 'ખાલી રાખેલ';
                        statusIcon = Icons.help_outline;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131B2E) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Header: Question Number, Status, Time Spent
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'પ્રશ્ન $qIndex',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(statusIcon, size: 14, color: statusColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatSeconds(timeSpent),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Question Text
                            Text(
                              item['question'] as String? ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.35),
                            ),

                            const SizedBox(height: 12),

                            // Options List with Visual Highlight
                            ...List.generate(options.length, (optIdx) {
                              final optText = options[optIdx].toString();
                              final isStudentChoice = studentAns == optIdx;
                              final isCorrectChoice = correctAns == optIdx;

                              Color optBg;
                              Color optBorder;
                              Color optTextColor;
                              IconData? optIcon;

                              if (isCorrectChoice) {
                                optBg = const Color(0xFF10B981).withValues(alpha: 0.15);
                                optBorder = const Color(0xFF10B981);
                                optTextColor = const Color(0xFF047857);
                                optIcon = Icons.check_circle;
                              } else if (isStudentChoice) {
                                optBg = Colors.red.withValues(alpha: 0.12);
                                optBorder = Colors.redAccent;
                                optTextColor = Colors.red.shade700;
                                optIcon = Icons.cancel;
                              } else {
                                optBg = isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC);
                                optBorder = isDark ? Colors.white10 : Colors.black12;
                                optTextColor = isDark ? Colors.white70 : Colors.black87;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: optBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: optBorder,
                                    width: (isCorrectChoice || isStudentChoice) ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: isCorrectChoice
                                          ? const Color(0xFF10B981)
                                          : (isStudentChoice ? Colors.red : (isDark ? Colors.white12 : Colors.black12)),
                                      child: Text(
                                        String.fromCharCode(65 + optIdx),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: (isCorrectChoice || isStudentChoice)
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : Colors.black87),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        optText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: (isCorrectChoice || isStudentChoice)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isDark && !isCorrectChoice && !isStudentChoice
                                              ? Colors.white70
                                              : optTextColor,
                                        ),
                                      ),
                                    ),
                                    if (optIcon != null) ...[
                                      const SizedBox(width: 6),
                                      Icon(optIcon, size: 16, color: optBorder),
                                    ],
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 6),

                            // Footer Note
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    studentAns != null
                                        ? 'તમારો ઉત્તર: ${String.fromCharCode(65 + studentAns)}'
                                        : 'તમારો ઉત્તર: ખાલી રાખેલ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'સાચો ઉત્તર: ${String.fromCharCode(65 + correctAns)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildFilterButton(int index, String label) {
    final isSelected = _filterIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filterIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
