#!/bin/bash
webapp_name=$1
dns_zone=$2

provision_by_bicep() {
    deploy_name=`date +"%Y%m%d%H%M"`
    az deployment group create --name ${deploy_name} --resource-group $1 --template-file $2 --parameters "{ \"webAppName\": { \"value\": \"${webapp_name}\" }, \"dnsZoneName\": { \"value\": \"${dns_zone}\" } }"
}

check_validation_token() {
    az staticwebapp hostname show --name $1 --resource-group $2 --hostname $3 --query validationToken
}

echo "Provisioning swa with custom domain in a separated process ..."
provision_by_bicep ruhe-playground-0526 swa_with_custom_domain.bicep &
# Store the process ID of the deployment
swa_deployment_id=$!
echo "SWA deployment process id is ${swa_deployment_id}. Keep it for later use."

while true; do
    output=`az staticwebapp hostname show --name ${webapp_name} --resource-group ruhe-playground-0526 --hostname ${dns_zone} --query validationToken`

    if [ $? -eq 0 ] && [ -n "$output" ]; then
        echo "Validation token is ready from swa's custom domain, so it's ready to add the corresponding TXT record."
        break
    fi

    echo "Validation token is not ready, so sleep for 10 seconds and will check it again."
    sleep 10
done

# Add a corresponding TXT record.
echo "Adding TXT record ..."
provision_by_bicep ruhe-playground-0526 add_txt.bicep

# Wait for the previous swa deployment to be done.
echo "Waiting for swa deployment to be done ..."
wait $swa_deployment_id

echo "The swa deployment with custom domain finished with exit code $?."