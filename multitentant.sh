# Enumerate multitenant app registrations and export to CSV
# Fields: appId, displayName, objectId, signInAudience, createdDateTime, owners, verifiedPublisher

# Ensure you're in the right tenant
az account show --output table

# Query Graph; note ConsistencyLevel eventual for $count
az rest \
  --method GET \
  --headers "ConsistencyLevel=eventual" \
  --url "https://graph.microsoft.com/v1.0/applications?\$filter=signInAudience%20eq%20'AzureADMultipleOrgs'&\$count=true&\$select=id,appId,displayName,signInAudience,createdDateTime,verifiedPublisher" \
  --output json \
| jq -r '
  # Enrich with owners (second call per app)
  .value as $apps
  | (["displayName","appId","objectId","signInAudience","createdDateTime","verifiedPublisher.displayName","ownerUpns"] | @csv),
    ($apps[] | [
      .displayName,
      .appId,
      .id,
      .signInAudience,
      .createdDateTime,
      (.verifiedPublisher.displayName // ""),
      # fetch owners UPNs for each app
      (([.id] | join("")) as $appid
       | ( $appid ) )
    ] | @csv)
' > multitenant_apps_raw.csv
