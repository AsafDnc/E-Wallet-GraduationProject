/// Derives a short first name from a full name for greetings (e.g. "Jane Doe" → "Jane").
///
/// Uses the first whitespace-separated token. Falls back to `"User"` when empty.
String greetingFirstName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) {
    return 'User';
  }
  final parts = trimmed.split(RegExp(r'\s+'));
  final first = parts.firstWhere((s) => s.isNotEmpty, orElse: () => '');
  return first.isEmpty ? 'User' : first;
}
