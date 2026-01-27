# Project Restructuring Plan

## New Folder Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── app/                    # App-level configuration
│   ├── app.dart
│   └── routes.dart
├── core/                   # Core infrastructure
│   ├── constants/
│   ├── errors/
│   └── widgets/           # Basic widgets (loader, etc.)
├── shared/                 # Shared resources
│   ├── ui/                # Shared UI widgets
│   ├── theme/             # Theme configuration
│   └── utils/             # Shared utilities
├── auth/                   # Authentication module
│   └── screens/
├── dashboard/              # Role-based dashboards
│   ├── contractor/
│   ├── engineer/
│   └── worker/
├── governance/             # Governance & approvals
│   ├── approvals/
│   ├── sites/
│   └── models/
├── modules/                # Feature modules
│   ├── inventory/
│   ├── payments/
│   ├── work_sessions/
│   ├── engineer_management/
│   ├── worker_management/
│   ├── block_management/
│   └── safety/
├── notifications/          # Notifications module
├── profiles/               # User profiles
└── services/               # Business logic services
```

## File Mapping

### Auth Module
- `features/auth/*` → `auth/screens/*`

### Dashboard Module
- `features/contractor/contractor_dashboard_screen.dart` → `dashboard/contractor/`
- `features/engineer/engineer_dashboard_screen.dart` → `dashboard/engineer/`
- `features/worker/worker_home_dashboard_screen.dart` → `dashboard/worker/`
- Shells remain in their respective modules

### Governance Module
- `features/approvals/*` → `governance/approvals/`
- `features/contractor/site_management_screen.dart` → `governance/sites/`
- `features/contractor/site_form_screen.dart` → `governance/sites/`
- `features/contractor/site_access_screen.dart` → `governance/sites/`
- `features/contractor/models/site_model.dart` → `governance/models/`

### Modules
- `features/inventory/*` → `modules/inventory/`
- `features/payments/*` → `modules/payments/`
- `features/work_sessions/*` → `modules/work_sessions/`
- `features/engineer/engineer_*.dart` (management) → `modules/engineer_management/`
- `features/engineer/models/*` → `modules/engineer_management/models/`
- `features/worker/worker_*.dart` (management) → `modules/worker_management/`
- `features/worker/worker_types.dart` → `modules/worker_management/`
- `features/block_management/*` → `modules/block_management/`
- `features/safety/*` → `modules/safety/`

### Notifications
- `features/notifications/*` → `notifications/`

### Profiles
- `features/worker/worker_profile_screen.dart` → `profiles/worker_profile_screen.dart`
- `features/contractor/contractor_settings_screen.dart` → `profiles/contractor_settings_screen.dart`
- `features/contractor/contractor_alerts_screen.dart` → `profiles/contractor_alerts_screen.dart`

### Services
- `core/services/*` → `services/`

### Shared
- `app/ui/widgets/*` → `shared/ui/widgets/`
- `app/theme/*` → `shared/theme/`
- `app/utils/*` → `shared/utils/`
- `core/utils/*` → `shared/utils/`
- `core/widgets/*` → `shared/ui/widgets/` (basic widgets)

### Core
- `core/constants/*` → `core/constants/`
- `core/errors/*` → `core/errors/`
