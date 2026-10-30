import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Hide amounts": hides money on the Home screen so a balance is not on
/// show to whoever is next to you. It is a device setting and is remembered.
class PrivacyMode extends ChangeNotifier {
  PrivacyMode({this._hidden = false, this._prefs});

  static const String _key = 'hide_amounts';
  static const String mask = '••••••';

  final SharedPreferences? _prefs;
  bool _hidden;

  /// Loads the saved choice. Falls back to showing amounts if storage fails.
  static Future<PrivacyMode> load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return PrivacyMode(hidden: prefs.getBool(_key) ?? false, prefs: prefs);
    } catch (_) {
      return PrivacyMode();
    }
  }

  bool get hidden => _hidden;

  void toggle() {
    _hidden = !_hidden;
    notifyListeners();
    _prefs?.setBool(_key, _hidden);
  }
}

/// Gives the widget tree the [PrivacyMode]. Without one, amounts are shown.
class PrivacyScope extends InheritedNotifier<PrivacyMode> {
  const PrivacyScope({
    super.key,
    required PrivacyMode mode,
    required super.child,
  }) : super(notifier: mode);

  static final PrivacyMode _visible = PrivacyMode();

  static PrivacyMode of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PrivacyScope>()?.notifier ??
      _visible;

  /// [text] as it should appear now: itself, or a row of dots when hidden.
  static String shown(BuildContext context, String text) =>
      of(context).hidden ? PrivacyMode.mask : text;
}
