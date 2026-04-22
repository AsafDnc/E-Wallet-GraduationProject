/// Holds all user-configurable budget settings.
class BudgetSettings {
  const BudgetSettings({
    this.monthlyLimit = 10000.0,
    this.isAlertEnabled = true,
    this.alertThreshold = 0.75,
  });

  final double monthlyLimit;
  final bool isAlertEnabled;

  /// Fraction at which an alert fires: 0.5, 0.75, 0.9, or 1.0.
  final double alertThreshold;

  BudgetSettings copyWith({
    double? monthlyLimit,
    bool? isAlertEnabled,
    double? alertThreshold,
  }) {
    return BudgetSettings(
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      isAlertEnabled: isAlertEnabled ?? this.isAlertEnabled,
      alertThreshold: alertThreshold ?? this.alertThreshold,
    );
  }
}
