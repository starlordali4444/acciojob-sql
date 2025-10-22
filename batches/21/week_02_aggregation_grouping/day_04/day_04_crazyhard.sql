/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 4 (CRAZY HARD LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Filtering & Sorting — Expert Patterns (single-table only)
   Scope (STRICT):
     - Clauses only: WHERE, AND, OR, BETWEEN, IN, LIKE/ILIKE, IS [NOT] NULL, DISTINCT,
       ORDER BY (ASC/DESC, NULLS FIRST/LAST), LIMIT/OFFSET
     - Read-only SELECT queries on retailmart schema (no joins, no aggregates)
   Structure: 10 Conceptual + 50 Expert Filtering + 40 Advanced Sorting/Pagination = 100 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (10)
   ------------------------------------------------------------ */
/* Q1. Why can mixing AND/OR without parentheses produce unexpected filter results? Give an example. */
/* Q2. Explain three different ways to express "not in a range" without NOT BETWEEN. */
/* Q3. How do LIKE patterns behave with wildcard escape characters in PostgreSQL? */
/* Q4. When does ILIKE become essential in user-facing search features? */
/* Q5. Why should ORDER BY always precede LIMIT for deterministic pagination? */
/* Q6. How do NULLS FIRST/LAST change result ordering semantics? */
/* Q7. Why is using ORDER BY ordinal position (e.g., ORDER BY 2) risky in maintainability? */
/* Q8. What are stable sort keys, and why do we need a tie-breaker column for pagination? */
/* Q9. How can DISTINCT change row counts before ORDER BY and LIMIT are applied? */
/* Q10. Why should filters prefer equality/IN over LIKE for selectivity (high-level performance reasoning)? */

/* ============================================================
   🔍 SECTION B: EXPERT FILTERING (50)
   (Realistic single-table scenarios with layered predicates)
   ------------------------------------------------------------ */
/* Q11. products: High-end electronics — price >= 50000 AND category = 'Electronics'. */
/* Q12. products: Budget picks — price <= 499 AND category IN ('Grocery','Stationery','Accessories'). */
/* Q13. products: Exclude seasonal — category NOT IN ('Seasonal','Festive') AND price BETWEEN 999 AND 4999. */
/* Q14. products: Name search — product_name ILIKE '%pro%' OR product_name ILIKE '%max%'. */
/* Q15. products: Safety filter — product_name IS NOT NULL AND category IS NOT NULL AND price IS NOT NULL. */
/* Q16. products: Fragile items by name pattern — product_name ILIKE '%glass%' OR ILIKE '%ceramic%'. */
/* Q17. products: Narrow by two ranges — (price BETWEEN 1000 AND 1500) OR (price BETWEEN 3000 AND 3500). */
/* Q18. products: Exclude ambiguous names — product_name NOT ILIKE '%sample%' AND NOT ILIKE '%demo%'. */
/* Q19. products: Category starts-with — category LIKE 'E%' OR category LIKE 'F%'. */
/* Q20. products: Multi-clause — category = 'Electronics' AND price BETWEEN 10000 AND 30000 AND product_name ILIKE '%phone%'. */
/* Q21. customers: North metros — city IN ('Delhi','Kolkata') AND gender = 'F'. */
/* Q22. customers: Missing contacts — email IS NULL OR email NOT LIKE '%@%'. */
/* Q23. customers: Case-insensitive name find — name ILIKE 'a%r%'. */
/* Q24. customers: Cleanup candidates — city IS NULL OR city ILIKE 'unknown%'. */
/* Q25. customers: Two-group logic — (city IN ('Mumbai','Pune') AND gender='M') OR (city='Chennai' AND gender='F'). */
/* Q26. customers: Avoid Delhi unless female — NOT (city='Delhi' AND gender='M'). */
/* Q27. customers: Exact set — city IN ('Surat','Jaipur','Indore') AND name ILIKE '%sh%'. */
/* Q28. customers: Short names — name LIKE '_a%' OR name LIKE '_e%'. */
/* Q29. customers: Email domain filter — email ILIKE '%@gmail.%' OR email ILIKE '%@yahoo.%'. */
/* Q30. customers: City starts-with filter — city LIKE 'M%' AND name ILIKE '%i%'. */
/* Q31. hr.employees: Senior finance — department='Finance' AND salary >= 90000. */
/* Q32. hr.employees: HR or Admin under cap — department IN ('HR','Admin') AND salary < 40000. */
/* Q33. hr.employees: Entry window — joining_date BETWEEN '2022-01-01' AND '2022-12-31' AND role ILIKE '%intern%'. */
/* Q34. hr.employees: Flexible role search — role ILIKE '%manager%' OR role ILIKE '%lead%'. */
/* Q35. hr.employees: Missing info scan — department IS NULL OR salary IS NULL OR role IS NULL. */
/* Q36. hr.employees: Finance+Sales but exclude interns — department IN ('Finance','Sales') AND role NOT ILIKE '%intern%'. */
/* Q37. hr.employees: Salary band edges — salary NOT BETWEEN 25000 AND 75000. */
/* Q38. hr.employees: Complex — (department='Sales' AND salary BETWEEN 35000 AND 55000) OR (department='Marketing' AND salary>60000). */
/* Q39. hr.employees: Name phonetics — name ILIKE '%sh%' OR name ILIKE '%raj%'. */
/* Q40. hr.employees: City-sensitive (if city column exists) — city IS NOT NULL AND city NOT ILIKE 'test%'. */
/* Q41. sales.orders: Post-2023 high-value — order_date >= '2023-01-01' AND total_amount > 25000. */
/* Q42. sales.orders: Delivered card/upi — status='Delivered' AND payment_mode IN ('Card','UPI'). */
/* Q43. sales.orders: Pending or processing in 2022 — status IN ('Pending','Processing') AND order_date BETWEEN '2022-01-01' AND '2022-12-31'. */
/* Q44. sales.orders: Data quality — order_date IS NOT NULL AND total_amount IS NOT NULL. */
/* Q45. sales.orders: Single-day slice — order_date='2023-05-01'. */
/* Q46. sales.orders: Outside legacy window — order_date NOT BETWEEN '2018-01-01' AND '2020-12-31'. */
/* Q47. sales.orders: Exclude cancelled/returned — NOT (status IN ('Cancelled','Returned')). */
/* Q48. sales.orders: Mode missing — payment_mode IS NULL OR payment_mode = ''. */
/* Q49. sales.orders: Name-contains (if customer_name col exists) — customer_name ILIKE '%an%'. */
/* Q50. sales.orders: Complex — (payment_mode='Cash' AND total_amount BETWEEN 2000 AND 6000) OR (payment_mode='Card' AND total_amount > 10000). */
/* Q51. products: Dual LIKE — product_name LIKE '% Phone' OR product_name LIKE 'Phone %'. */
/* Q52. products: Suffix filter — product_name LIKE '% Edition'. */
/* Q53. products: Prefix exclusion — NOT (product_name ILIKE 'test %' OR product_name ILIKE 'sample %'). */
/* Q54. customers: Two-tier exclusion — NOT (city IN ('Delhi','Mumbai') AND email ILIKE '%@example.%'). */
/* Q55. hr.employees: Role family — role ILIKE ANY (ARRAY['%Engineer%','%Developer%','%Scientist%']). */
/* Q56. hr.employees: Salary OR role — salary > 120000 OR role ILIKE '%Principal%'. */
/* Q57. sales.orders: Weekend suspicion (date literal examples only) — order_date IN ('2023-06-10','2023-06-11'). */
/* Q58. sales.orders: Holiday test set — order_date IN ('2023-01-26','2023-08-15','2023-10-24'). */
/* Q59. products: Multi-exclude — category NOT IN ('Refurbished','Damaged','Retired'). */
/* Q60. customers: Multi-include — city IN ('Nagpur','Bhopal','Lucknow') AND name ILIKE '%a%'. */

/* ============================================================
   🔢 SECTION C: ADVANCED SORTING & PAGINATION (40)
   (Deterministic orderings, tie-breakers, and window-friendly pagination patterns — no aggregates)
   ------------------------------------------------------------ */
/* Q61. products: Sort by price DESC, product_name ASC. */
/* Q62. products: Sort by category ASC, price DESC, product_name ASC. */
/* Q63. products: Sort by price DESC NULLS LAST, then product_name ASC. */
/* Q64. products: Top 10 electronics by price — WHERE category='Electronics' ORDER BY price DESC LIMIT 10. */
/* Q65. products: Next page — same filter, ORDER BY price DESC, product_id ASC as tiebreaker, OFFSET 10 LIMIT 10. */
/* Q66. products: Alphabetical categories — DISTINCT category ORDER BY category ASC. */
/* Q67. products: Reverse categories — DISTINCT category ORDER BY category DESC LIMIT 10. */
/* Q68. customers: City-first — ORDER BY city ASC NULLS LAST, name ASC. */
/* Q69. customers: Gender, then city, then name — ORDER BY gender DESC, city ASC, name ASC. */
/* Q70. customers: First 20 with stable key — ORDER BY name ASC, customer_id ASC LIMIT 20. */
/* Q71. customers: Next 20 using OFFSET — ORDER BY name ASC, customer_id ASC OFFSET 20 LIMIT 20. */
/* Q72. customers: Names with NULL handling — ORDER BY name ASC NULLS LAST LIMIT 15. */
/* Q73. hr.employees: Highest salaries — ORDER BY salary DESC NULLS LAST LIMIT 10. */
/* Q74. hr.employees: Department then salary — ORDER BY department ASC, salary DESC. */
/* Q75. hr.employees: Department DESC, role ASC, name ASC LIMIT 25. */
/* Q76. hr.employees: Oldest hires — ORDER BY joining_date ASC NULLS LAST LIMIT 10. */
/* Q77. sales.orders: Most recent 15 orders — ORDER BY order_date DESC NULLS LAST LIMIT 15. */
/* Q78. sales.orders: Oldest 10 delivered — WHERE status='Delivered' ORDER BY order_date ASC LIMIT 10. */
/* Q79. sales.orders: Card first by value — WHERE payment_mode='Card' ORDER BY total_amount DESC, order_id ASC LIMIT 10. */
/* Q80. sales.orders: Mode, then recency — ORDER BY payment_mode ASC, order_date DESC. */
/* Q81. sales.orders: Stable pagination — ORDER BY order_date DESC, order_id DESC LIMIT 20. */
/* Q82. sales.orders: Next page — same ORDER with OFFSET 20 LIMIT 20. */
/* Q83. products: Name length sort — ORDER BY LENGTH(product_name) DESC, product_name ASC. */
/* Q84. customers: Case-insensitive sort — ORDER BY LOWER(name) ASC, customer_id ASC LIMIT 20. */
/* Q85. hr.employees: Distinct departments — SELECT DISTINCT department FROM retailmart.hr.employees ORDER BY department ASC. */
/* Q86. products: Distinct categories — SELECT DISTINCT category FROM retailmart.products ORDER BY category ASC LIMIT 10. */
/* Q87. customers: Top cities list — SELECT DISTINCT city FROM retailmart.customers ORDER BY city ASC LIMIT 10. */
/* Q88. sales.orders: Highest totals first — ORDER BY total_amount DESC NULLS LAST LIMIT 25. */
/* Q89. sales.orders: Recent cash orders — WHERE payment_mode='Cash' ORDER BY order_date DESC LIMIT 10. */
/* Q90. hr.employees: Salary bands view — WHERE salary BETWEEN 60000 AND 120000 ORDER BY salary DESC, name ASC. */
/* Q91. products: Mixed sort — WHERE category IN ('Furniture','Decor') ORDER BY category ASC, price ASC, product_name ASC. */
/* Q92. customers: City starts-with M — WHERE city LIKE 'M%' ORDER BY city ASC, name ASC LIMIT 12. */
/* Q93. products: Deterministic page 1 — ORDER BY category ASC, price DESC, product_id ASC LIMIT 12. */
/* Q94. products: Deterministic page 2 — same ORDER with OFFSET 12 LIMIT 12. */
/* Q95. sales.orders: Delivered first by value — WHERE status='Delivered' ORDER BY total_amount DESC, order_date DESC, order_id DESC LIMIT 20. */
/* Q96. sales.orders: Pending/Processing recency list — WHERE status IN ('Pending','Processing') ORDER BY order_date DESC, order_id DESC LIMIT 20. */
/* Q97. hr.employees: Role-sensitive sort — WHERE role ILIKE '%analyst%' ORDER BY department ASC, salary DESC, name ASC. */
/* Q98. customers: Null-friendly last page — ORDER BY name DESC NULLS LAST, customer_id DESC LIMIT 25. */
/* Q99. products: First 10 categories alphabetically (distinct) — DISTINCT category ORDER BY 1 ASC LIMIT 10. */
/* Q100. sales.orders: Oldest 10 with non-null payment mode — WHERE payment_mode IS NOT NULL ORDER BY order_date ASC LIMIT 10. */

/* ============================================================
   ✅ END OF DAY 4 — CRAZY HARD LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Stay single-table, read-only on retailmart.
   - Use parentheses to control complex boolean logic.
   - Always pair ORDER BY with a stable tiebreaker for pagination.
============================================================ */
