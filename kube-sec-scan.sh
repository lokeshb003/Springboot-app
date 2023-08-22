#!/bin/bash


kubesec_scan=$(curl -sSX POST --data-binary @"kube-deployment.yaml" https://v2.kubesec.io/scan)
kubesec_scan_message=$(curl -sSX POST --data-binary @"kube-deployment.yaml" https://v2.kubesec.io/scan | jq .[0>kubesec_scan_score=$(curl -sSX POST --data-binary @"kube-deployment.yaml" https://v2.kubesec.io/scan | jq .[0].>

echo $kubesec_scan >> kube-scan-report.json
mkdir kube-sec
mv kube-scan-report.json kube-sec/

if [[ "${kubesec_scan_score}" -ge 5 ]]; then
  echo "Score is $kubesec_scan_score"
  echo "Kubesec Scan Message: $kubesec_scan_message"
else
  echo "Score is $kubesec_scan_score, which is less than or equal to 5"
  echo "Scanning Kubernetes Security has Failed!"
  exit 1;
fi;