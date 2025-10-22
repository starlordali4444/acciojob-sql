/* ============================================================
   ACCIOJOB SQL PRACTICE SET — DAY 4 (HARD LEVEL)
   Instructor: Sayyed Siraj Ali
   Topic: Filtering & Sorting (Advanced Conditional Logic)
   Scope:
     - Complex WHERE conditions with nested AND/OR, IN, BETWEEN, LIKE, IS NULL.
     - Multi-level ORDER BY with ASC/DESC + NULLS control.
     - Advanced filtering using expressions and alias sorting.
     - Only SELECT queries from retailmart schema.
   Structure: 10 Conceptual + 50 Complex Filtering + 40 Advanced Sorting = 100 total
   ============================================================ */

/* ============================================================
   🧠 SECTION A: CONCEPTUAL QUESTIONS (10)
   ------------------------------------------------------------ */
/* Q1. How does PostgreSQL evaluate parentheses in WHERE conditions? */
/* Q2. What happens if both AND and OR are used without parentheses? */
/* Q3. What is the difference between = NULL and IS NULL? */
/* Q4. Why is case sensitivity important when using LIKE vs ILIKE? */
/* Q5. How does PostgreSQL handle NULLs in ORDER BY when using ASC/DESC? */
/* Q6. What is the purpose of ORDER BY 1 syntax? */
/* Q7. Can expressions (e.g., price * quantity) be used in WHERE? */
/* Q8. How does ORDER BY with multiple columns determine precedence? */
/* Q9. How can you sort records in a specific custom order using CASE? */
/* Q10. Why is OFFSET typically used with LIMIT in pagination? */

/* ============================================================
   🔍 SECTION B: COMPLEX FILTERING (50)
   ------------------------------------------------------------ */
/* Q11. Retrieve all products where (price > 1000 AND category = 'Electronics') OR (price < 200 AND category = 'Stationery'). */
/* Q12. Retrieve all products where category IN ('Electronics','Furniture') AND (price BETWEEN 500 AND 1500 OR price IS NULL). */
/* Q13. Retrieve all products where (category = 'Clothing' OR category = 'Footwear') AND price < 2000. */
/* Q14. Retrieve all customers where (city = 'Delhi' OR city = 'Mumbai') AND gender = 'F'. */
/* Q15. Retrieve all customers where (email IS NULL OR email NOT LIKE '%@%') AND city IS NOT NULL. */
/* Q16. Retrieve all employees where (salary > 50000 AND department = 'Finance') OR (salary < 30000 AND department = 'HR'). */
/* Q17. Retrieve employees whose name LIKE '%a%' AND (role = 'Manager' OR role = 'Analyst'). */
/* Q18. Retrieve employees where NOT (department = 'Sales' OR department = 'Support'). */
/* Q19. Retrieve employees where department IN ('Finance','HR') AND salary BETWEEN 30000 AND 80000. */
/* Q20. Retrieve employees whose department IS NULL OR salary IS NULL. */
/* Q21. Retrieve orders where (payment_mode = 'Card' AND total_amount > 10000) OR (payment_mode = 'UPI' AND total_amount > 20000). */
/* Q22. Retrieve orders where (order_date BETWEEN '2021-01-01' AND '2022-12-31') AND status IN ('Delivered','Shipped'). */
/* Q23. Retrieve orders where NOT (status = 'Cancelled' OR status IS NULL). */
/* Q24. Retrieve orders where order_date IS NULL OR total_amount IS NULL. */
/* Q25. Retrieve customers where (city LIKE 'M%' OR city LIKE 'D%') AND gender = 'M'. */
/* Q26. Retrieve customers where name LIKE '%n%' AND (city = 'Pune' OR city = 'Kolkata'). */
/* Q27. Retrieve customers where name ILIKE '%Ali%' (case-insensitive search). */
/* Q28. Retrieve products where product_name ILIKE '%pro%' OR ILIKE '%max%'. */
/* Q29. Retrieve products where NOT (price BETWEEN 500 AND 1000). */
/* Q30. Retrieve products where price BETWEEN 1000 AND 5000 AND category IN ('Electronics','Appliances'). */
/* Q31. Retrieve products where price > 2000 AND product_name LIKE '%Phone%' AND category = 'Electronics'. */
/* Q32. Retrieve products where (category = 'Electronics' AND price BETWEEN 500 AND 1000) OR category = 'Gadgets'. */
/* Q33. Retrieve employees where (department = 'HR' AND role IN ('Clerk','Executive')) OR department = 'Finance'. */
/* Q34. Retrieve employees where salary BETWEEN 40000 AND 80000 AND (role LIKE '%Manager%' OR role LIKE '%Lead%'). */
/* Q35. Retrieve employees where NOT (department IN ('HR','Support')). */
/* Q36. Retrieve employees where role ILIKE '%lead%' AND salary > 70000. */
/* Q37. Retrieve customers where email LIKE '%@gmail%' OR email LIKE '%@yahoo%'. */
/* Q38. Retrieve customers where name LIKE '_a%' OR name LIKE '_e%'. */
/* Q39. Retrieve customers where gender IS NULL OR city IS NULL OR email IS NULL. */
/* Q40. Retrieve customers where (city IN ('Delhi','Kolkata') AND gender = 'F') OR email LIKE '%outlook%'. */
/* Q41. Retrieve products where product_name LIKE '%book%' OR product_name LIKE '%case%'. */
/* Q42. Retrieve products where price NOT BETWEEN 100 AND 500 AND category NOT IN ('Grocery'). */
/* Q43. Retrieve employees where salary > 40000 AND (department = 'Finance' OR department = 'Operations') AND name LIKE '%i%'. */
/* Q44. Retrieve employees where department LIKE 'S%' AND role LIKE '%Analyst%'. */
/* Q45. Retrieve orders where payment_mode IN ('UPI','Card') AND (status = 'Delivered' OR status = 'Processing'). */
/* Q46. Retrieve orders where NOT (payment_mode IS NULL OR total_amount < 1000). */
/* Q47. Retrieve customers where name ILIKE '%a%' AND city ILIKE '%pur%' OR gender = 'F'. */
/* Q48. Retrieve products where category IS NULL OR product_name IS NULL. */
/* Q49. Retrieve orders where order_date NOT BETWEEN '2020-01-01' AND '2021-12-31' AND status = 'Delivered'. */
/* Q50. Retrieve employees whose salary BETWEEN 20000 AND 90000 AND department NOT IN ('Support','Admin'). */
/* Q51. Retrieve all employees where salary IS NULL OR salary = 0. */
/* Q52. Retrieve all orders where order_date IS NOT NULL AND payment_mode IS NOT NULL. */
/* Q53. Retrieve all customers where city LIKE '%a%' AND email IS NOT NULL. */
/* Q54. Retrieve all products where category NOT LIKE 'F%' AND price > 1000. */
/* Q55. Retrieve products where category LIKE 'E%' AND (price > 1000 AND price < 5000). */
/* Q56. Retrieve products where NOT (category = 'Electronics' OR category = 'Appliances'). */
/* Q57. Retrieve customers where NOT (city = 'Delhi' OR gender = 'M'). */
/* Q58. Retrieve employees where NOT (salary BETWEEN 20000 AND 40000) AND role LIKE '%Manager%'. */
/* Q59. Retrieve orders where total_amount > 10000 AND NOT (status = 'Cancelled' OR status = 'Returned'). */
/* Q60. Retrieve products where (price < 200 OR price > 2000) AND category = 'Electronics'. */

/* ============================================================
   🔢 SECTION C: ADVANCED SORTING & PAGINATION (40)
   ------------------------------------------------------------ */
/* Q61. Retrieve products ordered by category ASC, price DESC. */
/* Q62. Retrieve products ordered by LENGTH(product_name) DESC. */
/* Q63. Retrieve customers ordered by city ASC NULLS LAST. */
/* Q64. Retrieve customers ordered by name DESC NULLS FIRST. */
/* Q65. Retrieve employees ordered by salary DESC, department ASC. */
/* Q66. Retrieve employees ordered by role, salary DESC NULLS LAST. */
/* Q67. Retrieve orders ordered by payment_mode ASC, total_amount DESC. */
/* Q68. Retrieve orders ordered by order_date DESC NULLS LAST. */
/* Q69. Retrieve top 10 orders ordered by total_amount DESC LIMIT 10. */
/* Q70. Retrieve top 5 cheapest orders by total_amount ASC LIMIT 5. */
/* Q71. Retrieve customers ordered by city, gender, and name. */
/* Q72. Retrieve employees ordered by department DESC, salary ASC. */
/* Q73. Retrieve 10 most recent orders ordered by order_date DESC LIMIT 10. */
/* Q74. Retrieve 10 oldest orders ordered by order_date ASC LIMIT 10. */
/* Q75. Retrieve top 10 highest-paid employees ordered by salary DESC. */
/* Q76. Retrieve lowest 10 employees ordered by salary ASC. */
/* Q77. Retrieve distinct city names ordered alphabetically LIMIT 10. */
/* Q78. Retrieve distinct departments ordered alphabetically DESC. */
/* Q79. Retrieve products ordered by category, price DESC, product_name ASC. */
/* Q80. Retrieve customers ordered by gender DESC, city ASC, name ASC. */
/* Q81. Retrieve 10 customers where city LIKE 'M%' ordered by name ASC LIMIT 10. */
/* Q82. Retrieve 5 customers where city IS NOT NULL ordered by city, name. */
/* Q83. Retrieve products where price > 1000 ordered by category DESC, price DESC LIMIT 10. */
/* Q84. Retrieve employees where department IN ('Finance','HR') ordered by name ASC, salary DESC LIMIT 10. */
/* Q85. Retrieve top 10 orders with highest total_amount and sort by order_date DESC. */
/* Q86. Retrieve top 5 employees by salary with department = 'Sales'. */
/* Q87. Retrieve top 10 Electronics products ordered by price DESC LIMIT 10. */
/* Q88. Retrieve products ordered by price, then by product_name. */
/* Q89. Retrieve products ordered alphabetically by category with LIMIT 15. */
/* Q90. Retrieve 5 customers from Delhi ordered by name ASC. */
/* Q91. Retrieve 5 customers whose city starts with 'K' ordered by name. */
/* Q92. Retrieve 10 employees ordered by department ASC NULLS LAST. */
/* Q93. Retrieve products where category IN ('Furniture','Decor') ordered by price DESC. */
/* Q94. Retrieve employees where role LIKE '%Analyst%' ordered by salary DESC LIMIT 10. */
/* Q95. Retrieve orders where total_amount BETWEEN 5000 AND 15000 ordered by total_amount DESC LIMIT 10. */
/* Q96. Retrieve 10 most recent orders where payment_mode = 'Card'. */
/* Q97. Retrieve 10 oldest orders where payment_mode IS NOT NULL. */
/* Q98. Retrieve first 10 distinct departments alphabetically. */
/* Q99. Retrieve 10 distinct product categories alphabetically DESC. */
/* Q100. Retrieve 5 distinct cities ordered alphabetically. */

/* ============================================================
   ✅ END OF DAY 4 — HARD LEVEL PRACTICE FILE (100 QUESTIONS)
   ------------------------------------------------------------
   Instructions:
   - Combine multiple filters with parentheses for clarity.
   - Use advanced ORDER BY expressions, NULLS control, and pagination.
   - All queries read-only from retailmart schema.
============================================================ */
