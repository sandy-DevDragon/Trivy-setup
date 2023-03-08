#!/bin/bash
ACR_NAME="tynybaytrivy"
#ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
ACR_LOGIN_SERVER="tynybaytrivy.azurecr.io"
#ACR_NAME="tynybaytrivy"
#ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
#ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)
#STORAGE_ACCOUNT_NAME="tynybaytrivyreport"
#STORAGE_ACCOUNT_KEY="zE8B0h2yvDvoRpA58dR7xl6s5XiEQkCIl7onzvnPLSS7lagVaU5fW5W0GYbrdH2GLB0+ZO1CyAwT+AStvPw7gw=="
#STORAGE_CONTAINER_NAME="trivy-scan-reports"
client_id="f7224a41-62ca-4163-9334-d9f13e287b62"
client_secret="6qk8Q~rSkiOEQjy4bBeWQBFCxU6m1cCVMcO5Cas0"
tenant_id="5079d9f7-c62b-44a0-9332-cb7cd90373fe"

az login --service-principal -u $client_id -p $client_secret --tenant $tenant_id

REPO_LIST=$(az acr repository list --name $ACR_NAME --output tsv)

echo $REPO_LIST
for image in $REPO_LIST
do
    TAG_LIST=$(az acr repository show-tags --name $ACR_NAME --repository $image --orderby time_desc --output tsv)
    for tag in $TAG_LIST
    do
	IMAGE_NAME="$ACR_LOGIN_SERVER/$image:$tag"
	echo "Scanning $IMAGE_NAME"
    	trivy client --remote http://20.204.221.104:80 $IMAGE_NAME --format template --template "@/usr/local/share/my-html.tpl" --output "trivy-scan-report-${image}.html"
    	az storage blob upload --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_ACCOUNT_KEY --container-name $STORAGE_CONTAINER_NAME --overwrite --type block --name "trivy-scan-report-${image}.html" --file "trivy-scan-report-${image}.html"
	break 
    done
done

