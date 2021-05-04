###############################################################################
# Working as regular User

# Login
az login   # this will open new login window in Web Browser and ask for 2FA

# Get Current Subscription - incl. user details
az account show

# Get Current user
az ad signed-in-user show
az ad signed-in-user show --query userPrincipalName --output tsv

# Assign UserName to variable
aadAccount=$(az ad signed-in-user show --query userPrincipalName --output tsv)

# Assign UserName and Id to Array  - to be used in other commands
userArr=( $(az ad user show --id "user.name@domain.onmicrosoft.com" --query "{userObjectId:objectId,userPrincipalName:userPrincipalName}" -o tsv) )
echo ${userArr[0]}
echo ${userArr[1]}


# Get info about any user
az ad user show --id "<userPrincipalName>"

az ad user show --id "user.name@domain.onmicrosoft.com"
az ad user show --id "user.name@domain.onmicrosoft.com" --query objectId -o tsv
az ad user show --id "user.name@domain.onmicrosoft.com" --query "[userPrincipalName, objectId]"


###############################################################################
# EXAMPLE : dynamically assign current user as Synapse Active Directory Admin  -- ALL TOGETHER

aadAccount=$(az ad signed-in-user show --query userPrincipalName --output tsv)
userArr=($(az ad user show --id ${aadAccount} --query "{userObjectId:objectId,userPrincipalName:userPrincipalName}" -o tsv))
az synapse sql ad-admin update --workspace-name <WS_NAME> --resource-group <RG-NAME> --display-name ${userArr[1]} --object-id ${userArr[0]}


