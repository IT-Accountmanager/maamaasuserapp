import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maamaas/Services/App_color_service/theme_notifier.dart';

import 'color_scheme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppColorScheme>(
  (_) => ThemeNotifier(),
);
