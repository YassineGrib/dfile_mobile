import '../projects/data/project.dart';

export '../projects/data/project.dart'
    show PaymentMethod, PaymentType, PaymentStats, ProjectPayment;

/// Centralised user-facing strings and label getters for payments.
abstract final class PaymentStrings {
  // Payment Type labels
  static const String advance = 'Advance';
  static const String milestone = 'Milestone';
  static const String finalLabel = 'Final';
  static const String tip = 'Tip';

  // Payment Method labels
  static const String baridimob = 'BaridiMob';
  static const String ccp = 'CCP';
  static const String bank = 'Bank wire';
  static const String cash = 'Cash';

  /// Resolves the user-facing display label for a [PaymentType].
  static String typeLabel(PaymentType type) => type.label;

  /// Resolves the user-facing display label for a [PaymentMethod].
  static String methodLabel(PaymentMethod method) => method.label;
}
