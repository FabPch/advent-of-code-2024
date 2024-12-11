DROP TABLE IF EXISTS #advent_8_raw
DROP TABLE IF EXISTS #advent_8

CREATE TABLE #advent_8_raw(row_indice INT, [value] VARCHAR(MAX))
CREATE TABLE #advent_8(row_indice INT, col_indice INT, [value] VARCHAR(1))

BULK INSERT #advent_8_raw
FROM 'C:\Users\Fabien\Documents\rise-again\advent-of-code-2024\advent-8-input-big.txt'
WITH (
    ROWTERMINATOR = ' \n'
    , FIELDTERMINATOR = '|'
);

INSERT INTO #advent_8 (row_indice, col_indice, [value])
SELECT
    A.row_indice
	, L.ordinal AS col_indice
	, L.[value]

FROM #advent_8_raw A
CROSS APPLY STRING_SPLIT(A.[value], ' ', 1) L
WHERE L.[value] != ' '

DECLARE @max_row INT
DECLARE @max_col INT

SELECT 
    @max_col = MAX(col_indice)
    , @max_row = MAX(row_indice)
FROM #advent_8

;WITH ALL_POS AS (
SELECT
    A.row_indice - (B.row_indice - A.row_indice) AS row_pos
	, A.col_indice - (B.col_indice - A.col_indice) AS col_pos
FROM #advent_8 A
JOIN #advent_8 B ON A.col_indice != B.col_indice 
    AND A.row_indice != B.row_indice 
	AND A.[value] = B.[value] COLLATE Latin1_General_CS_AS
WHERE A.[value] != '.' 
    AND B.[value] != '.'

UNION ALL

SELECT
	B.row_indice - (A.row_indice - B.row_indice) AS row_pos
	, B.col_indice - (A.col_indice - B.col_indice) AS col_pos
FROM #advent_8 A
JOIN #advent_8 B ON A.col_indice != B.col_indice 
    AND A.row_indice != B.row_indice 
	AND A.[value] = B.[value] COLLATE Latin1_General_CS_AS
WHERE A.[value] != '.' 
    AND B.[value] != '.'
)

, ALL_POSSIBLE_POS AS (
SELECT row_pos, col_pos
FROM ALL_POS
WHERE row_pos > 0 
    AND row_pos <= @max_row
    AND col_pos > 0
	AND col_pos <= @max_col
GROUP BY row_pos, col_pos
)

SELECT COUNT(1) AS answer_1
FROM ALL_POSSIBLE_POS
