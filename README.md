# Balkan Toast Master - Vending Machine Simulation

## Project Overview
Balkan Toast Master is a comprehensive software simulation of a specialized food vending kiosk designed to prepare and sell region-specific products such as toasts and tea. Developed using MATLAB App Designer, this project serves as the final submission for the ENS101 Introduction to Engineering course at the International University of Sarajevo.

Unlike standard vending machine simulations that handle static products, this system simulates complex engineering constraints including thermal physics, fluid dispensing logic, financial solvency verification, and dynamic user interface state management.

## Table of Contents
- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Technical Details](#technical-details)
  - [Thermal Simulation](#thermal-simulation)
  - [Financial Logic](#financial-logic)
  - [Data Persistence](#data-persistence)
- [Installation and Usage](#installation-and-usage)
- [File Structure](#file-structure)
- [Authors](#authors)

## Key Features

### User Interface and Experience
- **Dynamic Context Adaptation:** The interface automatically reconfigures control inputs based on the selected product (e.g., displaying "Ketchup" controls for solid foods versus "Sugar" controls for hot beverages).
- **Real-Time Visualization:** Utilizes high-resolution avatars and status indicators to provide immediate visual feedback for system states (Cooking, Idle, Error).
- **Event-Driven Interactions:** Implements a non-blocking GUI where user inputs are handled via callback orchestration to prevent race conditions during critical operations.

### Administrative System
- **Secure Access:** Protected by an authentication layer requiring an administrator password.
- **Telemetry Dashboard:** Features a real-time graph plotting temperature history over the last 30 seconds.
- **Inventory Management:** Allows for "hot-edits" of product prices and stock quantities directly through the interface, which are then serialized back to the external database.

## System Architecture
The project adopts a modular architecture that separates the presentation layer from the business logic, ensuring maintainability and scalability.

1.  **Presentation Layer (View):** Managed by `RunToastMachine`, this layer handles all graphical rendering, user input events, and audio feedback. It utilizes `uigridlayout` for responsive design.
2.  **Logic Engine (Model):** Encapsulated within the `ToastLogic` class, this component manages the Finite State Machine (FSM), thermal physics calculations, and financial algorithms.
3.  **Data Layer (Persistence):** External Excel files (`inventory.xlsx`) and text logs (`log.txt`) store configuration and audit data.

## Technical Details

### Thermal Simulation
The system does not use a simple timer for cooking but implements a hybrid physics-based temperature model:
- **Linear Cooling:** When idle, the temperature decays at a rate of 1°C/s towards the ambient temperature (25°C).
- **Asymptotic Heating:** During active cooking cycles, the temperature rises towards the target (180°C or 200°C) using a proportional step algorithm, creating a realistic heating curve.
- **Safety Interlocks:** A safety mechanism prevents operation if the internal temperature exceeds 150°C, requiring a cooldown period.

### Financial Logic
The financial subsystem ensures transactional integrity through three core algorithms:
- **Input Validation:** Rejects coin insertions if the specific denomination bin is full (capacity > 50 units).
- **Solvency Check:** Performs a pre-computation lookahead before transaction commitment to verify if the machine possesses the exact denominations required for a refund.
- **Greedy Algorithm:** optimizing change dispensation by prioritizing the largest available denominations to minimize coin count.

### Data Persistence
- **Inventory State:** Product stocks, prices, and coin counts are loaded from `inventory.xlsx` at startup and saved upon administrative commits.
- **Audit Logging:** Every financial transaction, error event, and temperature change is timestamped and appended to `log.txt` and `temperature_log.txt` for post-session analysis.

## Installation and Usage

### Prerequisites
- MATLAB R2025b (or compatible newer version).
- MATLAB App Designer Support Package.

### Running the Simulation
1.  Clone the repository to your local machine.
2.  Ensure `inventory.xlsx` and the `assets` folder are in the root directory.
3.  Open MATLAB and navigate to the project folder.
4.  Run the following command in the Command Window:
    ```matlab
    RunToastMachine
    ```
5.  **User Mode:** Select a product, adjust parameters, insert coins, and click Confirm.
6.  **Admin Mode:** Click the "Settings" button and enter the default password `1234` to access the backend dashboard.

## File Structure

- **RunToastMachine.m**: Entry point and main GUI lifecycle manager.
- **ToastLogic.m**: Backend class definition containing state machine and algorithms.
- **ToastComponents.m**: Factory class for dynamic UI component generation.
- **inventory.xlsx**: Database for products and coin stocks.
- **log.txt**: Sequential audit trail of system events.
- Images and audio files are containing same folder.

## Authors
**International University of Sarajevo - Faculty of Engineering and Natural Sciences**

- **[Ahmet Yusuf Özgören](https://www.linkedin.com/in/ayozgoren)** 
- **[Erdinç Taha Diker](https://www.linkedin.com/in/erdin%C3%A7-taha-d-5ba59631a/)** 

**Submitted to** Dr. Tarik Namas
