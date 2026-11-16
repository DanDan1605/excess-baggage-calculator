# Excess Baggage Fee Estimator

A Flutter mobile application built to estimate excess baggage fees for air travel[cite: 30].

## Student & Course Information
* **Course:** ICT602 - Mobile Technology (Individual Assignment - 20%)[cite: 30, 36]
* **Author:** ADAM DANIAL BIN MOHAMMAD HADI
* **Matric Number:** 2025227902
* **Lecturer:** Madam Idayati Binti Mazlan
* **GitHub Repository:** [excess-baggage-calculator](https://github.com/DanDan1605/excess-baggage-calculator)[cite: 36]

---

## Project Overview & Calculation Rules
This application calculates excess baggage charges based on checked baggage weight, ticket class allowance, and excess rate per kilogram[cite: 30]:

1. **Free Baggage Allowance ($X$):**[cite: 30]
   * **Economy Class:** `20 kg`[cite: 30]
   * **Business Class:** `40 kg`[cite: 30]
2. **Excess Baggage Weight:**[cite: 30]
   $$\text{Excess Weight} = \max(0, \text{Baggage Weight} - X)$$
   *(If baggage weight is less than or equal to $X$, excess weight is `0 kg`—never negative)[cite: 30].*
3. **Excess Baggage Charge:**[cite: 30]
   $$\text{Excess Charge} = \text{Excess Weight (kg)} \times \text{Rate per kg (RM)}$$
4. **Total Amount Payable (incl. 8% Service Tax):**[cite: 30]
   $$\text{Total Payable} = \text{Excess Charge} + (0.08 \times \text{Excess Charge})$$

---

## Sample Test Cases

| Baggage Weight (kg) | Ticket Class | Rate / kg (RM) | Excess Weight (kg) | Excess Charge (RM) | Total Payable (RM) |
| :---: | :---: | :---: | :---: | :---: | :---: |
| 25.0 | Economy | 15.00 | 5.00 | 75.00 | 81.00 |
| 18.0 | Economy | 15.00 | 0.00 | 0.00 | 0.00 |
| 55.0 | Business | 12.00 | 15.00 | 180.00 | 194.40 |
| 42.5 | Business | 12.00 | 2.50 | 30.00 | 32.40 |[cite: 30]

---

## Features Implemented
* **Interactive Inputs:** Decimal numeric inputs for baggage weight and rate per kg, paired with a custom Material 3 selection widget for Economy and Business classes[cite: 30, 31].
* **Formatted Summary Output:** Displays excess weight, base excess charge, 8% service tax breakdown, and total payable formatted to two decimal places[cite: 30, 31].
* **Navigation Menu:** Drawer navigation switching seamlessly between the **Home** calculator and the **About** page[cite: 31].
* **About Page:** Displays the custom app icon, student details, copyright notice, and a clickable GitHub repository link powered by `url_launcher`[cite: 31].
* **Input Validation & Design:** Includes upfront allowance instructions, error handling via floating SnackBars for invalid/empty inputs, and a one-tap reset button[cite: 31].
