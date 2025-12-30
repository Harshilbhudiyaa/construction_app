# Project Structure & Architecture Documentation

This document outlines the "Feature-First" folders structure used in the Smart Construction app. The goal is to keep the project modular, scalable, and easy to navigate by separating concerns into dedicated feature modules.

## 📁 Root Directory Structure

- `lib/app`: App-level configuration (routes, theme, constants).
- `lib/core`: Reusable utilities, base widgets, and infrastructure services.
- `lib/features`: All business modules organized by feature.

---

## 🏗️ Feature Modules (`lib/features/`)

Each feature folder follows a Clean Architecture layer pattern (Data, Domain, Presentation).

### 1. **Auth (`/auth`)**
- **Purpose**: Handles user authentication, splash screen, and role selection.
- **Key Files**: `login_screen.dart`, `role_select_screen.dart`, `splash_screen.dart`.

### 2. **Worker (`/worker`)**
- **Purpose**: Role-specific screens and logic for field workers.
- **Key Files**: `worker_home_dashboard_screen.dart`, `worker_profile_screen.dart`.

### 3. **Engineer (`/engineer`)**
- **Purpose**: Role-specific shells and dashboard for Site Engineers.
- **Key Files**: `engineer_shell.dart`, `engineer_dashboard_screen.dart`.

### 4. **Contractor (`/contractor`)**
- **Purpose**: High-level oversight and administrative dashboards for Contractors.
- **Key Files**: `contractor_shell.dart`, `contractor_dashboard_screen.dart`.

### 5. **Trucks (`/trucks`)**
- **Purpose**: Fleet management and trip tracking.
- **Key Files**: `truck_trips_list_screen.dart`, `create_truck_entry_screen.dart`, `truck_trip_detail_screen.dart`.

### 6. **Inventory (`/inventory`)**
- **Purpose**: Managing raw materials, stock levels, and issue entries.
- **Key Files**: `inventory_dashboard_screen.dart`, `material_issue_entry_screen.dart`, `inventory_ledger_screen.dart`.

### 7. **Block Management (`/block_management`)**
- **Purpose**: Tracking production of construction blocks.
- **Key Files**: `block_production_entry_screen.dart`, `block_overview_screen.dart`.

### 8. **Payments & Billing (`/payments`, `/billing`)**
- **Purpose**: Financial tracking, worker payouts, and contractor invoicing.
- **Key Files**: `payments_dashboard_screen.dart`, `contractor_billing_screen.dart`.

### 9. **Work Sessions (`/work_sessions`)**
- **Purpose**: Shared logic for starting/stopping work and attendance details.

---

## 🔄 Organizing Strategy

When adding new code:
1. **If it's a specific feature** (like a new machine tracking system), create a new folder under `lib/features/`.
2. **If it's a role-only view** (like a dashboard that aggregates data), keep it in the role folder (worker/engineer/contractor).
3. **Common Widgets** used across multiple features go to `lib/core/widgets`.
4. **App-wide styling** goes to `lib/app/theme`.
