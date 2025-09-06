USE book;


 ---Top 10 expensive books

SELECT TOP 10 BookTitle , Price
FROM dbo.Books_Final
ORDER BY Price DESC;

---Average books price in each category
SELECT Category, AVG(Price) AS AvgPrice
FROM dbo.Books_Final
GROUP BY Category
ORDER BY AvgPrice DESC;

 
---Books with 5 star rating
SELECT BookTitle, Price, Category
FROM dbo.Books_Final
WHERE Rating = 5;


---Percentage of Available vs. Unavailable Books
SELECT Availability, 
COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dbo.Books_Final) AS Percentage
FROM dbo.Books_Final
GROUP BY Availability;


 ---Top categories by number of books
 SELECT TOP 10 Category, COUNT(*) AS CountBooks
 FROM dbo.Books_Final
 GROUP BY Category
 ORDER BY CountBooks DESC;

 
 --- Top 3 expensive books in each category
SELECT Category, BookTitle, Price
FROM (
    SELECT Category, BookTitle, Price,
           ROW_NUMBER() OVER (PARTITION BY Category ORDER BY Price DESC) AS rn
    FROM dbo.Books_Final
) t
WHERE rn <= 3;