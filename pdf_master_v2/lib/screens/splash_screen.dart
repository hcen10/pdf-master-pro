import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

    _fade     = CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4, curve: Curves.easeOut));
    _scale    = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.4, curve: Curves.elasticOut)));
    _progress = CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0));

    _ctrl.forward();
    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, a, __) => const MainShell(),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A12) : const Color(0xFFF4F4FF);
    final accent = const Color(0xFF7C6FF7);
    final state = context.read<AppState>();

    return Scaffold(
      backgroundColor: bg,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C6FF7), Color(0xFFFF6B8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('📄', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    state.t('app_name'),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF7C6FF7), Color(0xFFFF6B8A)],
                        ).createShader(const Rect.fromLTWH(0, 0, 260, 40)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.t('tagline'),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFF8888AA) : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 48),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progress.value,
                      backgroundColor: accent.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF7C6FF7)),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    state.t('privacy'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF8888AA) : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
