import 'package:equatable/equatable.dart';

class PptResponseModel extends Equatable {
  final bool success;
  final String url;
  final String pdfUrl;
  final String message;

  const PptResponseModel({
    required this.success,
    required this.url,
    required this.pdfUrl,
    required this.message,
  });

  factory PptResponseModel.fromJson(Map<String, dynamic> json) {
    return PptResponseModel(
      success: json['data']?['success'] ?? json['success'] ?? false,
      url: json['data']?['url'] ?? '',
      pdfUrl: json['data']?['pdfUrl'] ?? '',
      message: json['message'] ?? '',
    );
  }

  @override
  List<Object> get props => [success, url, pdfUrl, message];
}
