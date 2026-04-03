# INDUSTRIAL TRAINING REPORT
# ON
# Smart Construction Management Mobile Application
(Application)

**Prepared By:**  
VEKARIYA NIMESH (23SDSCE01174)

**DIPLOMA IN COMPUTER ENGINEERING**  
**Semester – 6th**

**Year: 2023-26**

**SCHOOL OF DIPLOMA STUDIES**  
**RK. UNIVERSITY**  
**RAJKOT (GUJRAT-INDIA) 360020.**

---

### TABLE OF CONTENT
1. Acknowledgement ........................................... 3
2. Abstract .................................................. 4
3. Chapter 1 – Introduction ................................... 8
4. Chapter 2 – System Requirements ............................ 9
5. Chapter 3 – Company Profile ................................ 10
6. Chapter 4 – System Analysis ................................ 12
7. Chapter 5 – System Design .................................. 13
8. Chapter 6 – Information about project ....................... 15
9. Chapter 7 – References ..................................... 15
10. Chapter 8 – Conclusion ..................................... 16

---

### ACKNOWLEDGEMENT
I would like to express my sincere gratitude to our project guide and faculty members for their valuable guidance and support throughout the development of the Smart Construction Management Mobile Application. Their continuous encouragement and technical suggestions helped us to complete this project successfully.

I also thank my team members for their cooperation, dedication, and teamwork. Finally, I would like to thank my institute for providing the necessary resources and environment to carry out this project work.

**With Sincere Regards,**  
Vekariya Nimesh (23SDSCE01174)

---

### ABSTRACT
The Smart Construction Management Mobile Application is designed to digitalize and simplify construction site operations. In traditional construction management, tracking materials, approving work progress, and communication between contractors and site engineers is often manual, leading to delays and errors.

This application provides a centralized, secure, and intelligent platform. The system facilitates real-time interaction between Site Engineers, Contractors, and Supervisors. Key features include precise material calculators (Brick, Concrete, Steel, Tile), inward/outward inventory management, party-wise ledgers, and automated report generation. The aim of this project is to reduce paperwork, increase transparency, and enhance productivity at construction sites through Flutter mobile technology.

---

### CHAPTER 1: INTRODUCTION

#### 1.1 Project Summary
The Smart Construction Management App is a mobile-based solution that connects all construction roles in a single system. It allows:
- **Material Estimation:** Advanced calculators for bricks, concrete, steel, and tiles.
- **Inventory Tracking:** Real-time logging of inward materials and stock-out consumption.
- **Financial Ledger:** Digital management of payments and dues for suppliers and contractors.
- **Role-Based Access:** Secure modules for site management and contractor operations.
- **Reporting:** One-click PDF/Excel generation for audit-ready records.

#### 1.2 Aim and Objective
**Aim:** To develop a mobile application that unifies construction operations into one digital platform.
**Objectives:**
- Automate construction material quantity estimation.
- Replace manual inventory and financial record-keeping.
- Provide real-time monitoring of site progress and stock levels.
- Improve transparency and coordination between stakeholders.
- Maintain a digital archive of project transactions.

#### 1.3 Uses of Application
- Real-time construction site monitoring.
- Accurate material requirement planning.
- Digital financial ledger for project transparency.
- Professional report generation for audits and meetings.

---

### CHAPTER 2: SYSTEM REQUIREMENTS

#### 2.1 Hardware and Software requirements
**Hardware:**
- Android / iOS Mobile Phone (Minimum 2GB RAM)
- Internet Connection for reporting services.
- Laptop/PC for development and debugging.

**Software:**
- Framework: **Flutter SDK (3.x)**
- Language: **Dart**
- State Management: **Provider**
- Data Storage: **Shared Preferences & Repository Pattern**
- IDE: **VS Code / Android Studio**

---

### CHAPTER 3: COMPANY PROFILE
**Company Name:** DeepCoder Private Limited  
**Location:** 504 Jaihind HN Safal, Besides Newyork Tower Thaltej Cross Road, Sarkhej - Gandhinagar Hwy, Ahmedabad, Gujarat 380054

DeepCoder is a leading IT solutions company dedicated to delivering world-class technology services. Since its establishment in 2015, DeepCoder has experienced rapid growth and has built a strong reputation in the IT industry. The company offers a comprehensive portfolio of services, including Cloud Computing, Cybersecurity, Data Visualization, and Managed IT Services.

---

### CHAPTER 4: SYSTEM ANALYSIS
The system analysis identifies the flow of data within the application:
1. **User Role Analysis:** Identification of tasks for Site Engineers (calculators, stock-out) and Contractors (ledgers, inward management).
2. **Technical Feasibility:** Leveraging Flutter's cross-platform capabilities and Dart's performance for real-time local state management.
3. **Operational Feasibility:** Designing an intuitive interface using the "Hard Hat Yellow" theme for field workers.
4. **Economic Feasibility:** Reducing physical paperwork costs and minimizing manual estimation errors.

---

### CHAPTER 5: SYSTEM DESIGN
The application follows a **Modular Design** pattern:
- **Presentation Layer:** Flutter Widgets and custom design tokens (Hard Hat Theme).
- **Business Logic Layer:** Provider classes for managing app state (Inventory, Ledger, Calculation).
- **Data Layer:** Local repositories for persistent data storage and industry-specific models (Brick, Steel, etc.).
- **Service Layer:** Routing, Theme, and Reporting services.

---

### CHAPTER 6: INFORMATION ABOUT PROJECT
*Note: This section summarizes the core logic implemented in the SmartConstruction app, such as the `calculation_history_model.dart` for tracking previous estimates and the `inventory_repository.dart` for managing demo data and stock operations.*

---

### CHAPTER 7: REFERENCES
- www.google.com
- www.stackoverflow.com
- www.github.com
- www.youtube.com
- www.geeksforgeeks.org
- flutter.dev
- pub.dev

---

### CHAPTER 8: CONCLUSION
The Smart Construction Management Mobile Application successfully replaces traditional manual construction management methods with a digital and intelligent solution. It improves transparency, accountability, and productivity at construction sites. By implementing digital calculators and ledgers, the system ensures accurate monitoring and efficient workflow. This project demonstrates how mobile technology can transform construction management into a modern, efficient, and paperless system.
