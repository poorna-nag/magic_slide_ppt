import 'package:magic_slide_ppt/features/ppt/data/ppt_response_model.dart';



abstract class PresentationRepository {
  Future<PptResponseModel> generatePresentation(
    String topic,
    String email,
    Map<String, dynamic> options,
  );
}
