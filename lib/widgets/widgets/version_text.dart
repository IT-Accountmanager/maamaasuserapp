import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatefulWidget {
  const VersionText({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VersionTextState createState() => _VersionTextState();
}

class _VersionTextState extends State<VersionText> {
  String _version = "";

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${packageInfo.version}+${packageInfo.buildNumber}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _version.isEmpty ? "Loading..." : "App Version $_version",
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }
}
