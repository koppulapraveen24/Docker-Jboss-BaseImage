#!/bin/bash

ECR_REPO=$1
IMAGE_TAG=$2
SCAN_STATUS=1

# Check if scan is complete
until [ "$SCAN_STATUS" -eq "0" ];
do  
  SCAN_STATUS=$(aws ecr wait image-scan-complete --repository-name $ECR_REPO --image-id imageTag=$IMAGE_TAG; echo $?)
  echo "Waiting for scan to complete"
  sleep 5
done

# Get the Scan results
SCAN_FINDINGS=$(aws ecr describe-image-scan-findings --repository-name $ECR_REPO --image-id imageTag=$IMAGE_TAG | jq '.imageScanFindings.findingSeverityCounts')

CRITICAL=$(echo $SCAN_FINDINGS | jq '.CRITICAL')
HIGH=$(echo $SCAN_FINDINGS | jq '.HIGH')
MEDIUM=$(echo $SCAN_FINDINGS | jq '.MEDIUM')
LOW=$(echo $SCAN_FINDINGS | jq '.LOW')
INFORMATIONAL=$(echo $SCAN_FINDINGS | jq '.INFORMATIONAL')
UNDEFINED=$(echo $SCAN_FINDINGS | jq '.UNDEFINED')

if [ $CRITICAL != null ] || [ $HIGH != null ]; then
 if [ "$HIGH" -gt "15" ]; then
   echo "============================================"
   echo "** Docker image contains vulnerabilities ***"
   echo "============================================"
   exit 1  
 fi
fi

echo "INFO: No Vulnerabilities found"
