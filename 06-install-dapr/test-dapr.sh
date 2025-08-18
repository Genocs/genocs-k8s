#!/bin/bash

echo "Testing Dapr Sample Application..."

# Get the pod name
POD_NAME=$(kubectl get pods -n myapp -l app=sample-app -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
    echo "Error: No sample-app pod found in myapp namespace"
    exit 1
fi

echo "Found pod: $POD_NAME"

# Wait for pod to be ready
echo "Waiting for pod to be ready..."
kubectl wait --for=condition=ready pod/$POD_NAME -n myapp --timeout=120s

if [ $? -ne 0 ]; then
    echo "Error: Pod did not become ready in time"
    kubectl describe pod $POD_NAME -n myapp
    exit 1
fi

echo "Pod is ready!"

# Test the application directly
echo "Testing application endpoints..."

# Test health endpoint
echo "1. Testing /health endpoint:"
kubectl exec -n myapp $POD_NAME -c sample-app -- curl -s http://localhost:3000/health | jq .

# Test root endpoint
echo "2. Testing / endpoint:"
kubectl exec -n myapp $POD_NAME -c sample-app -- curl -s http://localhost:3000/ | jq .

# Test Dapr health endpoint
echo "3. Testing Dapr health endpoint:"
kubectl exec -n myapp $POD_NAME -c sample-app -- curl -s http://localhost:3000/v1.0/healthz | jq .

# Test Dapr state store (if Redis is available)
echo "4. Testing Dapr state store operations:"

# Store a value
echo "   Storing value..."
kubectl exec -n myapp $POD_NAME -c sample-app -- curl -X POST "http://localhost:3500/v1.0/state/statestore" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "key": "test-key",
      "value": "Hello from Dapr!"
    }
  ]'

echo ""

# Retrieve the value
echo "   Retrieving value..."
kubectl exec -n myapp $POD_NAME -c sample-app -- curl -s "http://localhost:3500/v1.0/state/statestore/test-key" | jq .

echo ""
echo "Dapr test completed successfully!"
