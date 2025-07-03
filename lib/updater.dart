import 'package:flutter/material.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

class AppUpdater {
  static Future<void> checkForUpdate(BuildContext context) async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setDefaults({
      'app_version': '0.0.1',
      'is_optional': true,
      'ios_path': '',
      'android_path': '',
    });

    await remoteConfig.fetchAndActivate();

    final currentVersion = (await PackageInfo.fromPlatform()).version;
    final newVersion = remoteConfig.getString('app_version');
    final isOptional = remoteConfig.getBool('is_optional');

    final updateNeeded = _isNewVersionAvailable(currentVersion, newVersion);
    if (updateNeeded) {
      final storeLink = Platform.isIOS
          ? remoteConfig.getString('ios_path')
          : remoteConfig.getString('android_path');

      _showUpdateDialog(context, isOptional, storeLink);
    }
  }

  static bool _isNewVersionAvailable(String current, String remote) {
    List<int> cv = current.split('.').map(int.parse).toList();
    List<int> rv = remote.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (rv[i] > cv[i]) return true;
      if (rv[i] < cv[i]) return false;
    }
    return false;
  }

  static void _showUpdateDialog(BuildContext context, bool isOptional, String storeLink) {
    showDialog(
      barrierDismissible: isOptional,
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Yangi versiya mavjud"),
        content: const Text("Iltimos, ilovani yangilang."),
        actions: [
          if (isOptional)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Keyinroq"),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              launchUrl(Uri.parse(storeLink));
            },
            child: const Text("Yangilash"),
          ),
        ],
      ),
    );
  }
}
