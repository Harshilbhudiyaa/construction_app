# SMARTCONSTRUCTION: SYSTEM DOCUMENTATION

## 1. Overall Application Concept

SmartConstruction is a specialized mobile application built to provide **Unified Digital Management** for the civil construction industry. It serves as a centralized "Command Center" that bridges the gap between on-site engineering tasks and administrative financial tracking.

*   **Main Purpose:** To digitize construction workflows, ensuring real-time visibility into material stock, project expenses, and site progress.
*   **Primary Users:**
    *   **Civil Contractors:** Oversee multiple projects, manage finances (receivables/payables), and monitor total stock value.
    *   **Site Engineers:** Handle daily operations, log material consumption, perform engineering calculations, and request new stock.
    *   **Material Suppliers:** Targeted indirectly via the Party Ledger and Inward Entry systems which track vendor-specific deliveries and dues.
*   **Core Problems Solved:**
    *   **Manual Errors:** Replaces paper-based logs with digital entry and automated math.
    *   **Stock Leakages:** Strict tracking of inward movements vs. consumption (Stock Out).
    *   **Financial Opacity:** Automatic synchronization between material delivery and vendor ledger credits.
    *   **Fragmented Tools:** Combines specialized engineering calculators with ERP-like inventory and ledger features.

---

## 2. Module Breakdown

### A. Authentication & User Management
*   **Onboarding:** Secure login and registration for administrators and managers.
*   **Branded Entry:** A professional splash screen for a premium initial experience.
*   **Role-Based Access Control (RBAC):** Strict permission matrix (Admin, Manager, Site Engineer, Storekeeper, Contractor) defining view/action access.

### B. Dashboard (Command Center)
*   **KPI Overview:** High-level metrics for Total Success (received payments), Pending Payments, Receivables, and Payables.
*   **Site Context:** Allows users to switch between different construction sites, instantly filtering all data (stock, ledger, milestones) for that specific project.
*   **Quick Access:** One-tap shortcuts to all primary operational tools.

### C. Inventory Management
*   **Material Master:** A catalog where users define materials (Cement, Sand, Steel, etc.) with specific categories, unit types (Bags, Tons, SqFt), and minimum stock levels.
*   **Inward Entry:** Digital logging of material arrivals including vehicle details, transporter info, unit rates, and tax calculations.
*   **Stock Operations:**
    *   **Stock Out:** Recording material usage/consumption on-site.
    *   **Stock Transfer:** Tracking movement of resources between different sites.
    *   **Stock Damage:** Logging wastage or damaged material for audit purposes.
*   **Material Requests:** A dedicated flow for site engineers to request restocks from the main office or suppliers.

### D. Financial Management (Ledger)
*   **Party Management:** Profiles for all stakeholders (Suppliers, Contractors, Clients).
*   **Unified Ledger:** A real-time transaction history for every party. It supports double-entry logic where inward material movement creates "Credit" and payments create "Debit."
*   **Payment History:** A dedicated log of all financial transactions with status tracking (Success, Pending, Failed).

### E. Labour & Contractor Management
*   **Contract Lifecycle:** Tracking labour contracts from "Ongoing" to "Completed" and "Settled."
*   **Payment Tracking:** Logging advance payments and reconciling final settlements.
*   **ERP Sync:** Automated ledger debits when labour contracts are settled.
*   **Site-Specific Costing:** Viewing total labour expenditure per project.

### F. Advanced Construction Calculators
*   **Specialized Estimators:** Precision tools for civil engineering math:
    *   **Brick Calculator:** Quantity based on wall volume and mortar ratios.
    *   **Concrete Calculator:** Volume and material mix (Cement/Sand/Aggregate) for slabs, beams, and columns.
    *   **Steel Calculator:** Weight estimation using bar diameter and length.
    *   **Tile Calculator:** Area-based tile count with wastage margins.
*   **Calculation History:** Persistence of previous estimates for quick retrieval.

### F. Milestones & Reporting
*   **Milestone Tracker:** Monitoring critical project phases and payment due dates.
*   **Export Center:** Generation of professional PDF and Excel reports for financial auditing and inventory stock-taking.
*   **Live Analytics:** Data visualization (charts) showing stock movement trends and financial distributions.

---

## 3. User Flow

The application follows a logical operational loop centered around material and money movement:

1.  **Initialization:** User registers and sets up the project sites and material master catalog.
2.  **Resource In-flow:** Materials arrive at the site. The user logs an **Inward Entry**.
3.  **Approval Loop:** An administrator reviews the Inward Entry. Once approved:
    *   The **Material Stock** is automatically incremented.
    *   A **Ledger Entry** is automatically created to show the amount owed to the supplier.
4.  **Field Operations:** Engineers use **Calculators** to estimate required quantities and log a **Stock Out** (Consumption) as materials are used.
5.  **Labour Management:** Contractors are registered, and work contracts are logged. **Advance Payments** are tracked.
6.  **Completion & Settlement:** Work is marked as finished. The system calculates the **Pending Balance**. Upon **Final Settlement**, a corresponding **Ledger Debit** is generated.
7.  **Review & Export:** Users monitor the **Command Center** for alerts (low stock, pending settlements, or overdue milestones) and generate **PDF Reports**.

---

## 4. Data Flow

The system is designed with **Atomic ERP Logic**, meaning data flows automatically across modules to ensure consistency:

*   **Inventory ➔ Ledger:** Approving an inward log triggers a financial credit in the relevant party's ledger.
*   **Payments ➔ Ledger:** Recording a payment toward a party creates a debit entry, reducing the outstanding balance.
*   **Site Context ➔ All Modules:** The `selectedSiteId` acts as a global filter. When a site is changed in the Command Center, the Stock View, Ledger, and Milestone lists refresh to show data only for that site.
*   **Calculators ➔ Field Data:** While currently separate for math, calculation history serves as a reference for manual entry into the Stock Out module.

---

## 5. Key Functionalities (Working Logic)

*   **Multi-Site Management:** A robust site selector that allows a single contractor to manage multiple geographically separate projects from one dashboard.
*   **Automated Stock Sync:** Stock levels are not updated manually; they are a calculated result of approved Inward entries minus Stock Out/Damage entries.
*   **Offline-First Architecture:** The system uses local storage (SharedPreferences) to persist all data. This ensures it remains functional in remote areas with poor connectivity.
*   **Audit-Ready Transaction Logs:** Every material movement and financial transaction is logged with timestamps, "recorded by" users, and "approved by" administrators.
*   **Dynamic Theming:** High-performance "Hard Hat Yellow" theme that provides an industry-specific professional feel while maintaining high readability.

---

## 6. Current Limitations

*   **Local Persistence Only:** Current data is stored on the device using `SharedPreferences`. There is no cloud synchronization or cross-device data sharing implemented yet.
*   **Manual Calculator Linking:** Estimates from the calculators aren't automatically pulled into the Inward or Stock Out forms; users must manually enter the amounts.
*   **Historical Trends:** While Rate History is now tracked for materials, advanced forecasting models are not yet implemented.

---

## 7. Technical Summary (For Developers)

*   **Frontend:** Flutter (Mobile, Desktop, Web support).
*   **State Management:** `Provider` (using `MultiProvider` for dependency injection).
*   **Repository Pattern:** Decoupled data logic in `lib/data/repositories`.
*   **Workflow Service:** A coordinator service (`WorkflowService`) that handles multi-repo atomic operations (e.g., Inventory + Ledger sync).
*   **Storage:** JSON-encoded objects in `SharedPreferences`.
*   **Theme:** Custom Design System defined in `lib/core/theme`.
