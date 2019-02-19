#!/usr/bin/env bash
oc new-project tasks-build
oc new-app jboss-eap71-openshift:1.3~https://github.com/wkulhanek/openshift-tasks --name tasks
oc set triggers dc tasks --remove-all
oc expose svc tasks

oc new-project tasks-dev
oc new-app tasks-build/tasks:dev --name=tasks --allow-missing-images -n tasks-dev
oc set triggers dc tasks --remove-all
oc expose dc/tasks --port 8080 -n tasks-dev
oc expose svc tasks

oc new-project tasks-test
oc new-app tasks-build/tasks:test --name=tasks --allow-missing-images -n tasks-test
oc set triggers dc tasks --remove-all
oc expose dc/tasks --port 8080 -n tasks-test
oc expose svc tasks

oc new-project tasks-prod
oc new-app tasks-build/tasks:prod --name=tasks --allow-missing-images -n tasks-prod
oc set triggers dc tasks --remove-all
oc expose dc/tasks --port 8080 -n tasks-prod
oc expose svc tasks

oc new-project cicd-dev 
oc new-app jenkins-persistent --param ENABLE_OAUTH=true --param MEMORY_LIMIT=2Gi --param VOLUME_CAPACITY=4Gi --param DISABLE_ADMINISTRATIVE_MONITORS=true
oc policy add-role-to-user edit system:serviceaccount:cicd-dev:jenkins -n tasks-build
oc policy add-role-to-user edit system:serviceaccount:cicd-dev:jenkins -n tasks-dev
oc policy add-role-to-user edit system:serviceaccount:cicd-dev:jenkins -n tasks-test
oc policy add-role-to-user edit system:serviceaccount:cicd-dev:jenkins -n tasks-prod
oc policy add-role-to-group system:image-puller system:serviceaccounts:tasks-dev -n tasks-build
oc policy add-role-to-group system:image-puller system:serviceaccounts:tasks-test -n tasks-build
oc policy add-role-to-group system:image-puller system:serviceaccounts:tasks-prod -n tasks-build
oc create -f jenkins_template.yml
echo "Start the build"
oc start-build tasks-pipeline

echo '{
    "kind": "LimitRange",
    "apiVersion": "v1",
    "metadata": {
        "name": "tasks-hpa",
        "creationTimestamp": null
    },
    "spec": {
        "limits": [
            {
                "type": "Pod",
                "max": {
                    "cpu": "1",
                    "memory": "1Gi"
                },
                "min": {
                    "cpu": "200m",
                    "memory": "6Mi"
                }
            },
            {
                "type": "Container",
                "max": {
                    "cpu": "1",
                    "memory": "1Gi"
                },
                "min": {
                    "cpu": "100m",
                    "memory": "4Mi"
                },
                "default": {
                    "cpu": "300m",
                    "memory": "200Mi"
                },
                "defaultRequest": {
                    "cpu": "200m",
                    "memory": "100Mi"
                },
                "maxLimitRequestRatio": {
                    "cpu": "10"
                }

            }
        ]
    }
}' | oc create -f - -n tasks-prod
oc autoscale dc/tasks --min 1 --max 5 --cpu-percent=80 -n tasks-prod
