DELIMITER //

DROP PROCEDURE IF EXISTS GetContactData //

-- Get details for a specified contact, all contacts or all contacts at a specified company

CREATE PROCEDURE GetContactData (IN theContactId INT, 
                                 IN theCompanyId INT)
SQL SECURITY INVOKER
COMMENT 'Get contact details for a specified one, all at a company or all in general'
BEGIN
  --
  -- Determine whether we are getting details for all contacts or a single one
  --
  SET @whereClause = '';
  IF theContactId IS NOT NULL AND theContactId <> 0 THEN
    SET @whereClause = CONCAT(' WHERE c.contactId = ', theContactId);
  ELSE
    --
    -- They didn't specify a contact, so see if they want all or just those at
    -- a specific company
    --
    IF theCompanyId IS NOT NULL AND theCompanyId <> 0 THEN
      SET @whereClause = CONCAT(' WHERE c.companyId = ', theCompanyId);
    END IF;
  END IF;
  --
  -- Now build the SELECT and then execute it
  --
  SET @selStmt = CONCAT('SELECT c.companyId, cc.name AS companyName, 
                                c.contactId, c.forename, c.surname, c.title, c.initials, c.salutation, 
                                c.telephone, c.jobTitle, c.jobCodeId, j.code AS jobCode, c.sources, 
                                c.notes, c.mobile, c.urgency, c.lastUpdate, c.nextCall, c.hvi, 
                                c.hviHistorical, c.trendESeq, c.trendCSeq, c.trendCompCode, c.trendESuffix, 
                                c.custFlag, c.ownEntry, c.cLastUpdate, c.email, c.emailConfirmed, 
                                c.mSort, c.gSelectedContact, c.gContactFilter, c.gAssociatedCompany
                        FROM contact AS c
                        LEFT JOIN company AS cc ON (cc.companyId = c.companyId)
                        LEFT JOIN jobCode AS j ON (j.jobCodeId = c.jobCodeId)',
                        @whereClause,
                        ' ORDER BY cc.name, c.surname, c.forename');
  PREPARE selectContact FROM @selStmt;
  EXECUTE selectContact;
  DEALLOCATE PREPARE selectContact;
  
END //

DELIMITER ;
