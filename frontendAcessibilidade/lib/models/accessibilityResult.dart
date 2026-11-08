class ContrastResult {
  final String filename;
  final bool isValid;
  final String message;

  ContrastResult({required this.filename, required this.isValid, required this.message});

  factory ContrastResult.fromJson(Map<String, dynamic> json) {
    return ContrastResult(
      filename: json['filename'],
      isValid: json['is_valid'],
      message: json['message'],
    );
  }
}

class AccessibilityResult {
  final List<ContrastResult> carouselAnalysis;
  final bool isAltTextValid;
  final List<String> altTextIssues;

  AccessibilityResult({
    required this.carouselAnalysis,
    required this.isAltTextValid,
    required this.altTextIssues,
  });

  factory AccessibilityResult.fromJson(Map<String, dynamic> json) {
    final carousel = json['accessibility_score']['carousel_analysis'] as List;
    final altText = json['accessibility_score']['alt_text'];

    return AccessibilityResult(
      carouselAnalysis: carousel.map((img) => ContrastResult.fromJson(img)).toList(),
      isAltTextValid: altText['is_valid'],
      altTextIssues: List<String>.from(altText['issues'] ?? []),
    );
  }
}