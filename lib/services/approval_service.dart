import 'package:flutter/material.dart';
import 'package:construction_app/governance/approvals/models/action_request.dart';
import 'package:construction_app/governance/approvals/approvals_queue_screen.dart';
import 'package:construction_app/profiles/worker_types.dart';
import 'package:construction_app/modules/resources/tool_model.dart';
import 'package:construction_app/modules/resources/machine_model.dart';
import 'package:construction_app/modules/inventory/models/material_model.dart';
import 'package:construction_app/services/mock_notification_service.dart';
import 'package:construction_app/notifications/models/notification_model.dart';
import 'package:construction_app/services/mock_worker_service.dart';
import 'package:construction_app/services/mock_tool_service.dart';
import 'package:construction_app/services/mock_machine_service.dart';
import 'package:construction_app/services/inventory_service.dart';

class ApprovalService with ChangeNotifier {
  final List<ActionRequest> _requests = [];

  List<ActionRequest> get requests => List.unmodifiable(_requests);

  List<ActionRequest> getPendingRequests() {
    return _requests.where((r) => r.status == ApprovalStatus.pending).toList();
  }

  void submitRequest(ActionRequest request, {MockNotificationService? notificationService}) {
    _requests.insert(0, request);
    
    // Notify Admin of new request
    notificationService?.addNotification(NotificationModel(
      id: 'NT-${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.approval,
      title: 'Action Approval Required',
      message: '${request.requesterName} requested to ${request.action.name.toUpperCase()} ${request.entityType} at ${request.siteId}',
      timestamp: DateTime.now(),
      priority: NotificationPriority.high,
    ));

    notifyListeners();
  }

  Future<void> processRequest(
    String requestId, 
    ApprovalStatus status, {
    String? remark,
    MockWorkerService? workerService,
    MockToolService? toolService,
    MockMachineService? machineService,
    InventoryService? inventoryService,
    MockNotificationService? notificationService,
  }) async {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final request = _requests[idx];
      _requests[idx] = request.copyWith(
        status: status,
        adminRemark: remark,
        reviewedAt: DateTime.now(),
      );
      
      if (status == ApprovalStatus.approved) {
        try {
          await _executeMutation(request, workerService, toolService, machineService, inventoryService);
        } catch (e) {
          debugPrint('Error executing mutation for request $requestId: $e');
        }
      }

      // Notify Requester of outcome
      notificationService?.addNotification(NotificationModel(
        id: 'NT-${DateTime.now().millisecondsSinceEpoch}',
        type: NotificationType.approval,
        title: 'Request ${status.name.toUpperCase()}',
        message: 'Your request for ${request.entityType} was ${status.name}. ${remark != null ? "Remark: $remark" : ""}',
        timestamp: DateTime.now(),
        priority: status == ApprovalStatus.approved ? NotificationPriority.normal : NotificationPriority.high,
      ));
      
      notifyListeners();
    }
  }

  Future<void> _executeMutation(
    ActionRequest request,
    MockWorkerService? workerService,
    MockToolService? toolService,
    MockMachineService? machineService,
    InventoryService? inventoryService,
  ) async {
    final payload = request.payload;
    final entity = request.entityType.toLowerCase();

    switch (entity) {
      case 'worker':
        if (workerService != null) {
          final worker = Worker(
            id: payload['id'] ?? 'WK-${DateTime.now().millisecondsSinceEpoch}',
            name: payload['name'] ?? 'Unknown',
            phone: payload['phone'] ?? '',
            skill: payload['skill'] ?? 'General',
            shift: WorkerShift.values[payload['shift'] ?? 0],
            rateType: PayRateType.values[payload['rateType'] ?? 0],
            rateAmount: (payload['rateAmount'] ?? 0).toDouble(),
            status: WorkerStatus.active,
            assignedSite: payload['assignedSite'] ?? '',
            siteId: request.siteId,
            isActive: true,
            photoUrl: payload['photoUrl'],
            assignedWorkTypes: List<String>.from(payload['assignedWorkTypes'] ?? []),
          );
          if (request.action == ActionType.add) {
            await workerService.addWorker(worker);
          } else if (request.action == ActionType.edit) {
            await workerService.updateWorker(worker);
          }
        }
        break;

      case 'tool':
        if (toolService != null) {
          final tool = ToolModel(
            id: payload['id'] ?? 'T-${DateTime.now().millisecondsSinceEpoch}',
            name: payload['name'] ?? 'Unknown',
            type: ToolType.values.firstWhere((e) => e.name == payload['type'], orElse: () => ToolType.powerTool),
            usagePurpose: payload['usagePurpose'] ?? '',
            quantity: payload['quantity'] ?? 1,
            availableQuantity: payload['quantity'] ?? 1,
            condition: ToolCondition.values.firstWhere((e) => e.name == payload['condition'], orElse: () => ToolCondition.good),
            lastInspectionDate: DateTime.now(),
            assignedSiteId: request.siteId,
            assignedSiteName: payload['assignedSiteName'],
            assignedEngineerId: request.requesterId,
            assignedEngineerName: request.requesterName,
          );
          if (request.action == ActionType.add) {
            toolService.addTool(tool);
          } else if (request.action == ActionType.edit) {
            toolService.updateTool(tool);
          }
        }
        break;

      case 'machine':
        if (machineService != null) {
          final machine = MachineModel(
            id: payload['id'] ?? 'M-${DateTime.now().millisecondsSinceEpoch}',
            name: payload['name'] ?? 'Unknown',
            type: MachineType.values.firstWhere((e) => e.name == payload['type'], orElse: () => MachineType.excavator),
            status: MachineStatus.available,
            lastMaintenanceDate: DateTime.now(),
            assignedSiteId: request.siteId,
            assignedSiteName: payload['assignedSiteName'],
          );
          if (request.action == ActionType.add) {
            await machineService.addMachine(machine);
          } else if (request.action == ActionType.edit) {
            await machineService.updateMachine(machine);
          }
        }
        break;

      case 'material':
        if (inventoryService != null) {
          final material = ConstructionMaterial(
            id: payload['id'] ?? 'MAT-${DateTime.now().millisecondsSinceEpoch}',
            masterMaterialId: payload['masterMaterialId'] ?? 'legacy',
            name: payload['name'] ?? 'Unknown',
            siteId: request.siteId,
            category: MaterialCategory.values.firstWhere(
              (e) => e.name == (payload['category'] ?? ''),
              orElse: () => MaterialCategory.other,
            ),
            subType: payload['subType'] ?? 'General',
            pricePerUnit: (payload['pricePerUnit'] ?? 0).toDouble(),
            unitType: UnitType.values.firstWhere(
              (e) => e.name == (payload['unitType'] ?? ''),
              orElse: () => UnitType.unit,
            ),
            currentStock: (payload['currentStock'] ?? 0).toDouble(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          if (request.action == ActionType.add) {
            await inventoryService.addMaterial(material);
          } else if (request.action == ActionType.edit) {
            await inventoryService.updateMaterial(material);
          }
        }
        break;
    }
  }

  List<ActionRequest> getRequestsBySite(String siteId) {
    return _requests.where((r) => r.siteId == siteId).toList();
  }
}
