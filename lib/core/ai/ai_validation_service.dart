/// Resultat de validation IA (mock pour MVP).
class AiValidationResult {
  const AiValidationResult({
    required this.isPothole,
    required this.dangerScore,
    required this.estimatedSize,
    required this.estimatedDepth,
  });

  final bool isPothole;
  final int dangerScore;
  final String estimatedSize;
  final String estimatedDepth;

  AiValidationResult copyWith({
    bool? isPothole,
    int? dangerScore,
    String? estimatedSize,
    String? estimatedDepth,
  }) {
    return AiValidationResult(
      isPothole: isPothole ?? this.isPothole,
      dangerScore: dangerScore ?? this.dangerScore,
      estimatedSize: estimatedSize ?? this.estimatedSize,
      estimatedDepth: estimatedDepth ?? this.estimatedDepth,
    );
  }

  Map<String, dynamic> toMap() => {
        'isPothole': isPothole,
        'dangerScore': dangerScore,
        'estimatedSize': estimatedSize,
        'estimatedDepth': estimatedDepth,
      };

  factory AiValidationResult.fromMap(Map<String, dynamic> map) {
    return AiValidationResult(
      isPothole: map['isPothole'] as bool? ?? true,
      dangerScore: (map['dangerScore'] as num?)?.toInt() ?? 0,
      estimatedSize: map['estimatedSize'] as String? ?? '',
      estimatedDepth: map['estimatedDepth'] as String? ?? '',
    );
  }
}

abstract class AiValidationService {
  Future<AiValidationResult> validatePotholeImage(String imageUrl);
}
