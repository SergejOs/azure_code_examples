###############################################################################
# Working as regular User

# Login
az login   # this will open new login window in Web Browser and ask for 2FA

# Get Current user
az ad signed-in-user show

# Get Current User's Name
az ad signed-in-user show --query userPrincipalName --output tsv

# Assign UserName to variable
aadAccount=$(az ad signed-in-user show --query userPrincipalName --output tsv)

# Assign UserName and Id to Array  - to be used in other commands
userArr=( $(az ad user show --id "Sergej.Ostashchuk.Admin.C@a1g.onmicrosoft.com" --query "{userObjectId:objectId,userPrincipalName:userPrincipalName}" -o tsv) )
echo ${userArr[0]}
echo ${userArr[1]}


# Get info about any user
az ad user show --id "<userPrincipalName>"


###############################################################################
# EXAMPLE : dynamically assign current user as Synapse Active Directory Admin  -- ALL TOGETHER

aadAccount=$(az ad signed-in-user show --query userPrincipalName --output tsv)
userArr=($(az ad user show --id ${aadAccount} --query "{userObjectId:objectId,userPrincipalName:userPrincipalName}" -o tsv))
az synapse sql ad-admin update --workspace-name <WS_NAME> --resource-group <RG-NAME> --display-name ${userArr[1]} --object-id ${userArr[0]}


###############################################################################
# Working as Service Principals

### Execute as a user with Read permissions on AD
# Get list of all SP
az ad sp list --all -o table

# get info about SP  - filter the list
az ad sp list --display-name <ServicePrincipalDisplayName>

# The appId and tenantId keys that appear in the output are used in service principal authentication / login.
az ad sp list  --display-name <ServicePrincipalDisplayName> --query "[].{name:appDisplayName, id:appId, tenant:appOwnerTenantId}"
### END

# Login as Servie Principal
az login --service-principal --username <APP_ID> --password <PASSWORD> --tenant <TENANT_ID>
az login --service-principal --username "b785646a-ef56-4a45-b9a4-2e2e687954a" --password "ertgertger3trg3565234554t" --tenant "245t45-d3a2-4d59-a14a-acaedd98e798"

# Get Current Service Principal
az account show

# Get Service Principal Id - to be used in other commands
az account show --query id -o tsv
sp_id=$(az account show --query id -o tsv)
echo $sp_id


###############################################################################
# Subscriptions

# Get a list of subscriptions for the logged in account.
az account list 	
az account list -o table

# Get details of default subscription
az account show

# Get details of any subscription.
az account show -s SubscriptionName

# Set a subscription to be the current active subscription.
az account set -s "<Name or ID of subscription>"


