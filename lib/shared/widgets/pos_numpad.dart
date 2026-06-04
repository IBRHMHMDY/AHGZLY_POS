import 'package:flutter/material.dart';

// ==========================================
// 1. PIN Dots Indicator
// ==========================================
class PinDots extends StatelessWidget {
  final int pinLength;
  final int maxLength;

  const PinDots({super.key, required this.pinLength, required this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxLength, (index) {
        final isFilled = index < pinLength;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: isFilled ? 24 : 20,
          height: isFilled ? 24 : 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.teal : Colors.grey.shade300,
            border: isFilled ? null : Border.all(color: Colors.grey.shade400, width: 2),
          ),
        );
      }),
    );
  }
}

// ==========================================
// 2. Custom POS Numpad (Hotfix: Responsive & Scrollable)
// ==========================================
class PosNumpad extends StatelessWidget {
  final ValueChanged<String> onNumberPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onSubmitPressed;
  final bool isLoading;
  final IconData submitIcon;

  const PosNumpad({
    super.key,
    required this.onNumberPressed,
    required this.onDeletePressed,
    required this.onSubmitPressed,
    required this.isLoading,
    this.submitIcon = Icons.login_rounded,
  });

  @override
  Widget build(BuildContext context) {
    // 🚀 [HOTFIX]: استخدام LayoutBuilder لمعرفة المساحة واستخدام ScrollView لمنع الـ Overflow
    return LayoutBuilder(
      builder: (context, constraints) {
        // حساب ارتفاع الزر ديناميكياً بحيث لا يتجاوز 65 ولا يقل عن 50 بكسل
        final double buttonHeight = constraints.maxHeight < 400 ? 55 : 65;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRow(['1', '2', '3'], buttonHeight),
              const SizedBox(height: 12),
              _buildRow(['4', '5', '6'], buttonHeight),
              const SizedBox(height: 12),
              _buildRow(['7', '8', '9'], buttonHeight),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildActionBtn(Icons.backspace_rounded, onDeletePressed, Colors.redAccent.shade100, Colors.red, buttonHeight)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildNumberBtn('0', buttonHeight)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: isLoading 
                        ? _buildLoadingBtn(buttonHeight) 
                        : _buildActionBtn(submitIcon, onSubmitPressed, Colors.teal.shade100, Colors.teal.shade800, buttonHeight),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(List<String> numbers, double height) {
    return Row(
      children: [
        Expanded(child: _buildNumberBtn(numbers[0], height)),
        const SizedBox(width: 12),
        Expanded(child: _buildNumberBtn(numbers[1], height)),
        const SizedBox(width: 12),
        Expanded(child: _buildNumberBtn(numbers[2], height)),
      ],
    );
  }

  Widget _buildNumberBtn(String number, double height) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : () => onNumberPressed(number),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.teal.shade900,
          elevation: 0,
          padding: EdgeInsets.zero, // لمنع المساحات الداخلية من كسر التصميم
        ),
        child: Text(number, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onPressed, Color bgColor, Color iconColor, double height) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: bgColor,
          foregroundColor: iconColor,
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 28),
      ),
    );
  }

  Widget _buildLoadingBtn(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(16)),
      child: const Center(child: CircularProgressIndicator(color: Colors.teal)),
    );
  }
}