/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 4 (MEDIUM LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Filtering & Sorting (Multi-condition Filtering)
   Scope:
     - Clauses: WHERE, AND, OR, BETWEEN, IN, LIKE, IS NULL, DISTINCT, ORDER BY, LIMIT
     - Combine multiple clauses in a single query
     - Only SELECT queries from retailmart schema
   Structure: 10 Conceptual + 50 Filtering Queries + 40 Sorting Queries = 100 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (10)
   ------------------------------------------------------------ */
/* Q1. What is the evaluation order of conditions when combining AND and OR? */
/* Q2. How can parentheses change the order of logical evaluation in WHERE? */
/* Q3. Why is BETWEEN inclusive of both boundaries? */
/* Q4. What is the difference between WHERE category IN (...) and category = ANY(...)? */
/* Q5. What happens when you use LIKE on a numeric column? */
/* Q6. How can IS NULL and IS NOT NULL be combined with AND/OR logic? */
/* Q7. How does ORDER BY handle NULL values by default in PostgreSQL? */
/* Q8. How can you sort by multiple columns in different orders? */
/* Q9. What is the advantage of using DISTINCT before ORDER BY? */
/* Q10. Why should LIMIT always come after ORDER BY for consistent results? */

/* ============================================================
   🔍 SECTION B: MULTI-CONDITION FILTERING (50)
   ------------------------------------------------------------ */
/* Q11. Retrieve all products where price > 500 AND category = 'Electronics'. */
/* Q12. Retrieve products where category = 'Furniture' OR price < 300. */
/* Q13. Retrieve products where category IN ('Clothing','Accessories') AND price BETWEEN 100 AND 500. */
/* Q14. Retrieve customers from city IN ('Delhi','Mumbai') AND gender = 'F'. */
/* Q15. Retrieve customers from city NOT IN ('Chennai','Pune') OR gender = 'M'. */
/* Q16. Retrieve employees where department = 'HR' AND role = 'Manager'. */
/* Q17. Retrieve employees where department IN ('Sales','Finance') AND salary BETWEEN 30000 AND 80000. */
/* Q18. Retrieve employees whose name starts with 'A' AND department = 'Marketing'. */
/* Q19. Retrieve employees whose name LIKE '%an%' OR name LIKE '%sh%'. */
/* Q20. Retrieve employees whose joining_date BETWEEN '2020-01-01' AND '2023-01-01' AND salary > 40000. */
/* Q21. Retrieve orders where order_date BETWEEN '2021-01-01' AND '2022-12-31' AND status = 'Delivered'. */
/* Q22. Retrieve orders where status IN ('Pending','Processing') AND order_date >= '2023-01-01'. */
/* Q23. Retrieve orders where payment_mode IN ('Card','UPI') OR total_amount > 10000. */
/* Q24. Retrieve customers where email IS NULL OR city IS NULL. */
/* Q25. Retrieve customers where city IS NOT NULL AND email IS NOT NULL. */
/* Q26. Retrieve customers whose name LIKE 'S%' AND city LIKE '%pur'. */
/* Q27. Retrieve customers whose name ILIKE '%raj%' (case-insensitive). */
/* Q28. Retrieve customers whose city IN ('Kolkata','Delhi') AND gender = 'F'. */
/* Q29. Retrieve products where category = 'Electronics' AND price BETWEEN 1000 AND 2000. */
/* Q30. Retrieve products where category NOT IN ('Grocery','Stationery') AND price < 1500. */
/* Q31. Retrieve products where price > 2000 OR brand = 'Samsung'. */
/* Q32. Retrieve products where price BETWEEN 100 AND 200 OR price BETWEEN 500 AND 600. */
/* Q33. Retrieve employees where department IN ('Finance','Sales') AND role IN ('Analyst','Manager'). */
/* Q34. Retrieve employees where department = 'Finance' AND (role = 'Manager' OR salary > 70000). */
/* Q35. Retrieve employees where department = 'Sales' AND name LIKE '%sh%' AND salary BETWEEN 30000 AND 60000. */
/* Q36. Retrieve employees where department IN ('Sales','Finance') AND role NOT IN ('Intern'). */
/* Q37. Retrieve customers where city LIKE 'M%' AND email LIKE '%gmail%'. */
/* Q38. Retrieve customers where city NOT LIKE 'D%' AND gender = 'M'. */
/* Q39. Retrieve customers where name LIKE '_a%' AND city = 'Delhi'. */
/* Q40. Retrieve customers where name LIKE '%i%' OR name LIKE '%u%' AND gender = 'F'. */
/* Q41. Retrieve orders where order_date IS NOT NULL AND status = 'Delivered'. */
/* Q42. Retrieve orders where status IS NULL OR total_amount IS NULL. */
/* Q43. Retrieve orders placed BETWEEN '2022-01-01' AND '2022-06-30' AND payment_mode = 'Cash'. */
/* Q44. Retrieve orders placed NOT BETWEEN '2020-01-01' AND '2021-01-01'. */
/* Q45. Retrieve all products where product_name LIKE '%Pro%' OR product_name LIKE '%Plus%'. */
/* Q46. Retrieve products where product_name LIKE '%book%' AND category = 'Electronics'. */
/* Q47. Retrieve customers where city IS NULL OR city = 'Unknown'. */
/* Q48. Retrieve employees where department IS NULL OR salary IS NULL. */
/* Q49. Retrieve distinct category values from retailmart.products where category LIKE '%ics%'. */
/* Q50. Retrieve distinct city values from retailmart.customers where city LIKE 'M%'. */
/* Q51. Retrieve customers where gender IS NULL OR gender = ''. */
/* Q52. Retrieve orders where total_amount BETWEEN 5000 AND 15000 AND payment_mode IN ('Card','UPI'). */
/* Q53. Retrieve employees where role LIKE '%Manager%' OR department LIKE '%Finance%'. */
/* Q54. Retrieve employees where department NOT LIKE '%HR%' AND salary > 40000. */
/* Q55. Retrieve employees whose department LIKE '%e%' AND name LIKE 'S%'. */
/* Q56. Retrieve customers whose email IS NOT NULL AND email LIKE '%.com'. */
/* Q57. Retrieve customers whose city NOT IN ('Chennai','Hyderabad') AND gender = 'M'. */
/* Q58. Retrieve orders placed after '2023-01-01' AND total_amount > 20000. */
/* Q59. Retrieve orders placed before '2020-01-01' OR payment_mode IS NULL. */
/* Q60. Retrieve all distinct product names where category = 'Furniture' AND price < 1000. */

/* ============================================================
   🔢 SECTION C: SORTING & PAGINATION (40)
   ------------------------------------------------------------ */
/* Q61. Retrieve products where category = 'Electronics' ordered by price DESC. */
/* Q62. Retrieve products where price BETWEEN 100 AND 1000 ordered by price ASC. */
/* Q63. Retrieve customers where city = 'Mumbai' ordered by name ASC. */
/* Q64. Retrieve customers where city IN ('Delhi','Pune') ordered by city, name. */
/* Q65. Retrieve customers where gender = 'F' ordered by city DESC, name ASC. */
/* Q66. Retrieve employees from Sales ordered by salary DESC. */
/* Q67. Retrieve employees from HR ordered by name ASC. */
/* Q68. Retrieve employees from Finance ordered by department, salary DESC. */
/* Q69. Retrieve employees where salary BETWEEN 40000 AND 80000 ordered by name. */
/* Q70. Retrieve orders where status = 'Delivered' ordered by order_date DESC. */
/* Q71. Retrieve orders where payment_mode = 'Card' ordered by total_amount DESC. */
/* Q72. Retrieve top 10 orders by total_amount DESC. */
/* Q73. Retrieve top 5 oldest orders by order_date ASC. */
/* Q74. Retrieve products where category = 'Furniture' ordered by product_name ASC. */
/* Q75. Retrieve first 10 products where price > 100 using LIMIT. */
/* Q76. Retrieve next 10 products using OFFSET 10 LIMIT 10. */
/* Q77. Retrieve customers from Delhi ordered by name LIMIT 5. */
/* Q78. Retrieve top 10 employees with highest salaries. */
/* Q79. Retrieve bottom 5 employees by salary ascending. */
/* Q80. Retrieve customers where email IS NOT NULL ordered by city, name LIMIT 10. */
/* Q81. Retrieve employees ordered by department ASC, salary DESC LIMIT 15. */
/* Q82. Retrieve distinct city names ordered alphabetically. */
/* Q83. Retrieve distinct departments ordered by department name DESC. */
/* Q84. Retrieve distinct product categories ordered alphabetically. */
/* Q85. Retrieve first 5 categories alphabetically. */
/* Q86. Retrieve 5 customers whose name starts with 'A' ordered by city. */
/* Q87. Retrieve top 5 Electronics products ordered by price DESC. */
/* Q88. Retrieve 10 Furniture products ordered by price ASC. */
/* Q89. Retrieve top 5 most recent orders ordered by order_date DESC. */
/* Q90. Retrieve 10 oldest orders ordered by order_date ASC. */
/* Q91. Retrieve first 10 employees ordered by joining_date ASC. */
/* Q92. Retrieve last 5 employees ordered by joining_date DESC. */
/* Q93. Retrieve 10 customers where gender = 'M' ordered by name ASC LIMIT 10. */
/* Q94. Retrieve distinct product categories LIMIT 10. */
/* Q95. Retrieve 10 customers where city LIKE 'M%' ordered by city, name. */
/* Q96. Retrieve employees where department IN ('Sales','Finance') ordered by department, salary DESC LIMIT 10. */
/* Q97. Retrieve top 5 departments alphabetically using DISTINCT and LIMIT. */
/* Q98. Retrieve 5 most expensive products in 'Electronics' using ORDER BY DESC LIMIT 5. */
/* Q99. Retrieve 10 cities alphabetically with LIMIT 10. */
/* Q100. Retrieve 10 distinct product categories alphabetically. */

/* ============================================================
   ✅ END OF DAY 4 — MEDIUM LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Use multiple filtering clauses together (AND, OR, BETWEEN, IN, LIKE).
   - Combine ORDER BY with LIMIT for sorted outputs.
   - All queries read-only from retailmart schema.
============================================================ */