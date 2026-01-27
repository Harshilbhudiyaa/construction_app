import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:construction_app/shared/theme/professional_theme.dart';
import 'package:construction_app/services/payment_service.dart';
import 'payment_method_selector.dart';
import 'payment_proof_upload_widget.dart';
import 'recipient_selector.dart';

class PaymentFormSheet extends StatefulWidget {
  final Payment? existingPayment; // Null for create, populated for edit
  final String category; // 'engineer', 'worker', 'inventory'
  final Function(Payment) onSubmit;

  const PaymentFormSheet({
    super.key,
    this.existingPayment,
    required this.category,
    required this.onSubmit,
  });

  @override
  State<PaymentFormSheet> createState() => _PaymentFormSheetState();
}

class _PaymentFormSheetState extends State<PaymentFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _totalPayableController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _transactionRefController = TextEditingController();
  
  // Role-specific controllers
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _siteNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _unitController = TextEditingController();
  
  String? _selectedRecipientId;
  String? _selectedRecipientName;
  Map<String, dynamic>? _recipientDetails;
  DateTime _selectedDate = DateTime.now();
  DateTime? _periodStart;
  DateTime? _periodEnd;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  String _selectedStatus = 'pending';
  String? _proofUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingPayment != null) {
      final p = widget.existingPayment!;
      _selectedRecipientId = p.recipientId;
      _selectedRecipientName = p.recipientName;
      _amountController.text = p.amount.toString();
      _totalPayableController.text = p.totalPayable.toString();
      _descriptionController.text = p.description ?? '';
      _transactionRefController.text = p.transactionRef ?? '';
      _selectedDate = p.date;
      _selectedPaymentMethod = _parsePaymentMethod(p.paymentMethod);
      _selectedStatus = p.status;
      _proofUrl = p.proofUrl;
      
      _siteNameController.text = p.siteName ?? '';
      _roleController.text = p.role ?? '';
      _quantityController.text = p.quantity?.toString() ?? '';
      _unitPriceController.text = p.unitPrice?.toString() ?? '';
      _unitController.text = p.unit ?? '';
      _periodStart = p.periodStart;
      _periodEnd = p.periodEnd;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _recipientDetails = RecipientSelector.getRecipientDetails(
              context, 
              widget.category, 
              _selectedRecipientId
            );
          });
        }
      });
    }

    // Listeners for auto-calculation
    if (widget.category == 'inventory') {
      _quantityController.addListener(_updateInventoryTotal);
      _unitPriceController.addListener(_updateInventoryTotal);
    } else if (widget.category == 'worker') {
      _unitPriceController.addListener(_updateWorkerTotal);
    }
  }

  void _updateInventoryTotal() {
    final qty = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_unitPriceController.text) ?? 0;
    final total = qty * price;
    if (total > 0) {
      _totalPayableController.text = total.toStringAsFixed(2);
      if (_selectedStatus == 'paid') {
        _amountController.text = total.toStringAsFixed(2);
      }
    }
  }

  void _updateWorkerTotal() {
    if (_periodStart == null || _periodEnd == null) return;
    final wage = double.tryParse(_unitPriceController.text) ?? 0;
    final days = _periodEnd!.difference(_periodStart!).inDays + 1;
    if (days > 0 && wage > 0) {
      final total = days * wage;
      _totalPayableController.text = total.toStringAsFixed(2);
      if (_selectedStatus == 'paid') {
        _amountController.text = total.toStringAsFixed(2);
      }
    }
  }

  PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'cash': return PaymentMethod.cash;
      case 'upi': return PaymentMethod.upi;
      case 'bankTransfer':
      case 'bank': return PaymentMethod.bankTransfer;
      case 'cheque': return PaymentMethod.cheque;
      default: return PaymentMethod.cash;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _totalPayableController.dispose();
    _descriptionController.dispose();
    _transactionRefController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _siteNameController.dispose();
    _roleController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  String get _title => widget.existingPayment != null ? 'Edit Payment' : 'Create Payment';
  String get _submitLabel => widget.existingPayment != null ? 'Update' : 'Create';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(_title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RecipientSelector(
                      category: widget.category,
                      initialRecipientId: _selectedRecipientId,
                      onRecipientSelected: (id, name, details) {
                        setState(() {
                          _selectedRecipientId = id;
                          _selectedRecipientName = name;
                          _recipientDetails = details;
                          _autoFillFromRecipient(details);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    if (_recipientDetails != null) ...[
                      _buildRecipientDetails(),
                      const SizedBox(height: 16),
                    ],

                    _buildCategorySpecificFields(),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _totalPayableController,
                            label: 'Total Payable (₹)',
                            icon: Icons.account_balance_wallet_rounded,
                            keyboardType: TextInputType.number,
                            validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                          ),
                        ),
                        if (_selectedStatus == 'partial') ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _amountController,
                              label: 'Paid (₹)',
                              icon: Icons.payments_rounded,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                final paid = double.tryParse(v!) ?? 0;
                                final total = double.tryParse(_totalPayableController.text) ?? 0;
                                if (paid >= total) return 'Paid < Total';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_selectedStatus == 'partial') ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 4),
                        child: Text(
                          'Balance to pay: ₹${((double.tryParse(_totalPayableController.text) ?? 0) - (double.tryParse(_amountController.text) ?? 0)).toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    _buildDatePicker('Payment Date', _selectedDate, (d) => setState(() => _selectedDate = d)),
                    const SizedBox(height: 16),

                    _buildStatusSelector(),
                    const SizedBox(height: 16),

                    PaymentMethodSelector(
                      selectedMethod: _selectedPaymentMethod,
                      onMethodSelected: (method) => setState(() => _selectedPaymentMethod = method),
                    ),
                    const SizedBox(height: 16),

                    if (_selectedPaymentMethod != PaymentMethod.cash) ...[
                      _buildTextField(
                        controller: _transactionRefController,
                        label: 'Transaction ID / Ref',
                        icon: Icons.receipt_long_rounded,
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description / Remarks',
                      icon: Icons.description_rounded,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    const PaymentProofUploadWidget(),
                    const SizedBox(height: 24),

                    _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _autoFillFromRecipient(Map<String, dynamic> details) {
    if (widget.category == 'engineer') {
      _siteNameController.text = details['site'] ?? '';
      _roleController.text = details['role'] ?? '';
    } else if (widget.category == 'worker') {
      _siteNameController.text = details['site'] ?? '';
      _roleController.text = details['role'] ?? '';
      _unitPriceController.text = details['dailyWage']?.toString() ?? '';
    } else if (widget.category == 'inventory') {
      _unitPriceController.text = details['unitPrice']?.toString() ?? '';
      _unitController.text = details['unit'] ?? '';
    }
  }

  Widget _buildCategorySpecificFields() {
    switch (widget.category) {
      case 'engineer':
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _siteNameController, label: 'Assigned Site', icon: Icons.location_on_rounded, readOnly: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(controller: _roleController, label: 'Role', icon: Icons.work_rounded, readOnly: true)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDatePicker('Start Date', _periodStart ?? DateTime.now(), (d) => setState(() => _periodStart = d))),
                const SizedBox(width: 12),
                Expanded(child: _buildDatePicker('End Date', _periodEnd ?? DateTime.now(), (d) => setState(() => _periodEnd = d))),
              ],
            ),
          ],
        );
      case 'worker':
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _siteNameController, label: 'Current Site', icon: Icons.location_on_rounded, readOnly: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(controller: _unitPriceController, label: 'Daily Wage', icon: Icons.currency_rupee_rounded, keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDatePicker('Start Date', _periodStart ?? DateTime.now(), (d) {
                  setState(() => _periodStart = d);
                  if (widget.category == 'worker') _updateWorkerTotal();
                })),
                const SizedBox(width: 12),
                Expanded(child: _buildDatePicker('End Date', _periodEnd ?? DateTime.now(), (d) {
                  setState(() => _periodEnd = d);
                  if (widget.category == 'worker') _updateWorkerTotal();
                })),
              ],
            ),
          ],
        );
      case 'inventory':
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _quantityController, label: 'Quantity', icon: Icons.shopping_bag_rounded, keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(controller: _unitController, label: 'Unit (e.g. kg, bag)', icon: Icons.straighten_rounded)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(controller: _unitPriceController, label: 'Unit Price (₹)', icon: Icons.price_check_rounded, keyboardType: TextInputType.number),
          ],
        );
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildRecipientDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Text('${widget.category.toUpperCase()} INFO', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ..._recipientDetails!.entries.where((e) => e.key != 'engineerId').map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key.toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
                Text(e.value.toString(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w700),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: label,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), fontSize: 15, fontWeight: FontWeight.w600),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        filled: true,
        fillColor: readOnly ? Theme.of(context).dividerColor.withOpacity(0.05) : Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5)),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime current, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: current, firstDate: DateTime(2025), lastDate: DateTime(2030));
        if (d != null) onPicked(d);
      },
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(DateFormat('dd MMM yyyy').format(current), style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    final statuses = ['pending', 'paid', 'partial', 'overdue'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Status', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: statuses.map((s) {
              final isS = _selectedStatus == s;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedStatus = s;
                      if (s == 'paid') _amountController.text = _totalPayableController.text;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isS ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isS ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.1), width: 1.5),
                    ),
                    child: Text(s.toUpperCase(), style: TextStyle(color: isS ? Colors.white : Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w900)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
        child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_submitLabel, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRecipientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a recipient first'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    final totalVal = double.parse(_totalPayableController.text);
    final amountVal = _selectedStatus == 'paid' ? totalVal : (double.tryParse(_amountController.text) ?? 0);

    final payment = Payment(
      id: widget.existingPayment?.id ?? 'pay_${DateTime.now().millisecondsSinceEpoch}',
      category: widget.category,
      recipientName: _selectedRecipientName ?? 'Unknown',
      recipientId: _selectedRecipientId ?? 'UNK',
      amount: amountVal,
      totalPayable: totalVal,
      date: _selectedDate,
      status: _selectedStatus,
      paymentMethod: _selectedPaymentMethod.toString().split('.').last,
      description: _descriptionController.text,
      transactionRef: _transactionRefController.text,
      siteName: _siteNameController.text,
      role: _roleController.text,
      quantity: double.tryParse(_quantityController.text),
      unitPrice: double.tryParse(_unitPriceController.text),
      unit: _unitController.text,
      periodStart: _periodStart,
      periodEnd: _periodEnd,
      createdAt: widget.existingPayment?.createdAt ?? DateTime.now(),
      updatedAt: widget.existingPayment != null ? DateTime.now() : null,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
    if (mounted) {
      widget.onSubmit(payment);
      Navigator.pop(context);
    }
  }
}

