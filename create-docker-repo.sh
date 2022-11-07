#!/bin/bash

if [ $# -ne 1 ] ; then
  echo "Usage: $0 <app-name>"
  echo "       The app name will be the name of the repository, and is usually also the name"
  echo "       of the GitHub repository (e.g. foobar, my-thing)."
  exit 1
fi
app=$1

if [[ ! ("$app" =~ ^[a-z][a-z0-1\-]*$ ) ]] ; then
  echo "The app name should be lowercase with '-' separators"
  exit 1
fi

set -e

# Create a new Artifact Registry repository for our Docker images
gcloud artifacts repositories create $app \
    --repository-format=docker \
    --location=us-west1 \
    --description="Docker images for $app" \
    --project=kcs-ace2

# Create a new service account Travis will use to push Docker images
gcloud iam service-accounts create travis-$app \
    --display-name="Service account for Travis to push Docker images for $app" \
    --project=kcs-ace2

# Grant the Travis service account permission to push to the repository
gcloud artifacts repositories add-iam-policy-binding $app \
    --location=us-west1 \
    --member="serviceAccount:travis-$app@kcs-ace2.iam.gserviceaccount.com" \
    --role=roles/artifactregistry.writer \
    --project=kcs-ace2

# Create the Travis service account key and base64 encode it
gcloud iam service-accounts keys create ./local.tmp-key.json \
    --iam-account=travis-$app@kcs-ace2.iam.gserviceaccount.com
echo "Place the following service account key in Travis (this will never display again):"
echo "ARTIFACT_REGISTRY_KEY=$(base64 -i ./local.tmp-key.json)"
rm ./local.tmp-key.json