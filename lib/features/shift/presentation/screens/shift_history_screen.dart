import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_event.dart';
import 'package:ahgzly_pos/features/shift/presentation/bloc/shift_state.dart';

class ShiftHistoryScreen extends StatefulWidget {
  const ShiftHistoryScreen({super.key});

  @override
  State<ShiftHistoryScreen> createState() => _ShiftHistoryScreenState();
}

class _ShiftHistoryScreenState extends State<ShiftHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ShiftBloc>().add(LoadShiftsHistoryEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      context.read<ShiftBloc>().add(LoadShiftsHistoryEvent(isLoadMore: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.history),
              SizedBox(width: 8),
              Text('سجل الورديات السابقة', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<ShiftBloc>().add(LoadShiftsHistoryEvent()),
            ),
          ],
        ),
        body: BlocBuilder<ShiftBloc, ShiftState>(
          buildWhen: (previous, current) => current is ShiftsHistoryLoaded || current is ShiftLoading || current is ShiftError,
          builder: (context, state) {
            if (state is ShiftLoading && context.read<ShiftBloc>().state is! ShiftsHistoryLoaded) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            } else if (state is ShiftError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red, fontSize: 18)));
            } else if (state is ShiftsHistoryLoaded) {
              if (state.shifts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('لا يوجد ورديات سابقة', style: TextStyle(fontSize: 20, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
                              dataRowMinHeight: 60,
                              dataRowMaxHeight: 60,
                              columns: const [
                                DataColumn(label: Text('رقم الوردية', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('الكاشير', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('وقت البدء', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('وقت الإغلاق', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('العهدة (البداية)', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('المتوقع', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('الفعلي', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('العجز/الزيادة', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: state.shifts.map((shift) {
                                final isClosed = shift.status == 'closed';
                                final difference = isClosed ? shift.actualCash - shift.expectedCash : 0;
                                
                                return DataRow(
                                  cells: [
                                    DataCell(Text('#${shift.id}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(shift.cashierName ?? 'كاشير #${shift.cashierId}')), // 🚀 [Sprint 2] UX Fix
                                    DataCell(Text(shift.startTime.toString().substring(0, 16))),
                                    DataCell(Text(shift.endTime != null ? shift.endTime.toString().substring(0, 16) : '-')),
                                    DataCell(Text('${shift.startingCash.toFormattedMoney()} ج.م')),
                                    DataCell(Text('${shift.expectedCash.toFormattedMoney()} ج.م', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(isClosed ? '${shift.actualCash.toFormattedMoney()} ج.م' : '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(
                                      Text(
                                        isClosed ? '${difference.toFormattedMoney()} ج.م' : '-',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isClosed 
                                              ? (difference == 0 ? Colors.green : (difference < 0 ? Colors.red : Colors.orange))
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isClosed ? Colors.grey.shade200 : Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isClosed ? 'مغلقة' : 'نشطة',
                                          style: TextStyle(
                                            color: isClosed ? Colors.grey.shade800 : Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                            if (!state.hasReachedMax)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator(color: Colors.teal)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
