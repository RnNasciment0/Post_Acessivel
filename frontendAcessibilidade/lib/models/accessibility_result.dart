class AccessibilityResult {
  final bool isContrastValid;
  final String contrastMessage;
  final bool isAltTextValid;
  final List<String> altTextIssues;

  AccessibilityResult({
    required this.isContrastValid,
    required this.contrastMessage,
    required this.isAltTextValid,
    required this.altTextIssues,
  });

  factory AccessibilityResult.fromJson(Map<String, dynamic> json) {
    final contrast = json['accessibility_score']['contrast'];
    final altText = json['accessibility_score']['alt_text'];

    return AccessibilityResult(
      isContrastValid: contrast['is_valid'],
      contrastMessage: contrast['message'],
      isAltTextValid: altText['is_valid'],
      altTextIssues: List<String>.from(altText['issues'] ?? []),
    );
  }
}