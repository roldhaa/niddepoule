import 'package:niddepoule/core/ai/ai_validation_service.dart';

class MockAiValidationService implements AiValidationService {
  @override
  Future<AiValidationResult> validatePotholeImage(String imageUrl) async {
    return const AiValidationResult(
      isPothole: true,
      dangerScore: 67,
      estimatedSize: '45cm x 35cm',
      estimatedDepth: '8cm',
    );
  }
}
