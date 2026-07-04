import 'package:flutter/material.dart';
import 'package:maamaas/Services/appconfigurations/cofigkeys.dart';
import 'app_configurtion_service.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = AppConfigService.instance.getConfig(AppConfigKeys.appMaintenance);

    debugPrint("Maintenance Config = $config");
    debugPrint(
      "All Configs = ${AppConfigService.instance.allConfigs.map((e) => e.configKey).toList()}",
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build_circle, size: 100, color: Colors.orange),
              const SizedBox(height: 20),

              Text(
                config?.title ?? "App Under Maintenance",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                config?.description ?? "Please try again later.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
