#!/usr/bin/env bash
oc new-project smoke-test
oc new-app nodejs-mongo-persistent
echo "Waiting for 40 seconds for the pod to build and start before testing"
sleep 40
oc get route
echo "verify the exposed route with CURL"
curl -s -S -X GET http://$(oc get route -n smoke-test -o jsonpath='{.items[*].spec.host}') | grep "Welcome to your Node.js"
oc delete project smoke-test