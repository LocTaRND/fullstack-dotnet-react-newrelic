#!/bin/bash

ACTION=${1:-apply}

if [[ "$ACTION" == "apply" ]]; then
    # Create namespace 'application' if it does not exist
    if ! kubectl get namespace application &> /dev/null; then
        echo "Creating namespace 'application'..."
        kubectl create namespace application
    else
        echo "Namespace 'application' already exists."
    fi

    jq '.' appsettings.test.json > appsettings.json
    export appSettingsBase64=$(cat "appsettings.json" | base64 -w 0)
    envsubst < secret.yaml > manifest/secret-backend.yaml

    kubectl apply -f manifest/secret-backend.yaml -n application
    kubectl apply -f manifest/newrelic-license-secret.yaml -n application
    kubectl apply -f manifest/newrelic-config.yaml -n application
    kubectl apply -f manifest/k8s-deployment-api.yaml -n application
    kubectl apply -f manifest/k8s-deployment-node.yaml -n application
    kubectl apply -f manifest/instrumentation-dotnet.yaml -n newrelic
    # Clean up
    rm appsettings.json
    rm manifest/secret-backend.yaml

    # Check if the secret was created successfully
    if kubectl get secret appsettings-backend -n application &> /dev/null; then
        echo "Secret created successfully."
    else
        echo "Failed to create secret."
        exit 1
    fi

    # Wait for backend-api pod to be running
    echo "Waiting for backend-api pod to be running..."
    kubectl wait --for=condition=Ready pod -l app=backend-api -n application --timeout=120s

    if [ $? -eq 0 ]; then
        echo "backend-api pod is running."
    else
        echo "backend-api pod failed to reach running state."
        kubectl get pods -n application
        exit 1
    fi

    # Wait for frontend (node) pod to be running
    echo "Waiting for frontend pod to be running..."
    kubectl wait --for=condition=Ready pod -l app=frontend -n application --timeout=120s

    if [ $? -eq 0 ]; then
        echo "frontend pod is running."
    else
        echo "frontend pod failed to reach running state."
        kubectl get pods -n application
        exit 1
    fi

elif [[ "$ACTION" == "delete" ]]; then
    echo "Deleting resources..."
    kubectl delete -f manifest/k8s-deployment-api.yaml -n application
    kubectl delete -f manifest/k8s-deployment-node.yaml -n application
    kubectl delete -f manifest/newrelic-config.yaml -n application
    kubectl delete -f manifest/newrelic-license-secret.yaml -n application
    kubectl delete -f manifest/secret-backend.yaml -n application --ignore-not-found
    kubectl delete -f manifest/instrumentation-dotnet.yaml -n newrelic
    # Optionally delete namespace (uncomment if desired)
    kubectl delete namespace application
else
    echo "Usage: $0 [apply|delete]"
    exit 1
fi

