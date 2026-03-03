#!/bin/bash

# Wait for Polaris to be ready
echo "Waiting for Polaris to be ready..."
until curl -s http://polaris:8182/healthcheck > /dev/null; do
    sleep 2
done
echo "Polaris is ready!"

# Get bearer token
echo "Getting bearer token..."
#if ! output=$(curl -X POST -H "Polaris-Realm: default-realm" "http://polaris:8181/api/catalog/v1/oauth/tokens" \
#  -d "grant_type=client_credentials" \
#  -d "client_id=admin" \
#  -d "client_secret=password" \
#  -d "scope=PRINCIPAL_ROLE:ALL"); then
#    echo "Failed to get bearer token"
#    exit 1
#fi

#token=$(echo "$output" | awk -F\" '{print $4}')

token=$(curl -X POST http://polaris:8181/api/catalog/v1/oauth/tokens \
  -d "grant_type=client_credentials" \
  -d "client_id=polaris" \
  -d "client_secret=password" \
  -d "scope=PRINCIPAL_ROLE:ALL" | jq -r .access_token)

if [ -z "${token}" ]; then
  echo "Failed to get bearer token."
  exit 1
fi

PRINCIPAL_TOKEN=$token
echo "Bearer token obtained successfully"
echo $PRINCIPAL_TOKEN
export PRINCIPAL_TOKEN

# Create catalog
echo "Creating Polaris catalog..."
if ! curl -X POST http://polaris:8181/api/management/v1/catalogs \
   -H "Authorization: Bearer $PRINCIPAL_TOKEN" \
   -H 'Content-Type: application/json' \
   -H 'Accept: application/json' \
   -d '{
        "catalog": {
          "name": "polaris",
          "type": "INTERNAL",
          "properties": {
            "s3.path-style-access": "true",
            "s3.access-key-id": "admin",
            "s3.secret-access-key": "password123",
            "default-base-location": "s3://polaris-bucket/warehouse",
            "s3.region": "us-east-1",
            "s3.endpoint": "http://minio:9000"
          },
          "storageConfigInfo": {
            "roleArn": "arn:aws:iam::000000000000:role/polaris-bucket",
            "storageType": "S3",
            "s3.pathStyleAccess": true,
            "allowedLocations": [
              "s3://polaris-bucket/*"
            ]
          }
        }
      }' | jq; then
    echo "Failed to create catalog"
    exit 1
fi
echo "Catalog created successfully"

# Add CATALOG_MANAGE_CONTENT to catalog_admin role
echo "Adding CATALOG_MANAGE_CONTENT privilege to catalog_admin role..."
if ! curl -i -X PUT -H "Authorization: Bearer $PRINCIPAL_TOKEN" -H 'Accept: application/json' -H 'Content-Type: application/json' \
  http://polaris:8181/api/management/v1/catalogs/polaris/catalog-roles/catalog_admin/grants \
  -d '{"type": "catalog", "privilege": "CATALOG_MANAGE_CONTENT"}'; then
    echo "Failed to add CATALOG_MANAGE_CONTENT privilege"
    exit 1
fi
echo "CATALOG_MANAGE_CONTENT privilege added successfully"
echo "Polaris catalog setup completed successfully!" 