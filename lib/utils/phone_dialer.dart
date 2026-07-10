import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dials USSD on Android (direct call). Other platforms open the phone dialer.
class PhoneDialer {
  static const _channel = MethodChannel('reer_sh_yoonis/phone');

  static Future<PhoneDialResult> callUssd(String ussdCode) async {
    if (Platform.isAndroid) {
      final status = await Permission.phone.request();
      if (!status.isGranted) {
        return PhoneDialResult.permissionDenied;
      }

      try {
        final ok = await _channel.invokeMethod<bool>('callUssd', ussdCode);
        return ok == true ? PhoneDialResult.success : PhoneDialResult.failed;
      } on PlatformException {
        return PhoneDialResult.failed;
      }
    }

    final uri = Uri.parse('tel:${ussdCode.replaceAll('#', '%23')}');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    return launched ? PhoneDialResult.success : PhoneDialResult.failed;
  }
}

enum PhoneDialResult { success, failed, permissionDenied }
