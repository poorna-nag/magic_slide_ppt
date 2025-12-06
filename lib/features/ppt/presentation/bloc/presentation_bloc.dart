import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic_slide_ppt/features/ppt/data/repo/presentation_repository.dart';
import 'package:magic_slide_ppt/features/ppt/presentation/bloc/presentation_state.dart';

import 'presentation_event.dart';

class PresentationBloc extends Bloc<PresentationEvent, PresentationState> {
  final PresentationRepository repository;

  PresentationBloc(this.repository) : super(PresentationInitial()) {
    on<GeneratePresentation>(_onGenerate);
  }

  Future<void> _onGenerate(
    GeneratePresentation event,
    Emitter<PresentationState> emit,
  ) async {
    emit(PresentationLoading());
    try {
      final response = await repository.generatePresentation(
        event.topic,
        event.email,
        event.options,
      );
      emit(PresentationSuccess(response.url, response.pdfUrl));
    } catch (e) {
      emit(PresentationError(e.toString()));
    }
  }
}
