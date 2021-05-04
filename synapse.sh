###############################################################################################################
# Content
# 1. Synapse workspaces 
# 2. Synapse SQL Active Directory admin 
# 3. SQL Servers 
# 4. SQL Servers Active Directory admin 
# 5. Firewall Rules
# 6. Azure AD authentication - create user, (alter role - does not help)
# 7. CREATE DATABASE - currently does not work in Synapse - create SQL POOL instead
# 8. Grant permissions to Database - use it instead of dbmanager role 
# 9. How to examples - Dedicated SQL pools
# 10. Serverless pool - role assignment

### For SQL Servers - see below ###

###############################################################################################################
# 1. Synapse workspaces 

# List 
az synapse workspace list -o table
az synapse workspace list --subscription "GP-Prod-Subscription"  -o table

az synapse workspace show --resource-group GP-RG-Dev-001 --name gp-as-dev-001

# Dedicated pools
az synapse sql pool list --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001 -o table
az synapse sql pool create --name sqlpool_test --performance-level "DW100c" --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001
az synapse sql pool delete --name sqlpool_test --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001


# Managed identities
az synapse workspace managed-identity show-sql-access --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001


###############################################################################################################
### 2. Synapse SQL Active Directory admin 
# !!! To enhance manageability, we recommend you provision a dedicated Azure AD group as an administrator. !!!

# show
az synapse sql ad-admin show --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001

# create
az synapse sql ad-admin create --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001 --display-name "user.name@domain.onmicrosoft.com" --object-id d36ef1dd-56be-4577-92ec-3e1b3456365

# delete
az synapse sql ad-admin delete -y --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001

# update
az synapse sql ad-admin update --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001 --display-name "user.name@domain.onmicrosoft.com" --object-id d36ef1dd-56be-4577-92ec-3e1bertyert5

# UPDATE with USER ARRAY
az synapse sql ad-admin update --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001 --display-name ${userArr[1]} --object-id ${userArr[0]}

### FULL EXAMPLE: Set SQL AD Admin dynamically for current user
aadAccount=$(az ad signed-in-user show --query userPrincipalName --output tsv)
userArr=($(az ad user show --id ${aadAccount} --query "{userObjectId:objectId,userPrincipalName:userPrincipalName}" -o tsv))
az synapse sql ad-admin update --workspace-name gp-as-dev-001 --resource-group GP-RG-Dev-001 --display-name ${userArr[1]} --object-id ${userArr[0]}


###############################################################################################################
# 3. SQL Servers 

# List 
az sql server list -o table         # including Synapse dedicated pools
az sql mi list                      # Managed instances SQL servers - except Synapse

###############################################################################################################
### 4. SQL Servers Active Directory admin - for SQL servers (NOT SYNAPSE !)

# list
az sql server ad-admin list --resource-group "GP-RG-Dev-001" --server-name "gp-sql-dev-001"
# create
az sql server ad-admin create --display-name "user.name@domain.onmicrosoft.com" --object-id d36ef1dd-56be-4577-92ec-3e1345ec65 --resource-group "GP-RG-Dev-001" --server "gp-sql-dev-001"
# delete
az sql server ad-admin delete --resource-group "GP-RG-Dev-001" --server "gp-sql-dev-001"
# update ...


###############################################################################################################
# 5. Firewall Rules

# By default, all connections to the server and database are rejected. 
# For the most secure configuration: set Allow access to Azure services to OFF . Then, create a reserved IP for the resource that needs to connect.

# Server-level IP firewall rules apply to all databases within the same server.
# Enable clients to access entire server - all the databases managed by the server. These rules are stored in the master database.
# Can configure using the Azure portal, PowerShell, or Transact-SQL statements.

# Database-level firewall rules apply to individual databases.
# You create the rules for each database (including the master database), and they're stored in the individual database.
# Only by using Transact-SQL statements 

# Azure Synapse only supports server-level IP firewall rules. It doesn't support database-level IP firewall rules.

# Show server-level firewall rules
az sql server firewall-rule list

# SQL - server and database level
SELECT * FROM sys.firewall_rules ORDER BY name;
SELECT * FROM sys.database_firewall_rules ORDER BY name;


###############################################################################################################
# 6. Azure AD authentication

# Azure Active Directory authentication requires that database users are created as contained. 
# A contained database user maps to an identity in the Azure AD directory associated with the database and has no login in the master database.
# The Azure AD identity can either be for an individual user or a group.
# Database users (except administrators) cannot be created using the Azure portal. 
# Azure roles do not propagate to SQL servers, databases, or data warehouses. They are only used to manage Azure resources and do not apply to database permissions.

# !!! Azure AD administrator is the owner of the database !!!
# !!! Only one Azure AD user can be unrestricted admin !!!

# SELECT DB USERS
SELECT * FROM sys.database_principals
SELECT LEFT(name,60) as name, principal_id, LEFT(type_desc, 20) as type_desc, left(authentication_type_desc,10) as authentication_type_desc from sys.database_principals;


# Create DB user connected to AAD - execute this in EACH DATABASE 
# Azure AD users are marked in the database metadata with type E (EXTERNAL_USER) and type X (EXTERNAL_GROUPS) for groups. 
# Created USERS automatically granted CONNECT permission to DATABASE

CREATE USER [GP_DEV_SYNAPSE_SERVER_MANAGER] FROM EXTERNAL PROVIDER
ALTER ROLE   dbmanager  ADD MEMBER  GP_DEV_SYNAPSE_SERVER_MANAGER

SELECT DP1.name AS DatabaseRoleName,   
   isnull (DP2.name, 'No members') AS DatabaseUserName   
 FROM sys.database_role_members AS DRM  
 RIGHT OUTER JOIN sys.database_principals AS DP1  
   ON DRM.role_principal_id = DP1.principal_id  
 LEFT OUTER JOIN sys.database_principals AS DP2  
   ON DRM.member_principal_id = DP2.principal_id  
 WHERE DP1.type = 'R'
 ORDER BY DP1.name;  

# dbmanager role
# These database roles exist only in the virtual master database. 
# Their permissions are !!! restricted to actions performed in master !!! . 
# Only database users in master can be added to these roles.
# However, in Synapse a new DB can not be created using SQL statement - create SQL pool instead !

DROP USER GP_DEV_SYNAPSE_SERVER_MANAGER
ALTER ROLE   dbmanager  DROP MEMBER  GP_DEV_SYNAPSE_SERVER_MANAGER

### ALL SELECTS TOGETHER ###
PRINT 'database='+ DB_NAME(); 
PRINT 'user=' + CURRENT_USER;

SELECT * FROM sys.database_principals

SELECT DP1.name AS DatabaseRoleName,   
   isnull (DP2.name, 'No members') AS DatabaseUserName   
 FROM sys.database_role_members AS DRM  
 RIGHT OUTER JOIN sys.database_principals AS DP1  
   ON DRM.role_principal_id = DP1.principal_id  
 LEFT OUTER JOIN sys.database_principals AS DP2  
   ON DRM.member_principal_id = DP2.principal_id  
 WHERE DP1.type = 'R'
 ORDER BY DP1.name;  

SELECT DISTINCT pr.principal_id, pr.name, pr.type_desc, 
        pr.authentication_type_desc, pe.state_desc, pe.permission_name
    FROM sys.database_principals AS pr
    JOIN sys.database_permissions AS pe
        ON pe.grantee_principal_id = pr.principal_id;



###############################################################################################################
# 7. CREATE DATABASE
# https://docs.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=azure-sqldw-latest&preserve-view=true&tabs=sqlpool

# DB name must be unique on the SQL server, which can host both Azure SQL Database databases and Azure Synapse Analytics databases
# Required permissions: 
#    Server level principal login, created by the provisioning process, or
#    Member of the dbmanager database role.

# Limitations:
#     You must be connected to the master database to create a new database.
#     The CREATE DATABASE statement must be the only statement in a Transact-SQL batch.
#     You cannot change the database collation after the database is created.
#     EDITION Specifies the service tier of the database. For Azure Synapse Analytics use 'datawarehouse'.
#     'Azure SQL Data Warehouse Gen1 has been deprecated in this region. Please use SQL Analytics in Azure Synapse.'


-- CREATE DATABASE TestDW (EDITION = 'datawarehouse', SERVICE_OBJECTIVE='DW100c');
# ERROR : Msg 49974, Level 16, State 1, Line 1
# CREATE DATABASE statement is not supported in a Synapse workspace. To create a SQL pool, use the Azure Synapse Portal or the Synapse REST API.

### CREATE SQL POOL instead ###


###############################################################################################################
# 8. Grant permissions to Database

# You can grant permissions to AAD contained users and groups 
GRANT CONTROL TO GP_DEV_SYNAPSE_SERVER_MANAGER;
GRANT CONTROL ON DATABASE::SQLPOOL1 TO GP_DEV_SYNAPSE_SERVER_MANAGER;

REVOKE CONTROL ON DATABASE::SQLPOOL1 FROM GP_DEV_SYNAPSE_SERVER_MANAGER;

# Show all permissions granted on database
SELECT DISTINCT pr.principal_id, pr.name, pr.type_desc, 
        pr.authentication_type_desc, pe.state_desc, pe.permission_name
    FROM sys.database_principals AS pr
    JOIN sys.database_permissions AS pe
        ON pe.grantee_principal_id = pr.principal_id;


###############################################################################################################
# 9. How to examples - Dedicated SQL pools

# 1) create new dedicated SQL pool - end user in portal GUI

# 2) Login to new database using AD authentication as a user assigned Synapse Active Directory admin
#    CREATE SQL Server user for existing Azure AD User or Group 
CREATE USER [user.name@domain.onmicrosoft.com] FROM EXTERNAL PROVIDER;

# 3) GRANT database permissions
GRANT CONTROL TO [user.name@domain.onmicrosoft.com];


###############################################################################################################
# 10. Serverless pool - role assignment

# Synapse RBAC extends the capabilities of Azure RBAC for Synapse workspaces
# Azure RBAC is used to manage who can create, update, or delete the Synapse workspace and its SQL pools, Apache Spark pools, and Integration runtimes.
# Synapse RBAC: 
#     is used to publis code, execute and monitor jobs, access linked data services protected by credentials
#     provides (only limited) access control to serverless SQL pools
#     not used to control access to dedicated SQL pools (managed using SQL security)
# When a new workspace is created, the creator is automatically given the Synapse Administrator role at workspace scope.

# list workspaces in specified subscription - workspace name will be used below
az synapse workspace list --subscription "GP-SUBSCRIPTION-DEV"  -o table

# list synapse role assignments
az synapse role assignment list --workspace-name gp-as-dev-001 --subscription "GP-SUBSCRIPTION-DEV"

'''
  {                                                                        
    "id": "721ba536-fe83-4126-b708-edf6wertwer1c4",                          
    "principalId": "d36ef1dd-56be-4577-92ec-3ewertwertec65",                 
    "principalType": "User",                                               
    "roleDefinitionId": "6e4bf58a-b8e1-4cc3-bbf9-d7314wertwr",            
    "scope": "workspaces/gp-as-dev-001"                                    
  }                                                                        
'''
# use principalId to get AD user info
az ad user show --id "d36ef1dd-56be-4577-92ec-3e1ertwretrwt5" --query userPrincipalName

# use roleDefinitionId to get role info
az synapse role definition show --workspace-name gp-as-dev-001 --subscription "GP-SUBSCRIPTION-DEV" --role 6e4bf58a-b8e1-4cc3-bbf9-d731werterw8
az synapse role definition show --workspace-name gp-as-dev-001 --subscription "GP-SUBSCRIPTION-DEV" --role 6e4bf58a-b8e1-4cc3-bbf9-d7wertwrett8 --query name --only-show-errors -o tsv

