#!/bin/bash
KC=/root/labs/rbac/deployer.kubeconfig
[ -s "$KC" ] || { echo "deployer.kubeconfig not found in /root/labs/rbac"; exit 1; }
who=$(kubectl --kubeconfig "$KC" auth whoami -o json 2>/dev/null | jq -r '.status.userInfo.username')
[ "$who" = "system:serviceaccount:rbac-lab:deployer" ] || { echo "the kubeconfig authenticates as '$who', not the deployer service account"; exit 1; }
tok=$(kubectl --kubeconfig "$KC" config view --raw -o jsonpath='{.users[?(@.name=="deployer")].user.token}')
[ -n "$tok" ] || { echo "the kubeconfig has no token for user deployer"; exit 1; }
claims=$(echo "$tok" | cut -d. -f2 | tr '_-' '/+' | awk '{ l=length($0)%4; if(l==2) print $0"=="; else if(l==3) print $0"="; else print $0 }' | base64 -d 2>/dev/null)
life=$(echo "$claims" | jq -r '.exp - .iat' 2>/dev/null)
[ -n "$life" ] && [ "$life" -le 3600 ] || { echo "the token should be short-lived (at most 1 hour), lifetime=$life"; exit 1; }
echo "ok: the kubeconfig authenticates as the deployer with a ${life}s token"
