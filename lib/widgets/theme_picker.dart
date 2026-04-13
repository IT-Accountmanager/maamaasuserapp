import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Services/App_color_service/app_colours.dart';

/// Drop-in widget that lets users pick the app's primary colour palette.
///
/// Add it anywhere — profile screen, settings page, drawer, etc.
///
/// ```dart
/// const ThemePicker()
/// ```
class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'App Theme',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
              letterSpacing: 0.4,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(AppPalettes.all.length, (i) {
            final palette  = AppPalettes.all[i];
            final isActive = palette.scheme.primary == current.primary;

            return GestureDetector(
              onTap: () => notifier.setPalette(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(right: 10.w),
                width:  isActive ? 44.w : 36.w,
                height: isActive ? 44.w : 36.w,
                decoration: BoxDecoration(
                  color: palette.scheme.primary,
                  shape: BoxShape.circle,
                  border: isActive
                      ? Border.all(
                          color: palette.scheme.primary,
                          width: 3,
                        )
                      : null,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: palette.scheme.primary.withOpacity(0.45),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: isActive
                    ? Icon(Icons.check, color: Colors.white, size: 18.sp)
                    : null,
              ),
            );
          }),
        ),
        SizedBox(height: 6.h),
        // Palette name label
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              AppPalettes.all
                  .firstWhere(
                    (p) => p.scheme.primary == current.primary,
                    orElse: () => AppPalettes.all.first,
                  )
                  .name,
              // ignore: deprecated_member_use
              key: ValueKey(current.primary.value),
              style: TextStyle(
                fontSize: 12.sp,
                color: current.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
