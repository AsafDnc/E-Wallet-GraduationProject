/// Where the PIN setup flow was started (affects post-confirm navigation).
enum PinFlowSource {
  /// After email OTP — complete flow ends on [Home].
  signup,

  /// From Password & PIN settings — return to the previous screen.
  settings,
}
