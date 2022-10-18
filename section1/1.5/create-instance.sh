#!/bin/bash

ZONE="us-central1-a"
PROJECT_ID=$(gcloud config get-value project)
MACHINE_TYPE="e2-small"
INSTANCE_NAME="my-ubuntu-vm"
SUBNET="default"

gcloud  compute --project=${PROJECT_ID} instances create ${INSTANCE_NAME} --zone ${ZONE} \
--machine-type=${MACHINE_TYPE} --subnet=${SUBNET} \
--network-tier=PREMIUM \
--tags=${INSTANCE_NAME} \
--image=ubuntu-1804-bionic-v20211115 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=${INSTANCE_NAME}  \
--preemptible


#gcloud compute instances list
#gcloud compute ssh ${INSTANCE_NAME}
