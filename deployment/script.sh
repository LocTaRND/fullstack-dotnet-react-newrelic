#!/bin/bash

jq '.' appsettings.test.json > appsettings.json
export appSettingsBase64=$(cat "appsettings.json" | base64 -w 0)
envsubst < secret.yaml > secret-backend.yaml

kubectl apply -f secret-backend.yaml -n application
kubectl apply -f newrelic-config.yaml -n application
kubectl apply -f k8s-deployment-api.yaml -n application
kubectl apply -f k8s-deployment-node.yaml -n application
# Clean up
rm appsettings.json
rm secret-backend.yaml

# Check if the secret was created successfully
if kubectl get secret appsettings-backend -n application &> /dev/null; then
    echo "Secret created successfully."
else
    echo "Failed to create secret."
    exit 1
fi

# # Check if the secret contains the expected data
# if kubectl get secret backend-secret -o jsonpath='{.data.appSettingsBase64}' | grep -q "$(echo -n "$appSettingsBase64" | base64)"; then
#     echo "Secret contains the expected data."
# else
#     echo "Secret does not contain the expected data."
#     exit 1
# fi
# # Check if the secret is mounted correctly in the pod
# if kubectl exec -it $(kubectl get pods -l app=backend -o jsonpath='{.items[0].metadata.name}') -- cat /appsettings.json | grep -q "$(echo -n "$appSettingsBase64" | base64 --decode)"; then
#     echo "Secret is mounted correctly in the pod."
# else
#     echo "Secret is not mounted correctly in the pod."
#     exit 1
# fi
# # Check if the pod is running
# if kubectl get pods -l app=backend -o jsonpath='{.items[0].status.phase}' | grep -q "Running"; then
#     echo "Pod is running."
# else
#     echo "Pod is not running."
#     exit 1
# fi
# # Check if the service is running
# if kubectl get svc -l app=backend -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}' &> /dev/null; then
#     echo "Service is running."
# else
#     echo "Service is not running."
#     exit 1
# fi
# # Check if the deployment is running
# if kubectl get deployments -l app=backend -o jsonpath='{.items[0].status.availableReplicas}' | grep -q "1"; then
#     echo "Deployment is running."
# else
#     echo "Deployment is not running."
#     exit 1
# fi