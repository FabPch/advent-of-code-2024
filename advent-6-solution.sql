DROP TABLE IF EXISTS #advent_6_raw
DROP TABLE IF EXISTS #advent_6

CREATE TABLE #advent_6_raw(row_indice INT, [value] VARCHAR(MAX))
CREATE TABLE #advent_6(row_indice INT, col_indice INT, [value] VARCHAR(1))

BULK INSERT #advent_6_raw
FROM 'C:\Users\Fabien\Documents\rise-again\advent-of-code-2024\advent-6-input-big.txt'
WITH (
    ROWTERMINATOR = ' \n'
    , FIELDTERMINATOR = '|'
);

--SELECT * FROM #advent_6_raw

INSERT INTO #advent_6 (row_indice, col_indice, [value])
SELECT
    A.row_indice
	, L.ordinal AS col_indice
	, L.[value]

FROM #advent_6_raw A
CROSS APPLY STRING_SPLIT(A.[value], ' ', 1) L
WHERE L.[value] != ' '

--SELECT * FROM #advent_6

DECLARE @is_outside BIT = 0
DECLARE @direction VARCHAR(1)
DECLARE @row_indice INT
DECLARE @col_indice INT
DECLARE @obstacle_row_indice INT
DECLARE @obstacle_col_indice INT

DECLARE @print_debug VARCHAR(200)

SELECT
    @direction = [value]
	, @row_indice = row_indice
	, @col_indice = col_indice
FROM #advent_6 
WHERE [value] NOT in ('.', '#')

PRINT 'Begin loop'

WHILE @is_outside != 1
BEGIN

/* We verify if there is an obstacle on the road: is it outside at the end of the line or not ? */
SELECT @is_outside = CASE WHEN COUNT(1) >= 1 THEN 0 ELSE 1 END
    , @obstacle_col_indice = CASE WHEN @direction IN ('^', 'v') THEN @col_indice
	                              WHEN @direction = '>' THEN MIN(col_indice)
								  WHEN @direction = '<' THEN MAX(col_indice)
							 END
    , @obstacle_row_indice = CASE WHEN @direction IN ('<', '>') THEN @row_indice
	                              WHEN @direction = '^' THEN MAX(row_indice)
								  WHEN @direction = 'v' THEN MIN(row_indice)
							 END
FROM #advent_6
WHERE [value] = '#'
    AND ((@direction = '^' AND row_indice < @row_indice AND col_indice = @col_indice)
	    OR (@direction = 'v' AND row_indice > @row_indice AND col_indice = @col_indice)
	    OR (@direction = '>' AND row_indice = @row_indice AND col_indice > @col_indice)
	    OR (@direction = '<' AND row_indice = @row_indice AND col_indice < @col_indice))

--SELECT @is_outside  AS is_outside, @row_indice AS row_indice, @col_indice AS col_indice
--SELECT @is_outside  AS is_outside, @obstacle_row_indice AS obstacle_row_indice, @obstacle_col_indice AS obstacle_col_indice
/* We find the first '#' position. */

/* We move the guard by updating all the position by 'X' until we reach the fifrst '#'. */
UPDATE #advent_6
SET [value] = 'X'
WHERE [value] != '#'
    AND ((@direction = '^' AND row_indice <= @row_indice AND col_indice = @col_indice AND (row_indice > @obstacle_row_indice OR @is_outside = 1))
	    OR (@direction = 'v' AND row_indice >= @row_indice AND col_indice = @col_indice AND (row_indice < @obstacle_row_indice OR @is_outside = 1))
	    OR (@direction = '>' AND row_indice = @row_indice AND col_indice >= @col_indice AND (col_indice < @obstacle_col_indice OR @is_outside = 1))
	    OR (@direction = '<' AND row_indice = @row_indice AND col_indice <= @col_indice AND (col_indice > @obstacle_col_indice OR @is_outside = 1)))

/* We update the guard position: */
SET @col_indice = (SELECT CASE WHEN @direction = '^' THEN @obstacle_col_indice 
                               WHEN @direction = 'v' THEN @obstacle_col_indice
							   WHEN @direction = '>' THEN @obstacle_col_indice - 1
							   WHEN @direction = '<' THEN @obstacle_col_indice + 1
						  END)
SET @row_indice = (SELECT CASE WHEN @direction = '^' THEN @obstacle_row_indice + 1
                               WHEN @direction = 'v' THEN @obstacle_row_indice - 1
							   WHEN @direction = '>'  THEN @obstacle_row_indice
							   WHEN @direction = '<'  THEN @obstacle_row_indice
					      END)

--SELECT @col_indice AS new_guard_col_indice, @row_indice AS new_guard_row_indice

/* We turn the direction */
IF  @is_outside != 1
BEGIN
    
    SET @direction = (SELECT CASE WHEN @direction = '^' THEN '>'
	                              WHEN @direction = '>' THEN 'v'
								  WHEN @direction = 'v' THEN '<'
								  WHEN @direction = '<' THEN '^'
							END)
END

SET @print_debug = (SELECT CONCAT('direction: ', @direction, '   col_indice: ', @col_indice, '   row_indice: ', @row_indice, '   is_outside: ', @is_outside))
PRINT @print_debug

END

SELECT COUNT(1) AS total_update
FROM #advent_6
WHERE [value] = 'X'

/*
SELECT
    row_indice
	, STRING_AGG([value], ' ') WITHIN GROUP (ORDER BY col_indice ASC) AS [value]
FROM #advent_6
GROUP BY row_indice
*/
