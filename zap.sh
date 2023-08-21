#!/bin/bash

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].port)


chmod 777 $(pwd)

echo $(id -u):$(id -g)

docker run --rm -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t http://$applicationURL:$PORT/v3/api-docs -f openapi -r zap_report_scan.html


exit_code=$?

mkdir -p owasp-zap-report
mv zap_report_scan.html owasp-zap-report

echo "Exit Code : $exit_code"

 if [[ ${exit_code} -ne 0 ]];  then
    echo "OWASP ZAP Report has either Low/Medium/High Risk. Please check the HTML Report"
    exit 1;
   else
    echo "OWASP ZAP did not report any Risk"
 fi;