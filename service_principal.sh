###############################################################################
# Working as Service Principals

# Login as Servie Principal
az login --service-principal --username <APP_ID> --password <PASSWORD> --tenant <TENANT_ID>
az login --service-principal --username "b785-ef-45-a4-2e54a" --password "ertger2354234t" --tenant "245-d3a2-4d59-a14a-ace798"

# Get Current Service Principal - can be seen as part of subscription information
az account show

# Get Service Principal Id - to be used in other commands
az account show --query id -o tsv
sp_id=$(az account show --query id -o tsv)
echo $sp_id


# Get the details of a service principal    
#       be aware :  Service principal name == "appId"
#                   object id == "objectId"

az ad sp show --id  <Service principal name, or object id>
az ad sp show --id b78012fa-ef8d-4ae7-b9f8-2e2e0120829a


########## Execute as a user with Read permissions on AD
# Get list of all SP
az ad sp list --all -o table

# get info about SP  - filter the list - the same info as returned by az ad sp show
az ad sp list --display-name <ServicePrincipalDisplayName>
az ad sp list --display-name GP-FA-SynapseDEV-GRDP-001

# The appId and tenantId keys that appear in the output are used in service principal authentication / login.
az ad sp list  --display-name <ServicePrincipalDisplayName> --query "[].{name:appDisplayName, id:appId, tenant:appOwnerTenantId}"


