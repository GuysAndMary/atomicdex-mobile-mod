import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:komodo_dex/services/job_service.dart';
import 'package:komodo_dex/services/notif_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:package_info/package_info.dart';

class UpdatesProvider extends ChangeNotifier {
  UpdatesProvider() {
    _init();
  }

  bool isFetching = false;
  UpdateStatus status;
  String currentVersion;
  String newVersion;
  String message;

  final String url = 'https://komodo.live/adexversion';

  Future<void> check() => _check();

  Future<void> _init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    currentVersion = packageInfo.version;

    jobService.install('checkUpdates', 300, (_) async {
      if (notifService.isInBackground) _check();
    });

    notifyListeners();
  }

  Future<void> _check() async {
    isFetching = true;
    newVersion = null;
    status = null;
    message = null;
    notifyListeners();

    http.Response response;
    Map<String, dynamic> json;

    try {
      response = await http.post(
        url,
        body: jsonEncode({
          'currentVersion': currentVersion,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      json = jsonDecode(response.body);
    } catch (e) {
      Log('updates_provider:47', '_check] $e');

      isFetching = false;
      status = UpdateStatus.upToDate;
      notifyListeners();
      return;
    }

    message = json['message'];
    final String jsonVersion = json['newVersion'];
    if (jsonVersion != null && currentVersion != null) {
      if (jsonVersion.compareTo(currentVersion) > 0) {
        newVersion = jsonVersion;
      } else {
        isFetching = false;
        status = UpdateStatus.upToDate;
        notifyListeners();
        return;
      }
    }

    switch (json['status']) {
      case 'upToDate':
        {
          status = UpdateStatus.upToDate;
          break;
        }
      case 'available':
        {
          status = UpdateStatus.available;
          break;
        }
      case 'recommended':
        {
          status = UpdateStatus.recommended;
          break;
        }
      case 'required':
        {
          status = UpdateStatus.required;
          break;
        }
      default:
        status =
            newVersion == null ? UpdateStatus.upToDate : UpdateStatus.available;
    }

    isFetching = false;

    if (status != UpdateStatus.upToDate) {
      notifService.show(
        NotifObj(
          title: 'Update available',
          text: newVersion == null
              ? 'New version available. Please update.'
              : 'Version $newVersion available. Please update.',
        ),
      );
    }

    notifyListeners();
  }
}

enum UpdateStatus {
  upToDate,
  available,
  recommended,
  required,
}
