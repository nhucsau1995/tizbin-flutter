import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/shell/app_shell.dart';
import 'state/providers.dart';

class TizbinApp extends ConsumerWidget {
  const TizbinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedIn = ref.watch(sessionProvider) != null;
    final largeText = ref.watch(prefsProvider).largeText;
    return MaterialApp(
      title: 'تیزبین',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // Full Persian right-to-left UI.
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(largeText ? 1.15 : 1)),
        child: child!,
      ),
      home: signedIn ? const AppShell() : const WelcomeScreen(),
    );
  }
}
