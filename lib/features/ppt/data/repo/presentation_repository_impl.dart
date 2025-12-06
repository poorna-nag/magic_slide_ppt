import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:magic_slide_ppt/features/ppt/data/ppt_response_model.dart';

import 'presentation_repository.dart';

class PresentationRepositoryImpl implements PresentationRepository {
  @override
  Future<PptResponseModel> generatePresentation(
    String topic,
    String email,
    Map<String, dynamic> options,
  ) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final String jsonString = await rootBundle.loadString('assets/z.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      return PptResponseModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load mock data: ${e.toString()}');
    }

    // ACTUAL API CALL (COMMENTED OUT FOR LOCAL TESTING)

    // try {
    //   final data = {
    //     'topic': topic,
    //     'email': email,
    //     'accessId': AppConstants.magicSlidesAccessId,
    //     ...options,
    //   };

    //   final response = await _dio.post(
    //     AppConstants.magicSlidesApiUrl,
    //     data: data,
    //     options: Options(headers: {'Content-Type': 'application/json'}),
    //   );

    //   if (response.statusCode == 200) {
    //     return PptResponseModel.fromJson(response.data);
    //   } else {
    //     throw Exception(
    //       'Failed to generate presentation: ${response.statusCode}',
    //     );
    //   }
    // } on DioException catch (e) {
    //   if (e.type == DioExceptionType.connectionTimeout ||
    //       e.type == DioExceptionType.receiveTimeout ||
    //       e.type == DioExceptionType.sendTimeout) {
    //     throw Exception(
    //       'Connection timeout. Please check your internet connection.',
    //     );
    //   } else if (e.type == DioExceptionType.connectionError) {
    //     throw Exception('No internet connection. Please check your network.');
    //   } else if (e.response != null) {
    //     throw Exception(
    //       'API error: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
    //     );
    //   } else {
    //     throw Exception('Network error: ${e.message}');
    //   }
    // } catch (e) {
    //   throw Exception('Unexpected error: ${e.toString()}');
    // }
  }
}
