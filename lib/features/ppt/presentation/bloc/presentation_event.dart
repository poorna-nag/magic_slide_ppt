import 'package:equatable/equatable.dart';

abstract class PresentationEvent extends Equatable {
  const PresentationEvent();

  @override
  List<Object> get props => [];
}

class GeneratePresentation extends PresentationEvent {
  final String topic;
  final String email;
  final Map<String, dynamic> options;
  const GeneratePresentation(this.topic, this.email, this.options);
  @override
  List<Object> get props => [topic, email];
}
