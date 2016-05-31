DELIMITER //

-- Define a procedure to get a list of records of the specified class of data matching the search string

DROP PROCEDURE IF EXISTS GetMatchingRecords //

CREATE PROCEDURE GetMatchingRecords (IN theSearchString VARCHAR(255),
                                     IN theClassType VARCHAR(32)
                                    )
COMMENT 'Get list of records mathcing the search string and the class of data'
SQL SECURITY INVOKER
BEGIN
  --
  -- The class type parameter defines the type of the class for which the first letters should be returned.
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
  SET @columnSearch = 'cy.name';
  
  IF theClassType = 'area' THEN
    SET @tableSearch = 'salesArea';
    SET @columnSearch = 'sa.name';
  ELSEIF theClassType = 'town' THEN
    SET @columnSearch = 'cy.postalTown';
  ELSEIF theClassType = 'postcode' THEN
    SET @columnSearch = 'cy.postCode';
  ELSEIF theClassType = 'surname' THEN
    SET @tableSearch = 'contact';
    SET @columnSearch = 'cn.surname';
  ELSEIF theClassType = 'job' THEN
    SET @tableSearch = 'jobCode';
    SET @columnSearch = 'jc.description';
  END IF;
  --
  -- The SELECT will depend on the data being searched: a company-based search (name, area, town & postcode) will
  -- return only company information; a contact-based search will return some contact details and a reduced set of
  -- company details (or maybe not - leave all in for now).
  --
  IF @tableSearch = 'company' OR @tableSearch = 'salesArea' THEN
    SET @selStmt = CONCAT('SELECT cy.companyId, cy.name AS companyName, cy.address1, cy.address2, cy.address3, cy.postalTown, 
                          cy.postCode, cy.webAddress, ct.description AS companyType, co.name AS county, sa.name AS salesArea
                          FROM company AS cy, county AS co, salesArea AS sa, companyType AS ct
                          WHERE ', @columnSearch, ' LIKE \'', theSearchString, '%\'',  
                          ' AND co.countyId = cy.countyId
                          AND sa.salesAreaId = co.salesAreaId
                          AND ct.companyTypeId = cy.companyTypeId
                          ORDER BY cy.name');
  ELSE
    SET @selStmt = CONCAT('SELECT cn.contactId, cn.title, cn.forename, cn.surname, jc.description AS jobCode, 
                          cy.companyId, cy.name AS companyName, cy.address1, cy.address2, cy.address3, cy.postalTown, 
                          cy.postCode, cy.webAddress, ct.description AS companyType, co.name AS county, sa.name AS salesArea
                          FROM contact AS cn, jobCode AS jc, company AS cy, county AS co, salesArea AS sa, companyType AS ct
                          WHERE ', @columnSearch, ' LIKE \'', theSearchString, '%\'',  
                          ' AND jc.jobCodeId = cn.jobCodeId
                          AND cy.companyId = cn.companyId
                          AND co.countyId = cy.countyId
                          AND sa.salesAreaId = co.salesAreaId
                          AND ct.companyTypeId = cy.companyTypeId
                          ORDER BY cn.surname, cn.forename');
  END IF;
  
  PREPARE listData FROM @selStmt;
  EXECUTE listData;
  DEALLOCATE PREPARE listData;

END //

DELIMITER ;
