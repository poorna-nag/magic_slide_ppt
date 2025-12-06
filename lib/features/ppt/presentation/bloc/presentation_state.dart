import 'package:equatable/equatable.dart';

abstract class PresentationState extends Equatable {
  const PresentationState();

  @override
  List<Object> get props => [];
}

class PresentationInitial extends PresentationState {
  const PresentationInitial();
}

class PresentationLoading extends PresentationState {
  const PresentationLoading();
}

class PresentationSuccess extends PresentationState {
  final String pptUrl;
  final String pdfUrl;
  const PresentationSuccess(this.pptUrl, this.pdfUrl);

  @override
  List<Object> get props => [pptUrl, pdfUrl];
}

class PresentationError extends PresentationState {
  final String message;
  const PresentationError(this.message);

  @override
  List<Object> get props => [message];
}
