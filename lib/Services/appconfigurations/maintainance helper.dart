import 'package:flutter/material.dart';
import 'package:maamaas/Services/appconfigurations/cofigkeys.dart';
import 'app_configurtion_service.dart';
import 'appmaintainancescreen.dart';

class MaintenanceHelper {
  static Future<bool> check(BuildContext context) async {
    await AppConfigService.instance.loadConfigs();

    final enabled = AppConfigService.instance.isEnabled(
      AppConfigKeys.appMaintenance,
    );

    if (enabled && context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MaintenanceScreen()),
        (route) => false,
      );
    }

    return enabled;
  }
}
