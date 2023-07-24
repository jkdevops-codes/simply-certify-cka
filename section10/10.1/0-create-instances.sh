#!/bin/bash

REGION="us-central1"
ZONE="us-central1-c"
PROJECT_ID=$(gcloud config get-value project)
MACHINE_TYPE="e2-medium"
SUBNET="kubeadm-mm-nodes-subnet"
NODE_SUBNET_RANGE="10.20.0.0/24"
VPC_NAME="kubeadm-mm-network"
#IMAGE_OS="projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20221015"
IMAGE_OS="projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20230615"

#Create VPC Network and subnet range for nodes
gcloud compute networks create ${VPC_NAME} --subnet-mode custom
gcloud compute networks subnets create ${SUBNET} --network ${VPC_NAME} --range ${NODE_SUBNET_RANGE} --region  ${REGION} 
#--enable-private-ip-google-access


INSTANCE_NAME="lb"
NETWORK_IP="10.20.0.10"

gcloud  compute --project=${PROJECT_ID} instances create ${INSTANCE_NAME} --zone ${ZONE} \
--machine-type=${MACHINE_TYPE} --subnet=${SUBNET} \
--can-ip-forward \
--tags=${INSTANCE_NAME},master \
--image=${IMAGE_OS} \
--private-network-ip ${NETWORK_IP} \
--boot-disk-size=30GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=${INSTANCE_NAME}  \
--preemptible


INSTANCE_NAME="m-1"
NETWORK_IP="10.20.0.11"

gcloud  compute --project=${PROJECT_ID} instances create ${INSTANCE_NAME} --zone ${ZONE} \
--machine-type=${MACHINE_TYPE} --subnet=${SUBNET} \
--can-ip-forward \
--tags=${INSTANCE_NAME},master \
--image=${IMAGE_OS} \
--private-network-ip ${NETWORK_IP} \
--boot-disk-size=50GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=${INSTANCE_NAME} 



INSTANCE_NAME="m-2"
NETWORK_IP="10.20.0.12"

gcloud  compute --project=${PROJECT_ID} instances create ${INSTANCE_NAME} --zone ${ZONE} \
--machine-type=${MACHINE_TYPE} --subnet=${SUBNET} \
--can-ip-forward \
--tags=${INSTANCE_NAME},worker \
--image=${IMAGE_OS} \
--private-network-ip ${NETWORK_IP} \
--boot-disk-size=50GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=${INSTANCE_NAME}


INSTANCE_NAME="w-1"
NETWORK_IP="10.20.0.13"

gcloud  compute --project=${PROJECT_ID} instances create ${INSTANCE_NAME} --zone ${ZONE} \
--machine-type=${MACHINE_TYPE} --subnet=${SUBNET} \
--can-ip-forward \
--tags=${INSTANCE_NAME},worker \
--image=${IMAGE_OS} \
--private-network-ip ${NETWORK_IP} \
--boot-disk-size=50GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=${INSTANCE_NAME}

INSTANCE_NAME="w-2"
NETWORK_IP="10.20.0.14"

gcloud  compute --project=${PROJECT_ID} instances create ${INSTANCE_NAME} --zone ${ZONE} \
--machine-type=${MACHINE_TYPE} --subnet=${SUBNET} \
--can-ip-forward \
--tags=${INSTANCE_NAME},worker \
--image=${IMAGE_OS} \
--private-network-ip ${NETWORK_IP} \
--boot-disk-size=30GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=${INSTANCE_NAME}  \
--preemptible


#Allow all firewall rules for learning purpose
gcloud compute firewall-rules create kubeadm-mm-allow-all --allow all --network ${VPC_NAME} --source-ranges 0.0.0.0/0

#gcloud compute instances list
#gcloud compute ssh ${INSTANCE_NAME}

