import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/auth_repository.dart';
import 'package:intl/intl.dart';

class StockInSheet extends StatefulWidget {
  final String materialId;
  const StockInSheet({super.key, required this.materialId});

  @override
  State<StockInSheet> createState() => _StockInSheetState();
}

class _StockInSheetState extends State<StockInSheet> {
  final _qtyCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final repo = context.read<InventoryRepository>();
    final material = repo.materials.firstWhere((m) => m.id == widget.materialId);
    _rateCtrl.text = material.purchasePrice.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<InventoryRepository>();
    final material = repo.materials.firstWhere((m) => m.id == widget.materialId);

    return Container(
      decoration: const BoxDecoration(
        color: bcSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          const SizedBox(height: 12),
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSummary(material),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(flex: 3, child: _perfectField('QTY TO ADD', _qtyCtrl, '0', isNumber: true)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _perfectField('UNIT', TextEditingController(text: material.unitType.toUpperCase()), '', enabled: false)),
            ],
          ),
          const SizedBox(height: 16),
          _perfectField('PURCHASE RATE (₹)', _rateCtrl, '0', isNumber: true),
          const SizedBox(height: 16),
          _buildDatePicker(context),
          const SizedBox(height: 16),
          _perfectField('REMARKS / NOTE', _remarksCtrl, 'e.g. Received from Supplier X'),
          const SizedBox(height: 32),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildHandle() => Center(
    child: Container(
      width: 40, height: 4,
      decoration: BoxDecoration(color: bcBorder.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2)),
    ),
  );

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('STOCK PROCUREMENT', style: TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
            Text('Inventory Addition Entry', style: TextStyle(color: bcTextSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bcBorder.withValues(alpha: 0.3), shape: BoxShape.circle),
            child: const Icon(Icons.close_rounded, size: 18, color: bcNavy),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(dynamic m) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: bcBorder.withValues(alpha: 0.5)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bcSuccess.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.inventory_2_rounded, color: bcSuccess, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.name, style: const TextStyle(color: bcNavy, fontWeight: FontWeight.w900, fontSize: 15)),
              Text('In Stock: ${m.currentStock.toStringAsFixed(0)} ${m.unitType}', 
                style: const TextStyle(color: bcTextSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        StatusPill(label: m.subType, color: bcInfo),
      ],
    ),
  );

  Widget _perfectField(String label, TextEditingController ctrl, String hint, {bool isNumber = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(color: bcTextSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        ),
        TextField(
          controller: ctrl,
          enabled: enabled,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(fontWeight: FontWeight.w800, color: enabled ? bcNavy : bcTextSecondary, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14, fontWeight: FontWeight.normal),
            filled: true, fillColor: enabled ? Colors.white : bcSurface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: bcBorder.withValues(alpha: 0.6))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: bcBorder.withValues(alpha: 0.6))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: bcPrimary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: bcNavy, onPrimary: Colors.white, onSurface: bcNavy),
            ),
            child: child!,
          ),
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text('ENTRY DATE', style: TextStyle(color: bcTextSecondary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: bcBorder.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: bcAmber),
                const SizedBox(width: 12),
                Text(DateFormat('dd MMMM yyyy').format(_selectedDate), 
                  style: const TextStyle(fontWeight: FontWeight.w800, color: bcNavy, fontSize: 15)),
                const Spacer(),
                const Icon(Icons.expand_more_rounded, color: bcTextSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: bcNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task_rounded, size: 20),
            SizedBox(width: 12),
            Text('CONFIRM ADDITION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    if (qty <= 0) return;

    final repo = context.read<InventoryRepository>();
    final auth = context.read<AuthRepository>();
    await repo.recordStockIn(
      materialId: widget.materialId,
      quantity: qty,
      rate: rate,
      date: _selectedDate,
      remarks: _remarksCtrl.text,
      recordedBy: auth.userName ?? 'System',
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inventory updated successfully', style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: bcSuccess,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
