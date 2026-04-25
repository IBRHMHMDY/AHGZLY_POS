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
// 2. Custom POS Numpad
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
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildNumberBtn('1'), _buildNumberBtn('2'), _buildNumberBtn('3'),
        _buildNumberBtn('4'), _buildNumberBtn('5'), _buildNumberBtn('6'),
        _buildNumberBtn('7'), _buildNumberBtn('8'), _buildNumberBtn('9'),
        _buildActionBtn(Icons.backspace_rounded, onDeletePressed, Colors.redAccent.shade100, Colors.red),
        _buildNumberBtn('0'),
        isLoading 
            ? _buildLoadingBtn() 
            : _buildActionBtn(submitIcon, onSubmitPressed, Colors.teal.shade100, Colors.teal.shade800),
      ],
    );
  }

  Widget _buildNumberBtn(String number) {
    return ElevatedButton(
      onPressed: isLoading ? null : () => onNumberPressed(number),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.teal.shade900,
        elevation: 0,
      ),
      child: Text(number, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionBtn(IconData icon, VoidCallback onPressed, Color bgColor, Color iconColor) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: bgColor,
        foregroundColor: iconColor,
        elevation: 0,
      ),
      child: Icon(icon, size: 32),
    );
  }

  Widget _buildLoadingBtn() {
    return Container(
      decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(16)),
      child: const Center(child: CircularProgressIndicator(color: Colors.teal)),
    );
  }
}