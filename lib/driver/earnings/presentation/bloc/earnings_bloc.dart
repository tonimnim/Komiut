import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../../../history/domain/repositories/history_repository.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsRepository earningsRepository;
  final HistoryRepository historyRepository;

  EarningsBloc({
    required this.earningsRepository,
    required this.historyRepository,
  }) : super(EarningsInitial()) {
    on<GetEarningsSummaryEvent>(_onGetEarningsSummary);
    on<GetTripHistoryEvent>(_onGetTripHistory);
    on<GetTripHistoryDetailsEvent>(_onGetTripHistoryDetails);
  }

  Future<void> _onGetTripHistoryDetails(
    GetTripHistoryDetailsEvent event,
    Emitter<EarningsState> emit,
  ) async {
    emit(EarningsLoading());
    final result = await historyRepository.getTripHistoryDetails(event.tripId);
    result.fold(
      (failure) => emit(EarningsError(failure.message)),
      (details) => emit(TripHistoryDetailsLoaded(details)),
    );
  }

  Future<void> _onGetEarningsSummary(
    GetEarningsSummaryEvent event,
    Emitter<EarningsState> emit,
  ) async {
    emit(EarningsLoading());

    final summaryResult = await earningsRepository.getEarningsSummary(
      period: event.period,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    final historyResult = await historyRepository.getTripHistory(
      limit: 5, // Get recent few for the summary screen
    );

    summaryResult.fold(
      (failure) => emit(EarningsError(failure.message)),
      (summary) {
        historyResult.fold(
          (failure) => emit(EarningsLoaded(summary: summary, tripHistory: const [])),
          (history) => emit(EarningsLoaded(summary: summary, tripHistory: history)),
        );
      },
    );
  }

  Future<void> _onGetTripHistory(
    GetTripHistoryEvent event,
    Emitter<EarningsState> emit,
  ) async {
    // This could update a separate HistoryLoaded state if needed, 
    // or we can just refill the current one.
    // For simplicity, let's keep it in one loaded state for now.
    
    final currentState = state;
    if (currentState is EarningsLoaded) {
      final historyResult = await historyRepository.getTripHistory(
        page: event.page,
        limit: event.limit,
        startDate: event.startDate,
        endDate: event.endDate,
        routeId: event.routeId,
      );

      historyResult.fold(
        (failure) => emit(EarningsError(failure.message)),
        (history) => emit(EarningsLoaded(
          summary: currentState.summary,
          tripHistory: history,
        )),
      );
    } else {
      // If summary isn't loaded, we might need a dummy summary or load it first.
      add(GetEarningsSummaryEvent(period: 'weekly'));
    }
  }
}
