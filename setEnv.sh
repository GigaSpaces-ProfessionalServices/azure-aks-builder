#!/bin/bash
RESOURCE_GROUP=csm-bbw
TAG_GSPOLICY=noprod
LOCATION=eastus
AKS_NODE_COUNT=3
AKS_VM_SIZE="Standard_B16ms"

DIH_HELM_REPO="https://s3.amazonaws.com/resources.gigaspaces.com/helm-charts-dih"
DIH_HELM_CHART="16.4.0"
DIH_HELM_CONF_FILE="DIH/helm/dih-umbrella.yaml"

JUMPER_IMAGE=RedHat:rhel_test_offers:rhel8_7-gen2:8.7.20221109
#"Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
JUMPER_USERDATA="AKS/userdata-install_jumper_tools.sh"
JUMPER_ADMIN_USER="azureuser"
JUMPER_PUBLIC_KEY="AKS/AA-jumper-demo.pub"
JUMPER_SIZE="Standard_B8ms"

# ARM_CLIENT_ID=
# ARM_CLIENT_SECRET=
# ARM_SUBSCRIPTION_ID=
# ARM_TENANT_ID=
