--USE CSI_Admin
--USE CSI_GULF_COUNTY
USE CSI_Client_COS_578
--USE CSI_Client_COS_613
--USE CSI_Client_COS_642

DECLARE
	@ProcSearch BIT
	,@TableSearch BIT
	,@SearchCrit NVARCHAR(MAX)
	,@ConcatSearch NVARCHAR(MAX)
	,@TableColumnSearch BIT
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
	@SearchCrit = 'paymenttypeterminalidentifier'
SET
	@TableColumnSearch = 0
	



---- DO NOT ALTER ANYTHING BELOW THIS LINE
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
SET
	@ConcatSearch = CONCAT('%',@SearchCrit,'%')

IF @ProcSearch = 1
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

ELSE IF @TableSearch = 1
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
ELSE IF @TableColumnSearch = 0
-------------------------------------------------------------------------------Columns
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
				THEN CAST(CONCAT('Char/Octet Length: ',CHARACTER_MAXIMUM_LENGTH,', ',CHARACTER_OCTET_LENGTH) AS VARCHAR(36))
			WHEN
				DATA_TYPE LIKE 'DECIMAL'
				OR DATA_TYPE LIKE 'INT'
				THEN CAST(CONCAT('Precision,Radix,Scale: ',NUMERIC_PRECISION, ', ',NUMERIC_PRECISION_RADIX,', ',NUMERIC_SCALE) AS VARCHAR(36))
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
	ORDER BY
		--ORDINAL_POSITION
		COLUMN_NAME
		,
		TABLE_NAME
		,TABLE_SCHEMA
ELSE
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
				THEN CAST(CONCAT('Char/Octet Length: ',CHARACTER_MAXIMUM_LENGTH,', ',CHARACTER_OCTET_LENGTH) AS VARCHAR(36))
			WHEN
				DATA_TYPE LIKE 'DECIMAL'
				OR DATA_TYPE LIKE 'INT'
				THEN CAST(CONCAT('Precision,Radix,Scale: ',NUMERIC_PRECISION, ', ',NUMERIC_PRECISION_RADIX,', ',NUMERIC_SCALE) AS VARCHAR(36))
			WHEN
				DATA_TYPE LIKE 'DATE%'
				THEN CAST(CONCAT('Precision: ',DATETIME_PRECISION) AS VARCHAR(36))
		END AS EXTRA_DATA
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE
		COLUMN_NAME LIKE @SearchCrit
		AND TABLE_NAME NOT LIKE 'ef%'
		AND TABLE_NAME NOT LIKE 'v%'
		AND TABLE_SCHEMA NOT LIKE 'history'
	ORDER BY
		--ORDINAL_POSITION
		COLUMN_NAME
		,
		TABLE_NAME
		,TABLE_SCHEMA