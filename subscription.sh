###############################################################################
# Subscriptions

# Get details of a subscription. 
# If the subscription isn't specified, shows the details of the default subscription.
az account show

#  --subscription -s        : Name or ID of subscription.
az account show -s  "Subscription Name"

# Get a list of all subscriptions available for the logged in account.
az account list 	
az account list -o table


# Set a subscription to be the current active subscription.
az account set -s "<Name or ID of subscription>"

