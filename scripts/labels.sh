#!/usr/bin/env bash
echo "Set the current GUID "
GUID=`hostname|awk -F. '{print $2}'`
oc label node node1.$GUID.internal alpha=true
oc label node node2.$GUID.internal beta=true
oc label node node3.$GUID.internal common=true

oc label user/amy client=alpha
oc label user/andrew client=alpha
oc label user/betty client=beta
oc label user/brian client=beta

oc patch clusterrolebinding.rbac self-provisioners -p '{"subjects": null}'
oc adm new-project alpha --node-selector='alpha=true'
oc adm new-project beta --node-selector='beta=true'
oc adm new-project common --node-selector='common=true'
oc adm policy add-role-to-user admin amy -n alpha
oc adm policy add-role-to-user admin andrew -n alpha
oc adm policy add-role-to-user admin betty -n alpha
oc adm policy add-role-to-user admin brian -n alpha

echo '{
    "kind": "LimitRange",
    "apiVersion": "v1",
    "metadata": {
        "name": "alpha-limit",
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
}' | oc create -f - -n alpha

echo '{
    "kind": "LimitRange",
    "apiVersion": "v1",
    "metadata": {
        "name": "beta-limit",
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
}' | oc create -f - -n beta
