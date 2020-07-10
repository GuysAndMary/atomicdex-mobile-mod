import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/widgets/bloc_provider.dart';

SettingsBloc settingsBloc = SettingsBloc();

class SettingsBloc implements BlocBase {
  bool isDeleteLoading = true;
  bool showBalance = true;

  final StreamController<bool> _isDeleteLoadingController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inIsDeleteLoading => _isDeleteLoadingController.sink;
  Stream<bool> get outIsDeleteLoading => _isDeleteLoadingController.stream;


  final StreamController<bool> _showBalanceController =
      StreamController<bool>.broadcast();
  Sink<bool> get _inShowBalance => _showBalanceController.sink;
  Stream<bool> get outShowBalance => _showBalanceController.stream;

  @override
  void dispose() {
    _isDeleteLoadingController.close();
  }

  void setDeleteLoading(bool isLoading) {
    isDeleteLoading = isLoading;
    _inIsDeleteLoading.add(isDeleteLoading);
  }

  String getNameLanguage(BuildContext context, String languageCode) {
    switch (languageCode) {
      case 'en':
        return AppLocalizations.of(context).englishLanguage;
        break;
      case 'fr':
        return AppLocalizations.of(context).frenchLanguage;
        break;
      case 'de':
        return AppLocalizations.of(context).deutscheLanguage;
        break;
      case 'zh':
        return AppLocalizations.of(context).chineseLanguage;
        break;
      case 'zh_TW':
        return AppLocalizations.of(context).simplifiedChinese;
        break;
      case 'ru':
        return AppLocalizations.of(context).russianLanguage;
        break;
      case 'ja':
        return AppLocalizations.of(context).japaneseLanguage;
        break;
      case 'tr':
        return AppLocalizations.of(context).turkishLanguage;
        break;
      case 'hu':
        return AppLocalizations.of(context).hungarianLanguage;
        break;
      default:
        return AppLocalizations.of(context).englishLanguage;
    }
  }

  void setShowBalance(bool val) {
    showBalance = val;
    _inShowBalance.add(val);
  }
}
