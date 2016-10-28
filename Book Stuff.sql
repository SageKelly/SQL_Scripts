USE MVCLibrary
GO

ALTER PROCEDURE lib.InsertBook
	@Author NVARCHAR(MAX)
	,@Title NVARCHAR(MAX)
AS
BEGIN
	--First check to see if it doesn't exist already
	IF NOT EXISTS
		(
			SELECT
				*
			FROM lib.Books
			WHERE
				AuthorName = @Author
				AND Title = @Title
		)

	INSERT INTO lib.Books
	VALUES
	(
		NEWID()
		,@Author
		,@Title
	)
END
GO

CREATE PROCEDURE lib.DeleteBook
	@ID UNIQUEIDENTIFIER
AS
BEGIN
	DELETE FROM lib.Books 
		WHERE BookID = @ID
END
GO

CREATE PROCEDURE lib.UpdateBook
	@ID UNIQUEIDENTIFIER
	,@Author NVARCHAR(MAX)
	,@Title NVARCHAR(MAX)
AS
BEGIN
	UPDATE lib.Books
		SET
			AuthorName = @Author
			,Title = @Title
		WHERE
			BookID = @ID
END
GO

INSERT INTO lib.Books
VALUES
 (NEWID(),'To Jack up a Goose','Hay Mayweather')
,(NEWID(),'She Is Just Not Feeling You','Jerome Miller')
,(NEWID(),'Nighttime','Vampire Lady')
,(NEWID(),'Hangry Affairs','Antoine Ferguson')
,(NEWID(),'Clenchers','Steven Oleburg')
,(NEWID(),'Centinniel Catastrophe','Steven Ming')
,(NEWID(),'Teleprompter: the Anchorman&quot;s Hero','Retired Anchorman')
GO

SELECT
	*
FROM lib.Books;

WITH TEMP AS
(
	SELECT
		AuthorName AS Title
		,Title AS Author
	FROM lib.Books
)

UPDATE lib.Books
	SET
		AuthorName = Title
		,Title = AuthorName
	FROM lib.Books
	WHERE
		BookID = BookID

SELECT
	*
FROM lib.Books


INSERT INTO lib.Books
VALUES
(
	NEWID()
	,'Hack Lalane'
	,'I''l Jack You Up'
)