#!/usr/bin/env bash
oc delete project cicd-dev
oc delete project tasks-build
oc delete project tasks-dev
oc delete project tasks-test
oc delete project tasks-prod
