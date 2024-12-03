DROP TABLE IF EXISTS #advent_2
DROP TABLE IF EXISTS #advent_2_ordered
DROP TABLE IF EXISTS #result_1_by_line
DROP TABLE IF EXISTS #advent_2_minus_1

CREATE TABLE #advent_2([level] VARCHAR(MAX))

BULK INSERT #advent_2
   FROM 'C:\Users\Fabien\Documents\rise-again\advent-of-code-2024\advent-2-input.txt'
   WITH (
      ROWTERMINATOR = '\n'
	  , FIELDTERMINATOR = ' '
   );

SELECT *
    , ROW_NUMBER() OVER(ORDER BY [level]) AS line_number
INTO #advent_2_ordered
FROM #advent_2

; WITH CTE_DIFF AS (
SELECT
    L.ordinal
	, L.[value]
	, L.[value] - COALESCE(LAG(L.[value]) OVER(PARTITION BY A.line_number ORDER BY L.ordinal), 0) AS diff
	, A.line_number
	, A.[level]
FROM #advent_2_ordered A
CROSS APPLY STRING_SPLIT(A.[level], ' ', 1) L
)

SELECT
    CASE WHEN MIN(diff) > 0 AND MIN(diff) <= 3 AND MAX(diff) > 0 AND MAX(diff) <= 3 THEN 1
	     WHEN MIN(diff) < 0 AND MIN(diff) >= -3 AND MAX(diff) < 0 AND MAX(diff) >= -3 THEN 1
		 ELSE 0
	END AS is_safe
	, line_number

INTO #result_1_by_line

FROM CTE_DIFF
WHERE ordinal > 1
GROUP BY line_number

SELECT COUNT(1) AS answer_1 FROM #result_1_by_line WHERE is_safe = 1

;WITH NEW_INPUT AS (
SELECT
    L.ordinal
	, A.line_number
	, A.[level]
	, STRING_AGG(N.[value], ' ') WITHIN GROUP (ORDER BY N.ordinal) AS level_minus_one
FROM #advent_2_ordered A
LEFT JOIN #result_1_by_line R ON R.line_number = A.line_number AND R.is_safe = 1
CROSS APPLY STRING_SPLIT(A.[level], ' ', 1) L
CROSS APPLY STRING_SPLIT(A.[level], ' ', 1) N
WHERE R.line_number IS NULL
    AND L.ordinal != N.ordinal
GROUP BY L.ordinal, A.line_number, A.[level]
)

SELECT level_minus_one, line_number, level

INTO #advent_2_minus_1

FROM NEW_INPUT
GROUP BY level_minus_one, line_number, level

--SELECT * FROM #advent_2_minus_1 ORDER BY level

; WITH CTE_DIFF AS (
SELECT
    L.ordinal
	, L.[value]
	, L.[value] - COALESCE(LAG(L.[value]) OVER(PARTITION BY A.level_minus_one ORDER BY L.ordinal), 0) AS diff
	, A.line_number
	, A.level_minus_one
FROM #advent_2_minus_1 A
CROSS APPLY STRING_SPLIT(A.level_minus_one, ' ', 1) L
)

, CTE_RES AS (
SELECT
    CASE WHEN MIN(diff) > 0 AND MIN(diff) <= 3 AND MAX(diff) > 0 AND MAX(diff) <= 3 THEN 1
	     WHEN MIN(diff) < 0 AND MIN(diff) >= -3 AND MAX(diff) < 0 AND MAX(diff) >= -3 THEN 1
		 ELSE 0
	END AS is_safe
	, line_number

FROM CTE_DIFF
WHERE ordinal > 1
GROUP BY level_minus_one, line_number
)

, CTE_COUNT AS (
    SELECT COUNT(1) AS total_count
    FROM CTE_RES
    WHERE CTE_RES.is_safe = 1
	GROUP BY line_number
)

, CTE_2_ANS AS (
SELECT COUNT(1) AS total_res
FROM CTE_COUNT

UNION ALL

SELECT COUNT(1) AS total_res
FROM #result_1_by_line
WHERE is_safe = 1
)

SELECT SUM(total_res) AS answer_2
FROM CTE_2_ANS

DROP TABLE IF EXISTS #advent_2
DROP TABLE IF EXISTS #advent_2_ordered
DROP TABLE IF EXISTS #advent_2_minus_1
DROP TABLE IF EXISTS #result_1_by_line
