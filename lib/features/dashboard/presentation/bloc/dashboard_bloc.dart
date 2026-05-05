import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/dashboard_local_data_source.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardLocalDataSource dataSource;

  DashboardBloc({required this.dataSource}) : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(LoadDashboardEvent event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final data = await dataSource.getDashboardData();
      emit(DashboardLoaded(data: data));
    } catch (e) {
      emit(DashboardError('فشل في تحميل لوحة التحكم: $e'));
    }
  }
}
