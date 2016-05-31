DELIMITER //

-- Define a procedure to get a list of the first letters of the specified class of data

DROP PROCEDURE IF EXISTS GetFirstLetters //

CREATE PROCEDURE GetFirstLetters (IN theClassType VARCHAR(32)
                                  )
COMMENT 'Get list of first letters of the class of data'
SQL SECURITY INVOKER
BEGIN
  --
  -- The parameter defines the type of the class for which the first letters should be returned.
  -- This can be:
  --  company
  --  area
  --  town
  --  postcode
  --  surname
  --  job
  -- The value is specified by the parameter having one of the above strings specified.
  --
  -- Default to a company name search...
  --
  SET @tableSearch = 'company';
  SET @columnSearch = 'name';
  
  IF theClassType = 'area' THEN
    SET @tableSearch = 'salesArea';
    SET @columnSearch = 'name';
  ELSEIF theClassType = 'town' THEN
    SET @columnSearch = 'postalTown';
  ELSEIF theClassType = 'postcode' THEN
    SET @columnSearch = 'postCode';
  ELSEIF theClassType = 'surname' THEN
    SET @tableSearch = 'contact';
    SET @columnSearch = 'surname';
  ELSEIF theClassType = 'job' THEN
    SET @tableSearch = 'jobCode';
    SET @columnSearch = 'description';
  END IF;

  SET @selStmt = CONCAT('SELECT DISTINCT LEFT(', @columnSearch, ', 1)
                        FROM ', @tableSearch,
                        ' ORDER BY ', @columnSearch);
  PREPARE listFirstLetters FROM @selStmt;
  EXECUTE listFirstLetters;
  DEALLOCATE PREPARE listFirstLetters;

END //

DELIMITER ;
