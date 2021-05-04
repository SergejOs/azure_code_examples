###############################################################################
# Role assignments

# If no filter - list assignments for all AD identities (users, service principals, groups )
# By default, only assignments with scope = CURRENT SUBSCRIPTION.
az role assignment list

# --all : Assignments for current subscription AND all resources within.
az role assignment list --all

# --assignee : Represent a user, group, or service principal. 
#              Supported format: object (principal) id, user sign-in name, or service principal name.
az role assignment list --all --assignee "d36efxxx-56xx-45xx-92xx-3e1b2f5eexxx"
az role assignment list --all --assignee "UserName@Domain.onmicrosoft.com"

# --include-groups --include-inherited
az role assignment list --all --assignee "UserName@Domain.onmicrosoft.com" --include-groups --include-inherited

###############################################################################
# What is assignee (principalId, principalName)

# User: 
# principalId <== objectId
# principalName <== userPrincipalName

az ad signed-in-user show

: '     "objectId": "d36ef1dd-56be-4577-92ec-3587697844c65",
        "userPrincipalName": "UserName@Domain.onmicrosoft.com",
'
az role assignment list --all --assignee "d36ef1dd-56be-4577-92ec-3e15768574565"

: '     "principalId": "d36ef1dd-56be-4577-92ec-3e1b57684c65",
        "principalName": "UserName@Domain.onmicrosoft.com",
'

# Service principal
# principalId <== objectId
# principalName <==  appId, servicePrincipalNames[0]

az ad sp list --display-name GP-FA-SynapseDEV-GRDP-001

        "appDisplayName": "GP-SynapseDEV-principal-001",
        "appId": "b78012fa-ef8d-4ae7-b9f8-2e2e58674899a",

        "objectId": "c550a50c-8039-4c82-8993-ff44965879452",
        "objectType": "ServicePrincipal",

        "servicePrincipalNames": [
              "b78012fa-ef8d-4ae7-b9f8-2e2e354i7429a"
        ],
        "servicePrincipalType": "Application",


az role assignment list --all --assignee b78012fa-ef8d-4ae7-b9f8-2e2e0120829a
        "principalId": "c550a50c-8039-4c82-8993-ff4a6878e52",
        "principalName": "b78012fa-ef8d-4ae7-b9f8-2e2e01298797a",
        "principalType": "ServicePrincipal",
