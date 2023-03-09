#!/bin/bash
#ACR_NAME="tynybaytrivy"
#ACR_LOGIN_SERVER="tynybaytrivy.azurecr.io"
#ACR_NAME="tynybaytrivy"
#ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
#ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query passwords[0].value --output tsv)
#STORAGE_ACCOUNT_NAME="tynybaytrivyreport"
#STORAGE_ACCOUNT_KEY="zE8B0h2yvDvoRpA58dR7xl6s5XiEQkCIl7onzvnPLSS7lagVaU5fW5W0GYbrdH2GLB0+ZO1CyAwT+AStvPw7gw=="
#STORAGE_CONTAINER_NAME="trivy-scan-reports"

az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer --output tsv)
REPO_LIST=$(az acr repository list --name $ACR_NAME --output tsv)

echo $REPO_LIST
for image in $REPO_LIST
do
    TAG_LIST=$(az acr repository show-tags --name $ACR_NAME --repository $image --orderby time_desc --output tsv)
    for tag in $TAG_LIST
    do
	IMAGE_NAME="$ACR_LOGIN_SERVER/$image:$tag"
	echo "Scanning $IMAGE_NAME"
    	trivy client --remote http://$LOAD_BALANCER_PUBLIC_IP:80 $IMAGE_NAME --format template --template "@/usr/local/share/my-html.tpl" --output "trivy-scan-report-${image}.html"
    	az storage blob upload --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_ACCOUNT_KEY --container-name $STORAGE_CONTAINER_NAME --overwrite --type block --name "trivy-scan-report-${image}.html" --file "trivy-scan-report-${image}.html"
	break 
    done
done

