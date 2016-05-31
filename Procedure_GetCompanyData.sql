DELIMITER //

-- Added a comment to modify this file

DROP PROCEDURE IF EXISTS GetCompanyData //

-- Add a different line here for Branch2
-- Get details for all companies or a specified company

CREATE PROCEDURE GetCompanyData (IN theCompanyId INT)
SQL SECURITY INVOKER
COMMENT 'Get company details for all or a specified one'
BEGIN
  --
  -- Determine whether we are getting details for all companies or a single one
  --
  SET @whereClause = '';
  IF theCompanyId IS NOT NULL AND theCompanyId <> 0 THEN
    SET @whereClause = CONCAT(' WHERE c.companyId = ', theCompanyId);
  END IF;
  --
  -- Now build the SELECT and then execute it
  --
  SET @selStmt = CONCAT('SELECT c.companyId, c.name AS companyName, c.prefix, c.address1, c.address2, c.address3, 
                                c.postalTown, c.countyId, cc.name AS county, c.postCode, c.phoneNumber, 
                                cc.salesAreaId, sa.name AS salesArea, c.salesEngineer, c.pressStream, 
                                c.companyTypeId, ct.typeCode, c.notes, c.contacts, c.lastUpdate, 
                                c.lastContact, c.contactMethod, c.numEmployees, c.userEntry, c.trendCode, 
                                c.trendSequence, c.trendSource, c.sources, c.ownEntry, c.cLastUpdate,
                                c.advertiser, c.webAddress, c.email, c.emailConfirmed, c.advertPdf, c.bookletPageNumber 
                        FROM company AS c
                        LEFT JOIN companyType AS ct ON (ct.companyTypeId = c.companyTypeId)
                        LEFT JOIN county AS cc ON (cc.countyId = c.countyId)
                        LEFT JOIN salesArea AS sa ON (sa.salesAreaId = cc.salesAreaId)',
                        @whereClause,
                        ' ORDER BY c.name, c.postalTown');
  PREPARE selectCompany FROM @selStmt;
  EXECUTE selectCompany;
  DEALLOCATE PREPARE selectCompany;
  
END //

DELIMITER ;
