String? validateEmail(String? value) {
  if (value == null || value.isEmpty) return 'Email required';
  if (!value.contains('@')) return 'Enter a valid email';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.length < 6) return 'Password must be 6+ chars';
  return null;
}

String? validateNonEmpty(String? value, {String message = 'Required'}) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}
