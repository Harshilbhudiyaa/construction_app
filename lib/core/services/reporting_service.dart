import 'package:flutter/foundation.dart';
import 'package:construction_app/data/models/inward_movement_model.dart';
import 'package:construction_app/data/models/material_model.dart';
import 'package:construction_app/data/models/inventory_transaction.dart';
import 'package:construction_app/data/repositories/inventory_repository.dart';
import 'package:construction_app/data/repositories/labour_repository.dart';
import 'package:construction_app/data/repositories/ledger_repository.dart';
import 'package:construction_app/data/repositories/site_repository.dart';

class ReportSummary {
  final double totalInwardValue;
  final double totalOutwardQty;
  final int totalEntries;
  final int pendingApprovals;
  final double totalStockValue;

  ReportSummary({
    required this.totalInwardValue,
    required this.totalOutwardQty,
    required this.totalEntries,
    required this.pendingApprovals,
    required this.totalStockValue,
  });
}

class ProjectPerformance {
  final double totalBudget;
  final double materialExpense;
  final double labourExpense;
  final double otherExpense;
  final double profitOrLoss;
  final double wastageEstimate;

  ProjectPerformance({
    required this.totalBudget,
    required this.materialExpense,
    required this.labourExpense,
    required this.otherExpense,
    required this.profitOrLoss,
    required this.wastageEstimate,
  });
  
  double get totalExpense => materialExpense + labourExpense + otherExpense;
  double get marginPercent => totalBudget > 0 ? (profitOrLoss / totalBudget) * 100 : 0;
}

class ReportingService extends ChangeNotifier {
  final InventoryRepository _inventoryRepo;
  final LabourRepository? _labourRepo;
  final LedgerRepository? _ledgerRepo;
  final SiteRepository? _siteRepo;

  ReportingService(
    this._inventoryRepo, {
    LabourRepository? labourRepo,
    LedgerRepository? ledgerRepo,
    SiteRepository? siteRepo,
  })  : _labourRepo = labourRepo,
        _ledgerRepo = ledgerRepo,
        _siteRepo = siteRepo {
    _inventoryRepo.addListener(notifyListeners);
    _labourRepo?.addListener(notifyListeners);
    _ledgerRepo?.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _inventoryRepo.removeListener(notifyListeners);
    _labourRepo?.removeListener(notifyListeners);
    _ledgerRepo?.removeListener(notifyListeners);
    super.dispose();
  }

  // --- Project Performance ---

  ProjectPerformance getProjectPerformance({String? siteId}) {
    final materialExpense = _inventoryRepo.logs
        .where((l) => l.status == InwardStatus.approved && (siteId == null || l.id.contains(siteId))) // Inward logs don't have siteId yet, but let's assume filtering by ID for now if needed.
        .fold<double>(0, (sum, l) => sum + l.totalAmount);
    
    final labourExpense = _labourRepo?.entries
        .where((e) => siteId == null || e.siteId == siteId)
        .fold<double>(0, (sum, e) => sum + e.totalContractAmount) ?? 0;
    
    // Budget from site repo
    final site = siteId != null ? _siteRepo?.getSiteById(siteId) : null;
    final totalBudget = site?.budgetAmount ?? 5000000.0; 
    
    final profitOrLoss = totalBudget - (materialExpense + labourExpense);
    
    return ProjectPerformance(
      totalBudget: totalBudget,
      materialExpense: materialExpense,
      labourExpense: labourExpense,
      otherExpense: materialExpense * 0.1, // Estimating 10% overhead
      profitOrLoss: profitOrLoss,
      wastageEstimate: materialExpense * 0.05, // 5% estimated waste
    );
  }

  // --- Filtering Logic ---

  List<InwardMovementModel> getInwardReport({
    DateTime? startDate,
    DateTime? endDate,
    InwardStatus? status,
  }) {
    return _inventoryRepo.logs.where((log) {
      if (startDate != null && log.createdAt.isBefore(startDate)) return false;
      if (endDate != null && log.createdAt.isAfter(endDate)) return false;
      if (status != null && log.status != status) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<InventoryTransaction> getTransactionReport({
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
    String? materialId,
  }) {
    return _inventoryRepo.transactions.where((txn) {
      if (startDate != null && txn.timestamp.isBefore(startDate)) return false;
      if (endDate != null && txn.timestamp.isAfter(endDate)) return false;
      if (type != null && txn.type != type) return false;
      if (materialId != null && txn.materialId != materialId) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<ConstructionMaterial> getStockLevelReport({
    bool lowStockOnly = false,
  }) {
    return _inventoryRepo.materials.where((m) {
      if (lowStockOnly && m.currentStock > m.minimumStockLimit) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // --- Summary Statistics ---

  ReportSummary getSummaryStats({DateTime? startDate, DateTime? endDate}) {
    final filteredLogs = getInwardReport(startDate: startDate, endDate: endDate, status: InwardStatus.approved);
    final filteredTxns = getTransactionReport(startDate: startDate, endDate: endDate, type: TransactionType.outward);

    final totalInwardValue = filteredLogs.fold<double>(0, (sum, log) => sum + log.totalAmount);
    final totalOutwardQty = filteredTxns.fold<double>(0, (sum, txn) => sum + txn.quantity);
    final totalEntries = getInwardReport(startDate: startDate, endDate: endDate).length;
    final pending = _inventoryRepo.logs.where((l) => l.status == InwardStatus.pendingApproval).length;
    final stockValue = _inventoryRepo.materials.fold<double>(0, (sum, m) => sum + m.totalAmount);

    return ReportSummary(
      totalInwardValue: totalInwardValue,
      totalOutwardQty: totalOutwardQty,
      totalEntries: totalEntries,
      pendingApprovals: pending,
      totalStockValue: stockValue,
    );
  }
}
