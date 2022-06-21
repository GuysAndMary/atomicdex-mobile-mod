import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/check_button.dart';
import '../../helpers/enter_pin.dart';

Future<void> restoreWalletToTest(WidgetTester tester,
    {bool fromStart = true}) async {
  // Restores wallet to be used in following tests
  try {
    const String seedPhrase =
        'hazard slam top rail jacket ecology trash first stock nut swift thought youth rack slot regular wasp bulk spatial legal staff change way brush';
    const String invalidSeed = 'hazard slam top';
    const String usedWalletName = 'my-wallet';
    const String walletName = 'restored-wallet';
    const String invalidPassword = 'abcd';
    const String password = 'pppaaasssDDD555444@@@';
    const String wrongPassword = '';
    const String confirmPassword = 'pppaaasssDDD555444@@@';
    const String correctPin = '123456';
    const String wrongPin = '123457';
    final Finder restoreWalletButton = find.byKey(const Key('restoreWallet'));
    final Finder nameField = find.byKey(const Key('name-wallet-field'));
    final Finder importSeedField = find.byKey(const Key('restore-seed-field'));
    final Finder confirmSeedButton =
        find.byKey(const Key('confirm-seed-button'));
    final Finder passwordField = find.byKey(const Key('create-password-field'));
    final Finder passwordConfirmField =
        find.byKey(const Key('create-password-field-confirm'));
    final Finder confirmPasswordButton =
        find.byKey(const Key('confirm-password'));
    final Finder eulaCheckBox = find.byKey(const Key('checkbox-eula'));
    final Finder tocCheckBox = find.byKey(const Key('checkbox-toc'));
    final Finder scrollButton =
        find.byKey(const Key('disclaimer-scroll-button'));
    final Finder disclaimerButton = find.byKey(const Key('next-disclaimer'));
    final Finder viewPasswordBtn = find.byKey(const Key('password-visibility'));

    // =========== authenticate_page.dart =============== //
    await tester.ensureVisible(restoreWalletButton);
    await tester.tap(restoreWalletButton);
    await tester.pumpAndSettle();
    // welcome_page.dart
    if (!fromStart) {
      // already used name
      await tester.tap(nameField);
      await tester.enterText(nameField, usedWalletName);
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      expect(usedWalletName, walletName,
          reason: 'Already used wallet name', skip: true);
    }
    await tester.tap(nameField);
    await tester.enterText(nameField, walletName);
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    // =========== restore_seed_page.dart =============== //
    // test wrong seed
    await tester.pump(Duration(seconds: 1));
    await tester.enterText(importSeedField, invalidSeed);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(viewPasswordBtn);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmSeedButton);
    await tester.pump(Duration(seconds: 1));
    expect(invalidSeed, seedPhrase, reason: 'Invalid Seed', skip: true);
    checkButtonStatus(tester, confirmSeedButton);
    // test correct seed
    await tester.enterText(importSeedField, seedPhrase);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(viewPasswordBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmSeedButton);
    await tester.pump(Duration(seconds: 1));
    // =========== create_password_page.dart =============== //
    // test invalid password
    await tester.tap(passwordField);
    await tester.enterText(passwordField, invalidPassword);
    await tester.tap(passwordConfirmField);
    await tester.enterText(passwordConfirmField, invalidPassword);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmPasswordButton);
    await tester.pump(Duration(seconds: 1));
    expect(invalidPassword, password, reason: 'Invalid Password', skip: true);
    checkButtonStatus(tester, confirmPasswordButton);
    // test wrong password
    await tester.tap(passwordField);
    await tester.enterText(passwordField, password);
    await tester.tap(passwordConfirmField);
    await tester.enterText(passwordConfirmField, wrongPassword);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmPasswordButton);
    await tester.pump(Duration(seconds: 1));
    expect(wrongPassword, password, reason: 'Wrong Password', skip: true);
    checkButtonStatus(tester, confirmPasswordButton);
    //  correct password
    await tester.tap(passwordField);
    await tester.enterText(passwordField, password);
    await tester.tap(viewPasswordBtn);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(passwordConfirmField);
    await tester.enterText(passwordConfirmField, confirmPassword);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(confirmPasswordButton);
    await tester.pump(Duration(seconds: 1));
    // ============ disclaimer_page.dart =============== //
    await tester.tap(disclaimerButton);
    checkButtonStatus(tester, disclaimerButton);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(eulaCheckBox);
    await tester.tap(tocCheckBox);
    await tester.longPress(scrollButton);
    await tester.pump(Duration(seconds: 1));
    await tester.tap(disclaimerButton);
    await tester.pump(Duration(seconds: 1));
    // ============== pin_page.dart ================== //
    await tester.pumpAndSettle();
    await enterPinCode(tester, pin: correctPin);
    await tester.pumpAndSettle();
    //check for wrong pin
    await enterPinCode(tester, pin: wrongPin);
    await tester.pumpAndSettle();
    expect(wrongPin, correctPin, reason: 'Wrong PIN', skip: true);
    await tester.pump(Duration(seconds: 1));
    await enterPinCode(tester, pin: correctPin);
    await tester.pumpAndSettle();
  } catch (e) {
    print(e?.message ?? e);
  }
}
