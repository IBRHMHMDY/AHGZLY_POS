import 'package:ahgzly_pos/features/shift/domain/entities/shift_entity.dart';
import 'package:ahgzly_pos/features/shift/presentation/widgets/btns_shift_reports.dart';
import 'package:ahgzly_pos/features/shift/presentation/widgets/financial_summary_card.dart';
import 'package:ahgzly_pos/features/shift/presentation/widgets/shift_status_header.dart';
import 'package:flutter/material.dart';

class ActiveShiftView extends StatelessWidget {
  final ShiftEntity shift;
  final VoidCallback onPrintReport;
  final VoidCallback onCloseShift;

  const ActiveShiftView({super.key, 
    required this.shift,
    required this.onPrintReport,
    required this.onCloseShift,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            ShiftStatusHeader(shift: shift),
            const SizedBox(height: 32),
            FinancialSummaryCard(shift: shift),
            const SizedBox(height: 32),
            BtnsShiftReport(
              onPrintReport: onPrintReport,
              onCloseShift: onCloseShift,
            ),
          ],
        ),
      ),
    );
  }
}