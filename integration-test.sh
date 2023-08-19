#!/bin/bash


sleep 5s

PORT=$(kubectl -n default get svc ${serviceName} -o json | jq.spec.ports[].port)
echo $PORT
echo $applicationURL:$PORT/$applicationURI

if [[ ! -z $PORT]];
then
  response=$(curl -s $applicationURL:$PORT/$applicationURI)
  http_code=$(curl -s -o /dev/null -w "%{http_code}" $applicationURL:$PORT/$applicationURI)
  if [[ "$response" == 100 ]];
  then
    echo "Increment Test Success"
  else
    echo "Increment Test Failed"
  fi;

  if [[ "$http_code" == 200 ]];
  then
    echo "HTTP Status Code Test Passed"
  else
    echo "HTTP Status Code Test Failed"
  fi;
else

  echo "The Service does not have a nodePort"
  exit 1;
fi;
