import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:construction_app/core/theme/aesthetic_tokens.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:intl/intl.dart';

class StockOutSheet extends StatefulWidget {
  final String materialId;
  const StockOutSheet({super.key, required this.materialId});

  @override
  State<StockOutSheet> createState() => _StockOutSheetState();
}

class _StockOutSheetState extends State<StockOutSheet> {
  final _qtyCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final repo = context.read<InventoryRepository>();
    final material = repo.materials.firstWhere((m) => m.id == widget.materialId);
    _rateCtrl.text = material.salePrice.toString();
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          Text(material.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: bcNavy)),
          Text('Available Stock: ${material.currentStock} ${material.unitType.label}', style: TextStyle(fontSize: 12, color: material.isLowStock ? Colors.red : Colors.grey)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildTextField('Quantity', _qtyCtrl, '0', isNumber: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField('Unit', TextEditingController(text: material.unitType.label), '', enabled: false)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('Rate (at which you sold)', _rateCtrl, '₹ 0', isNumber: true),
          const SizedBox(height: 16),
          _buildDatePicker(context),
          const SizedBox(height: 16),
          _buildTextField('Remarks', _remarksCtrl, 'Optional'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _submit(material.currentStock),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('REMOVE STOCK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Stock Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: bcNavy)),
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, String hint, {bool isNumber = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        TextField(
          controller: ctrl,
          enabled: enabled,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontWeight: FontWeight.bold, color: bcNavy),
          decoration: InputDecoration(
            hintText: hint,
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 0.5)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: bcPrimary, width: 2)),
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
        );
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date', style: TextStyle(fontSize: 12, color: Colors.grey)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Text(DateFormat('dd MMM yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.bold, color: bcNavy)),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
        ],
      ),
    );
  }

  Future<void> _submit(double availableQty) async {
    final qty = double.tryParse(_qtyCtrl.text) ?? 0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    
    if (qty <= 0) return;
    if (qty > availableQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient stock'), backgroundColor: Colors.red),
      );
      return;
    }

    final repo = context.read<InventoryRepository>();
    await repo.recordStockOut(
      materialId: widget.materialId,
      quantity: qty,
      rate: rate,
      date: _selectedDate,
      remarks: _remarksCtrl.text,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Stock removed successfully'), backgroundColor: Colors.red),
    );
  }
}
