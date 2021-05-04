-- F5 == RUN in SSMS
-- print @@servername; -- does not work in managed SQL pool
PRINT DB_NAME();
PRINT CURRENT_USER;

PRINT 'database='+ DB_NAME()  + CHAR(13) + 'user=' + CURRENT_USER;



-- List of databases
SELECT name FROM sys.databases;

-- List user tables
SELECT name, crdate FROM SYSOBJECTS WHERE xtype = 'U';

-- List of DB users
SELECT * FROM sys.database_principals

-- Listing effective permissions on the server - the function exists not everywhere 
SELECT * FROM fn_my_permissions(NULL, 'SERVER');  

-- Listing effective permissions on the database - the function exists not everywhere 
SELECT * FROM fn_my_permissions (NULL, 'DATABASE');  



-- For testing DB USERS and ROLES

SELECT * FROM sys.database_principals;

SELECT DP1.name AS DatabaseRoleName,   
   isnull (DP2.name, 'No members') AS DatabaseUserName   
 FROM sys.database_role_members AS DRM  
 RIGHT OUTER JOIN sys.database_principals AS DP1  
   ON DRM.role_principal_id = DP1.principal_id  
 LEFT OUTER JOIN sys.database_principals AS DP2  
   ON DRM.member_principal_id = DP2.principal_id  
 WHERE DP1.type = 'R'
 ORDER BY DP1.name;  


-- CREATE external SQL Server user from AAD Group
CREATE USER [AT_GP_DEV_SYNAPSE_SERVER_MANAGER] FROM EXTERNAL PROVIDER;

-- When you create a database user, that user receives the CONNECT permission and can connect to that database as a member of the PUBLIC role.


-- Special Roles for SQL Database and Azure Synapse

-- db_owner
--   this works in dedicated SQL POOL in every database except master
EXEC sp_addrolemember 'db_owner', 'GP_DEV_SYNAPSE_SERVER_MANAGER';


-- dbmanager: 
--	 Can create and delete databases. A member of the dbmanager role that creates a database, becomes the owner of that database 
--   which allows that user to connect to that database as the dbo user. The dbo user has all database permissions in the database. 
--   Members of the dbmanager role do not necessarily have permission to access databases that they do not own.

-- this works in dedicated SQL POOL in master database
-- but Synapse does not allow to create databases from SQL statment - nust use Azure API (CLI, portal)
ALTER ROLE   dbmanager  ADD MEMBER  GP_DEV_SYNAPSE_SERVER_MANAGER;


-- this is not needed, probably
-- loginmanager: 	Can create and delete logins in the virtual master database.
ALTER ROLE loginmanager ADD MEMBER  GP_DEV_SYNAPSE_SERVER_MANAGER;

-- DROP USER
-- Drop role
DROP USER GP_DEV_SYNAPSE_SERVER_MANAGER  ;
ALTER ROLE   dbmanager  DROP MEMBER  GP_DEV_SYNAPSE_SERVER_MANAGER



-----
-- SERVER
-- For testing DB USERS and ROLES
SELECT * FROM sys.server_principals;

SELECT SP1.name AS DatabaseRoleName,   
   isnull (SP2.name, 'No members') AS DatabaseUserName   
 FROM sys.server_role_members AS SRM  
 RIGHT OUTER JOIN sys.server_principals AS SP1  
   ON SRM.role_principal_id = SP1.principal_id  
 LEFT OUTER JOIN sys.server_principals AS SP2  
   ON SRM.member_principal_id = SP2.principal_id  
ORDER BY SP1.name;  



