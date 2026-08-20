# Olist E-Commerce Business Analysis | Python , SQL & Power BI

## 📌 Project Overview

This project analyzes **Olist, a Brazilian e-commerce marketplace**, to understand sales performance, customer purchasing behavior, category performance, and operational issues.

The analysis follows a complete analytics workflow:

**Data Cleaning → Data Validation → SQL Analysis → Business Questions → Power BI Dashboard → Insights & Recommendations**

The primary objective was not only to identify what changed in business performance, but also to investigate **why it changed and what the business should investigate or improve next.**

---

## 🎯 Business Problem

The business experienced a decline in monthly revenue and order volume toward the later period of the dataset.

The analysis aimed to answer:

* Is the revenue decline driven by fewer orders or lower customer spending?
* How is AOV changing over time?
* Which product categories contribute most to revenue and order volume?
* What explains the decline in orders?
* Are cancellations contributing to the decline?
* Is there an unusual payment-related cancellation pattern?
* Are there data-quality issues affecting business reporting?

---

## 🗂️ Dataset

The Olist dataset contains multiple interconnected tables covering:

* Orders
* Order Items
* Customers
* Products
* Sellers
* Payments
* Reviews
* Geolocation
* Product Category Translation

The data was cleaned and validated using **Python/Pandas** before being analyzed using SQL and Power BI.

---

## 🛠️ Tools & Technologies

* **Python** — Data cleaning and validation
* **Pandas** — Data manipulation
* **PostgreSQL** — SQL analysis
* **Power BI** — Dashboard and visualization
* **DAX** — KPI calculations and measures

---

## 🔎 Analysis Approach

### 1. Data Cleaning & Validation

The datasets were checked for:

* Missing values
* Duplicate records
* Incorrect data types
* Invalid values
* Date inconsistencies
* Referential integrity
* Business-rule violations

Because the dataset contains multiple related tables, relationships between orders, products, customers, payments, and order items were also validated.

---

### 2. Business & Sales Analysis

The analysis examined:

* Total revenue
* Total orders
* Total customers
* Product count
* AOV
* Freight value
* Monthly revenue
* Monthly order volume
* Items per order
* Category-level revenue
* Category-level order volume

---

### 3. Root-Cause Investigation

When monthly revenue declined, the analysis did not stop at identifying the decline.

The investigation followed:

**Revenue ↓ → Orders ↓ → AOV ↑ → Category analysis → Cancellation investigation → Payment analysis**

This helped distinguish between a **volume problem** and a **spending problem**.

---

# 📊 Power BI Dashboard

The dashboard contains **4 KPI cards**:

* **Total Revenue**
* **Total Orders**
* **Average Order Value**
* **Items per Order**

### Main Visuals

1. **Revenue by Month & Year**
2. **Orders by Month & Year**
3. **AOV by Month & Year**
4. **Items per Order by Month & Year**
5. **Revenue by Product Category**
6. **Orders by Product Category**

The dashboard was designed to keep the analysis focused on the major business questions rather than adding visuals without analytical purpose.

---

# 💡 Key Insights

### 📉 1. Revenue decline was primarily driven by order volume

Monthly revenue decreased during the later period, while order volume also declined.

At the same time, **AOV increased**, indicating that the decline was not primarily caused by customers spending less per order.

**Business implication:**
The key issue is **transaction volume**, making successful order acquisition and retention more important than simply increasing basket value.

---

### 📈 2. AOV increased despite declining orders

AOV did not follow the downward movement in total orders.

This indicates that the remaining orders were generating relatively higher value on average.

**Business implication:**
The business should focus on **recovering lost order volume** rather than assuming the problem is low customer spending.

---

### 🏆 3. Health & Beauty was the leading revenue category

Health & Beauty generated the highest revenue among the product categories analyzed.

Other major revenue contributors included categories such as:

* Watches & Gifts
* Bed Bath & Table
* Sports & Leisure
* Computer Accessories

**Business implication:**
High-performing categories could be prioritized for inventory availability, promotions, and customer acquisition strategies.

---

### 🚨 4. September showed an extreme voucher cancellation anomaly

Voucher orders had a cancellation rate of approximately:

* **August: 22.41%**
* **September: 93.33%**

This represents an unusually large increase.

**Important:** This indicates a strong association, but does **not prove that vouchers caused the cancellations**.

**Business implication:**
The voucher/payment/order-processing workflow should be investigated for possible transaction or integration issues.

---

### ⚠️ 5. September contained incomplete transaction records

Some September orders did not have corresponding records in the `order_items` table.

This limits the ability to reliably connect those orders to:

* Products
* Categories
* Sellers
* Order-level revenue

**Business implication:**
Incomplete transaction records can reduce the reliability of operational reporting and make root-cause analysis more difficult.

---

### 🔍 6. Cancellation patterns were not strongly concentrated geographically

The cancelled September orders were spread across different customers and locations rather than being dominated by one specific customer or city.

**Business implication:**
The issue appears less likely to be caused by a small group of customers or a single geographic market and deserves investigation at the **payment/order-processing level**.

---

# 🎯 Recommendations

### 1. Investigate the voucher/payment workflow

Review:

* Voucher validation
* Voucher redemption
* Payment confirmation
* Order creation
* Cancellation triggers
* Payment-to-order integration

**Priority: High**

---

### 2. Monitor cancellation rate by payment type

Create an ongoing KPI for:

**Cancellation Rate = Cancelled Orders / Total Orders**

Monitor it by:

* Month
* Payment type
* Category
* Seller
* Geography

This can help identify abnormal spikes earlier.

---

### 3. Improve transaction traceability

Ensure that orders can be reliably traced through:

**Order → Order Item → Product → Seller**

This is particularly important for cancelled and incomplete transactions.

---

### 4. Focus on recovering order volume

Since AOV increased while order volume declined, growth efforts should focus on:

* Increasing successful transactions
* Reducing cancellations
* Improving payment reliability
* Recovering lost orders

rather than focusing only on increasing order value.

---

# 📌 Limitations

* Some records contain missing or inconsistent timestamps.
* Certain September orders lack corresponding order-item records.
* The voucher cancellation spike indicates an association, not confirmed causation.
* Delivery-performance analysis was not finalized because some delivery timestamps contained logical inconsistencies.

These limitations were considered before drawing conclusions from the data.

---


---

# 🚀 Key Takeaway

The analysis identified that the decline in business performance was primarily associated with **falling order volume rather than declining AOV**, while September revealed an unusual **voucher cancellation spike and incomplete transaction records**.

The analysis demonstrates how SQL and Power BI can be used not only to report metrics, but to move from:

**Business Problem → Investigation → Root Cause → Insight → Recommendation**.
