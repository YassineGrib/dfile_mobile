import '../payments/payment_strings.dart';
import 'data/expense.dart';

export '../payments/payment_strings.dart' show PaymentMethod;
export 'data/expense.dart' show ExpenseCategory;

/// Centralised user-facing display labels for expense categories and payment methods.
abstract final class ExpenseStrings {
  // Category full labels
  static const String softwareTools = 'Software/Tools';
  static const String hostingServices = 'Hosting/Services';
  static const String marketing = 'Marketing';
  static const String equipment = 'Equipment';
  static const String others = 'Others';

  // Category short labels
  static const String softwareShort = 'Software';
  static const String hostingShort = 'Hosting';
  static const String marketingShort = 'Marketing';
  static const String equipmentShort = 'Equipment';
  static const String othersShort = 'Others';

  // Payment Method labels (reused from PaymentStrings)
  static const String baridimob = PaymentStrings.baridimob;
  static const String ccp = PaymentStrings.ccp;
  static const String bank = PaymentStrings.bank;
  static const String cash = PaymentStrings.cash;

  /// Resolves the user-facing full display label for an [ExpenseCategory].
  static String categoryFullLabel(ExpenseCategory category) =>
      category.fullLabel;

  /// Resolves the user-facing short display label for an [ExpenseCategory].
  static String categoryShortLabel(ExpenseCategory category) =>
      category.shortLabel;

  /// Resolves the user-facing display label for an [ExpenseCategory].
  static String categoryLabel(ExpenseCategory category) => category.fullLabel;

  /// Resolves the user-facing display label for a [PaymentMethod].
  static String methodLabel(PaymentMethod method) =>
      PaymentStrings.methodLabel(method);
}
