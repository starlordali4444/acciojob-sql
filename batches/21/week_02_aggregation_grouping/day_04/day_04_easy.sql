/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 4 (EASY LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Filtering & Sorting Basics
   Scope:
     - Clauses: WHERE, AND, OR, BETWEEN, IN, LIKE, IS NULL, DISTINCT, ORDER BY, LIMIT
     - Only SELECT queries from retailmart schema
     - No JOINs, GROUP BY, HAVING, or aggregation yet
   Structure: 10 Conceptual + 50 Filtering Queries + 40 Sorting Queries = 100 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (10)
   ------------------------------------------------------------ */
/* Q1. What is the purpose of the WHERE clause in SQL? */
/* Q2. What is the difference between AND and OR operators in SQL? */
/* Q3. How does BETWEEN work in SQL filtering? */
/* Q4. What is the difference between IN and multiple OR conditions? */
/* Q5. What is the difference between LIKE and ILIKE in PostgreSQL? */
/* Q6. What does IS NULL check for? */
/* Q7. What is the difference between DISTINCT and GROUP BY? */
/* Q8. Why is ORDER BY used, and what is the default sorting order? */
/* Q9. What does LIMIT do in SQL? */
/* Q10. Can WHERE and ORDER BY be used together in a query? */

/* ============================================================
   🔍 SECTION B: FILTERING PRACTICE (50)
   (Single-table filters — products, customers, orders, employees)
   ------------------------------------------------------------ */
/* Q11. Retrieve all columns from retailmart.products. */
/* Q12. Retrieve product_name and price from retailmart.products. */
/* Q13. Retrieve products where price is greater than 500. */
/* Q14. Retrieve products where price is less than 200. */
/* Q15. Retrieve products where category is 'Electronics'. */
/* Q16. Retrieve customers who live in 'Delhi'. */
/* Q17. Retrieve employees whose department is 'Sales'. */
/* Q18. Retrieve orders placed after '2022-01-01'. */
/* Q19. Retrieve orders placed before '2020-12-31'. */
/* Q20. Retrieve products priced between 100 and 1000 using BETWEEN. */
/* Q21. Retrieve products not priced between 200 and 500 using NOT BETWEEN. */
/* Q22. Retrieve products whose category is either 'Electronics' or 'Furniture' using IN. */
/* Q23. Retrieve products whose category is not in ('Grocery','Stationery'). */
/* Q24. Retrieve customers whose city is in ('Delhi','Mumbai','Kolkata'). */
/* Q25. Retrieve employees whose role is in ('Analyst','Manager'). */
/* Q26. Retrieve employees whose department is not 'HR'. */
/* Q27. Retrieve customers whose email IS NULL. */
/* Q28. Retrieve customers whose email IS NOT NULL. */
/* Q29. Retrieve products where product_name LIKE 'A%'. */
/* Q30. Retrieve products where product_name LIKE '%Phone%'. */
/* Q31. Retrieve products where product_name LIKE '_a%'. */
/* Q32. Retrieve products where category LIKE 'C%'. */
/* Q33. Retrieve employees whose name starts with 'S'. */
/* Q34. Retrieve employees whose name ends with 'a'. */
/* Q35. Retrieve orders where order_date IS NULL. */
/* Q36. Retrieve orders where order_date IS NOT NULL. */
/* Q37. Retrieve customers whose city is NOT NULL. */
/* Q38. Retrieve distinct category values from retailmart.products. */
/* Q39. Retrieve distinct city values from retailmart.customers. */
/* Q40. Retrieve distinct department values from retailmart.hr.employees. */
/* Q41. Retrieve all customers where city = 'Mumbai' AND gender = 'F'. */
/* Q42. Retrieve all customers where city = 'Delhi' OR city = 'Kolkata'. */
/* Q43. Retrieve all employees where department = 'Finance' OR department = 'Sales'. */
/* Q44. Retrieve all employees where department = 'Finance' AND role = 'Analyst'. */
/* Q45. Retrieve all orders where order_date BETWEEN '2021-01-01' AND '2022-12-31'. */
/* Q46. Retrieve all orders where order_date NOT BETWEEN '2018-01-01' AND '2020-01-01'. */
/* Q47. Retrieve all products priced IN (199,499,999). */
/* Q48. Retrieve all customers whose city IN ('Pune','Chennai'). */
/* Q49. Retrieve all customers whose gender NOT IN ('M'). */
/* Q50. Retrieve all orders placed on '2023-05-01'. */
/* Q51. Retrieve all orders placed after '2023-01-01' using > operator. */
/* Q52. Retrieve all employees whose joining_date is before '2022-01-01'. */
/* Q53. Retrieve all employees whose joining_date is after '2023-01-01'. */
/* Q54. Retrieve all employees where role is NULL. */
/* Q55. Retrieve all employees where salary is greater than 50000. */
/* Q56. Retrieve all employees where salary is less than 30000. */
/* Q57. Retrieve all employees where salary BETWEEN 30000 AND 70000. */
/* Q58. Retrieve all employees where department LIKE 'S%'. */
/* Q59. Retrieve all employees where name LIKE '%k%'. */
/* Q60. Retrieve all customers whose city NOT LIKE 'M%'. */

/* ============================================================
   🔢 SECTION C: SORTING & PAGINATION (40)
   (ORDER BY, DISTINCT, LIMIT)
   ------------------------------------------------------------ */
/* Q61. Retrieve all products ordered by price ascending. */
/* Q62. Retrieve all products ordered by price descending. */
/* Q63. Retrieve top 10 most expensive products using ORDER BY and LIMIT. */
/* Q64. Retrieve top 5 cheapest products. */
/* Q65. Retrieve customers ordered by city alphabetically. */
/* Q66. Retrieve customers ordered by city DESC. */
/* Q67. Retrieve first 10 customers alphabetically by name. */
/* Q68. Retrieve last 10 customers alphabetically by name (reverse order). */
/* Q69. Retrieve all employees ordered by department then by name. */
/* Q70. Retrieve products ordered by category then by price descending. */
/* Q71. Retrieve distinct product categories ordered alphabetically. */
/* Q72. Retrieve distinct cities ordered alphabetically. */
/* Q73. Retrieve first 20 products using LIMIT 20. */
/* Q74. Retrieve next 10 products using OFFSET 10 LIMIT 10. */
/* Q75. Retrieve top 10 customers with alphabetically smallest names. */
/* Q76. Retrieve last 5 customers alphabetically by name using ORDER BY DESC LIMIT 5. */
/* Q77. Retrieve all orders sorted by order_date ascending. */
/* Q78. Retrieve all orders sorted by order_date descending. */
/* Q79. Retrieve top 5 most recent orders. */
/* Q80. Retrieve oldest 5 orders. */
/* Q81. Retrieve all employees ordered by salary descending. */
/* Q82. Retrieve top 3 highest-paid employees. */
/* Q83. Retrieve lowest 3 salaries among employees. */
/* Q84. Retrieve employees sorted by department and salary descending. */
/* Q85. Retrieve all customers sorted by city then gender. */
/* Q86. Retrieve 10 products whose name starts with 'S' ordered by price ascending. */
/* Q87. Retrieve 10 customers from Delhi ordered by name alphabetically. */
/* Q88. Retrieve 10 employees from Sales department ordered by name ascending. */
/* Q89. Retrieve top 10 Electronics products by price descending. */
/* Q90. Retrieve 5 Furniture products ordered by price ascending. */
/* Q91. Retrieve distinct departments ordered alphabetically. */
/* Q92. Retrieve distinct product categories ordered reverse alphabetically. */
/* Q93. Retrieve top 10 unique cities in alphabetical order. */
/* Q94. Retrieve all customers ordered by name ignoring NULLs at the end. */
/* Q95. Retrieve all customers ordered by name NULLS FIRST. */
/* Q96. Retrieve 5 most recent orders using ORDER BY order_date DESC LIMIT 5. */
/* Q97. Retrieve 10 customers using LIMIT 10 for pagination. */
/* Q98. Retrieve next 10 customers using OFFSET 10 LIMIT 10. */
/* Q99. Retrieve first 10 unique product categories using DISTINCT and LIMIT. */
/* Q100. Retrieve 5 distinct city names in alphabetical order. */

/* ============================================================
   ✅ END OF DAY 4 — EASY LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Use only SELECT statements on retailmart tables.
   - Do not modify or insert any data.
   - Focus on filtering (WHERE, AND/OR, BETWEEN, IN, LIKE) and sorting (ORDER BY, LIMIT).
============================================================ */