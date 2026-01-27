import 'package:flutter/material.dart';

enum PaymentMethod {
  cash,
  upi,
  bankTransfer,
  cheque,
}

class PaymentMethodSelector extends StatefulWidget {
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;
  final bool showTransactionField;

  const PaymentMethodSelector({
    super.key,
    this.selectedMethod,
    required this.onMethodSelected,
    this.showTransactionField = true,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  PaymentMethod? _selectedMethod;
  final TextEditingController _transactionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod;
  }

  @override
  void dispose() {
    _transactionController.dispose();
    super.dispose();
  }

  String _getMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cheque:
        return 'Cheque';
    }
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.payments_rounded;
      case PaymentMethod.upi:
        return Icons.qr_code_scanner_rounded;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_rounded;
      case PaymentMethod.cheque:
        return Icons.receipt_long_rounded;
    }
  }

  Color _getMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Colors.green.shade700;
      case PaymentMethod.upi:
        return Colors.deepPurple;
      case PaymentMethod.bankTransfer:
        return Colors.blue.shade800;
      case PaymentMethod.cheque:
        return Colors.orange.shade800;
    }
  }

  bool _needsTransactionRef(PaymentMethod method) {
    return method == PaymentMethod.upi || 
           method == PaymentMethod.bankTransfer || 
           method == PaymentMethod.cheque;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(
            color: const Color(0xFF1A237E),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: PaymentMethod.values.map((method) {
            final isSelected = _selectedMethod == method;
            final color = _getMethodColor(method);

            return InkWell(
              onTap: () {
                setState(() => _selectedMethod = method);
                widget.onMethodSelected(method);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? color.withOpacity(0.05)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? color 
                        : const Color(0xFFEEEEEE),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getMethodIcon(method),
                      color: isSelected ? color : const Color(0xFF1A237E).withOpacity(0.3),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMethodLabel(method),
                      style: TextStyle(
                        color: isSelected ? color : const Color(0xFF1A237E).withOpacity(0.4),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        if (_selectedMethod != null && 
            _needsTransactionRef(_selectedMethod!) && 
            widget.showTransactionField) ...[
          const SizedBox(height: 16),
          Text(
            'Transaction Reference',
            style: TextStyle(
              color: const Color(0xFF1A237E),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _transactionController,
            style: const TextStyle(color: Color(0xFF1A237E)),
            decoration: InputDecoration(
              hintText: _selectedMethod == PaymentMethod.upi 
                  ? 'UPI Transaction ID'
                  : _selectedMethod == PaymentMethod.cheque
                      ? 'Cheque Number'
                      : 'Transaction Reference',
              hintStyle: TextStyle(color: const Color(0xFF1A237E).withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFF1A237E).withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFF1A237E).withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _getMethodColor(_selectedMethod!)),
              ),
              prefixIcon: Icon(
                Icons.numbers_rounded,
                color: const Color(0xFF1A237E).withOpacity(0.4),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
