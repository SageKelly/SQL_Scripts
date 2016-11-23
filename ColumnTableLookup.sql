--USE CSI_Admin
--USE CSI_GULF_COUNTY
--USE CSI_Client_COS_578
--USE CSI_Client_COS_613
--USE CSI_Client_COS_642
USE TSQL2012
DECLARE
	@ProcSearch BIT
	,@TableSearch BIT
	,@SearchCrit NVARCHAR(MAX)
	,@ConcatSearch NVARCHAR(MAX)
	,@TableColumnSearch BIT
	,@OrdinalOrder BIT
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
---- DO NOT ALTER ANYTHING ABOVE THIS LINE

--Combinational meanings:
--100/101/110/111: Procedure Name (approx.)
--010/011: Table Name (approx.)
--000: Table Name (exact)
--001: ColumnName (exact)

SET
	@ProcSearch = 0
SET
	@TableSearch = 0
SET
	@SearchCrit = 'productID'
SET
	@TableColumnSearch = 1
SET
	@OrdinalOrder = 1
	



---- DO NOT ALTER ANYTHING BELOW THIS LINE
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
SET
	@ConcatSearch = CONCAT('%',@SearchCrit,'%')

IF EXISTS
(
	SELECT
		*
	FROM tempdb.sys.tables
	WHERE
		[object_id] = OBJECT_ID(N'tempdb.sys.#COLUMN_SEARCH')
)
BEGIN
	DROP TABLE #COLUMN_SEARCH
END
CREATE TABLE #COLUMN_SEARCH
(
	TABLE_SCHEMA VARCHAR(128)
	,TABLE_NAME VARCHAR(128)
	,COLUMN_NAME VARCHAR(128)
	,ORDINAL_POSITION INT
	,IS_NULLABLE VARCHAR(3)
	,DATA_TYPE VARCHAR(128)
	,EXTRA_DATA VARCHAR(36)
)

IF @ProcSearch = 1-------------------Procedure Search
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM tempdb.sys.tables
		WHERE
			[object_id] = OBJECT_ID(N'tempdb.sys.#PROC_TABLE')
	)
	BEGIN
		DROP TABLE #PROC_TABLE
	END




	CREATE TABLE #PROC_TABLE
	(
		[SCHEMA_NAME] VARCHAR(128)
		,PROC_NAME VARCHAR(128)
	)
	INSERT INTO #PROC_TABLE
		SELECT 
			S.[SCHEMA_NAME]
			,P.[name]
		FROM SYS.procedures AS P
			JOIN INFORMATION_SCHEMA.SCHEMATA AS S
				ON P.[schema_id] = SCHEMA_ID(S.[SCHEMA_NAME])
		WHERE
			[name] LIKE @ConcatSearch
		ORDER BY
		S.[SCHEMA_NAME]
		,P.[name]
	SELECT
		*
	FROM #PROC_TABLE
	DROP TABLE #PROC_TABLE
END
ELSE IF @TableSearch = 1------------------------Table Search
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM tempdb.sys.tables
		WHERE
			[object_id] = OBJECT_ID(N'tempdb.sys.#TABLE_SEARCH', N'U')
	)
	BEGIN
		DROP TABLE #TABLE_SEARCH
	END
	CREATE TABLE #TABLE_SEARCH
	(
		TABLE_SCHEMA VARCHAR(128)
		,TABLE_NAME VARCHAR(128)
	)
	INSERT INTO #TABLE_SEARCH
		SELECT
			TABLE_SCHEMA
			,TABLE_NAME
		FROM INFORMATION_SCHEMA.TABLES
		WHERE
			TABLE_NAME LIKE @ConcatSearch
			AND TABLE_NAME NOT LIKE 'ef%'
			AND TABLE_SCHEMA NOT LIKE 'history'
			AND TABLE_TYPE LIKE 'BASE TABLE'
		ORDER BY
			TABLE_NAME
			,TABLE_SCHEMA
	SELECT
		*
	FROM #TABLE_SEARCH
	DROP TABLE #TABLE_SEARCH
END
ELSE
BEGIN
	IF @TableColumnSearch = 0-----------------Column Search: Table Name
	BEGIN
		INSERT INTO #COLUMN_SEARCH
			SELECT
				TABLE_SCHEMA
				,TABLE_NAME
				,COLUMN_NAME
				,ORDINAL_POSITION
				,IS_NULLABLE
				,DATA_TYPE
				,CASE 
					WHEN
						DATA_TYPE LIKE '%char'
						OR DATA_TYPE LIKE '%binary'
						THEN CAST(CONCAT
						(
							'Char/Octet Length: '
							,CHARACTER_MAXIMUM_LENGTH,', '
							,CHARACTER_OCTET_LENGTH
						) AS VARCHAR(36))
					WHEN
						DATA_TYPE LIKE 'DECIMAL'
						OR DATA_TYPE LIKE 'INT'
						THEN CAST(CONCAT
						(
							'Precision,Radix,Scale: '
							,NUMERIC_PRECISION, ', '
							,NUMERIC_PRECISION_RADIX,',	'
							,NUMERIC_SCALE
						) AS VARCHAR(36))
					WHEN
						DATA_TYPE LIKE 'DATE%'
						THEN CAST(CONCAT('Precision: ',DATETIME_PRECISION) AS VARCHAR(36))
				END AS EXTRA_DATA
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE
				TABLE_NAME LIKE @SearchCrit
				AND TABLE_NAME NOT LIKE 'ef%'
				AND TABLE_NAME NOT LIKE 'v%'
				AND TABLE_SCHEMA NOT LIKE 'history'		
	END
	ELSE-------------------------------------------Column Search: Column Name
	BEGIN
		INSERT INTO #COLUMN_SEARCH
		SELECT
			TABLE_SCHEMA
			,TABLE_NAME
			,COLUMN_NAME
			,ORDINAL_POSITION
			,IS_NULLABLE
			,DATA_TYPE
			,CASE 
				WHEN
					DATA_TYPE LIKE '%char'
					OR DATA_TYPE LIKE '%binary'
					THEN CAST(CONCAT
					(
						'Char/Octet Length: '
						,CHARACTER_MAXIMUM_LENGTH,', '
						,CHARACTER_OCTET_LENGTH
					) AS VARCHAR(36))
				WHEN
					DATA_TYPE LIKE 'DECIMAL'
					OR DATA_TYPE LIKE 'INT'
					THEN CAST(CONCAT
					(
						'Precision,Radix,Scale: '
						,NUMERIC_PRECISION, ', '
						,NUMERIC_PRECISION_RADIX,',	'
						,NUMERIC_SCALE
					) AS VARCHAR(36))
				WHEN
					DATA_TYPE LIKE 'DATE%'
					THEN CAST(CONCAT
					(
						'Precision: '
						,DATETIME_PRECISION
					) AS VARCHAR(36))
			END AS EXTRA_DATA
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE
			COLUMN_NAME LIKE @SearchCrit
			AND TABLE_NAME NOT LIKE 'ef%'
			AND TABLE_NAME NOT LIKE 'v%'
			AND TABLE_SCHEMA NOT LIKE 'history'		
	END
	IF @OrdinalOrder = 1-------------------------Order by Ordinal Position
	BEGIN
		SELECT
			*
		FROM #COLUMN_SEARCH
		ORDER BY
			ORDINAL_POSITION
			,COLUMN_NAME
			,TABLE_NAME
			,TABLE_SCHEMA
	END
	ELSE
	BEGIN
		SELECT
			*
		FROM #COLUMN_SEARCH
		ORDER BY
			COLUMN_NAME
			,TABLE_NAME
			,TABLE_SCHEMA
	END
	DROP TABLE #COLUMN_SEARCH
END