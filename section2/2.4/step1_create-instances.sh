#!/bin/bash


REGION="us-central1"
ZONE="us-central1-a"
PROJECT_ID=$(gcloud config get-value project)
MACHINE_TYPE="e2-small"
SUBNET="default"

#Create VPC Network and subnet range for nodes
gcloud compute networks create kubeadm-network --subnet-mode custom
gcloud compute networks subnets create kubeadm-nodes --network kubeadm-network --range 10.240.0.0/24 --region  ${REGION}


INSTANCE_NAME="master-1"

gcloud beta compute --project=${PROJECT_ID} instances create ${INSTANCE_NAME} --zone ${ZONE} \
--async
--machine-type=${MACHINE_TYPE} --subnet=${SUBNET} \
--network-tier=PREMIUM \
--can-ip-forward \
--tags=${INSTANCE_NAME} \
--image=ubuntu-1804-bionic-v20211115 \
--image-project=ubuntu-os-cloud \
--private-network-ip 10.240.0.200 \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=${INSTANCE_NAME}  \
--preemptible \
--subnet kubeadm-nodes

INSTANCE_NAME="worker"

for i in 205 206 ; do
gcloud beta compute --project=${PROJECT_ID} instances create ${INSTANCE_NAME} --zone ${ZONE} \
--machine-type=${MACHINE_TYPE} --subnet=${SUBNET} \
--network-tier=PREMIUM \
--tags=${INSTANCE_NAME}${i} \
--image=ubuntu-1804-bionic-v20211115 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=${INSTANCE_NAME}  \
--preemptible
done

INSTANCE_NAME="worker-2"
gcloud beta compute --project=${PROJECT_ID} instances create ${INSTANCE_NAME} --zone ${ZONE} \
--machine-type=${MACHINE_TYPE} --subnet=${SUBNET} \
--network-tier=PREMIUM \
--tags=${INSTANCE_NAME} \
--image=ubuntu-1804-bionic-v20211115 \
--image-project=ubuntu-os-cloud \
--boot-disk-size=10GB \
--boot-disk-type=pd-standard \
--boot-disk-device-name=${INSTANCE_NAME}  \
--preemptible


gcloud compute firewall-rules create kubeadm-allow-nodeprts --allow tcp:22,tcp:6443,icmp --network kubeadm-network --source-ranges 0.0.0.0/0

#gcloud compute instances list
#gcloud compute ssh ${INSTANCE_NAME}
