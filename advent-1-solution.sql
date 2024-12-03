DROP TABLE IF EXISTS #advent_1
DROP TABLE IF EXISTS #advent_1_ordered

CREATE TABLE #advent_1([distance_1] INT, [distance_2] INT)

BULK INSERT #advent_1
   FROM 'C:\Users\Fabien\Documents\rise-again\advent-of-code-2024\advent-1-input.txt'
   WITH (
      ROWTERMINATOR = '\n'
	  , FIELDTERMINATOR = '   '
   );

SELECT
    distance_1
	, ROW_NUMBER() OVER(ORDER BY distance_1 ASC) AS row_num_1
	, distance_2
	, ROW_NUMBER() OVER(ORDER BY distance_2 ASC) AS row_num_2

INTO #advent_1_ordered

FROM #advent_1

/* Answer 1 */
SELECT SUM(ABS(R_1.distance_1 - R_2.distance_2)) AS answer_1
FROM #advent_1_ordered R_1
JOIN #advent_1_ordered R_2 ON R_1.row_num_1 = R_2.row_num_2

/* Answer 2 */
; WITH D2_COUNT AS (
SELECT 
    distance_2
	, COUNT(1) AS total_count 
FROM #advent_1
GROUP BY distance_2
)

SELECT SUM(A.distance_1 * D2_COUNT.total_count) AS answer_2
FROM #advent_1 A
JOIN D2_COUNT ON A.distance_1 = D2_COUNT.distance_2

DROP TABLE IF EXISTS #advent_1
DROP TABLE IF EXISTS #advent_1_ordered
